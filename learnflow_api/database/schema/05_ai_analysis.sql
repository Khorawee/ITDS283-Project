USE learnflow;
-- 05_ai_analysis.sql  [FIXED + ON DELETE CASCADE]

CREATE TABLE IF NOT EXISTS topic_analysis (
    analysis_id     INT             NOT NULL AUTO_INCREMENT,
    user_id         INT             NOT NULL,
    subject_id      INT             NOT NULL,
    topic           VARCHAR(100)    NOT NULL,
    accuracy        FLOAT           NOT NULL DEFAULT 0,
    speed           FLOAT           NOT NULL DEFAULT 0,
    understanding   FLOAT           NOT NULL DEFAULT 0,
    mastery         FLOAT           NOT NULL DEFAULT 0,
    level           ENUM('Weak', 'Improving', 'Strong') NOT NULL DEFAULT 'Weak',
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (analysis_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_subject_topic (user_id, subject_id, topic)
);

CREATE TABLE IF NOT EXISTS recommendations (
    rec_id      INT             NOT NULL AUTO_INCREMENT,
    user_id     INT             NOT NULL,
    subject_id  INT             NOT NULL,
    topic       VARCHAR(100)    NOT NULL,
    action      ENUM('ฝึกเพิ่ม', 'ทบทวน', 'ผ่าน') NOT NULL,
    mastery     FLOAT           NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (rec_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_subject_rec (user_id, subject_id, topic)
);

CREATE INDEX idx_topic_analysis_user_id  ON topic_analysis  (user_id);
CREATE INDEX idx_recommendations_user_id ON recommendations (user_id);
