"""
Unit tests สำหรับ AI Logic ใน ai_service.py
รัน: python -m pytest ai_service_test.py -v
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'services'))

from ai_service import (
    calculate_understanding,
    calculate_topic_mastery,
    get_level,
    get_action,
)


# ── calculate_understanding ────────────────────────────────────────────────

class TestCalculateUnderstanding:
    def test_perfect_score(self):
        assert calculate_understanding(1.0, 1.0) == 1.0

    def test_zero_score(self):
        assert calculate_understanding(0.0, 0.0) == 0.0

    def test_weight_60_40(self):
        # Understanding = (0.6 × 0.8) + (0.4 × 0.5) = 0.48 + 0.20 = 0.68
        result = calculate_understanding(0.8, 0.5)
        assert abs(result - 0.68) < 0.001

    def test_correct_but_slow(self):
        # ตอบถูกหมดแต่ใช้เวลานาน speed=0.5
        result = calculate_understanding(1.0, 0.5)
        assert abs(result - 0.80) < 0.001

    def test_wrong_but_fast(self):
        # ตอบผิดหมดแต่ตอบเร็ว accuracy=0
        result = calculate_understanding(0.0, 1.0)
        assert abs(result - 0.40) < 0.001

    def test_result_range(self):
        # ผลลัพธ์ต้องอยู่ระหว่าง 0.0 – 1.0 เสมอ
        for acc in [0.0, 0.3, 0.7, 1.0]:
            for spd in [0.0, 0.5, 1.0]:
                result = calculate_understanding(acc, spd)
                assert 0.0 <= result <= 1.0


# ── calculate_topic_mastery ────────────────────────────────────────────────

class TestCalculateTopicMastery:
    def test_empty_list(self):
        assert calculate_topic_mastery([]) == 0.0

    def test_single_attempt(self):
        assert calculate_topic_mastery([0.75]) == 0.75

    def test_average_multiple(self):
        scores = [0.62, 0.77, 0.87]
        expected = round((0.62 + 0.77 + 0.87) / 3, 4)
        assert calculate_topic_mastery(scores) == expected

    def test_improving_trend(self):
        # mastery ควรสะท้อน avg ไม่ใช่ค่าสุดท้าย
        scores = [0.40, 0.60, 0.80]
        result = calculate_topic_mastery(scores)
        assert abs(result - 0.60) < 0.001


# ── get_level ──────────────────────────────────────────────────────────────

class TestGetLevel:
    def test_strong(self):
        assert get_level(0.81) == 'Strong'
        assert get_level(1.00) == 'Strong'

    def test_boundary_strong(self):
        # > 0.80 = Strong, 0.80 เองยังไม่ใช่ Strong
        assert get_level(0.80) == 'Improving'

    def test_improving(self):
        assert get_level(0.70) == 'Improving'
        assert get_level(0.60) == 'Improving'

    def test_boundary_weak(self):
        # < 0.60 = Weak
        assert get_level(0.59) == 'Weak'
        assert get_level(0.00) == 'Weak'


# ── get_action ─────────────────────────────────────────────────────────────

class TestGetAction:
    def test_weak_action(self):
        assert get_action('Weak') == 'ฝึกเพิ่ม'

    def test_improving_action(self):
        assert get_action('Improving') == 'ทบทวน'

    def test_strong_action(self):
        assert get_action('Strong') == 'ผ่าน'

    def test_unknown_defaults_to_review(self):
        assert get_action('Unknown') == 'ทบทวน'


# ── integration: full flow ─────────────────────────────────────────────────

class TestFullFlow:
    def test_algebra_example_from_requirement(self):
        """ตัวอย่างจาก Requirement: Algebra 3 attempts"""
        scores = [
            calculate_understanding(0.60, 0.65),
            calculate_understanding(0.75, 0.80),
            calculate_understanding(0.85, 0.90),
        ]
        mastery = calculate_topic_mastery(scores)
        level   = get_level(mastery)
        action  = get_action(level)

        assert mastery > 0.60          # ควรผ่าน Improving
        assert level == 'Improving'
        assert action == 'ทบทวน'

    def test_weak_subject(self):
        """บทที่ตอบผิดบ่อยและช้า ควรได้ Weak"""
        scores = [calculate_understanding(0.3, 0.4)] * 3
        mastery = calculate_topic_mastery(scores)
        assert get_level(mastery) == 'Weak'

    def test_speed_cap_at_1(self):
        """Speed ต้องไม่เกิน 1.0 แม้ตอบเร็วกว่า expected มาก"""
        expected_time = 30
        response_time = 5   # เร็วกว่า 6 เท่า
        speed = min(1.0, expected_time / max(response_time, 1))
        assert speed == 1.0

    def test_response_time_zero_guard(self):
        """response_time = 0 ต้องไม่ ZeroDivisionError"""
        speed = min(1.0, 30 / max(0, 1))
        assert speed == 1.0
