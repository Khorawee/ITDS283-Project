-- seed_quizzes.sql
-- ใส่ชุดข้อสอบลง DB
-- รันหลัง seed_subjects.sql และก่อน seed_questions.py
-- หมายเหตุ: seed_subjects.sql จะ TRUNCATE quizzes ไปแล้ว ไม่ต้อง TRUNCATE ซ้ำ

USE learnflow;

INSERT INTO quizzes (subject_id, title, level, total_questions) VALUES
-- Mathematics (subject_id = 1)
(1, 'Math Basic',              'easy', 10),   -- quiz_id = 1
(1, 'Math Advance',            'hard', 10),   -- quiz_id = 2

-- English (subject_id = 2)
(2, 'Eng Basic',               'easy', 10),   -- quiz_id = 3
(2, 'Eng Advance',             'hard', 10),   -- quiz_id = 4

-- Social Studies (subject_id = 3) — มัธยม
(3, 'Social Studies Basic',    'easy', 10),   -- quiz_id = 5
(3, 'Social Studies Advance',  'hard', 10),   -- quiz_id = 6

-- Programming (subject_id = 4) — นักศึกษา
(4, 'Programming Basic',       'easy', 10),   -- quiz_id = 7
(4, 'Programming Advance',     'hard', 10);   -- quiz_id = 8