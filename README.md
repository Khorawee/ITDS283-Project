# LearnFlow

Flutter + Flask + MySQL + Firebase Auth

---

## โครงสร้างไฟล์

### API (`learnflow_api/`)

```
learnflow_api/
├── app.py                        # entry point สร้าง Flask app และลงทะเบียน blueprints
├── requirements.txt              # Python dependencies
├── .env.example                  # ตัวอย่างค่า config (copy เป็น .env)
│
├── config/
│   ├── db_config.py              # สร้าง MySQL connection จาก .env
│   ├── firebase_config.py        # init Firebase Admin SDK
│   └── serviceAccountKey.json   # ⚠️ Firebase key — ไม่รวมใน git
│
├── middleware/
│   └── auth_middleware.py        # @require_auth ตรวจ Firebase token ทุก request
│
├── routes/
│   ├── auth.py                   # POST /api/auth/login, /api/auth/register
│   ├── quiz.py                   # GET /api/quizzes, /api/quiz/<id>, /api/quiz/<id>/attempted
│   │                             # POST /api/quiz/submit
│   ├── result.py                 # GET /api/result/<attempt_id>, /api/review/<attempt_id>
│   ├── analysis.py               # GET /api/analysis, /api/dashboard
│   ├── recommendation.py         # GET /api/recommendations
│   └── profile.py                # GET /api/profile
│
├── services/
│   ├── ai_service.py             # คำนวณ Understanding, Mastery, Level, Action
│   └── progress_service.py       # update topic_analysis และ progress รายวัน
│
└── database/
    ├── init.sql                  # รัน schema ทั้งหมดในคำสั่งเดียว
    ├── schema/
    │   ├── 01_users.sql          # table users (firebase_uid, email, name)
    │   ├── 02_subjects.sql       # table subjects (Mathematics, English, ...)
    │   ├── 03_quiz_system.sql    # table quizzes, questions, choices
    │   ├── 04_quiz_activity.sql  # table quiz_attempts, user_answers
    │   ├── 05_ai_analysis.sql    # table topic_analysis, recommendations
    │   └── 06_progress.sql       # table progress (avg_understanding รายวัน)
    └── seeds/
        ├── seed_subjects.sql     # ข้อมูล subjects เริ่มต้น
        ├── seed_quizzes.sql      # ข้อมูล quizzes เริ่มต้น
        └── seed_questions.py     # สร้างคำถามและตัวเลือกลง DB
```

### Flutter (`lib/`)

```
lib/
├── main.dart                     # entry point, Firebase init, Notification init,
│                                 # global locale state (LearnFlowApp.setLocale)
├── firebase_options.dart         # config Firebase สำหรับแต่ละ platform
│
├── services/
│   ├── api_service.dart          # HTTP client กลาง แนบ Firebase token ทุก request
│   ├── auth_service.dart         # sync user หลัง login/register → MySQL
│   ├── quiz_service.dart         # getQuizzes, getQuizDetail, submitQuiz
│   ├── result_service.dart       # getResult, getReview, hasAttempted
│   ├── analytics_service.dart    # getDashboard, getAnalysis
│   ├── profile_service.dart      # getProfile
│   ├── recommendation_service.dart  # getRecommendations
│   └── notification_service.dart    # local notification (Android/iOS เท่านั้น)
│                                     # Windows/Web → skip อัตโนมัติ
└── pages/
    ├── SplashScreen.dart         # หน้า loading → onboarding
    ├── OnboardingScreen.dart     # สไลด์แนะนำ app 3 หน้า
    ├── LoginPage.dart            # login email/password และ Google → sync API
    ├── RegisterPage.dart         # register email → Firebase + sync API
    ├── ForgotPasswordPage.dart   # ส่ง reset password email
    ├── HomePage.dart             # summary stats + recommended quizzes จาก API
    ├── QuizPage.dart             # รายการ quiz ทั้งหมด + search + filter
    ├── DetailBasicMathPage.dart  # รายละเอียด quiz ซ่อนปุ่ม Retake ถ้ายังไม่เคยทำ
    ├── BasicMathPage.dart        # ทำ quiz โหลดคำถามจาก API + submit คำตอบ
    ├── ResultPage.dart           # ผลคะแนน, grade, badge จาก API
    ├── ReviewAnswerPage.dart     # เฉลยทุกข้อจาก API
    ├── Analyticspage.dart        # กราฟ Bar/Line/Radar จาก API
    ├── Profilepage.dart          # ข้อมูล user, เปลี่ยนภาษา (EN/TH), toggle notification
    ├── Reminderpage.dart         # รายการการแจ้งเตือน
    └── ContactUsPage.dart        # ข้อมูลติดต่อผู้พัฒนา
```

---

## ขั้นตอนการรัน

### Phase 1 — ตั้งค่า Database

เปิด **MySQL Workbench** → connect → เปิดไฟล์ทีละไฟล์ด้วย File → Open SQL Script → Execute ตามลำดับ

```
01_users.sql → 02_subjects.sql → 03_quiz_system.sql
→ 04_quiz_activity.sql → 05_ai_analysis.sql → 06_progress.sql
```

> ⚠️ ต้องรันตามลำดับ 01 → 06 เพราะ Foreign Key อ้างอิง table ที่สร้างก่อน

จากนั้นใส่ข้อมูลเริ่มต้น (เปิดใน Workbench แล้ว Execute):

```
seed_subjects.sql → seed_quizzes.sql
```

แล้วรัน seed_questions ใน terminal:

```bash
python database/seeds/seed_questions.py
```

---

### Phase 2 — ตั้งค่า Flask API

**ขั้นที่ 1** — สร้าง Firebase Service Account Key

1. ไปที่ **Firebase Console → Project Settings → Service accounts**
2. คลิก **Generate new private key**
3. วางไฟล์ที่ได้ไว้ที่ `learnflow_api/config/serviceAccountKey.json`

> ⚠️ อย่า commit ไฟล์นี้ขึ้น git — เพิ่มใน `.gitignore`

**ขั้นที่ 2** — สร้างไฟล์ `.env`

```bash
cd learnflow_api
cp .env.example .env
```

แก้ไขค่าใน `.env`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=learnflow

FIREBASE_CREDENTIALS=config/serviceAccountKey.json

FLASK_ENV=development
SECRET_KEY=your_secret_key
```

สร้าง `SECRET_KEY` แบบ random ด้วยคำสั่งนี้ใน terminal:

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

จะได้ค่าออกมา เช่น:

```
a3f8c2d1e4b7a9f0c3d6e8b1a2c4d5e7f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4
```

copy ค่านั้นไปใส่ใน `.env`:

```env
SECRET_KEY=a3f8c2d1e4b7a9f0c3d6e8b1a2c4d5e7f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4
```

**ขั้นที่ 3** — ติดตั้งและรัน

```bash
cd learnflow_api

python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux

pip install -r requirements.txt

python app.py
```

> ✅ ถ้าสำเร็จจะเห็น: `LearnFlow API is running` ที่ `http://0.0.0.0:5000`

---

### Phase 3 — ตั้งค่า Flutter App

**ขั้นที่ 1** — ตั้งค่า baseUrl

เปิดไฟล์ `lib/services/api_service.dart` แล้วเปลี่ยน `baseUrl` ให้ตรงกับ device:

| Device | baseUrl |
|---|---|
| Android Emulator | `http://10.0.2.2:5000` |
| iOS Simulator / Web | `http://localhost:5000` |
| Physical device (WiFi เดียวกัน) | `http://192.168.x.x:5000` |

> หา IP จริงด้วย `ipconfig` (Windows) หรือ `ifconfig` (Mac/Linux)

**ขั้นที่ 2** — อนุญาต HTTP บน Android (development เท่านั้น)

เปิด `android/app/src/main/AndroidManifest.xml` เพิ่มใน `<application>` tag:

```xml
android:usesCleartextTraffic="true"
```

**ขั้นที่ 3** — รัน Flutter

```bash
flutter pub get
flutter run
```

---

## Troubleshooting

| ปัญหา | วิธีแก้ |
|---|---|
| Connection refused | ตรวจสอบว่า `python app.py` รันอยู่ และ `baseUrl` ถูกต้อง |
| Android ใช้ `localhost` ไม่ได้ | เปลี่ยนเป็น `10.0.2.2` |
| 401 Unauthorized | ตรวจสอบ `serviceAccountKey.json` ถูก path หรือไม่ |
| MySQL connection error | ตรวจสอบ `DB_PASSWORD` ใน `.env` และ MySQL service รันอยู่ |
| Cleartext HTTP blocked | เพิ่ม `usesCleartextTraffic="true"` ใน `AndroidManifest.xml` |
| ไม่มี quiz ขึ้น | รัน seed data ครบทั้ง 3 ไฟล์ตามลำดับ |
| Recommendations ว่างเปล่า | ต้องทำ quiz อย่างน้อย 1 ครั้งก่อน |
