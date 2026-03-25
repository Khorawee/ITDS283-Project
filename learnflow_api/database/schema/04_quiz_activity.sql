-- 04_quiz_activity.sql
-- เก็บพฤติกรรมการทำ Quiz ของผู้ใช้
-- ต้องสร้างหลัง users และ quiz_system
-- ข้อมูลในไฟล์นี้คือวัตถุดิบหลักของ AI ทั้งหมด
 
-- บันทึกทุกครั้งที่ผู้ใช้ทำ Quiz 1 ชุด
CREATE TABLE IF NOT EXISTS quiz_attempts (
    attempt_id      INT         NOT NULL AUTO_INCREMENT, --Attempt id
    user_id         INT         NOT NULL, --User id
    quiz_id         INT         NOT NULL, --Quiz id
    score           INT         NOT NULL, --correct score
    total           INT         NOT NULL, --total correct score
    time_spent      FLOAT       NOT NULL DEFAULT, --time to use
    attempt_date    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP, --Date to use

    PRIMARY KEY (attempt_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id)
);

-- บันทึกคำตอบทีละข้อ ใช้คำนวณ AI
CREATE TABLE IF NOT EXISTS user_answers (
    answer_id           INT         NOT NULL AUTO_INCREMENT, --Answer id
    attempt_id          INT         NOT NULL, --where attempt id
    question_id         INT         NOT NULL, --Answer which one
    selected_choice     VARCHAR(1)  NOT NULL, --Selected answer
    is_correct          BOOLEAN     NOT NULL DEFAULT FALSE, --True/False calculate Accuracy
    response_time       FLOAT       NOT NULL DEFAULT 0, --Response Time (seconds) → Calculate Speed
    attempt_count       INT         NOT NULL DEFAULT 1, --How many times do this exercise?
    PRIMARY KEY (answer_id),
    FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(attempt_id),
    FOREIGN KEY (question_id) REFERENCES questions(question_id)
);

-- Index ช่วยให้ AI ดึงข้อมูลรายคนเร็วขึ้น
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts (user_id);
CREATE INDEX idx_quiz_attempts_date ON quiz_attempts (attempt_date);
CREATE INDEX idx_user_answers_attempt_id ON user_answers (attempt_id);