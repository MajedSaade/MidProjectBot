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

# Install the specific required packages first to ensure they're available
echo "Installing critical packages..."
pip install python-dotenv fastapi uvicorn loguru discord.py

# Then install all requirements
echo "Installing all requirements..."
pip install -r polybot/requirements.txt

# Set up environment variables
echo "Setting up environment variables..."

# Create or update .env file with token from environment variable
if [ -n "$DISCORD_BOT_TOKEN" ]; then
  echo "Using Discord bot token from environment variable..."
  echo "DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN" > .env
  echo "YOLO_URL=http://10.0.1.90:8081/predict" >> .env
  echo "OLLAMA_URL=http://10.0.0.136:11434/api/chat" >> .env
  echo "OLLAMA_MODEL=gemma3:1b" >> .env
  echo "STATUS_SERVER_PORT=8443" >> .env
else
  # Check if .env exists and has DISCORD_BOT_TOKEN
  if [ ! -f ".env" ] || ! grep -q "DISCORD_BOT_TOKEN=" .env || [ "$(grep "DISCORD_BOT_TOKEN=" .env | cut -d= -f2)" = "" ]; then
    echo "❌ ERROR: DISCORD_BOT_TOKEN is not set!"
    echo "Please make sure to either:"
    echo "1. Set it in your .env file manually"
    echo "2. Pass it as an environment variable when running this script"
    echo "3. Add it to your GitHub repository secrets"
    
    # Create a default .env file
    echo "Creating .env file with empty token (you'll need to fill this in)..."
    echo "DISCORD_BOT_TOKEN=" > .env
    echo "YOLO_URL=http://10.0.1.90:8081/predict" >> .env
    echo "OLLAMA_URL=http://10.0.0.136:11434/api/chat" >> .env
    echo "OLLAMA_MODEL=gemma3:1b" >> .env
    echo "STATUS_SERVER_PORT=8443" >> .env
    
    echo "⚠️ WARNING: You need to edit the .env file and add your Discord bot token"
    echo "The bot will not work until you do this and restart the service."
  fi
fi

# Display current environment settings
echo "Current environment variables:"
echo "DISCORD_BOT_TOKEN: $(if grep -q "DISCORD_BOT_TOKEN=" .env && [ "$(grep "DISCORD_BOT_TOKEN=" .env | cut -d= -f2)" != "" ]; then echo "is set"; else echo "not set"; fi)"
echo "YOLO_URL: $(grep "YOLO_URL=" .env | cut -d= -f2)"
echo "OLLAMA_URL: $(grep "OLLAMA_URL=" .env | cut -d= -f2)"

# Make sure permissions are correct for .env
chmod 600 .env

# Make sure run_bot.sh is executable
chmod +x run_bot.sh

# Copy the systemd service file
echo "Setting up systemd service..."
sudo cp discord-bot.service /etc/systemd/system/

# Test run the app directly to check for errors
echo "Testing the app directly..."
./run_bot.sh --test-run || {
  echo "❌ The app failed to start when run directly. This might help identify the issue."
}

# Reload daemon and restart the service
echo "Restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart discord-bot.service
sudo systemctl enable discord-bot.service

# Check if the service is active
if ! systemctl is-active --quiet discord-bot.service; then
  echo "❌ discord-bot.service is not running."
  sudo systemctl status discord-bot.service --no-pager
  
  echo "Checking detailed logs for errors..."
  sudo journalctl -u discord-bot.service -n 100 --no-pager
  
  echo ""
  echo "The service failed to start. This might be because:"
  echo "1. The DISCORD_BOT_TOKEN is missing or invalid in the .env file"
  echo "2. The .env file is not being loaded properly by the service"
  echo "3. There are Python package dependencies missing"
  echo ""
  echo "Try running the bot manually to see more detailed errors:"
  echo "./run_bot.sh"
  echo ""
  
  exit 1
else
  echo "✅ Discord bot service is running successfully."
fi

echo "Deployment completed successfully!" 