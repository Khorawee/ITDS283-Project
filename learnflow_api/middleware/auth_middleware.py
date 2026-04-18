"""Firebase authentication middleware — verify ID tokens on protected endpoints.

Features:
- Extracts Firebase ID Token from Authorization header
- Verifies token with Firebase Admin SDK
- Sets g.firebase_uid and g.email for use in endpoints
- Handles token expiry and invalid token errors
- Generic error messages (no internal details leaked)

Usage:
    @app.route('/api/protected')
    @require_auth
    def protected_endpoint():
        user_id = g.firebase_uid
        email = g.email
"""

from functools import wraps
from flask import request, jsonify, g
from firebase_admin import auth
import logging

logger = logging.getLogger(__name__)


def require_auth(f):
    """Decorator — verify Firebase ID Token จาก Authorization header
    
    Set: g.firebase_uid, g.email สำหรับใช้ใน endpoint
    Return 401 ถ้า token ไม่ valid หรือ expired
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        # ดึง token จาก Header
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Missing or invalid token'}), 401

        token = auth_header.split('Bearer ')[1]

        try:
            # Verify token กับ Firebase
            decoded = auth.verify_id_token(token)
            g.firebase_uid = decoded['uid']       # UID จาก Firebase
            g.email = decoded.get('email', '')     # Email ของ user
        except auth.ExpiredIdTokenError:
            return jsonify({'error': 'Token expired'}), 401
        except auth.InvalidIdTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        except Exception as e:
            # FIX: Don't expose internal error details
            logger.error('Token verification failed: %s', str(e))
            return jsonify({'error': 'Authentication failed'}), 401

        return f(*args, **kwargs)
    return decorated