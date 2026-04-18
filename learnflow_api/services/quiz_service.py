"""Quiz Service — Business logic layer for quiz operations

Separates database queries and business logic from route handlers.
Makes code more testable and reusable.

Functions:
- get_quizzes_page(page, limit) — Get paginated list of quizzes
- get_quiz_detail(quiz_id) — Get quiz with all questions and choices
- check_quiz_attempted(user_id, quiz_id) — Check if user attempted quiz
- submit_quiz_answers(user_id, quiz_id, time_spent, answers) — Process submission
"""

from db_config import get_connection
from ai_service import calculate_understanding, calculate_topic_mastery, get_level, get_action
from progress_service import update_topic_analysis, update_progress
import logging

logger = logging.getLogger(__name__)


class QuizService:
    """Service class for quiz-related operations"""

    @staticmethod
    def get_quizzes_page(page: int, limit: int) -> dict:
        """Get paginated list of quizzes
        
        Args:
            page: Page number (1-indexed)
            limit: Items per page (max 50)
            
        Returns:
            {'quizzes': [...], 'pagination': {...}}
        """
        page = max(1, page)
        limit = min(50, max(1, limit))
        offset = (page - 1) * limit

        conn = get_connection()
        try:
            with conn.cursor() as cur:
                # Count total quizzes
                cur.execute('''
                    SELECT COUNT(DISTINCT q.quiz_id) AS total
                    FROM quizzes q
                    INNER JOIN questions qn ON qn.quiz_id = q.quiz_id
                ''')
                total = cur.fetchone()['total']

                # Get paginated quizzes
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

            return {
                'quizzes': quizzes,
                'pagination': {
                    'page': page,
                    'limit': limit,
                    'total': total,
                    'total_pages': -(-total // limit),
                }
            }
        finally:
            conn.close()

    @staticmethod
    def get_quiz_detail(quiz_id: int) -> dict:
        """Get quiz detail with all questions and choices (optimized JOIN)
        
        Uses single JOIN query to eliminate N+1 problem.
        
        Args:
            quiz_id: Quiz ID
            
        Returns:
            Quiz object with questions list and time_limit_seconds
            
        Raises:
            ValueError: If quiz not found
        """
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                # Get quiz metadata
                cur.execute('''\
                    SELECT q.quiz_id, q.title, q.level, q.total_questions,
                           s.subject_name
                    FROM quizzes q
                    JOIN subjects s ON q.subject_id = s.subject_id
                    WHERE q.quiz_id = %s
                ''', (quiz_id,))
                quiz = cur.fetchone()

                if not quiz:
                    raise ValueError(f'Quiz {quiz_id} not found')

                # Get questions + choices in single query (JOINed)
                cur.execute('''\
                    SELECT q.question_id, q.topic, q.question_text,
                           q.correct_choice, q.explanation, q.expected_time,
                           c.choice_id, c.choice_label, c.choice_text
                    FROM questions q
                    LEFT JOIN choices c ON q.question_id = c.question_id
                    WHERE q.quiz_id = %s
                    ORDER BY q.question_id, c.choice_label
                ''', (quiz_id,))
                rows = cur.fetchall()

                # Build nested structure from flat result
                questions_dict = {}
                for row in rows:
                    qid = row['question_id']
                    if qid not in questions_dict:
                        questions_dict[qid] = {
                            'question_id': row['question_id'],
                            'topic': row['topic'],
                            'question_text': row['question_text'],
                            'correct_choice': row['correct_choice'],
                            'explanation': row['explanation'],
                            'expected_time': row['expected_time'],
                            'choices': []
                        }
                    if row['choice_id']:
                        questions_dict[qid]['choices'].append({
                            'choice_id': row['choice_id'],
                            'choice_label': row['choice_label'],
                            'choice_text': row['choice_text']
                        })
                
                quiz['questions'] = list(questions_dict.values())

                # Calculate time limit based on difficulty
                total_questions = len(quiz['questions'])
                level = (quiz.get('level') or 'EASY').upper()
                mins_per_q = {'EASY': 1.0, 'MEDIUM': 1.5}.get(level, 1.5)
                time_limit_minutes = total_questions * mins_per_q
                quiz['time_limit_seconds'] = int(time_limit_minutes * 60)
                
                return quiz
        finally:
            conn.close()

    @staticmethod
    def check_quiz_attempted(user_id: int, quiz_id: int) -> bool:
        """Check if user has attempted quiz before
        
        Args:
            user_id: User ID
            quiz_id: Quiz ID
            
        Returns:
            True if attempted, False otherwise
        """
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(
                    'SELECT COUNT(*) as cnt FROM quiz_attempts WHERE user_id = %s AND quiz_id = %s',
                    (user_id, quiz_id)
                )
                result = cur.fetchone()
                return result['cnt'] > 0
        finally:
            conn.close()

    @staticmethod
    def submit_quiz_answers(user_id: int, quiz_id: int, time_spent: int, 
                           answers: list) -> dict:
        """Process quiz submission and calculate scores
        
        Handles:
        - Answer validation and scoring
        - Progress tracking
        - Recommendation updates
        - Attempt logging
        
        Args:
            user_id: User ID
            quiz_id: Quiz ID
            time_spent: Total time in seconds
            answers: List of answers with {question_id, selected_choice, response_time, attempt_count}
            
        Returns:
            {'attempt_id': ..., 'score': ..., 'total': ..., 'percentage': ...}
            
        Raises:
            ValueError: If quiz or user not found, or validation fails
        """
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                # Verify quiz exists and get questions + quiz level
                cur.execute('''\
                    SELECT q.question_id, q.correct_choice, q.expected_time,
                           q.quiz_id, q.topic, qz.subject_id, s.subject_name,
                           qz.level as quiz_level
                    FROM questions q
                    JOIN quizzes qz ON q.quiz_id = qz.quiz_id
                    JOIN subjects s ON qz.subject_id = s.subject_id
                    WHERE q.quiz_id = %s
                ''', (quiz_id,))
                questions = {q['question_id']: q for q in cur.fetchall()}

                if not questions:
                    raise ValueError(f'Quiz {quiz_id} has no questions')

                # Check for retakes
                cur.execute(
                    'SELECT COUNT(*) as attempt_count FROM quiz_attempts WHERE user_id = %s AND quiz_id = %s',
                    (user_id, quiz_id)
                )
                previous_attempts = cur.fetchone()['attempt_count']
                if previous_attempts > 0:
                    logger.info('User %s retaking quiz %s (attempt #%d)',
                               user_id, quiz_id, previous_attempts + 1)

                # Create attempt record
                cur.execute('''\
                    INSERT INTO quiz_attempts (user_id, quiz_id, score, total, time_spent)
                    VALUES (%s, %s, %s, %s, %s)
                ''', (user_id, quiz_id, 0, len(answers), time_spent))
                attempt_id = cur.lastrowid

                # Process answers
                score = 0
                understanding_scores = []
                understanding_scores_by_difficulty = {
                    'easy': [],
                    'medium': [],
                    'hard': []
                }
                speed_scores = []
                quiz_level = None
                subject_id = None
                subject_name = ''

                for ans in answers:
                    qid = ans.get('question_id')
                    selected = ans.get('selected_choice')
                    response_time = ans.get('response_time', 30)
                    attempt_count = ans.get('attempt_count', 1)
                    
                    if qid not in questions:
                        logger.warning('Question %s not in quiz %s', qid, quiz_id)
                        continue

                    q_data = questions[qid]
                    subject_id = q_data['subject_id']
                    subject_name = q_data.get('subject_name', '')
                    quiz_level = q_data.get('quiz_level', 'medium')
                    
                    is_correct = (selected == q_data['correct_choice'])
                    if is_correct:
                        score += 1

                    expected_t = q_data['expected_time'] or 30
                    accuracy = 1.0 if is_correct else 0.0
                    speed = min(1.0, expected_t / max(response_time, 1))
                    understanding = calculate_understanding(accuracy, speed)

                    understanding_scores.append(understanding)
                    understanding_scores_by_difficulty[quiz_level].append(understanding)
                    speed_scores.append(speed)

                    # Save user answer
                    cur.execute('''\
                        INSERT INTO user_answers
                        (attempt_id, question_id, selected_choice,
                         is_correct, response_time, attempt_count)
                        VALUES (%s, %s, %s, %s, %s, %s)
                    ''', (attempt_id, qid, selected, is_correct, response_time, attempt_count))

                # Update attempt score
                cur.execute(
                    'UPDATE quiz_attempts SET score = %s WHERE attempt_id = %s',
                    (score, attempt_id)
                )

                # Update analytics
                if subject_id and understanding_scores:
                    avg_speed = round(sum(speed_scores) / len(speed_scores), 4)
                    update_topic_analysis(cur, user_id, subject_id,
                                         understanding_scores, score, len(answers),
                                         avg_speed, subject_name,
                                         understanding_scores_by_difficulty)
                    update_progress(cur, user_id, understanding_scores)

                conn.commit()
                logger.info('Quiz submitted: user=%s quiz=%s score=%s/%s attempt=%s',
                           user_id, quiz_id, score, len(answers), attempt_id)

                return {
                    'attempt_id': attempt_id,
                    'score': score,
                    'total': len(answers),
                    'percentage': round((score / len(answers)) * 100, 1) if len(answers) > 0 else 0,
                }
        except Exception as e:
            conn.rollback()
            logger.error('Quiz submission failed: %s', str(e))
            raise
        finally:
            conn.close()
