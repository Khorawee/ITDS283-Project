# 🔧 Railway Build Fix

## ❌ Problem
Procfile กำลงเรียก `app:create_app()` แต่ไฟล์ `app.py` อยู่ใน `learnflow_api/` directory ไม่ใช่ root

---

## ✅ Solution: Updated Procfile

เปลี่ยน Procfile เป็น:
```
web: cd learnflow_api && gunicorn -w 4 -b 0.0.0.0:$PORT "app:create_app()"
```

**ทำให้:**
1. `cd` เข้าไปยัง `learnflow_api` directory
2. รัน `gunicorn` ที่จุดที่ถูก

---

## 📋 Deployment Steps ใหม่

```bash
# 1. ตรวจสอบ Procfile
cat learnflow_api/Procfile
# ควรเห็น: web: cd learnflow_api && gunicorn -w 4 -b 0.0.0.0:$PORT "app:create_app()"

# 2. Commit & Push
git add learnflow_api/Procfile
git commit -m "Fix Procfile path for Railway deployment"
git push origin main

# 3. Railway จะ auto-redeploy ✅
```

---

## 🚀 After Push

ไปที่ Railway Dashboard:
- Deployments tab → ดูว่า build ผ่านไหม
- Logs tab → ดูว่า app start OK ไหม
- ถ้า green ✅ = success!

---

## ✅ Test After Deployment

```bash
# Once deployed, test health endpoint
curl https://[your-project].railway.app/health

# Expected: {"status": "ok", "db": "connected"}
```

---

**Status:** ✅ **FIXED - Ready to redeploy**
