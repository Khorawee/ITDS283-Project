import os
import firebase_admin
from firebase_admin import credentials
from dotenv import load_dotenv

load_dotenv()

# เพิ่มบรรทัดนี้
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def init_firebase():
    """Initialize Firebase Admin SDK ครั้งเดียวตอนเริ่ม app"""
    if not firebase_admin._apps:
        cred_path = os.getenv(
            'FIREBASE_CREDENTIALS',
            os.path.join(BASE_DIR, 'serviceAccountKey.json')  # ← แก้ตรงนี้
        )
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)