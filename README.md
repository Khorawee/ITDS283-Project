# ITDS283-Project
LearnFlow - Adaptive Learning Mobile App
# LearnFlow

Flutter App + Flask API + MySQL + Firebase Auth

---

## สารบัญ

1. [ภาพรวมระบบ](#1-ภาพรวมระบบ)
2. [Bug Fixes ที่แก้ไขแล้ว](#2-bug-fixes-ที่แก้ไขแล้ว)
3. [ตั้งค่า Database — Phase 1](#3-ตั้งค่า-database--phase-1)
4. [ตั้งค่า Flask API — Phase 2](#4-ตั้งค่า-flask-api--phase-2)
5. [ตั้งค่า Flutter App — Phase 3](#5-ตั้งค่า-flutter-app--phase-3)
6. [API Endpoints ทั้งหมด](#6-api-endpoints-ทั้งหมด)
7. [Flutter Services Layer](#7-flutter-services-layer)
8. [Flutter Pages ที่อัปเดต](#8-flutter-pages-ที่อัปเดต)
9. [AI Logic](#9-ai-logic)
10. [Troubleshooting](#10-troubleshooting)
11. [โครงสร้างไฟล์](#11-โครงสร้างไฟล์)

---

## 1. ภาพรวมระบบ

| Component | Technology | หน้าที่ |
|---|---|---|
| Flutter App | Dart / Flutter | UI และ Mobile Application |
| Flask API | Python / Flask | Backend REST API |
| Database | MySQL | เก็บข้อมูล users, quizzes, analytics |
| Auth | Firebase Auth | Login / Register / Token verification |

### Auth Flow

ทุก API call ใช้ Firebase ID Token เป็น authentication โดยอัตโนมัติ

```
Flutter login
  → Firebase Auth
  → getIdToken()
  → Authorization: Bearer <token>
  → Flask @require_auth → verify_id_token()
  → MySQL query
  → Response
```

---

## 2. Bug Fixes ที่แก้ไขแล้ว

| ไฟล์ | Bug เดิม | แก้เป็น |
|---|---|---|
| `database/schema/03_quiz_system.sql` | `sudject_id` (typo) | `subject_id` |
| `database/schema/03_quiz_system.sql` | `total_question` | `total_questions` |
| `database/schema/04_quiz_activity.sql` | `DEFAULT` ไม่มีค่า | `DEFAULT 0` |
| `database/schema/04_quiz_activity.sql` | ขาด comma ใน FOREIGN KEY | เพิ่ม comma |
| `routes/quiz.py` | column name ไม่ตรง schema | แก้ให้ตรงกัน |

---

## 3. ตั้งค่า Database — Phase 1

### 3.1 สร้าง Database และ Tables
```bash
วิธีที่ 1 — MySQL Workbench (แนะนำ ง่ายสุด)

เปิด MySQL Workbench แล้ว connect เข้า server
สร้าง database ก่อน — คลิกขวาที่ SCHEMAS → Create Schema → ตั้งชื่อ learnflow → เลือก charset utf8mb4 → Apply
เปิดไฟล์ schema ทีละไฟล์ด้วย File → Open SQL Script → เลือก 01_users.sql
เลือก learnflow เป็น default schema (ดับเบิลคลิกที่ชื่อ schema ให้ตัวหนา)
กด Execute (สายฟ้า ⚡) → ทำซ้ำกับไฟล์ 02–06 ตามลำดับ
```

> ⚠️ ต้องรันตามลำดับ 01 → 06 เสมอ เพราะ Foreign Key ต้องอ้างอิง table ที่สร้างก่อน

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS learnflow \
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

mysql -u root -p learnflow < database/schema/01_users.sql
mysql -u root -p learnflow < database/schema/02_subjects.sql
mysql -u root -p learnflow < database/schema/03_quiz_system.sql
mysql -u root -p learnflow < database/schema/04_quiz_activity.sql
mysql -u root -p learnflow < database/schema/05_ai_analysis.sql
mysql -u root -p learnflow < database/schema/06_progress.sql
```

### 3.2 ใส่ข้อมูลเริ่มต้น (Seed data)

> ⚠️ ต้องรันตามลำดับ seed_subjects → seed_quizzes → seed_questions เสมอ

```bash
mysql -u root -p learnflow < database/seeds/seed_subjects.sql
mysql -u root -p learnflow < database/seeds/seed_quizzes.sql
python database/seeds/seed_questions.py
```

---

## 4. ตั้งค่า Flask API — Phase 2

### 4.1 สร้าง Firebase Service Account Key

Flask ต้องการ key นี้เพื่อ verify Firebase token จาก Flutter

1. ไปที่ **Firebase Console → Project Settings → Service accounts**
2. คลิก **Generate new private key**
3. วางไฟล์ที่ได้ไว้ที่ `learnflow_api/config/serviceAccountKey.json`

> ⚠️ อย่า commit ไฟล์นี้ขึ้น git เด็ดขาด — เพิ่มใน `.gitignore`

### 4.2 ตั้งค่าไฟล์ .env

```bash
cd learnflow_api
cp .env.example .env
```

แก้ไขค่าใน `.env` ให้ครบ:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password   # ← ใส่รหัสผ่านจริง
DB_NAME=learnflow

FIREBASE_CREDENTIALS=config/serviceAccountKey.json

FLASK_ENV=development
SECRET_KEY=any_random_string_here
```

### 4.3 ติดตั้ง dependencies และรัน API

```bash
cd learnflow_api

# สร้าง virtual environment (แนะนำ)
python -m venv venv
source venv/bin/activate       # macOS / Linux
# venv\Scripts\activate        # Windows

pip install -r requirements.txt

python app.py
```

> ✅ ถ้าสำเร็จจะเห็น: `LearnFlow API is running` ที่ `http://0.0.0.0:5000`

---

## 5. ตั้งค่า Flutter App — Phase 3

### 5.1 ตั้งค่า baseUrl ใน api_service.dart

เปิดไฟล์ `lib/services/api_service.dart` แล้วเลือก URL ให้ตรงกับ device:

| Device / Platform | baseUrl |
|---|---|
| Android Emulator | `http://10.0.2.2:5000` |
| iOS Simulator / Web | `http://localhost:5000` |
| Physical device (same WiFi) | `http://192.168.x.x:5000` |
| Production Server | `https://your-domain.com` |

```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

> Physical device: รัน `ipconfig` (Windows) หรือ `ifconfig` (Mac/Linux) เพื่อดู IP จริง

### 5.2 อนุญาต HTTP สำหรับ Android

> สำหรับ development เท่านั้น — production ใช้ HTTPS ไม่ต้องทำขั้นตอนนี้

เปิดไฟล์ `android/app/src/main/AndroidManifest.xml` แล้วเพิ่ม attribute นี้ใน `<application>` tag:

```xml
android:usesCleartextTraffic="true"
```

### 5.3 รัน Flutter App

```bash
cd learnflow_flutter

flutter pub get
flutter run

# หรือเลือก device:
flutter run -d android   # Android emulator
flutter run -d ios       # iOS simulator
flutter run -d chrome    # Web
```

---

## 6. API Endpoints ทั้งหมด

| Method | Endpoint | หน้า Flutter |
|---|---|---|
| POST | `/api/auth/login` | LoginPage (Google) |
| POST | `/api/auth/register` | RegisterPage |
| GET | `/api/quizzes` | QuizPage |
| GET | `/api/quiz/<id>` | BasicMathPage |
| POST | `/api/quiz/submit` | BasicMathPage (Finish) |
| GET | `/api/result/<attempt_id>` | ResultPage |
| GET | `/api/review/<attempt_id>` | ReviewAnswerPage |
| GET | `/api/dashboard` | AnalyticsPage |
| GET | `/api/profile` | ProfilePage, HomePage |
| GET | `/api/recommendations` | HomePage |

### ตัวอย่าง Request

```bash
# ทดสอบ API ด้วย curl (ต้องมี Firebase token จริง)
curl -X GET http://localhost:5000/api/quizzes \
  -H "Authorization: Bearer <firebase_id_token>"

# ทดสอบว่า server ทำงาน
curl http://localhost:5000/
# ควรได้: {"message": "LearnFlow API is running"}
```

### ตัวอย่าง Submit Quiz

```json
POST /api/quiz/submit
{
  "quiz_id": 1,
  "time_spent": 420,
  "answers": [
    {
      "question_id": 1,
      "selected_choice": "B",
      "response_time": 28.5,
      "attempt_count": 1
    }
  ]
}
```

---

## 7. Flutter Services Layer

ไฟล์ทั้งหมดอยู่ใน `lib/services/`

| ไฟล์ | หน้าที่ |
|---|---|
| `api_service.dart` | HTTP client กลาง — แนบ Firebase Token ทุก request อัตโนมัติ |
| `auth_service.dart` | Sync Google/Email login → MySQL |
| `quiz_service.dart` | `getQuizzes`, `getQuizDetail`, `submitQuiz` |
| `result_service.dart` | `getResult`, `getReview` |
| `analytics_service.dart` | `getDashboard`, `getAnalysis` |
| `profile_service.dart` | `getProfile` |
| `recommendation_service.dart` | `getRecommendations` |

### ตัวอย่างการใช้งาน

```dart
// โหลด quiz list
final quizzes = await QuizService.getQuizzes();

// submit คำตอบ
final result = await QuizService.submitQuiz(
  quizId: 1,
  timeSpent: 420,
  answers: [...],
);

// โหลด dashboard analytics
final dashboard = await AnalyticsService.getDashboard();
```

---

## 8. Flutter Pages ที่อัปเดต

| หน้า | API ที่เชื่อม |
|---|---|
| `LoginPage` | `POST /api/auth/login` (Google sync) |
| `RegisterPage` | `POST /api/auth/register` |
| `QuizPage` | `GET /api/quizzes` |
| `DetailBasicMathPage` | รับ/ส่ง `quiz_id` ผ่าน route arguments |
| `BasicMathPage` | `GET /api/quiz/<id>`, `POST /api/quiz/submit` |
| `ResultPage` | `GET /api/result/<attempt_id>` |
| `ReviewAnswerPage` | `GET /api/review/<attempt_id>` |
| `AnalyticsPage` | `GET /api/dashboard` (Bar/Line/Radar chart) |
| `ProfilePage` | `GET /api/profile` + Firebase `signOut` |
| `HomePage` | `GET /api/profile` + `GET /api/recommendations` |

---

## 9. AI Logic

คำนวณใน `services/ai_service.py` และ `services/progress_service.py`

| สูตร | รายละเอียด |
|---|---|
| Understanding | `(0.6 × Accuracy) + (0.4 × Speed)` |
| Mastery | `SUM(Understanding) / Total Attempts` |
| Level: Weak | Mastery < 0.60 |
| Level: Improving | Mastery 0.60 – 0.80 |
| Level: Strong | Mastery > 0.80 |

Speed คำนวณจาก `expected_time / response_time` (ค่าสูงสุด 1.0)

---

## 10. Troubleshooting

### Connection refused / SocketException

- ตรวจสอบว่า Flask API รันอยู่: `python app.py`
- ตรวจสอบ `baseUrl` ใน `api_service.dart` ตรงกับ device หรือไม่
- Android emulator ต้องใช้ `10.0.2.2` ไม่ใช่ `localhost`

### 401 Unauthorized

- Firebase ID Token หมดอายุ (อายุ 1 ชั่วโมง) — Flutter จะ refresh อัตโนมัติ
- ตรวจสอบว่า `serviceAccountKey.json` ถูกต้องและอยู่ใน path ที่กำหนด

### MySQL connection error

- ตรวจสอบค่าใน `.env` ว่า `DB_PASSWORD` ถูกต้อง
- ตรวจสอบว่า MySQL service รันอยู่
- ตรวจสอบว่า database `learnflow` ถูกสร้างแล้ว

### Cleartext HTTP blocked (Android)

- เพิ่ม `android:usesCleartextTraffic="true"` ใน `AndroidManifest.xml`

### No quizzes / No recommendations

- ตรวจสอบว่ารัน seed data ครบแล้ว: `seed_subjects.sql` → `seed_quizzes.sql` → `seed_questions.py`
- Recommendations จะปรากฏหลังจาก user ทำ quiz ครั้งแรกเสร็จ

---

## 11. โครงสร้างไฟล์

### API

```
learnflow_api/
├── app.py                         # Flask entry point
├── requirements.txt
├── .env.example
├── config/
│   ├── db_config.py               # MySQL connection
│   ├── firebase_config.py         # Firebase Admin SDK init
│   └── serviceAccountKey.json    # ⚠️ ไม่รวมใน git
├── middleware/
│   └── auth_middleware.py         # @require_auth decorator
├── routes/
│   ├── auth.py                    # POST /api/auth/*
│   ├── quiz.py                    # GET/POST /api/quiz*
│   ├── result.py                  # GET /api/result*, /api/review*
│   ├── analysis.py                # GET /api/analysis, /api/dashboard
│   ├── recommendation.py          # GET /api/recommendations
│   └── profile.py                 # GET /api/profile
├── services/
│   ├── ai_service.py              # สูตรคำนวณ Understanding / Mastery
│   └── progress_service.py        # update topic_analysis + progress
└── database/
    ├── init.sql
    ├── schema/
    │   ├── 01_users.sql
    │   ├── 02_subjects.sql
    │   ├── 03_quiz_system.sql      # [FIXED]
    │   ├── 04_quiz_activity.sql    # [FIXED]
    │   ├── 05_ai_analysis.sql
    │   └── 06_progress.sql
    └── seeds/
        ├── seed_subjects.sql
        ├── seed_quizzes.sql
        └── seed_questions.py
```

### Flutter

```
lib/
├── main.dart
├── firebase_options.dart
├── services/
│   ├── api_service.dart           # HTTP client + Firebase token
│   ├── auth_service.dart
│   ├── quiz_service.dart
│   ├── result_service.dart
│   ├── analytics_service.dart
│   ├── profile_service.dart
│   └── recommendation_service.dart
└── pages/
    ├── SplashScreen.dart
    ├── OnboardingScreen.dart
    ├── LoginPage.dart             # [UPDATED]
    ├── RegisterPage.dart          # [UPDATED]
    ├── ForgotPasswordPage.dart
    ├── HomePage.dart              # [UPDATED]
    ├── QuizPage.dart              # [UPDATED]
    ├── DetailBasicMathPage.dart   # [UPDATED]
    ├── BasicMathPage.dart         # [UPDATED]
    ├── ResultPage.dart            # [UPDATED]
    ├── ReviewAnswerPage.dart      # [UPDATED]
    ├── Analyticspage.dart         # [UPDATED]
    ├── Profilepage.dart           # [UPDATED]
    ├── Reminderpage.dart
    └── ContactUsPage.dart
```