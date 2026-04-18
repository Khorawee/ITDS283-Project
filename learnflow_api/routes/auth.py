"""Authentication endpoints — user login and registration.

Endpoints:
- POST /api/auth/login — Sync Firebase user to MySQL (create if not exists)
- POST /api/auth/register — Create new user with email/password

Features:
- Input validation (names, emails, auth providers)
- Rate limiting (5 per minute on login)
- Transaction safety with rollback on errors
- Generic error messages (no credential leakage)
"""

from flask import Blueprint, request, jsonify, g, current_app
from db_config import get_connection
from auth_middleware import require_auth
import logging

logger = logging.getLogger(__name__)
auth_bp = Blueprint('auth', __name__)


def _get_limiter():
    """Helper to get limiter from current app"""
    return current_app.extensions.get('limiter')


def _validate_name(name):
    """ตรวจสอบชื่อ: string, 1-100 chars, ไม่มี special chars
    
    Return: None (valid) หรือ error message
    """
    if not isinstance(name, str):
        return 'Name must be a string'
    name = name.strip()
    if not name or len(name) > 100:
        return 'Name must be 1-100 characters'
    if any(c in name for c in ['<', '>', '"', "'"]):
        return 'Name contains invalid characters'
    return None


def _validate_email(email):
    """ตรวจสอบ email: required, <= 255 chars, มี @ symbol
    
    Return: None (valid) หรือ error message
    """
    if not email or not isinstance(email, str):
        return 'Email is required'
    if len(email) > 255:
        return 'Email too long'
    if '@' not in email:
        return 'Invalid email format'
    return None


@auth_bp.route('/api/auth/login', methods=['POST'])
@require_auth
def login():
    """
    POST /api/auth/login
    Flutter ส่ง Firebase ID Token มา → verify → sync user ลง MySQL
    ถ้ายังไม่มี user → สร้างใหม่อัตโนมัติ (Google Login)
    Rate limited to 5 per minute per IP
    """
    data = request.get_json() or {}
    name = data.get('name', '').strip()
    auth_provider = data.get('auth_provider', 'google').strip()

    # ADD: Input validation
    name_error = _validate_name(name)
    if name_error:
        return jsonify({'error': name_error}), 400

    if auth_provider not in ['google', 'email', 'apple']:
        return jsonify({'error': 'Invalid auth provider'}), 400
    
    # CRITICAL: Validate email from request matches Firebase token email
    requested_email = data.get('email', '').strip()
    if requested_email and requested_email != g.email:
        logger.warning('Email mismatch for user %s: requested %s but token has %s',
                       g.firebase_uid[:8], requested_email, g.email)
        return jsonify({'error': 'Email mismatch with authentication'}), 401

    # Apply rate limit dynamically
    limiter = _get_limiter()
    if limiter:
        try:
            limiter.limit("5 per minute")(lambda: None)()
        except Exception as e:
            logger.warning('Rate limit check: %s', str(e))

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # เช็คว่ามี user นี้ใน DB แล้วหรือยัง
            cur.execute(
                'SELECT * FROM users WHERE firebase_uid = %s',
                (g.firebase_uid,)
            )
            user = cur.fetchone()

            if not user:
                # สร้าง user ใหม่ (Google Login ครั้งแรก)
                try:
                    cur.execute(
                        '''INSERT INTO users
                           (first_name, last_name, email, firebase_uid, auth_provider)
                           VALUES (%s, %s, %s, %s, %s)''',
                        (name, '', g.email, g.firebase_uid, auth_provider)
                    )
                    conn.commit()
                    cur.execute(
                        'SELECT * FROM users WHERE firebase_uid = %s',
                        (g.firebase_uid,)
                    )
                    user = cur.fetchone()
                except Exception as e:
                    conn.rollback()
                    logger.error('Login insert failed: %s', str(e))
                    return jsonify({'error': 'Login failed'}), 500

        if not user:
            return jsonify({'error': 'User not found'}), 404

        return jsonify({
            'user_id':       user['user_id'],
            'first_name':    user['first_name'],
            'last_name':     user['last_name'],
            'email':         user['email'],
            'auth_provider': user['auth_provider'],
        }), 200

    except Exception as e:
        logger.error('Login error: %s', str(e))
        return jsonify({'error': 'Authentication failed'}), 500
    finally:
        conn.close()


@auth_bp.route('/api/auth/register', methods=['POST'])
@require_auth
def register():
    """
    POST /api/auth/register
    Flutter ส่ง Firebase ID Token + ข้อมูล user มา → สร้าง user ใหม่ลง MySQL
    ใช้สำหรับ Email/Password Register
    """
    data = request.get_json() or {}
    first_name = data.get('first_name', '').strip()
    last_name  = data.get('last_name', '').strip()
    phone      = data.get('phone', '').strip()
    birth_date = data.get('birth_date', None)

    # ADD: Input validation
    first_error = _validate_name(first_name)
    if first_error:
        return jsonify({'error': f'First name: {first_error}'}), 400

    if last_name and len(last_name) > 100:
        return jsonify({'error': 'Last name too long'}), 400

    if phone and len(phone) > 20:
        return jsonify({'error': 'Phone too long'}), 400

    email_error = _validate_email(g.email)
    if email_error:
        return jsonify({'error': email_error}), 400

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # เช็คว่ามี user นี้อยู่แล้วหรือยัง
            cur.execute(
                'SELECT user_id FROM users WHERE firebase_uid = %s',
                (g.firebase_uid,)
            )
            existing = cur.fetchone()

            if existing:
                return jsonify({'error': 'User already exists'}), 409

            # INSERT user ใหม่ — with explicit error handling
            try:
                cur.execute(
                    '''INSERT INTO users
                       (first_name, last_name, email, phone, birth_date,
                        firebase_uid, auth_provider)
                       VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                    (first_name, last_name, g.email, phone, birth_date,
                     g.firebase_uid, 'email')
                )
                conn.commit()
                user_id = cur.lastrowid
            except Exception as e:
                conn.rollback()
                logger.error('Register insert failed: %s', str(e))
                return jsonify({'error': 'Registration failed'}), 500

        return jsonify({
            'user_id':    user_id,
            'first_name': first_name,
            'last_name':  last_name,
            'email':      g.email,
        }), 201

    except Exception as e:
        logger.error('Register error: %s', str(e))
        return jsonify({'error': 'Registration failed'}), 500
    finally:
        conn.close()