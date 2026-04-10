from datetime import date
from ai_service import calculate_topic_mastery, get_level, get_action


def update_topic_analysis(cur, user_id: int, subject_id: int,
                           understanding_scores: list,
                           correct: int, total: int,
                           avg_speed: float,
                           subject_name: str = ''):
    """
    คำนวณและอัปเดต topic_analysis
    avg_speed คือค่าเฉลี่ย min(1.0, expected_time / response_time) รายข้อ
    คำนวณแล้วจาก quiz.py ก่อนส่งเข้ามา
    """
    accuracy      = round(correct / total, 4) if total > 0 else 0.0
    mastery       = calculate_topic_mastery(understanding_scores)
    understanding = round(sum(understanding_scores) / len(understanding_scores), 4) \
                    if understanding_scores else 0.0
    level         = get_level(mastery)
    topic         = subject_name or ''

    cur.execute('''\
        INSERT INTO topic_analysis
            (user_id, subject_id, topic, accuracy, speed,
             understanding, mastery, level, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW())
        ON DUPLICATE KEY UPDATE
            accuracy      = VALUES(accuracy),
            speed         = VALUES(speed),
            understanding = VALUES(understanding),
            mastery       = VALUES(mastery),
            level         = VALUES(level),
            updated_at    = NOW()
    ''', (user_id, subject_id, topic, accuracy, avg_speed,
          understanding, mastery, level))

    action = get_action(level)
    cur.execute('''\
        INSERT INTO recommendations
            (user_id, subject_id, topic, action, mastery)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            action  = VALUES(action),
            mastery = VALUES(mastery)
    ''', (user_id, subject_id, topic, action, mastery))


def update_progress(cur, user_id: int, understanding_scores: list):
    """อัปเดต progress รายวัน สำหรับ Line Chart 7 วัน"""
    today = date.today()
    avg_understanding = round(
        sum(understanding_scores) / len(understanding_scores), 4
    ) if understanding_scores else 0.0

    cur.execute('''\
        INSERT INTO progress (user_id, date, avg_understanding)
        VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE
            avg_understanding = VALUES(avg_understanding)
    ''', (user_id, today, avg_understanding))
