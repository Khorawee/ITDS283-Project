#!/bin/bash
cd learnflow_api
pip install -r requirements.txt
gunicorn -w 4 -b 0.0.0.0:$PORT "app:create_app()"
