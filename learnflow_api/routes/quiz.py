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
import logging
import sys
import os

# Add parent directories to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'middleware'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'services'))

from auth_middleware import require_auth
from quiz_service import QuizService

logger = logging.getLogger(__name__)

quiz_bp = Blueprint('quiz', __name__)


def _validate_submit(quiz_id, time_spent, answers):
    """ตรวจสอบ input สำหรับ quiz submission
    
    Return: None (valid) หรือ error message
    """
    if not isinstance(quiz_id, int) or quiz_id <= 0:
        return 'Invalid quiz_id'
    if not isinstance(time_spent, (int, float)) or time_spent < 0:
        return 'Invalid time_spent'
    if not isinstance(answers, list) or len(answers) == 0:
        return 'Answers list is empty'
    
    for ans in answers:
        if not isinstance(ans, dict):
            return 'Each answer must be an object'
        if 'question_id' not in ans or 'selected_choice' not in ans:
            return 'Missing question_id or selected_choice in answer'
        if not isinstance(ans['question_id'], int) or ans['question_id'] <= 0:
            return 'Invalid question_id in answer'
        if not isinstance(ans['selected_choice'], str) or len(ans['selected_choice']) == 0:
            return 'Invalid selected_choice in answer'
    
    return None


@quiz_bp.route('/api/quizzes', methods=['GET'])
@require_auth
def get_quizzes():
    """GET /api/quizzes?page=1&limit=20 — ดึงรายการ Quiz พร้อม pagination
    
    Params: page (default 1), limit (default 20, max 50)
    Return: list of quizzes + pagination info
    """
    try:
        page  = max(1, int(request.args.get('page', 1)))
        limit = min(50, max(1, int(request.args.get('limit', 20))))
    except ValueError:
        return jsonify({'error': 'Invalid page or limit parameter'}), 400

    try:
        result = QuizService.get_quizzes_page(page, limit)
        return jsonify(result), 200
    except Exception as e:
        logger.error('Failed to get quizzes: %s', str(e))
        return jsonify({'error': 'Failed to retrieve quizzes'}), 500


@quiz_bp.route('/api/quiz/<int:quiz_id>', methods=['GET'])
@require_auth
def get_quiz_detail(quiz_id):
    """GET /api/quiz/<quiz_id> — ดึงรายละเอียด Quiz + คำถาม + choices + time_limit
    
    Return: quiz detail + time_limit_seconds (calculated from questions count)
    """
    try:
        quiz = QuizService.get_quiz_detail(quiz_id)
        return jsonify({'quiz': quiz}), 200
    except ValueError as e:
        logger.warning('Quiz not found: %s', str(e))
        return jsonify({'error': str(e)}), 404
    except Exception as e:
        logger.error('Failed to get quiz detail: %s', str(e))
        return jsonify({'error': 'Failed to retrieve quiz'}), 500


@quiz_bp.route('/api/quiz/<int:quiz_id>/attempted', methods=['GET'])
@require_auth
def check_attempted(quiz_id):
    """GET /api/quiz/<quiz_id>/attempted — เช็คว่า user เคยทำ quiz นี้หรือยัง"""
    from db_config import get_connection
    
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

            has_attempted = QuizService.check_quiz_attempted(user['user_id'], quiz_id)
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
    from db_config import get_connection
    
    data = request.get_json() or {}
    quiz_id    = data.get('quiz_id')
    time_spent = data.get('time_spent', 0)
    answers    = data.get('answers', [])

    # Input Validation
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
    finally:
        conn.close()

    try:
        result = QuizService.submit_quiz_answers(user_id, quiz_id, time_spent, answers)
        return jsonify(result), 201
    except ValueError as e:
        logger.warning('Validation error in quiz submission: %s', str(e))
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error('Failed to submit quiz: %s', str(e))
        return jsonify({'error': 'Failed to submit quiz'}), 500


# ── helpers ────────────────────────────────────────────────────────────────
# Note: Old code below is preserved but not in use (refactored to QuizService)