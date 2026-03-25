-- 03_quiz_system.sql
-- เก็บข้อมูล Quiz, คำถาม และตัวเลือก
-- ต้องสร้างหลัง subjects
 
-- ชุดข้อสอบ
CREATE TABLE IF NOT EXISTS quizzes (
    quiz_id         INT             NOT NULL AUTO_INCREMENT, -- Quiz id
    sudject_id      INT             NOT NULL, -- Subject ID
    title           VARCHAR(255)    NOT NULL, -- name title subject
    level           ENUM('easy', 'medium', 'hard') NOT NULL, -- Level in subject
    total_question  INT             NOT NULL DEFAULT 0, -- Total questions

    PRIMARY KEY (quiz_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- คำถามในแต่ละชุด
CREATE TABLE IF NOT EXISTS questions (
    question_id     INT             NOT NULL AUTO_INCREMENT,   --Question id
    quiz_id         INT             NOT NULL,                  --Quiz id
    topic           VARCHAR(100)    NOT NULL,                  --Topic
    question_text   TEXT            NOT NULL,                  --Question text 
    correct_choice  VARCHAR(1)      NOT NULL,                  --Correct choice
    explanation     TEXT            NULL,                      --Explanation
    expected_time   FLOAT           NOT NULL DEFAULT 30,       --Expected_time
 
    PRIMARY KEY (question_id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id)
);

-- ตัวเลือกของแต่ละคำถาม
CREATE TABLE IF NOT EXISTS choices (
    choice_id       INT             NOT NULL AUTO_INCREMENT,   --Choice id
    question_id     INT             NOT NULL,                  --Question_id
    choice_label    VARCHAR(1)      NOT NULL,                  -- A / B / C / D
    choice_text     VARCHAR(500)    NOT NULL,                  --Choice text
 
    PRIMARY KEY (choice_id),
    FOREIGN KEY (question_id) REFERENCES questions(question_id)
);
 
-- Index ช่วยให้ดึงคำถามและตัวเลือกเร็วขึ้น
CREATE INDEX idx_questions_quiz_id ON questions (quiz_id);
CREATE INDEX idx_choices_question_id ON choices (question_id);