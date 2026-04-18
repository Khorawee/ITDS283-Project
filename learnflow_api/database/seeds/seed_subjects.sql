-- seed_subjects.sql
-- ใส่วิชาทั้งหมดลง DB ก่อนเริ่มระบบ
-- รันก่อน seed_quizzes.sql เสมอ

USE learnflow;

-- ล้างข้อมูลเก่าออกก่อน (ปิด FK check ชั่วคราวเพื่อ TRUNCATE ได้)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE choices;
TRUNCATE TABLE questions;
TRUNCATE TABLE quizzes;
TRUNCATE TABLE subjects;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO subjects (subject_name) VALUES
('Mathematics'),    -- subject_id = 1
('English'),        -- subject_id = 2
('Social Studies'), -- subject_id = 3
('Programming');    -- subject_id = 4