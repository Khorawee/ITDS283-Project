import os
import json
import firebase_admin
from firebase_admin import credentials
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def init_firebase():
    """Initialize Firebase Admin SDK ครั้งเดียวตอนเริ่ม app
    - Railway/Production: อ่านจาก env var FIREBASE_CREDENTIALS_JSON (JSON string)
    - Local dev: อ่านจากไฟล์ serviceAccountKey.json เหมือนเดิม
    """
    if not firebase_admin._apps:
        creds_json = os.getenv('FIREBASE_CREDENTIALS_JSON')
        if creds_json:
            # Railway: ใส่ content ทั้งหมดของ serviceAccountKey.json ใน env var นี้
            cred_dict = json.loads(creds_json)
            cred = credentials.Certificate(cred_dict)
        else:
            # Local dev: ใช้ไฟล์เหมือนเดิม
            cred_path = os.getenv(
                'FIREBASE_CREDENTIALS',
                os.path.join(BASE_DIR, 'serviceAccountKey.json')
            )
            cred = credentials.Certificate(cred_path)

        firebase_admin.initialize_app(cred)
