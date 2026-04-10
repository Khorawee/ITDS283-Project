from flask import Blueprint, jsonify, g, request
from db_config import get_connection
from auth_middleware import require_auth

analysis_bp = Blueprint('analysis', __name__)


@analysis_bp.route('/api/analysis', methods=['GET'])
@require_auth
def get_analysis():
    """GET /api/analysis — ดึงผลวิเคราะห์ Topic Mastery รายวิชา"""
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

            cur.execute('''\
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
    GET /api/dashboard?days=7
    FIX: รับ days query param เพื่อให้ time filter ใน AnalyticsPage ทำงานจริง
    ค่า default = 7 วัน
    """
    # FIX: รับ days จาก query string ตรวจสอบ range 1-30
    try:
        days = int(request.args.get('days', 7))
        days = max(1, min(30, days))
    except ValueError:
        days = 7

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

            # Bar Chart: Topic Mastery รายวิชา
            cur.execute('''\
                SELECT s.subject_name, ta.mastery, ta.level
                FROM topic_analysis ta
                JOIN subjects s ON ta.subject_id = s.subject_id
                WHERE ta.user_id = %s
                ORDER BY ta.mastery DESC
            ''', (user_id,))
            bar_data = cur.fetchall()

            # FIX: Line Chart ใช้ days จริงแทน hardcode 6
            cur.execute('''\
                SELECT date, avg_understanding
                FROM progress
                WHERE user_id = %s
                AND date >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
                ORDER BY date ASC
            ''', (user_id, days - 1))
            line_data = cur.fetchall()

            # Radar Chart
            cur.execute('''\
                SELECT AVG(accuracy) as avg_accuracy,
                       AVG(speed)    as avg_speed,
                       AVG(mastery)  as avg_mastery
                FROM topic_analysis
                WHERE user_id = %s
            ''', (user_id,))
            radar_raw  = cur.fetchone()
            radar_data = {
                'accuracy': round(radar_raw['avg_accuracy'] or 0, 3),
                'speed':    round(radar_raw['avg_speed']    or 0, 3),
                'mastery':  round(radar_raw['avg_mastery']  or 0, 3),
            }

            # Recommendations รวมมาใน dashboard
            cur.execute('''\
                SELECT r.rec_id, r.topic, r.action, r.mastery,
                       s.subject_name, r.created_at
                FROM recommendations r
                JOIN subjects s ON r.subject_id = s.subject_id
                WHERE r.user_id = %s
                ORDER BY r.mastery ASC
                LIMIT 5
            ''', (user_id,))
            recommendations = cur.fetchall()

        return jsonify({
            'bar_chart':       bar_data,
            'line_chart':      line_data,
            'radar_chart':     radar_data,
            'recommendations': recommendations,
            'days':            days,   # ส่งกลับไปให้ Flutter รู้ว่า filter อะไรอยู่
        }), 200

    finally:
        conn.close()
