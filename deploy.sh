#!/bin/bash

# Exit on any error
set -e

echo "Starting deployment of Discord bot..."

# Create a Python virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv venv
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r polybot/requirements.txt

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
  exit 1
else
  echo "✅ Discord bot service is running successfully."
fi

echo "Deployment completed successfully!" 