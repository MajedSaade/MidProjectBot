#!/bin/bash

# Exit on any error
set -e

echo "Starting deployment of Discord bot..."

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3-venv python3-dev build-essential libssl-dev libffi-dev

# Install python3-venv if not already installed
if ! dpkg -l | grep -q python3-venv; then
  echo "Installing python3-venv package..."
  sudo apt-get install -y python3-venv
fi

# Remove existing venv if activation fails
if [ -d "venv" ] && [ ! -f "venv/bin/activate" ]; then
  echo "Found incomplete virtual environment, removing it..."
  rm -rf venv
fi

# Create a Python virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv venv
  
  # Verify the virtual environment was created properly
  if [ ! -f "venv/bin/activate" ]; then
    echo "❌ Failed to create virtual environment properly."
    exit 1
  fi
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Verify the virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
  echo "❌ Failed to activate virtual environment."
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r polybot/requirements.txt

# Set up environment variables
echo "Setting up environment variables..."
if [ ! -f ".env" ]; then
  echo "Creating .env file..."
  echo "DISCORD_BOT_TOKEN=" > .env
  echo "YOLO_URL=http://10.0.1.90:8081/predict" >> .env
  echo "OLLAMA_URL=http://10.0.0.136:11434/api/chat" >> .env
  echo "OLLAMA_MODEL=gemma3:1b" >> .env
  echo "STATUS_SERVER_PORT=8443" >> .env
  
  echo "⚠️ WARNING: You need to edit the .env file and add your Discord bot token"
fi

# Copy the systemd service file
echo "Setting up systemd service..."
sudo cp discord-bot.service /etc/systemd/system/

# Reload daemon and restart the service
echo "Restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart discord-bot.service
sudo systemctl enable discord-bot.service

# Check if the service is active
if ! systemctl is-active --quiet discord-bot.service; then
  echo "❌ discord-bot.service is not running."
  sudo systemctl status discord-bot.service --no-pager
  
  echo "Checking logs for errors..."
  journalctl -u discord-bot.service -n 50 --no-pager
  
  echo ""
  echo "The service failed to start. This might be because:"
  echo "1. The DISCORD_BOT_TOKEN is not set in the service file"
  echo "2. There are path issues in the service file"
  echo "3. The bot code has errors"
  echo ""
  echo "Please check the logs above for more details."
  
  exit 1
else
  echo "✅ Discord bot service is running successfully."
fi

echo "Deployment completed successfully!" 