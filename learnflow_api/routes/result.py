from flask import Blueprint, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth

result_bp = Blueprint('result', __name__)


@result_bp.route('/api/result/<int:attempt_id>', methods=['GET'])
@require_auth
def get_result(attempt_id):
    """
    GET /api/result/<attempt_id>
    ดึงผลลัพธ์หลังทำ Quiz เสร็จ
    Flutter ใช้แสดงหน้า ResultPage
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # ดึง user_id
            cur.execute(
                'SELECT user_id FROM users WHERE firebase_uid = %s',
                (g.firebase_uid,)
            )
            user = cur.fetchone()
            if not user:
                return jsonify({'error': 'User not found'}), 404

            # ดึงข้อมูล attempt
            cur.execute('''
                SELECT qa.*, q.title, s.subject_name
                FROM quiz_attempts qa
                JOIN quizzes q ON qa.quiz_id = q.quiz_id
                JOIN subjects s ON q.subject_id = s.subject_id
                WHERE qa.attempt_id = %s AND qa.user_id = %s
            ''', (attempt_id, user['user_id']))
            attempt = cur.fetchone()

            if not attempt:
                return jsonify({'error': 'Attempt not found'}), 404

            # คำนวณ grade
            pct = (attempt['score'] / attempt['total'] * 100) if attempt['total'] > 0 else 0
            if pct >= 80:
                grade = 'A'
                badge = 'EXCELLENT!'
            elif pct >= 60:
                grade = 'B'
                badge = 'GOOD JOB!'
            else:
                grade = 'C'
                badge = 'KEEP TRYING!'

        return jsonify({
            'attempt_id':      attempt['attempt_id'],
            'quiz_title':      attempt['title'],
            'subject_name':    attempt['subject_name'],
            'score':           attempt['score'],
            'total':           attempt['total'],
            'percentage':      round(pct, 1),
            'time_spent':      attempt['time_spent'],
            'correct':         attempt['score'],
            'incorrect':       attempt['total'] - attempt['score'],
            'grade':           grade,
            'badge':           badge,
        }), 200

    finally:
        conn.close()


@result_bp.route('/api/review/<int:attempt_id>', methods=['GET'])
@require_auth
def get_review(attempt_id):
    """
    GET /api/review/<attempt_id>
    ดึงคำตอบ + เฉลย + คำอธิบายทุกข้อ
    Flutter ใช้แสดงหน้า ReviewAnswerPage
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

            # ดึงคำตอบทั้งหมดพร้อมข้อมูลคำถาม
            cur.execute('''
                SELECT ua.answer_id, ua.selected_choice, ua.is_correct,
                       ua.response_time,
                       q.question_text, q.correct_choice, q.explanation,
                       c_list.choices
                FROM user_answers ua
                JOIN questions q ON ua.question_id = q.question_id
                JOIN quiz_attempts att ON ua.attempt_id = att.attempt_id
                LEFT JOIN (
                    SELECT question_id,
                           JSON_ARRAYAGG(
                               JSON_OBJECT('label', choice_label, 'text', choice_text)
                           ) AS choices
                    FROM choices
                    GROUP BY question_id
                ) c_list ON q.question_id = c_list.question_id
                WHERE ua.attempt_id = %s AND att.user_id = %s
                ORDER BY ua.answer_id
            ''', (attempt_id, user['user_id']))
            answers = cur.fetchall()

        return jsonify({'answers': answers}), 200

    finally:
        conn.close()