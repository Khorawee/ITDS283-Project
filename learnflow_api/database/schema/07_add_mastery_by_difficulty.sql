-- 07_add_mastery_by_difficulty.sql
-- เพิ่มคอลัมน์ mastery_by_difficulty เพื่อเก็บคะแนนแยกตามระดับความยาก

USE learnflow;

-- ตรวจสอบและเพิ่มคอลัมน์ใน topic_analysis (ถ้ายังไม่มี)
ALTER TABLE topic_analysis
ADD COLUMN mastery_by_difficulty JSON DEFAULT NULL COMMENT 'JSON object: {easy: {mastery, level, action}, medium: {...}, hard: {...}}' AFTER level;

-- ตรวจสอบและเพิ่มคอลัมน์ใน recommendations (ถ้ายังไม่มี)
ALTER TABLE recommendations
ADD COLUMN mastery_by_difficulty JSON DEFAULT NULL COMMENT 'JSON object: {easy: {mastery, level, action}, medium: {...}, hard: {...}}' AFTER mastery;

-- ตัวอย่างข้อมูล mastery_by_difficulty:
-- {
--   "easy": {"mastery": 0.9, "level": "Strong", "action": "ผ่าน"},
--   "medium": {"mastery": 0.7, "level": "Improving", "action": "ทบทวน"},
--   "hard": {"mastery": 0.4, "level": "Weak", "action": "ฝึกเพิ่ม"}
-- }
