from flask import Blueprint, request, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth
from ai_service import calculate_understanding

quiz_bp = Blueprint('quiz', __name__)


@quiz_bp.route('/api/quizzes', methods=['GET'])
@require_auth
def get_quizzes():
    """
    GET /api/quizzes
    ดึงรายการ Quiz ทั้งหมด พร้อม subject
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute('''
                SELECT q.quiz_id, q.title, q.level, q.total_questions,  -- FIX: total_questions
                       s.subject_name
                FROM quizzes q
                JOIN subjects s ON q.subject_id = s.subject_id
                ORDER BY q.quiz_id
            ''')
            quizzes = cur.fetchall()
        return jsonify({'quizzes': quizzes}), 200
    finally:
        conn.close()


@quiz_bp.route('/api/quiz/<int:quiz_id>', methods=['GET'])
@require_auth
def get_quiz_detail(quiz_id):
    """
    GET /api/quiz/<quiz_id>
    ดึงรายละเอียด Quiz + คำถามทั้งหมด + ตัวเลือก
    Flutter ใช้หน้า DetailBasicMathPage และ BasicMathPage
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute('''
                SELECT q.quiz_id, q.title, q.level, q.total_questions,  -- FIX: total_questions
                       s.subject_name
                FROM quizzes q
                JOIN subjects s ON q.subject_id = s.subject_id
                WHERE q.quiz_id = %s
            ''', (quiz_id,))
            quiz = cur.fetchone()

            if not quiz:
                return jsonify({'error': 'Quiz not found'}), 404

            cur.execute('''
                SELECT question_id, topic, question_text,
                       correct_choice, explanation, expected_time
                FROM questions
                WHERE quiz_id = %s
                ORDER BY question_id
            ''', (quiz_id,))
            questions = cur.fetchall()

            for q in questions:
                cur.execute('''
                    SELECT choice_id, choice_label, choice_text
                    FROM choices
                    WHERE question_id = %s
                    ORDER BY choice_label
                ''', (q['question_id'],))
                q['choices'] = cur.fetchall()

        quiz['questions'] = questions
        return jsonify({'quiz': quiz}), 200
    finally:
        conn.close()

def check_attempted(quiz_id):
    """
    GET /api/quiz/<quiz_id>/attempted
    ตรวจสอบว่า user เคยทำ quiz นี้มาก่อนหรือเปล่า
    Flutter ใช้ตัดสินใจว่าจะแสดงปุ่ม Retake หรือไม่
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

            cur.execute(
                '''SELECT COUNT(*) as cnt
                   FROM quiz_attempts
                   WHERE user_id = %s AND quiz_id = %s''',
                (user['user_id'], quiz_id)
            )
            result = cur.fetchone()
            has_attempted = result['cnt'] > 0

        return jsonify({'has_attempted': has_attempted}), 200

    finally:
        conn.close()


@quiz_bp.route('/api/quiz/submit', methods=['POST'])
@require_auth
def submit_quiz():
    """
    POST /api/quiz/submit
    รับคำตอบทั้งหมดหลังทำ Quiz เสร็จ
    คำนวณ Accuracy, Speed, Understanding แล้วบันทึกลง DB

    Body JSON:
    {
        "quiz_id": 1,
        "time_spent": 420,
        "answers": [
            {
                "question_id": 1,
                "selected_choice": "B",
                "response_time": 28.5,
                "attempt_count": 1
            }
        ]
    }
    """
    data = request.get_json() or {}
    quiz_id    = data.get('quiz_id')
    time_spent = data.get('time_spent', 0)
    answers    = data.get('answers', [])

    if not quiz_id or not answers:
        return jsonify({'error': 'Missing quiz_id or answers'}), 400

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

            cur.execute('''
                SELECT q.question_id, q.correct_choice, q.expected_time,
                       q.quiz_id, qz.subject_id
                FROM questions q
                JOIN quizzes qz ON q.quiz_id = qz.quiz_id
                WHERE q.quiz_id = %s
            ''', (quiz_id,))
            questions = {q['question_id']: q for q in cur.fetchall()}

            score = 0
            total = len(answers)
            subject_id = None
            understanding_scores = []

            cur.execute('''
                INSERT INTO quiz_attempts
                (user_id, quiz_id, score, total, time_spent)
                VALUES (%s, %s, %s, %s, %s)
            ''', (user_id, quiz_id, 0, total, time_spent))
            attempt_id = cur.lastrowid

            for ans in answers:
                qid           = ans['question_id']
                selected      = ans['selected_choice']
                response_time = ans.get('response_time', 30)
                attempt_count = ans.get('attempt_count', 1)
                q_data        = questions.get(qid)

                if not q_data:
                    continue

                subject_id  = q_data['subject_id']
                is_correct  = (selected == q_data['correct_choice'])
                expected_t  = q_data['expected_time'] or 30

                if is_correct:
                    score += 1

                accuracy      = 1.0 if is_correct else 0.0
                speed         = min(1.0, expected_t / max(response_time, 1))
                understanding = calculate_understanding(accuracy, speed)
                understanding_scores.append(understanding)

                cur.execute('''
                    INSERT INTO user_answers
                    (attempt_id, question_id, selected_choice,
                     is_correct, response_time, attempt_count)
                    VALUES (%s, %s, %s, %s, %s, %s)
                ''', (attempt_id, qid, selected,
                      is_correct, response_time, attempt_count))

            cur.execute(
                'UPDATE quiz_attempts SET score = %s WHERE attempt_id = %s',
                (score, attempt_id)
            )

            if subject_id and understanding_scores:
                from progress_service import update_topic_analysis, update_progress
                update_topic_analysis(cur, user_id, subject_id,
                                      understanding_scores, score, total,
                                      time_spent)
                update_progress(cur, user_id, understanding_scores)

            conn.commit()

        return jsonify({
            'attempt_id':  attempt_id,
            'score':       score,
            'total':       total,
            'percentage':  round((score / total) * 100, 1) if total > 0 else 0,
        }), 201

    finally:
        conn.close()
