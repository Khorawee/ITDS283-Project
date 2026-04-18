-- reset_and_seed.sql
-- รัน script นี้เพื่อ reset ข้อมูลใน subjects + quizzes ทั้งหมด
-- แล้วใส่ข้อมูลใหม่ที่ถูกต้อง
--
-- วิธีรัน:
--   mysql -u root -p learnflow < reset_and_seed.sql
--
-- ⚠️  หลังรัน script นี้แล้ว ต้องรัน seed_questions.py ใหม่ด้วย
--     เพราะ questions และ choices ถูก TRUNCATE ไปด้วย

USE learnflow;

-- ── Step 1: ล้างข้อมูลเก่าทั้งหมด ──────────────────────────────────────────
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE user_answers;   -- ขึ้นอยู่กับ quiz_attempts
TRUNCATE TABLE quiz_attempts;  -- ขึ้นอยู่กับ users + quizzes
TRUNCATE TABLE choices;        -- ขึ้นอยู่กับ questions
TRUNCATE TABLE questions;      -- ขึ้นอยู่กับ quizzes
TRUNCATE TABLE quizzes;        -- ขึ้นอยู่กับ subjects
TRUNCATE TABLE subjects;

SET FOREIGN_KEY_CHECKS = 1;

-- ── Step 2: ใส่ subjects ────────────────────────────────────────────────────
INSERT INTO subjects (subject_name) VALUES
('Mathematics'),    -- subject_id = 1
('English'),        -- subject_id = 2
('Social Studies'), -- subject_id = 3
('Programming');    -- subject_id = 4

-- ── Step 3: ใส่ quizzes ─────────────────────────────────────────────────────
INSERT INTO quizzes (subject_id, title, level, total_questions) VALUES
-- Mathematics (subject_id = 1)
(1, 'Math Basic',              'easy', 10),   -- quiz_id = 1
(1, 'Math Advance',            'hard', 10),   -- quiz_id = 2

-- English (subject_id = 2)
(2, 'Eng Basic',               'easy', 10),   -- quiz_id = 3
(2, 'Eng Advance',             'hard', 10),   -- quiz_id = 4

-- Social Studies (subject_id = 3)
(3, 'Social Studies Basic',    'easy', 10),   -- quiz_id = 5
(3, 'Social Studies Advance',  'hard', 10),   -- quiz_id = 6

-- Programming (subject_id = 4)
(4, 'Programming Basic',       'easy', 10),   -- quiz_id = 7
(4, 'Programming Advance',     'hard', 10);   -- quiz_id = 8

SELECT CONCAT('✅ Reset complete: ', COUNT(*), ' subjects inserted') AS status FROM subjects;
SELECT CONCAT('✅ Reset complete: ', COUNT(*), ' quizzes inserted') AS status FROM quizzes;
