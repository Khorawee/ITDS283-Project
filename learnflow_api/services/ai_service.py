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
    """แปลง Level เป็น Action สำหรับ Recommendation (English เพื่อ MySQL ENUM)"""
    actions = {
        'Weak':      'practice',  # FIX: เปลี่ยนจาก 'ฝึกเพิ่ม'
        'Improving': 'review',    # FIX: เปลี่ยนจาก 'ทบทวน'
        'Strong':    'pass',      # FIX: เปลี่ยนจาก 'ผ่าน'
    }
    return actions.get(level, 'review')


def calculate_mastery_by_difficulty(understanding_scores_by_difficulty: dict) -> dict:
    """
    คำนวณ Mastery Score แยกตามระดับความยาก

    Args:
        understanding_scores_by_difficulty: {
            'easy':   [0.9, 0.85],
            'medium': [0.65, 0.70],
            'hard':   [0.40, 0.45]
        }

    Returns:
        {
            'easy': {'mastery': 0.875, 'level': 'Strong', 'action': 'pass'},
            'medium': {'mastery': 0.675, 'level': 'Improving', 'action': 'review'},
            'hard': {'mastery': 0.425, 'level': 'Weak', 'action': 'practice'}
        }
    """
    result = {}
    
    for difficulty, scores in understanding_scores_by_difficulty.items():
        if not scores:
            result[difficulty] = {
                'mastery': 0.0,
                'level': 'Weak',
                'action': 'practice'
            }
            continue
        
        mastery = calculate_topic_mastery(scores)
        level = get_level(mastery)
        action = get_action(level)
        
        result[difficulty] = {
            'mastery': mastery,
            'level': level,
            'action': action
        }
    
    return result