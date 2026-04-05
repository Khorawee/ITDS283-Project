-- 04_quiz_activity.sql  [FIXED]
-- แก้ไข: DEFAULT ไม่มีค่า → DEFAULT 0, ขาด comma ระหว่าง FOREIGN KEY

CREATE TABLE IF NOT EXISTS quiz_attempts (
    attempt_id      INT         NOT NULL AUTO_INCREMENT,
    user_id         INT         NOT NULL,
    quiz_id         INT         NOT NULL,
    score           INT         NOT NULL DEFAULT 0,
    total           INT         NOT NULL DEFAULT 0,
    time_spent      FLOAT       NOT NULL DEFAULT 0,            -- FIX: DEFAULT ไม่มีค่า → DEFAULT 0
    attempt_date    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (attempt_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),           -- FIX: เพิ่ม comma
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id)
);

CREATE TABLE IF NOT EXISTS user_answers (
    answer_id           INT         NOT NULL AUTO_INCREMENT,
    attempt_id          INT         NOT NULL,
    question_id         INT         NOT NULL,
    selected_choice     VARCHAR(1)  NOT NULL,
    is_correct          BOOLEAN     NOT NULL DEFAULT FALSE,
    response_time       FLOAT       NOT NULL DEFAULT 0,
    attempt_count       INT         NOT NULL DEFAULT 1,

    PRIMARY KEY (answer_id),
    FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(attempt_id),
    FOREIGN KEY (question_id) REFERENCES questions(question_id)
);

CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts (user_id);
CREATE INDEX idx_quiz_attempts_date ON quiz_attempts (attempt_date);
CREATE INDEX idx_user_answers_attempt_id ON user_answers (attempt_id);
