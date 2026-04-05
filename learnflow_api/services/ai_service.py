def calculate_understanding(accuracy: float, speed: float) -> float:
    """
    คำนวณ Understanding Score จาก Accuracy และ Speed
    สูตร: Understanding = (0.6 × Accuracy) + (0.4 × Speed)
    ค่าอยู่ระหว่าง 0.0 – 1.0
    """
    return round((0.6 * accuracy) + (0.4 * speed), 4)


def calculate_topic_mastery(understanding_scores: list) -> float:
    """
    คำนวณ Topic Mastery จาก Understanding Score ทั้งหมดของ Topic นั้น
    สูตร: Mastery = SUM(Understanding) / Total Attempts
    """
    if not understanding_scores:
        return 0.0
    return round(sum(understanding_scores) / len(understanding_scores), 4)


def get_level(mastery: float) -> str:
    """
    แปลง Mastery Score เป็น Knowledge Level
    > 0.80 = Strong
    0.60–0.80 = Improving
    < 0.60 = Weak
    """
    if mastery > 0.80:
        return 'Strong'
    elif mastery >= 0.60:
        return 'Improving'
    else:
        return 'Weak'


def get_action(level: str) -> str:
    """แปลง Level เป็น Action สำหรับ Recommendation"""
    actions = {
        'Weak':      'ฝึกเพิ่ม',
        'Improving': 'ทบทวน',
        'Strong':    'ผ่าน',
    }
    return actions.get(level, 'ทบทวน')