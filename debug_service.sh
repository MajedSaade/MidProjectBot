#!/bin/bash

# Script to debug the Discord bot service

echo "==========================================="
echo "   Discord Bot Service Debugging Tool"
echo "==========================================="
echo ""

# Check if service is running
echo "Checking service status..."
sudo systemctl status discord-bot.service

# Check environment file
echo ""
echo "Checking .env file..."
if [ -f ".env" ]; then
    # Display .env variables without showing token value
    echo "Environment file exists. Variables:"
    grep -v "DISCORD_BOT_TOKEN" .env | sed 's/^/  /'
    if grep -q "DISCORD_BOT_TOKEN=" .env; then
        token_value=$(grep "DISCORD_BOT_TOKEN=" .env | cut -d= -f2)
        if [ -n "$token_value" ]; then
            echo "  DISCORD_BOT_TOKEN=******* (token is set)"
        else
            echo "  DISCORD_BOT_TOKEN= (token is empty)"
        fi
    else
        echo "  DISCORD_BOT_TOKEN not found in .env file"
    fi
    
    # Check .env file permissions
    env_perms=$(stat -c "%a" .env)
    echo "  .env file permissions: $env_perms (should be 600)"
else
    echo "No .env file found in current directory"
fi

# Try running the app directly
echo ""
echo "Trying to run the app directly as a module..."
source venv/bin/activate
python -c "
from dotenv import load_dotenv
import os
import sys

# Print Python version
print(f'Python version: {sys.version}')

# Load env variables and check
load_dotenv()
token = os.environ.get('DISCORD_BOT_TOKEN')
print(f'DISCORD_BOT_TOKEN: {"✓ Set" if token else "✗ NOT SET"}')
print(f'YOLO_URL: {os.environ.get(\"YOLO_URL\", \"Not set\")}')
print(f'OLLAMA_URL: {os.environ.get(\"OLLAMA_URL\", \"Not set\")}')
print(f'Working directory: {os.getcwd()}')
"

# Try running the module directly
echo ""
echo "Testing the module import:"
python -c "
try:
    import polybot.app
    print('✓ Successfully imported polybot.app module')
except Exception as e:
    print(f'✗ Failed to import polybot.app module: {e}')
"

# Check service logs
echo ""
echo "Recent service logs:"
sudo journalctl -u discord-bot.service -n 20 --no-pager

echo ""
echo "==========================================="
echo "Suggested fixes:"
echo ""
echo "1. Make sure the .env file has the correct Discord bot token"
echo "2. Ensure the Python module structure is correct"
echo "3. Run 'sudo systemctl daemon-reload' after changing the service file"
echo "4. Check that all dependencies are installed with 'pip list'"
echo "5. Check the Python path with 'python -c \"import sys; print(sys.path)\"'"
echo "===========================================" 