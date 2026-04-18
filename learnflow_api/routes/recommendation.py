from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

recommendation_bp = Blueprint('recommendation', __name__)


@recommendation_bp.route('/api/recommendations', methods=['GET'])
@require_auth
def get_recommendations():
    """
    GET /api/recommendations
    ดึงคำแนะนำการเรียนรายวิชา - หยิบ quizzes แบบสุ่มๆ มาแสดง (curated selection):
    - ดึง quizzes ทั้งหมด แบบสุ่ม ~5 อัน เร็วที่สุด
    Flutter ใช้แสดงใน HomePage (RECOMMENDED FOR YOU)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # ดึง quizzes ทั้งหมด แบบสุ่ม - เร็วที่สุด (ไม่ต้องเช็ค user history)
            cur.execute('''
                SELECT q.quiz_id as rec_id, q.title as topic, NULL as action,
                       NULL as mastery, NULL as mastery_by_difficulty,
                       s.subject_name, NOW() as created_at
                FROM quizzes q
                JOIN subjects s ON q.subject_id = s.subject_id
                ORDER BY RAND()
                LIMIT 5
            ''')
            recommendations = cur.fetchall()

        return jsonify({'recommendations': recommendations}), 200


    finally:
        conn.close()