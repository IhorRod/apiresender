#!/bin/bash

# Create a virtual environment
python3 -m venv venv
source venv/bin/activate

# Prompt for environment variables
read -p "Enter BASE_URL: " BASE_URL
read -p "Enter TOKEN: " TOKEN
read -p "Enter PORT (default 8000): " PORT
PORT=${PORT:-8000}

# Write environment variables to .env file
cat <<EOL > .env
BASE_URL=$BASE_URL
TOKEN=$TOKEN
PORT=$PORT
EOL

# Install required packages
pip install -r requirements.txt

# Create systemd service file
SERVICE_FILE=/etc/systemd/system/fastapi-proxy.service

sudo bash -c "cat <<EOL > $SERVICE_FILE
[Unit]
Description=FastAPI Proxy
After=network.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/venv/bin/uvicorn main:app --host 0.0.0.0 --port $PORT
EnvironmentFile=$(pwd)/.env
Restart=always

[Install]
WantedBy=multi-user.target
EOL"

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable fastapi-proxy
sudo systemctl start fastapi-proxy

echo "FastAPI proxy has been started and enabled to start on boot."