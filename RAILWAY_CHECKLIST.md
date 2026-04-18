# 🚀 Railway Deployment Checklist

## ✅ Pre-Deployment Checklist

- [ ] GitHub account created
- [ ] Code pushed to GitHub (main branch)
- [ ] `.env` file ไม่ได้ commit ✓
- [ ] `serviceAccountKey.json` ไม่ได้ commit ✓
- [ ] `requirements.txt` complete
- [ ] `Procfile` มีอยู่
- [ ] `runtime.txt` ระบุ Python 3.11

---

## 🚀 Railway Deployment Steps

### Step 1: Login to Railway
```
https://railway.app
→ Sign in with GitHub
```

### Step 2: Create New Project
```
New Project
→ GitHub Repo
→ Select: ITDS283-Project
→ Select branch: main
→ Deploy
```

### Step 3: Wait for Initial Build
- ⏳ 2-3 minutes
- ✅ Should see "Deployment successful"

### Step 4: Add MySQL Database
```
+ New
→ Database
→ MySQL
→ Create
```

### Step 5: Configure Variables
ใน Railway Dashboard → Variables:

**ค่าที่ Railway auto-inject (เมื่อเพิ่ม MySQL):**
```
MYSQLHOST
MYSQLPORT
MYSQLUSER
MYSQLPASSWORD
MYSQLDATABASE
```

**ค่าที่ต้องเพิ่มเอง:**

```env
FLASK_DEBUG=false
FLASK_ENV=production
SECRET_KEY=generate_strong_random_key

FIREBASE_CREDENTIALS_JSON={"type":"service_account","project_id":"..."}
[paste full Firebase JSON]

CORS_ORIGINS=*
```

### Step 6: Initialize Database

**Option A: Via Railway CLI**
```bash
npm install -g @railway/cli
railway login
railway link
railway connect

# In MySQL prompt:
source database/schema/main_schema.sql;
source database/seeds/sample_data.sql;
exit;
```

**Option B: Via Railway Web UI**
```
Dashboard → MySQL → Open Database Client
→ Run SQL from database/schema/main_schema.sql
```

### Step 7: Verify Deployment

```bash
# Get Railway URL from Dashboard
# Format: https://[project-name].railway.app

# Test health endpoint
curl https://[project-name].railway.app/health

# Expected: {"status": "ok", "db": "connected"}
```

---

## 🔗 Your Railway URL

```
https://[project-name].railway.app
```

Find it in:
- Railway Dashboard → Deployments → View
- Railway Dashboard → Settings → Domain

---

## 📝 Firebase Credentials Setup

1. Go to: https://console.firebase.google.com
2. Select your project
3. ⚙️ Project Settings
4. Service Accounts tab
5. **Generate New Private Key** (download JSON)
6. Copy entire JSON content
7. In Railway Dashboard Variables:
   - Variable: `FIREBASE_CREDENTIALS_JSON`
   - Value: [paste entire JSON]
8. Click **Add** and **Redeploy**

---

## ✅ Testing After Deployment

```bash
PROJECT_URL="https://your-railway-url"

# 1. Health check
curl $PROJECT_URL/health

# 2. List routes
curl $PROJECT_URL/api/debug/routes

# 3. Get quizzes
curl $PROJECT_URL/api/quiz

# 4. Check CORS
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     $PROJECT_URL/health
```

---

## 🔄 Auto-Deployment Setup (Auto!)

Railway automatically redeploys when you push to `main`:

```bash
# Make changes
git add .
git commit -m "Fix feature"
git push origin main

# Railway auto-deploys ✅
# Check Dashboard → Deployments
```

---

## 🐛 Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| 502 Bad Gateway | App crash or DB not ready | Check logs: `railway logs` |
| Cannot connect to database | DB not initialized | Import schema via `railway connect` |
| Firebase error | Wrong credentials | Verify `FIREBASE_CREDENTIALS_JSON` in Variables |
| CORS error | Origin not allowed | Set `CORS_ORIGINS=*` in Variables |
| Build fails | Missing requirements.txt | Ensure file exists in repo root |
| Deployment hangs | Waiting for something | Check logs for hung process |

---

## 📊 Monitor Your Deployment

```bash
# View real-time logs
railway logs --follow

# View last N logs
railway logs | tail -50

# Redeploy if needed
railway redeploy
```

Or via Dashboard:
- Select project
- **Logs** tab (watch in real-time)
- **Deployments** tab (see history)

---

## 🎯 Share Your API

Once deployed, share this:

```
🚀 LearnFlow API is LIVE!

API URL: https://[your-project].railway.app
Health: https://[your-project].railway.app/health

Repository: https://github.com/[your-account]/ITDS283-Project

Setup: See RAILWAY_DEPLOYMENT.md
```

---

## ✅ Final Verification

- [ ] Railway project created
- [ ] MySQL database added
- [ ] Environment variables configured
- [ ] Database schema imported
- [ ] Health endpoint returns 200 OK
- [ ] API endpoints respond correctly
- [ ] Logs show no errors
- [ ] URL shared with users
- [ ] Auto-deployment working (test with git push)

---

## 🎉 Deployment Complete!

Your LearnFlow API is now live on Railway and ready for:
- ✅ Teacher evaluation
- ✅ Student testing
- ✅ Public demo
- ✅ Flutter app integration

**Status:** 🟢 **LIVE & RUNNING**

**Next:** Update Flutter app base URL to Railway URL

---

**Created:** 2026-04-18  
**Last Updated:** 2026-04-18  
**Status:** ✅ READY FOR DEPLOYMENT
