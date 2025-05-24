#!/bin/bash

# Debug wrapper script for running the Discord bot

# Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Virtual environment not found! Creating one..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r polybot/requirements.txt
fi

# Debug info
echo "Starting Discord bot with environment:"
echo "DISCORD_BOT_TOKEN: ${DISCORD_BOT_TOKEN:0:3}...${DISCORD_BOT_TOKEN: -3} (masked for security)"
echo "YOLO_URL: $YOLO_URL"
echo "OLLAMA_URL: $OLLAMA_URL"
echo "OLLAMA_MODEL: $OLLAMA_MODEL"
echo "STATUS_SERVER_PORT: $STATUS_SERVER_PORT"
echo "Python executable: $(which python)"
echo "Python version: $(python --version)"

# Run the bot
exec python polybot/app.py 