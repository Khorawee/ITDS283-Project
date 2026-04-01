from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

recommendation_bp = Blueprint('recommendation', __name__)


@recommendation_bp.route('/api/recommendations', methods=['GET'])
@require_auth
def get_recommendations():
    """
    GET /api/recommendations
    ดึงคำแนะนำการเรียนรายวิชา เรียงจาก mastery ต่ำสุดก่อน
    Flutter ใช้แสดงใน HomePage (RECOMMENDED FOR YOU)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT user_id FROM users WHERE firebase_uid = %s',
                (g.firebase_uid,)
            )
            user = cur.fetchone()
            if not user:
                return jsonify({'error': 'User not found'}), 404

            # ดึงคำแนะนำเรียงจาก mastery ต่ำสุด (Weak ก่อน)
            cur.execute('''
                SELECT r.rec_id, r.topic, r.action, r.mastery,
                       s.subject_name, r.created_at
                FROM recommendations r
                JOIN subjects s ON r.subject_id = s.subject_id
                WHERE r.user_id = %s
                ORDER BY r.mastery ASC
                LIMIT 5
            ''', (user['user_id'],))
            recommendations = cur.fetchall()

        return jsonify({'recommendations': recommendations}), 200

    finally:
        conn.close()