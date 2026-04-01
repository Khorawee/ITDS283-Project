import os
import firebase_admin
from firebase_admin import credentials
from dotenv import load_dotenv

load_dotenv()

def init_firebase():
    """Initialize Firebase Admin SDK ครั้งเดียวตอนเริ่ม app"""
    if not firebase_admin._apps:
        cred_path = os.getenv('FIREBASE_CREDENTIALS', 'config/serviceAccountKey.json')
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)