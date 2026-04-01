from functools import wraps
from flask import request, jsonify, g
from firebase_admin import auth


def require_auth(f):
    """
    Decorator สำหรับ verify Firebase ID Token
    ใช้ใส่หน้า endpoint ที่ต้องการให้ user login ก่อน

    ตัวอย่างใช้งาน:
        @app.route('/api/profile')
        @require_auth
        def get_profile():
            user_id = g.user_id  # ดึง user_id ที่ verify แล้ว
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
            return jsonify({'error': str(e)}), 401

        return f(*args, **kwargs)
    return decorated