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