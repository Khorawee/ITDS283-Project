-- 05_ai_analysis.sql
-- เก็บผลการวิเคราะห์และคำแนะนำจาก AI
-- ต้องสร้างหลัง users และ subjects
 
-- ผลการวิเคราะห์รายวิชา คำนวณจาก user_answers ย้อนหลัง 7 วัน
CREATE TABLE IF NOT EXISTS topic_analysis (
    analysis_id         INT             NOT NULL AUTO_INCREMENT, --Analysis id
    user_id             INT             NOT NULL, --Whose is it?
    subject_id          INT             NOT NULL, --Which subject?
    topic               VARCHAR(100)    NOT NULL, --Subtopic
    accuracy            FLOAT           NOT NULL DEFAULT 0, --Accuracy Score (0-1)
    speed               FLOAT           NOT NULL DEFAULT 0, --Speed Score (0-1)
    understanding       FLOAT           NOT NULL DEFAULT 0, --Understanding = (0.6 x Accuracy) + (0.4 x Speed)
    mastery             FLOAT           NOT NULL DEFAULT 0, --Topic Mastery = SUM(Understanding) / Attempts
    Level               ENUM('Weak', 'Improving', 'Strong') NOT NULL DEFAULT 'Weak', --Level of understanding
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, --Last updated

    PRIMARY KEY (analysis_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    UNIQUE KEY uq_user_subject_topic (user_id, subject_id, topic) -- 1 user มีได้ 1 record ต่อ topic
);

-- คำแนะนำการเรียนรายวิชา เรียงจาก mastery ต่ำสุดก่อน
CREATE TABLE IF NOT EXISTS recommendations (
    rec_id          INT             NOT NULL AUTO_INCREMENT,   --Referral code
    user_id         INT             NOT NULL,                  --Whose is it?
    subject_id      INT             NOT NULL,                  --Which subject?
    topic           VARCHAR(100)    NOT NULL,                  --Recommended topics
    action          ENUM('ฝึกเพิ่ม', 'ทบทวน', 'ผ่าน') NOT NULL, --Advice
    mastery         FLOAT           NOT NULL DEFAULT 0,        --Mastery while introducing
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP, --Recommended date

    PRIMARY KEY (rec_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Index ช่วยให้ดึงผลวิเคราะห์รายคนเร็วขึ้น
CREATE INDEX idx_topic_analysis_user_id ON topic_analysis (user_id);
CREATE INDEX idx_recommendations_user_id ON recommendations (user_id);