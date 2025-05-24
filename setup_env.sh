#!/bin/bash

# Script to set up the environment variables for the Discord bot

# Display header
echo "====================================================="
echo "      Discord Bot Environment Setup"
echo "====================================================="
echo ""

# Check if an existing .env file exists
if [ -f ".env" ]; then
    echo "Existing .env file found. Current settings:"
    cat .env | grep -v "TOKEN" | sed 's/^/  /'
    
    # If token exists, show it's set but not the value
    if grep -q "DISCORD_BOT_TOKEN=" .env && [ "$(grep "DISCORD_BOT_TOKEN=" .env | cut -d= -f2)" != "" ]; then
        echo "  DISCORD_BOT_TOKEN=********** (token is set)"
    else
        echo "  DISCORD_BOT_TOKEN= (not set)"
    fi
    
    echo ""
    read -p "Do you want to keep these settings? (y/n): " keep_settings
    
    if [[ $keep_settings == "y" || $keep_settings == "Y" ]]; then
        echo "Keeping existing settings."
        
        # Check if Discord token needs to be set
        if ! grep -q "DISCORD_BOT_TOKEN=" .env || [ "$(grep "DISCORD_BOT_TOKEN=" .env | cut -d= -f2)" == "" ]; then
            echo "Discord bot token is not set in the .env file."
            read -p "Enter your Discord bot token (or leave empty to set later): " token
            
            if [ -n "$token" ]; then
                # Update token in existing file
                if grep -q "DISCORD_BOT_TOKEN=" .env; then
                    sed -i "s/^DISCORD_BOT_TOKEN=.*/DISCORD_BOT_TOKEN=$token/" .env
                else
                    echo "DISCORD_BOT_TOKEN=$token" >> .env
                fi
                echo "Discord bot token has been updated."
            else
                echo "Discord bot token not set. You'll need to add it later."
            fi
        fi
        
        chmod 600 .env
        echo "Setup complete!"
        exit 0
    fi
    
    # Backup the existing file
    mv .env .env.backup
    echo "Backed up existing .env to .env.backup"
fi

# Get Discord bot token
echo "Enter your Discord bot token"
echo "You can get this from the Discord Developer Portal: https://discord.com/developers/applications"
read -p "Discord Bot Token (or leave empty to set later): " discord_token

# Set up YOLO URL
read -p "YOLO API URL [http://10.0.1.90:8081/predict]: " yolo_url
yolo_url=${yolo_url:-"http://10.0.1.90:8081/predict"}

# Set up Ollama URL
read -p "Ollama API URL [http://10.0.0.136:11434/api/chat]: " ollama_url
ollama_url=${ollama_url:-"http://10.0.0.136:11434/api/chat"}

# Set up Ollama model
read -p "Ollama Model [gemma3:1b]: " ollama_model
ollama_model=${ollama_model:-"gemma3:1b"}

# Set up status server port
read -p "Status Server Port [8443]: " status_port
status_port=${status_port:-"8443"}

# Create the .env file
echo "Creating .env file..."
echo "DISCORD_BOT_TOKEN=$discord_token" > .env
echo "YOLO_URL=$yolo_url" >> .env
echo "OLLAMA_URL=$ollama_url" >> .env
echo "OLLAMA_MODEL=$ollama_model" >> .env
echo "STATUS_SERVER_PORT=$status_port" >> .env

# Set proper permissions
chmod 600 .env

echo ""
echo "====================================================="
echo "Environment file created successfully!"
echo "====================================================="

if [ -z "$discord_token" ]; then
    echo "⚠️  WARNING: Discord bot token is not set."
    echo "You need to edit the .env file and add your Discord bot token for the bot to work."
    echo "Edit the .env file directly or run this script again."
fi

echo ""
echo "To restart the bot after changing environment variables, run:"
echo "sudo systemctl restart discord-bot.service"
echo "=====================================================" 