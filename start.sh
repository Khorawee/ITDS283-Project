#!/bin/bash
cd /app/learnflow_api || cd learnflow_api || exit 1
gunicorn -w 4 -b 0.0.0.0:$PORT "app:create_app()"