"""Quiz endpoints — retrieve quizzes and submit answers.

Endpoints:
- GET /api/quizzes?page=1&limit=20 — List quizzes with pagination
- GET /api/quiz/<quiz_id> — Get quiz details + questions + choices
- POST /api/quiz/<quiz_id>/submit — Submit quiz answers

Features:
- Pagination support (default 20 per page, max 50)
- Time limit calculation (max(15, questions * 2.5) minutes)
- Attempt tracking (logs retakes)
- Score/accuracy/speed/understanding calculation
- Transaction safety for quiz submission
- Integration with progress_service and ai_service
"""

from flask import Blueprint, request, jsonify, g
from db_config import get_connection
from auth_middleware import require_auth
from ai_service import calculate_understanding
import logging

logger = logging.getLogger(__name__)

quiz_bp = Blueprint('quiz', __name__)


@quiz_bp.route('/api/quizzes', methods=['GET'])
@require_auth
def get_quizzes():
    """GET /api/quizzes?page=1&limit=20 — ดึงรายการ Quiz พร้อม pagination
    
    Params: page (default 1), limit (default 20, max 50)
    Return: list of quizzes + pagination info
    """
    # ADD: Pagination
    try:
        page  = max(1, int(request.args.get('page', 1)))
        limit = min(50, max(1, int(request.args.get('limit', 20))))
    except ValueError:
        return jsonify({'error': 'Invalid page or limit parameter'}), 400

    offset = (page - 1) * limit

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # นับเฉพาะ quiz ที่มีคำถามจริงอยู่ใน questions table
            cur.execute('''
                SELECT COUNT(DISTINCT q.quiz_id) AS total
                FROM quizzes q
                INNER JOIN questions qn ON qn.quiz_id = q.quiz_id
            ''')
            total = cur.fetchone()['total']

            cur.execute('''\
                SELECT q.quiz_id, q.title, q.level, q.total_questions,
                       s.subject_name,
                       COUNT(qn.question_id) AS question_count
                FROM quizzes q
                JOIN subjects s ON q.subject_id = s.subject_id
                INNER JOIN questions qn ON qn.quiz_id = q.quiz_id
                GROUP BY q.quiz_id, q.title, q.level, q.total_questions, s.subject_name
                ORDER BY q.quiz_id
                LIMIT %s OFFSET %s
            ''', (limit, offset))
            quizzes = cur.fetchall()

        return jsonify({
            'quizzes': quizzes,
            'pagination': {
                'page':        page,
                'limit':       limit,
                'total':       total,
                'total_pages': -(-total // limit),  # ceiling division
            }
        }), 200
    finally:
        conn.close()


@quiz_bp.route('/api/quiz/<int:quiz_id>', methods=['GET'])
@require_auth
def get_quiz_detail(quiz_id):
    """GET /api/quiz/<quiz_id> — ดึงรายละเอียด Quiz + คำถาม + choices + time_limit
    
    Return: quiz detail + time_limit_seconds (calculated from questions count)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute('''\
                SELECT q.quiz_id, q.title, q.level, q.total_questions,
                       s.subject_name
                FROM quizzes q
                JOIN subjects s ON q.subject_id = s.subject_id
                WHERE q.quiz_id = %s
            ''', (quiz_id,))
            quiz = cur.fetchone()

            if not quiz:
                return jsonify({'error': 'Quiz not found'}), 404

            cur.execute('''\
                SELECT question_id, topic, question_text,
                       correct_choice, explanation, expected_time
                FROM questions
                WHERE quiz_id = %s
                ORDER BY question_id
            ''', (quiz_id,))
            questions = cur.fetchall()

            for q in questions:
                cur.execute('''\
                    SELECT choice_id, choice_label, choice_text
                    FROM choices
                    WHERE question_id = %s
                    ORDER BY choice_label
                ''', (q['question_id'],))
                q['choices'] = cur.fetchall()

        quiz['questions'] = questions

        # คำนวณเวลาตามจำนวนข้อ × นาทีต่อข้อตามระดับความยาก
        # EASY: 1 นาที/ข้อ  |  MEDIUM: 1.5 นาที/ข้อ  |  HARD: 1.5 นาที/ข้อ
        total_questions = len(questions)
        level = (quiz.get('level') or 'EASY').upper()
        if level == 'EASY':
            mins_per_q = 1.0
        elif level == 'MEDIUM':
            mins_per_q = 1.5
        else:  # HARD
            mins_per_q = 1.5
        time_limit_minutes = total_questions * mins_per_q
        quiz['time_limit_seconds'] = int(time_limit_minutes * 60)
        
        return jsonify({'quiz': quiz}), 200
    finally:
        conn.close()


@quiz_bp.route('/api/quiz/<int:quiz_id>/attempted', methods=['GET'])
@require_auth
def check_attempted(quiz_id):
    """GET /api/quiz/<quiz_id>/attempted — เช็คว่า user เคยทำ quiz นี้หรือยัง"""
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
                'SELECT COUNT(*) as cnt FROM quiz_attempts WHERE user_id = %s AND quiz_id = %s',
                (user['user_id'], quiz_id)
            )
            has_attempted = cur.fetchone()['cnt'] > 0

        return jsonify({'has_attempted': has_attempted}), 200
    finally:
        conn.close()


@quiz_bp.route('/api/quiz/submit', methods=['POST'])
@require_auth
def submit_quiz():
    """
    POST /api/quiz/submit
    รับคำตอบทั้งหมดหลังทำ Quiz เสร็จ

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

    # ADD: Input Validation
    errors = _validate_submit(quiz_id, time_spent, answers)
    if errors:
        return jsonify({'error': errors}), 400

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

            # FIX: Check if user has already attempted this quiz (for tracking retakes)
            cur.execute(
                'SELECT COUNT(*) as attempt_count FROM quiz_attempts WHERE user_id = %s AND quiz_id = %s',
                (user_id, quiz_id)
            )
            previous_attempts = cur.fetchone()['attempt_count']
            if previous_attempts > 0:
                logger.info('User %s retaking quiz %s (attempt #%d)', g.firebase_uid[:8], quiz_id, previous_attempts + 1)

            cur.execute('''\
                SELECT q.question_id, q.correct_choice, q.expected_time,
                       q.quiz_id, q.topic, qz.subject_id, s.subject_name
                FROM questions q
                JOIN quizzes qz ON q.quiz_id = qz.quiz_id
                JOIN subjects s ON qz.subject_id = s.subject_id
                WHERE q.quiz_id = %s
            ''', (quiz_id,))
            questions = {q['question_id']: q for q in cur.fetchall()}

            score                = 0
            total                = len(answers)
            subject_id           = None
            subject_name         = ''
            understanding_scores = []
            speed_scores         = []

            cur.execute('''\
                INSERT INTO quiz_attempts (user_id, quiz_id, score, total, time_spent)
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

                subject_id   = q_data['subject_id']
                subject_name = q_data.get('subject_name', '')
                is_correct   = (selected == q_data['correct_choice'])
                expected_t   = q_data['expected_time'] or 30

                if is_correct:
                    score += 1

                accuracy      = 1.0 if is_correct else 0.0
                speed         = min(1.0, expected_t / max(response_time, 1))
                understanding = calculate_understanding(accuracy, speed)
                understanding_scores.append(understanding)
                speed_scores.append(speed)

                cur.execute('''\
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
                avg_speed = round(sum(speed_scores) / len(speed_scores), 4) \
                            if speed_scores else 0.0

                from progress_service import update_topic_analysis, update_progress
                update_topic_analysis(cur, user_id, subject_id,
                                      understanding_scores, score, total,
                                      avg_speed, subject_name)
                update_progress(cur, user_id, understanding_scores)

            conn.commit()

        logger.info('submit_quiz: user=%s quiz=%s score=%s/%s attempt=%s',
                    g.firebase_uid[:8], quiz_id, score, total, attempt_id)

        return jsonify({
            'attempt_id': attempt_id,
            'score':      score,
            'total':      total,
            'percentage': round((score / total) * 100, 1) if total > 0 else 0,
        }), 201

    except Exception as e:
        logger.error('submit_quiz error: user=%s quiz=%s error=%s',
                     g.firebase_uid[:8], quiz_id, str(e))
        conn.rollback()
        raise
    finally:
        conn.close()


# ── helpers ────────────────────────────────────────────────────────────────

def _validate_submit(quiz_id, time_spent, answers):
    """Validate quiz submit payload — คืน error string หรือ None"""
    if not quiz_id or not isinstance(quiz_id, int):
        return 'quiz_id is required and must be an integer'
    if not isinstance(time_spent, (int, float)) or time_spent < 0:
        return 'time_spent must be a non-negative number'
    if not answers or not isinstance(answers, list):
        return 'answers must be a non-empty list'
    if len(answers) > 200:
        return 'answers list too long (max 200)'

    for i, ans in enumerate(answers):
        if not isinstance(ans.get('question_id'), int):
            return f'answers[{i}].question_id must be an integer'
        if not isinstance(ans.get('selected_choice'), str) or \
                ans['selected_choice'].upper() not in ('A', 'B', 'C', 'D'):
            return f'answers[{i}].selected_choice must be A, B, C, or D'
        rt = ans.get('response_time', 30)
        if not isinstance(rt, (int, float)) or rt <= 0:
            return f'answers[{i}].response_time must be a positive number'

    return None