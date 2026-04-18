# 📚 LearnFlow - ระบบฝึกสอบออนไลน์

ระบบเรียนรู้ที่ใช้ **Flutter** (Mobile) + **Flask** (Backend) + **MySQL** (Database) + **Firebase** (Auth)

---

## 🎯 ฟีเจอร์หลัก

✅ **Authentication** - ล็อกอินด้วย Google / Email + Firebase  
✅ **Quiz Management** - ทำข้อสอบ, จับเวลา, เก็บประวัติ  
✅ **Analytics** - แสดงกราฟ (Bar, Radar, Line) วิเคราะห์ผลสอบ  
✅ **Progress Tracking** - ติดตามความก้าวหน้ารายวัน  
✅ **Smart Recommendations** - แนะนำข้อสอบตามความอ่อนแอ  
✅ **Multi-language** - ไทย / English  
✅ **Offline Support** - เก็บข้อมูล locally (Hive storage)  

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.0+, Dart |
| **Backend** | Flask 3.0, Python 3.9+ |
| **Database** | MySQL 8.0 |
| **Authentication** | Firebase Auth |
| **Caching** | In-memory + Hive (offline) |
| **HTTP Client** | http 1.2.0 with retry logic |

---

## 📁 โครงสร้างโปรเจค

```
ITDS283-Project/
├── learnflow/                    # Flutter App
│   ├── lib/
│   │   ├── main.dart            # Entry point
│   │   ├── services/            # API clients + utilities
│   │   │   ├── api_service.dart         # HTTP client (retry, timeout)
│   │   │   ├── cache_service.dart       # In-memory caching (TTL)
│   │   │   ├── local_storage_service.dart  # Offline storage (Hive)
│   │   │   ├── profile_service.dart     # Profile API
│   │   │   ├── quiz_service.dart        # Quiz API
│   │   │   ├── analytics_service.dart   # Analytics API
│   │   │   └── notification_service.dart # Local notifications
│   │   ├── pages/               # UI pages
│   │   │   ├── SplashScreen.dart
│   │   │   ├── LoginPage.dart
│   │   │   ├── HomePage.dart            # Dashboard
│   │   │   ├── QuizPage.dart            # Quiz list
│   │   │   ├── QuizPlayPage.dart        # Quiz taking
│   │   │   ├── ResultPage.dart          # Quiz result
│   │   │   ├── Analyticspage.dart       # Charts
│   │   │   ├── Profilepage.dart         # User profile
│   │   │   └── ... (6 more pages)
│   │   └── widgets/             # Reusable components
│   ├── pubspec.yaml             # Dependencies
│   └── android/                 # Android native
│
├── learnflow_api/               # Flask API
│   ├── app.py                   # Entry point
│   ├── requirements.txt          # Python packages
│   ├── config/
│   │   ├── db_config.py         # MySQL connection pooling
│   │   ├── firebase_config.py   # Firebase init
│   │   └── serviceAccountKey.json  # ⚠️ Keep secret!
│   ├── middleware/
│   │   └── auth_middleware.py   # Firebase token verification
│   ├── routes/                  # API endpoints
│   │   ├── auth.py              # Login/Register
│   │   ├── profile.py           # User profile + stats
│   │   ├── quiz.py              # Quiz operations
│   │   ├── result.py            # Quiz results
│   │   ├── analysis.py          # Analytics
│   │   └── recommendation.py    # Recommendations
│   ├── services/                # Business logic
│   │   ├── ai_service.py        # Score calculation
│   │   └── progress_service.py  # Progress tracking
│   └── database/
│       ├── init.sql             # Database schema
│       ├── schema/              # 6 SQL files
│       └── seeds/
│           └── seed_questions.py # Generate quiz data
│
└── README.md / README_TH.md
```

---

## 📖 ชี้แจงไฟล์ (Backend)

| ไฟล์ | ความหมาย |
|---|---|
| `app.py` | สร้าง Flask app + ลงทะเบียน API routes ทั้งหมด |
| `auth_middleware.py` | ตรวจ Firebase token ทุก request ที่ต้องการ login |
| `db_config.py` | สร้าง MySQL connection pooling (ประสิทธิภาพสูง) |
| `firebase_config.py` | ตั้งค่า Firebase Admin SDK |
| `routes/auth.py` | Endpoint login/register + input validation |
| `routes/quiz.py` | Endpoint ดึง quiz + ส่งคำตอบ + เก็บประวัติ |
| `routes/profile.py` | Endpoint ดึง user profile + สถิติทั้งหมด |
| `routes/analysis.py` | Endpoint dashboard + growth chart + analysis |
| `routes/result.py` | Endpoint ดึงผลลัพธ์ quiz attempt |
| `services/ai_service.py` | คำนวณ Accuracy, Speed, Understanding |
| `services/progress_service.py` | Update topic_analysis + daily progress |

---

## 📖 ชี้แจงไฟล์ (Frontend)

| ไฟล์ | ความหมาย |
|---|---|
| `main.dart` | Entry point + Firebase init + Notifications + Locale state |
| `api_service.dart` | HTTP client กลาง (Token auto-refresh, Retry 3x, Timeout 15s) |
| `cache_service.dart` | In-memory cache with TTL expiration (5-10 นาที) |
| `local_storage_service.dart` | Hive local storage เพื่อ offline data persistence |
| `profile_service.dart` | API client ดึง profile + cache 10 นาที |
| `quiz_service.dart` | API client ดึง quiz + ส่งคำตอบ |
| `analytics_service.dart` | API client ดึง dashboard + growth + analysis |
| `QuizPlayPage.dart` | หน้าทำข้อสอบ (timer, local cache, submit) |
| `ResultPage.dart` | หน้าแสดงผลลัพธ์ + score + grade |
| `Profilepage.dart` | หน้า profile user + settings + edit info |
| `Analyticspage.dart` | หน้าแสดงกราฟ analytics (Bar, Radar, Line) |

---

## 🚀 วิธีการรัน (Complete Guide)

### **ขั้นตอนที่ 1: ตั้งค่า Database** 🗄️

**1. เปิด MySQL Workbench → Connect**

**2. สร้าง Schema** (รัน SQL files ตามลำดับ)
```bash
File → Open SQL Script → เลือกไฟล์ลำดับนี้:
01_users.sql 
→ 02_subjects.sql 
→ 03_quiz_system.sql 
→ 04_quiz_activity.sql 
→ 05_ai_analysis.sql 
→ 06_progress.sql

Execute แต่ละไฟล์ (Ctrl+Shift+Enter)
```

**3. ใส่ข้อมูลเริ่มต้น**
```bash
seed_subjects.sql → Execute
seed_quizzes.sql → Execute
```

**4. สร้างข้อสอบ (Python)**
```bash
cd learnflow_api
python database/seeds/seed_questions.py
```

---

### **ขั้นตอนที่ 2: ตั้งค่า Flask API** 🔧

**1. Firebase Service Account Key**
```
Firebase Console 
→ Project Settings 
→ Service Accounts 
→ Generate New Private Key
→ วางไฟล์ที่ learnflow_api/config/serviceAccountKey.json
```

⚠️ **อย่า commit ไฟล์นี้!** เพิ่มใน `.gitignore`

**2. สร้างไฟล์ `.env`**
```bash
cd learnflow_api
cp .env.example .env
```

**3. แก้ไข `.env`** (เปิดด้วย code editor)
```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=learnflow

# Firebase
FIREBASE_CREDENTIALS=config/serviceAccountKey.json

# Flask
FLASK_ENV=development
SECRET_KEY=your_secret_key_here
```

สร้าง SECRET_KEY:
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```
Copy ค่าที่ได้ไปใส่ใน `.env`

**4. ติดตั้งและรัน**
```bash
cd learnflow_api

# สร้าง virtual environment
python -m venv venv
venv\Scripts\activate    # Windows
# source venv/bin/activate   # Mac/Linux

# ติดตั้ง packages
pip install -r requirements.txt

# รัน API
python app.py
```

✅ ถ้าสำเร็จจะเห็น:
```
LearnFlow API is running at http://0.0.0.0:5000
```

---

### **ขั้นตอนที่ 3: ตั้งค่า Flutter App** 📱

**1. ตั้ง baseUrl** (เปิด `lib/services/api_service.dart`)
```dart
// ตามประเภท device:
Android Emulator: http://10.0.2.2:5000
iOS Simulator:    http://localhost:5000
Physical device:  http://192.168.x.x:5000  (หา IP ด้วย ipconfig)
```

**2. อนุญาต HTTP** (เปิด `android/app/src/main/AndroidManifest.xml`)
```xml
<application
    android:usesCleartextTraffic="true"  <!-- เพิ่มบรรทัดนี้ -->
    ...>
```

**3. รัน Flutter**
```bash
cd learnflow
flutter pub get
flutter run
```

เลือก device:
```
1. Android Emulator
2. iOS Simulator
3. Physical device
```

---

## 🔌 API Endpoints

### Authentication
```
POST   /api/auth/login           - ล็อกอิน + sync user
POST   /api/auth/register        - สมัครสมาชิก
```

### Profile
```
GET    /api/profile              - ดึง user profile + stats
```

### Quiz
```
GET    /api/quizzes?page=1       - ดึงรายการ quiz (pagination)
GET    /api/quiz/<id>            - ดึง quiz detail + คำถาม + choices
GET    /api/quiz/<id>/attempted  - เช็คว่าเคยทำแล้วหรือ
POST   /api/quiz/submit          - ส่งคำตอบ
```

### Results
```
GET    /api/result/<attempt_id>  - ดึงผลลัพธ์ attempt
GET    /api/review/<attempt_id>  - ดึงเฉลย
```

### Analytics
```
GET    /api/dashboard?days=7     - Dashboard (Bar/Radar charts)
GET    /api/growth               - Growth chart (all-time)
GET    /api/analysis             - Topic mastery breakdown
```

---

## 🔑 Key Features Detail

### 🔐 Authentication
- Firebase Email + Password
- Google Sign-In
- Automatic token refresh
- Rate limiting (5 per minute)

### 💾 Data Persistence
- MySQL database with connection pooling
- In-memory cache (5-10 นาที TTL)
- Hive offline storage สำหรับ quiz submissions

### ⏱️ Quiz Management
- Auto time limit calculation (2.5 min/question)
- Per-question response time tracking
- Automatic submission on time-up
- Retry logic on network failure

### 📊 Analytics
- Bar chart: Topic mastery
- Radar chart: Accuracy, Speed, Understanding
- Line chart: Progress over time
- Growth tracking (all-time)

### 🎯 Recommendations
- AI-powered suggestions based on weak topics
- After each quiz attempt

---

## 🛠️ Troubleshooting

| ปัญหา | วิธีแก้ |
|---|---|
| **Connection refused** | ตรวจสอบ `python app.py` รันอยู่ + baseUrl ถูก |
| **401 Unauthorized** | Firebase token invalid → ล็อกอินใหม่ |
| **Android: localhost ไม่ได้** | เปลี่ยนเป็น `10.0.2.2` (Android Emulator special) |
| **MySQL Connection Error** | ตรวจสอบ DB_PASSWORD + MySQL service รันอยู่ |
| **Cleartext HTTP blocked** | เพิ่ม `usesCleartextTraffic="true"` ใน AndroidManifest.xml |
| **Build ช้า** | รัน `flutter clean` + enable parallel gradle |
| **ไม่มี quiz ขึ้น** | รัน seed ครบ 3 ไฟล์ตามลำดับ |
| **Notifications ไม่ขึ้น** | Android/iOS เท่านั้น (Web/Windows ข้าม) |

---

## 📋 Checklist ก่อนรัน

- [ ] MySQL database schema สร้างเสร็จ
- [ ] Seed data ใส่เสร็จ (subjects + quizzes + questions)
- [ ] Firebase serviceAccountKey.json วาง + ใน .gitignore
- [ ] `.env` ไฟล์สร้างและแก้ไขค่า
- [ ] `python app.py` รันสำเร็จ ที่ port 5000
- [ ] `baseUrl` ใน api_service.dart ถูกต้อง
- [ ] `usesCleartextTraffic="true"` เพิ่มใน AndroidManifest.xml
- [ ] `flutter run` เลือก device สำเร็จ

---

## 📝 Environment Variables (.env)

```env
# MySQL Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=mysql_password
DB_NAME=learnflow

# Firebase
FIREBASE_CREDENTIALS=config/serviceAccountKey.json

# Flask Configuration
FLASK_ENV=development
SECRET_KEY=your_random_secret_key_here
LOG_LEVEL=INFO

# CORS (optional)
CORS_ORIGINS=*
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  FLUTTER APP (Mobile)                   │
│  (UI Pages + Services + Local Cache + Notifications)    │
└──────────────┬──────────────────────────────────────────┘
               │ HTTPS (Firebase Token + Retry Logic)
               ▼
┌─────────────────────────────────────────────────────────┐
│                FLASK API (Backend)                      │
│  (Routes + Middleware + Business Logic + AI Service)    │
└──────────────┬──────────────────────────────────────────┘
               │ SQL Queries (Connection Pooling)
               ▼
┌─────────────────────────────────────────────────────────┐
│              MYSQL DATABASE                             │
│  (Users, Quizzes, Attempts, Analysis, Progress)         │
└─────────────────────────────────────────────────────────┘

Side Services:
- Firebase Auth (Token verification)
- Hive Local Storage (Offline quiz cache)
- In-Memory Cache (API response cache)
```

---

## 👨‍💻 Development Notes

- **Language**: Thai + English comments ในไฟล์
- **Formatting**: Dart/Python format เป็นมาตรฐาน
- **Testing**: Manual testing on Android Emulator
- **Performance**: Retry logic + connection pooling + caching
- **Security**: Firebase auth + rate limiting + generic errors

---

## 📚 Resources

- [Flutter Docs](https://flutter.dev)
- [Flask Docs](https://flask.palletsprojects.com)
- [Firebase Console](https://console.firebase.google.com)
- [MySQL Documentation](https://dev.mysql.com)

---

**Created: April 2026**  
**Status**: Production Ready ✅
