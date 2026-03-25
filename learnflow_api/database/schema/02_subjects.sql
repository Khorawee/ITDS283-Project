-- 02_subjects.sql
-- เก็บข้อมูลวิชาทั้งหมด ต้องสร้างก่อน quizzes
CREATE TABLE IF NOT EXISTS subjects (
    subject_id      INT             NOT NULL AUTO_INCREMENT, --Subject id
    subject_name    VARCHAR(100)    NOT NULL, -- Name subject
    PRIMARY KEY (subject_id)
);