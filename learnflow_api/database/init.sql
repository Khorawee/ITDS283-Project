-- init.sql
-- รัน schema ทั้งหมดในไฟล์เดียว
-- ใช้ตอนตั้งค่า DB ครั้งแรก หรือ reset DB ใหม่
-- วิธีรัน: mysql -u root -p learnflow < init.sql

-- สร้าง Database ถ้ายังไม่มี
CREATE DATABASE IF NOT EXISTS learnflow
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- เลือกใช้ Database นี้
USE learnflow;

-- รัน schema ตามลำดับ (FK ต้องสร้างทีหลัง PK เสมอ)
SOURCE database/schema/01_users.sql;
SOURCE database/schema/02_subjects.sql;
SOURCE database/schema/03_quiz_system.sql;
SOURCE database/schema/04_quiz_activity.sql;
SOURCE database/schema/05_ai_analysis.sql;
SOURCE database/schema/06_progress.sql;