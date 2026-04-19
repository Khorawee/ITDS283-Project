"""Database connection management with pooling.

Features:
- Uses DBUtils.PooledDB for connection pooling (10 max connections)
- Minimum 2, maximum 5 idle connections
- Health checks before using connections (ping=1)
- Supports both local .env (DB_*) and Railway (MYSQL*) environment variables
- Fallback to direct connection if pooling unavailable
- UTF-8 multi-byte charset support

Configuration:
    DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME (from .env or Railway)
"""

import os
import pymysql
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)

load_dotenv()

# Global database connection pool
_pool = None


def _init_pool():
    """สร้าง connection pool จาก DBUtils (10 connections max)
    
    Fallback: ถ้า DBUtils ไม่ได้ install ก็ set _pool = None
    """
    global _pool
    if _pool is not None:
        return
    
    try:
        from dbutils.pooled_db import PooledDB
        
        _pool = PooledDB(
            creator=pymysql,
            maxconnections=10,          # Maximum connections in pool
            mincached=2,                # Minimum idle connections
            maxcached=5,                # Maximum idle connections
            blocking=True,
            ping=1,                     # Check connection before using
            host=os.getenv('DB_HOST') or os.getenv('MYSQLHOST', 'localhost'),
            port=int(os.getenv('DB_PORT') or os.getenv('MYSQLPORT', 3306)),
            user=os.getenv('DB_USER') or os.getenv('MYSQLUSER', 'root'),
            password=os.getenv('DB_PASSWORD') or os.getenv('MYSQLPASSWORD', ''),
            database=os.getenv('DB_NAME') or os.getenv('MYSQLDATABASE', 'learnflow'),
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor,
        )
        logger.info('Database connection pool initialized')
    except ImportError:
        logger.warning('DBUtils not available, falling back to direct connections')
        _pool = None


def get_connection():
    """ดึง DB connection จาก pool หรือ fallback เป็น direct connection
    
    Support: local (.env) และ Railway (MYSQL* vars)
    Return: pymysql connection ready to use
    """
    _init_pool()
    
    if _pool is not None:
        try:
            return _pool.connection()
        except Exception as e:
            logger.error('Failed to get pooled connection: %s', str(e))
            # Fallback to direct connection
    
    # Direct connection (fallback)
    return pymysql.connect(
        host=os.getenv('DB_HOST') or os.getenv('MYSQLHOST', 'localhost'),
        port=int(os.getenv('DB_PORT') or os.getenv('MYSQLPORT', 3306)),
        user=os.getenv('DB_USER') or os.getenv('MYSQLUSER', 'root'),
        password=os.getenv('DB_PASSWORD') or os.getenv('MYSQLPASSWORD', ''),
        database=os.getenv('DB_NAME') or os.getenv('MYSQLDATABASE', 'learnflow'),
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
    )

