# Discord Image Processing Bot

A Discord bot that processes images using YOLO object detection and Ollama AI for natural language processing.

## Continuous Deployment Setup

This project uses GitHub Actions for continuous deployment. When you push changes to the `main` branch, the code is automatically deployed to your EC2 instance.

### Setting up GitHub Secrets

To enable the GitHub Actions workflow, you need to add the following secrets to your GitHub repository:

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Add the following secrets:

- `EC2_SSH_KEY`: Your private SSH key for connecting to the EC2 instance
- `EC2_HOST`: The hostname or IP address of your EC2 instance
- `EC2_USERNAME`: The username for SSH connection (usually "ubuntu" for AWS EC2)

### Branch Protection

To ensure code quality, it's recommended to protect the `main` branch:

1. Go to "Settings" > "Branches"
2. Add a branch protection rule for the `main` branch:
   - Check "Require a pull request before merging"
   - Check "Do not allow bypassing the above settings"

### Development Workflow

1. Create a feature branch: `git checkout -b feature-branch-name`
2. Make changes and commit them
3. Push the feature branch: `git push origin feature-branch-name`
4. Open a Pull Request on GitHub
5. After review and approval, merge the PR
6. The GitHub Actions workflow will automatically deploy the changes to your EC2 instance

## Environment Variables

The bot requires the following environment variables:

- `DISCORD_BOT_TOKEN`: Your Discord bot token
- `YOLO_URL`: URL for the YOLO API (default: "http://10.0.1.90:8081/predict")
- `OLLAMA_URL`: URL for the Ollama API (default: "http://10.0.0.136:11434/api/chat")
- `OLLAMA_MODEL`: Ollama model to use (default: "gemma3:1b")
- `STATUS_SERVER_PORT`: Port for the status server (default: 8443) 