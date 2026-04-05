USE learnflow;
-- 01_users.sql
-- เก็บข้อมูลผู้ใช้ทุกคน ต้องสร้างก่อนทุก table

CREATE TABLE IF NOT EXISTS users (
    user_id         INT             NOT NULL AUTO_INCREMENT,   -- รหัสผู้ใช้
    first_name      VARCHAR(100)    NOT NULL,                  -- ชื่อจริง
    last_name       VARCHAR(100)    NOT NULL,                  -- นามสกุล
    email           VARCHAR(255)    NOT NULL UNIQUE,           -- อีเมล Login
    birth_date      DATE            NULL,                      -- วันเกิด
    phone           VARCHAR(20)     NULL,                      -- เบอร์โทรศัพท์
    firebase_uid    VARCHAR(128)    NOT NULL UNIQUE,           -- UID จาก Firebase
    auth_provider   ENUM('google', 'email') NOT NULL DEFAULT 'google', -- วิธี Login
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP, -- วันที่สมัคร

    PRIMARY KEY (user_id)
);

-- Index ช่วยให้ค้นหาเร็วขึ้นตอน Login
CREATE INDEX idx_users_firebase_uid ON users (firebase_uid);
CREATE INDEX idx_users_email ON users (email);