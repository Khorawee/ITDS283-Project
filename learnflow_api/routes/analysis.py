"""Analytics endpoints — dashboard and growth charts data.

Endpoints:
- GET /api/dashboard?days=7 — Get topic mastery, accuracy, speed, all-time stats
- GET /api/growth — Get all-time progress for growth chart
- GET /api/analysis — Get topic mastery all-time

Features:
- Input validation (days parameter 1-365)
- Efficient database queries with JOINs
- Radar chart calculations (3-decimal rounding)
- Bar chart data for topic mastery
"""

from flask import Blueprint, jsonify, g, request
from db_config import get_connection
from auth_middleware import require_auth

analysis_bp = Blueprint('analysis', __name__)


@analysis_bp.route('/api/analysis', methods=['GET'])
@require_auth
def get_analysis():
    """GET /api/analysis — ดึง topic mastery รายวิชา (all-time)
    
    Return: list of topics with accuracy, speed, understanding, mastery scores
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
    Line chart ใช้ days จาก query param
    Bar / Radar / Recommendations ไม่เปลี่ยน (all-time)
    FIX: Add comprehensive input validation
    """
    try:
        days = int(request.args.get('days', 7))
        # FIX: Validate days range properly
        if days < 1 or days > 365:
            return jsonify({'error': 'Days must be between 1 and 365'}), 400
        days = max(1, min(365, days))
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid days parameter'}), 400

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

            # Bar Chart: Topic Mastery รายวิชา (all-time)
            cur.execute('''\
                SELECT s.subject_name, ta.mastery, ta.level
                FROM topic_analysis ta
                JOIN subjects s ON ta.subject_id = s.subject_id
                WHERE ta.user_id = %s
                ORDER BY ta.mastery DESC
            ''', (user_id,))
            bar_data = cur.fetchall()

            # Line Chart: กรองตาม days
            cur.execute('''\
                SELECT date, avg_understanding
                FROM progress
                WHERE user_id = %s
                  AND date >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
                ORDER BY date ASC
            ''', (user_id, days - 1))
            line_data = cur.fetchall()

            # Radar Chart (all-time)
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

            # Recommendations (all-time)
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
            'days':            days,
        }), 200

    finally:
        conn.close()


# FIX: endpoint ใหม่สำหรับ Growth chart — ดึง progress ทุก session all-time
@analysis_bp.route('/api/growth', methods=['GET'])
@require_auth
def get_growth():
    """
    GET /api/growth
    ดึง progress ทั้งหมดที่เคยทำ ไม่จำกัดวัน
    ใช้สำหรับ Growth chart ใน Analytics page
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

            # ดึง progress ทุกวันที่เคยทำ เรียงตามวันที่
            cur.execute('''\
                SELECT
                    DATE_FORMAT(date, '%%d/%%m') AS label,
                    date,
                    avg_understanding
                FROM progress
                WHERE user_id = %s
                ORDER BY date ASC
            ''', (user['user_id'],))
            growth_data = cur.fetchall()

        return jsonify({
            'growth': growth_data,
            'total_sessions': len(growth_data),
        }), 200

    finally:
        conn.close()