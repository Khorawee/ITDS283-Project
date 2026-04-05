from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

analysis_bp = Blueprint('analysis', __name__)


@analysis_bp.route('/api/analysis', methods=['GET'])
@require_auth
def get_analysis():
    """
    GET /api/analysis
    ดึงผลวิเคราะห์ Topic Mastery รายวิชา
    Flutter ใช้แสดง Bar Chart ใน AnalyticsPage
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

            cur.execute('''
                SELECT ta.subject_id, s.subject_name,
                       ta.accuracy, ta.speed, ta.understanding,
                       ta.mastery, ta.level, ta.updated_at
                FROM topic_analysis ta
                JOIN subjects s ON ta.subject_id = s.subject_id
                WHERE ta.user_id = %s
                ORDER BY ta.mastery ASC
            ''', (user['user_id'],))
            topics = cur.fetchall()

        return jsonify({'topics': topics}), 200

    finally:
        conn.close()


@analysis_bp.route('/api/dashboard', methods=['GET'])
@require_auth
def get_dashboard():
    """
    GET /api/dashboard
    ดึงข้อมูลสำหรับสร้างกราฟทั้ง 3 ใน AnalyticsPage
    - Bar Chart  : Topic Mastery รายวิชา
    - Line Chart : Understanding รายวัน 7 วัน
    - Radar Chart: Accuracy / Speed / Mastery รวม
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

            user_id = user['user_id']

            # ── Bar Chart: Topic Mastery รายวิชา ──
            cur.execute('''
                SELECT s.subject_name, ta.mastery, ta.level
                FROM topic_analysis ta
                JOIN subjects s ON ta.subject_id = s.subject_id
                WHERE ta.user_id = %s
                ORDER BY ta.mastery DESC
            ''', (user_id,))
            bar_data = cur.fetchall()

            # ── Line Chart: Understanding รายวัน 7 วัน ──
            cur.execute('''
                SELECT date, avg_understanding
                FROM progress
                WHERE user_id = %s
                AND date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
                ORDER BY date ASC
            ''', (user_id,))
            line_data = cur.fetchall()

            # ── Radar Chart: Accuracy / Speed / Mastery รวม ──
            cur.execute('''
                SELECT AVG(accuracy) as avg_accuracy,
                       AVG(speed)    as avg_speed,
                       AVG(mastery)  as avg_mastery
                FROM topic_analysis
                WHERE user_id = %s
            ''', (user_id,))
            radar_raw = cur.fetchone()
            radar_data = {
                'accuracy': round(radar_raw['avg_accuracy'] or 0, 3),
                'speed':    round(radar_raw['avg_speed']    or 0, 3),
                'mastery':  round(radar_raw['avg_mastery']  or 0, 3),
            }

        return jsonify({
            'bar_chart':   bar_data,
            'line_chart':  line_data,
            'radar_chart': radar_data,
        }), 200

    finally:
        conn.close()