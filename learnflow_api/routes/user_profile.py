"""User profile endpoint — retrieve user data and quiz statistics.

Endpoints:
- GET /api/profile — Get user profile + avg score + grade

Features:
- Floating-point precision for score calculations (DECIMAL type)
- Grade calculation (A/B/C based on percentage)
- Null-safe value extraction
- Total quizzes count and average score
"""

from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth
import logging

logger = logging.getLogger(__name__)

profile_bp = Blueprint('profile', __name__)


@profile_bp.route('/api/profile', methods=['GET'])
@require_auth
def get_profile():
    """GET /api/profile — ดึงข้อมูล user + avg score + grade
    
    Return: user profile data + total_quizzes, avg_score (0-100), grade (A/B/C)
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

            # Average score รวม — FIX: Use CAST to avoid integer division precision loss
            cur.execute('''
                SELECT AVG(CAST(score AS DECIMAL(5,2)) / CAST(total AS DECIMAL(5,2))) as avg_score
                FROM quiz_attempts
                WHERE user_id = %s AND total > 0
            ''', (user_id,))
            avg_raw   = cur.fetchone()
            avg_score = round((float(avg_raw['avg_score'] or 0)) * 100, 1)

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

    except Exception as e:
        logger.error('Profile fetch error: %s', str(e))
        return jsonify({'error': 'Failed to fetch profile'}), 500
    finally:
        conn.close()