# 🚀 Railway Deployment Guide - LearnFlow API

## ✅ สำหรับผู้ Deploy บน Railway (ง่ายสุด!)

---

## 📋 Prerequisites

- [ ] GitHub Account
- [ ] Railway Account (https://railway.app)
- [ ] Firebase Project
- [ ] MySQL Database (Railway ให้ฟรี)

---

## 🎯 Step-by-Step: Deploy to Railway

### **Step 1: Prepare GitHub Repository**

ให้ push code ไปที่ GitHub:

```bash
# ตรวจสอบว่าไฟล์ sensitive ไม่ได้ commit
git status | grep ".env\|serviceAccountKey"
# ผลลัพธ์ควร empty

# Commit & Push
git add .
git commit -m "LearnFlow API - Ready for Railway deployment"
git push origin main
```

### **Step 2: Sign Up Railway**

1. ไปที่ https://railway.app
2. Click **Sign in with GitHub**
3. Authorize Railway
4. Accept terms ✅

### **Step 3: Create New Project**

1. Dashboard → **New Project**
2. Select **GitHub Repo**
3. Search for your repository: `ITDS283-Project`
4. Select branch: `main`
5. Click **Deploy**

### **Step 4: Wait for Initial Build**

- Railway จะ auto-detect `Procfile` และ `requirements.txt`
- จะสร้าง instance ให้อัตโนมัติ
- รอ 2-3 นาที build เสร็จ

### **Step 5: Add MySQL Database**

1. ใน Railway Dashboard → **+ New**
2. Select **Database** → **MySQL**
3. Create ✅
4. Railway จะ inject environment variables อัตโนมัติ:
   ```
   MYSQLHOST
   MYSQLPORT
   MYSQLUSER
   MYSQLPASSWORD
   MYSQLDATABASE
   ```

---

## 🔧 Step 6: Configure Environment Variables

ใน Railway Dashboard:

1. **Project Settings** → **Variables**
2. เพิ่ม environment variables ต่อไปนี้:

### A. Flask Configuration:
```
FLASK_DEBUG = false
SECRET_KEY = [generate strong key: use secrets module or online generator]
FLASK_ENV = production
```

### B. Firebase Credentials:
```
FIREBASE_CREDENTIALS_JSON = [paste full JSON content here]
```

**วิธีได้ Firebase JSON:**
1. ไปที่ https://console.firebase.google.com
2. Select project → **Project Settings** ⚙️
3. Tab: **Service Accounts**
4. Click **Generate New Private Key**
5. Copy ทั้งหมด
6. Paste ลงใน Railway variable `FIREBASE_CREDENTIALS_JSON`

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "...",
  "token_uri": "...",
  "auth_provider_x509_cert_url": "...",
  "client_x509_cert_url": "..."
}
```

### C. CORS Configuration (Optional):
```
CORS_ORIGINS = https://yourdomain.com
```

(ถ้ายังไม่มี domain ใช้ `*` ได้)

---

## 📊 Step 7: Setup Database Schema

Railway CLI (recommended):

### Option A: Via Railway CLI (easiest)

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login to Railway
railway login

# 3. Link to your project
railway link

# 4. Connect to MySQL
railway connect

# 5. In MySQL prompt, run:
source database/schema/main_schema.sql;
source database/seeds/sample_data.sql;
exit;
```

### Option B: Via Railway Dashboard (GUI)

1. Dashboard → Select project
2. Go to MySQL service → **Canvas**
3. Click **MySQL** → **Open Database Studio** (or query tools)
4. Copy-paste from `database/schema/main_schema.sql`
5. Run ✅

---

## ✅ Step 8: Verify Deployment

### Check Logs:
```bash
# Via CLI
railway logs

# Or via Dashboard → Logs tab
```

### Test Health Endpoint:
```bash
# Get your Railway URL from Dashboard
# It looks like: https://your-app.railway.app

curl https://your-app.railway.app/health
# Expected response:
# {"status": "ok", "db": "connected"}
```

### Test API Endpoints:
```bash
# List all routes
curl https://your-app.railway.app/api/debug/routes

# Test quiz endpoint
curl https://your-app.railway.app/api/quiz
```

---

## 🔄 Step 9: Auto-Deploy on Git Push (Already Set!)

Railway จะ auto-deploy ทุกครั้งที่ push to main:

```bash
# Make changes locally
git add .
git commit -m "Update feature"
git push origin main
# Railway จะ auto-build & deploy ✅
```

---

## 🌐 Share Your API

Railway URL:
```
https://your-app.railway.app
```

Share ให้ผู้ใช้:
```
API Base URL: https://your-app.railway.app
Health Check: https://your-app.railway.app/health

Example:
- Login: POST https://your-app.railway.app/api/auth/login
- Quiz: GET https://your-app.railway.app/api/quiz
- Profile: GET https://your-app.railway.app/api/profile
```

---

## 🐛 Troubleshooting

### Issue 1: "502 Bad Gateway"
**Cause:** App crash หรือ database disconnected
**Fix:** 
```bash
# Check logs
railway logs

# Look for error messages
# Usually: Database not initialized หรือ Firebase error
```

### Issue 2: "Cannot connect to database"
**Solution:**
```
1. Check MySQL service is running in Railway
2. Verify MYSQLHOST, MYSQLUSER, MYSQLPASSWORD ใน Dashboard
3. Make sure database schema is imported
4. Try: railway connect [to test connection]
```

### Issue 3: "Firebase authentication failed"
**Solution:**
```
1. Check FIREBASE_CREDENTIALS_JSON ใน Railway Variables
2. Verify format is valid JSON (not escaped)
3. Check Firebase project ID matches
4. Download new credentials from Firebase Console
```

### Issue 4: "CORS error from frontend"
**Solution:**
```
1. In Railway Variables, set:
   CORS_ORIGINS = https://yourdomain.com,http://localhost:3000
2. Or use: CORS_ORIGINS = * (for testing only)
```

### Issue 5: Build fails - "requirements.txt not found"
**Solution:**
```bash
# Make sure file exists in repo
ls -la learnflow_api/requirements.txt

# If missing, create it
# Railway should auto-detect it
```

---

## 📊 Monitoring & Logs

### View Logs:
```bash
# Real-time logs
railway logs --follow

# Last 100 lines
railway logs | tail -100
```

### Check Status:
- Railway Dashboard → Your Project → Status
- Green = running ✅
- Red = error ❌

### Restart Service:
```bash
# Via CLI
railway redeploy

# Or via Dashboard: Deployments → Restart
```

---

## 💰 Railway Pricing

- **Free tier:** Up to $5/month credit (plenty for small projects)
- **Paid tier:** $5+ per month
- **MySQL:** ~$3/month for basic
- **Compute:** Auto-scaling

> For a school project, free tier is enough!

---

## 🎯 Final Checklist

Before sharing with others:

- [ ] Code pushed to GitHub
- [ ] Railway project created
- [ ] MySQL database added
- [ ] Environment variables set (Firebase, CORS)
- [ ] Database schema imported
- [ ] Health endpoint working ✅
- [ ] API endpoints tested
- [ ] Logs checked for errors
- [ ] URL shared with users

---

## 📝 Share This URL

```
🚀 LearnFlow API is now live!
API Base URL: https://[your-project].railway.app

📖 Documentation: https://github.com/[your-account]/ITDS283-Project

Health Check: https://[your-project].railway.app/health

Quick Test:
curl https://[your-project].railway.app/api/quiz
```

---

## 🔒 Security Notes

- ✅ Secret keys are hidden in Railway
- ✅ Firebase credentials are protected
- ✅ Database password never exposed
- ✅ API logs don't show sensitive data
- ⚠️ Don't expose `.env` or `serviceAccountKey.json` files

---

## 📞 Support

If deployment fails:

1. **Check Railway Logs:** Dashboard → Logs
2. **Read error messages** carefully
3. **Common fixes:**
   - Restart service
   - Redeploy project
   - Check environment variables
   - Verify database is running

---

## 🎉 You're Done!

Your LearnFlow API is now live on Railway!

Next: Share the URL with:
- Your teacher (for grading)
- Friends (for testing)
- Flutter app (update API base URL)

```bash
# For Flutter, update base URL in:
# learnflow/lib/services/api_service.dart
const String BASE_URL = 'https://[your-project].railway.app';
```

---

**Deployment Date:** 2026-04-18  
**Status:** ✅ LIVE ON RAILWAY
