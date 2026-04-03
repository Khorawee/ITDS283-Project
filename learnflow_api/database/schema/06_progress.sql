USE learnflow;
-- 06_progress.sql
-- เก็บพัฒนาการรายวัน ใช้สร้าง Line Chart 7 วัน
-- ต้องสร้างหลัง users
-- Flask จะ INSERT/UPDATE ทุกวันหลังผู้ใช้ทำ Quiz

CREATE TABLE IF NOT EXISTS progress (
    progress_id         INT         NOT NULL AUTO_INCREMENT,   -- Progress id 
    user_id             INT         NOT NULL,                  -- Whose is it?
    date                DATE        NOT NULL,                  -- Date
    avg_understanding   FLOAT       NOT NULL DEFAULT 0,        -- Understanding the average of that day

    PRIMARY KEY (progress_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY uq_user_date (user_id, date) -- 1 user can have 1 record per day
);

-- Index ช่วยให้ดึงข้อมูล 7 วันย้อนหลังเร็วขึ้น
CREATE INDEX idx_progress_user_date ON progress (user_id, date);