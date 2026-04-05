from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

profile_bp = Blueprint('profile', __name__)


@profile_bp.route('/api/profile', methods=['GET'])
@require_auth
def get_profile():
    """
    GET /api/profile
    ดึงข้อมูล user + สถิติการทำ Quiz
    Flutter ใช้แสดงหน้า ProfilePage
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # ดึงข้อมูล user
            cur.execute(
                'SELECT * FROM users WHERE firebase_uid = %s',
                (g.firebase_uid,)
            )
            user = cur.fetchone()
            if not user:
                return jsonify({'error': 'User not found'}), 404

            user_id = user['user_id']

            # จำนวน Quiz ที่ทำทั้งหมด
            cur.execute(
                'SELECT COUNT(*) as total_quizzes FROM quiz_attempts WHERE user_id = %s',
                (user_id,)
            )
            quiz_count = cur.fetchone()['total_quizzes']

            # Average score รวม
            cur.execute('''
                SELECT AVG(score / total) as avg_score
                FROM quiz_attempts
                WHERE user_id = %s AND total > 0
            ''', (user_id,))
            avg_raw   = cur.fetchone()
            avg_score = round((avg_raw['avg_score'] or 0) * 100, 1)

            # Grade ล่าสุด
            if avg_score >= 80:
                grade = 'A'
            elif avg_score >= 60:
                grade = 'B'
            else:
                grade = 'C'

        return jsonify({
            'user_id':       user['user_id'],
            'first_name':    user['first_name'],
            'last_name':     user['last_name'],
            'email':         user['email'],
            'phone':         user.get('phone', ''),
            'birth_date':    str(user.get('birth_date', '')),
            'auth_provider': user['auth_provider'],
            'total_quizzes': quiz_count,
            'avg_score':     avg_score,
            'grade':         grade,
        }), 200

    finally:
        conn.close()