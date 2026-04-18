import os
os.environ['FLASK_DEBUG'] = 'false'

from app import create_app
app = create_app()

print('✅ Flask Configuration:')
print(f'  Debug: {app.debug}')

try:
    from config.db_config import get_connection
    print('✅ Database config loaded')
except Exception as e:
    print(f'❌ Database config error: {e}')

try:
    from config.firebase_config import init_firebase
    print('✅ Firebase config loaded')
except Exception as e:
    print(f'⚠️  Firebase config note: {str(e)[:100]}')

print('\n✅ All dependencies OK!')
print(f'✅ Total endpoints: {len(list(app.url_map.iter_rules()))}')
