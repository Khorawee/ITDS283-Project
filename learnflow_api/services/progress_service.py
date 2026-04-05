from datetime import date
from ai_service import calculate_topic_mastery, get_level, get_action


def update_topic_analysis(cur, user_id: int, subject_id: int,
                           understanding_scores: list,
                           correct: int, total: int,
                           time_spent: float):
    """
    คำนวณและอัปเดต topic_analysis
    ใช้ INSERT ... ON DUPLICATE KEY UPDATE เพื่อ upsert
    """
    accuracy  = round(correct / total, 4) if total > 0 else 0.0
    avg_speed = round(min(1.0, 30 / max(time_spent / max(total, 1), 1)), 4)
    mastery   = calculate_topic_mastery(understanding_scores)
    understanding = round(sum(understanding_scores) / len(understanding_scores), 4) if understanding_scores else 0.0
    level     = get_level(mastery)

    cur.execute('''
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
    ''', (user_id, subject_id, '', accuracy, avg_speed,
          understanding, mastery, level))

    # อัปเดต recommendation
    action = get_action(level)
    cur.execute('''
        INSERT INTO recommendations
            (user_id, subject_id, topic, action, mastery)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            action  = VALUES(action),
            mastery = VALUES(mastery)
    ''', (user_id, subject_id, '', action, mastery))


def update_progress(cur, user_id: int, understanding_scores: list):
    """
    อัปเดต progress รายวัน สำหรับ Line Chart 7 วัน
    ถ้ามี record วันนี้แล้ว → UPDATE avg_understanding
    ถ้ายังไม่มี → INSERT
    """
    today = date.today()
    avg_understanding = round(
        sum(understanding_scores) / len(understanding_scores), 4
    ) if understanding_scores else 0.0

    cur.execute('''
        INSERT INTO progress (user_id, date, avg_understanding)
        VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE
            avg_understanding = VALUES(avg_understanding)
    ''', (user_id, today, avg_understanding))