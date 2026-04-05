from flask import Blueprint, request, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/api/auth/login', methods=['POST'])
@require_auth
def login():
    """
    POST /api/auth/login
    Flutter ส่ง Firebase ID Token มา → verify → sync user ลง MySQL
    ถ้ายังไม่มี user → สร้างใหม่อัตโนมัติ (Google Login)
    """
    data = request.get_json() or {}
    name = data.get('name', '')
    auth_provider = data.get('auth_provider', 'google')

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

        return jsonify({
            'user_id':       user['user_id'],
            'first_name':    user['first_name'],
            'last_name':     user['last_name'],
            'email':         user['email'],
            'auth_provider': user['auth_provider'],
        }), 200

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
    first_name = data.get('first_name', '')
    last_name  = data.get('last_name', '')
    phone      = data.get('phone', '')
    birth_date = data.get('birth_date', None)

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

            # INSERT user ใหม่
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

        return jsonify({
            'user_id':    user_id,
            'first_name': first_name,
            'last_name':  last_name,
            'email':      g.email,
        }), 201

    finally:
        conn.close()