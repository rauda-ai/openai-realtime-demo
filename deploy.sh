#!/bin/bash
# Script to deploy the latest version from GitHub Container Registry

set -e

# Check if GitHub token is provided
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Please set the GITHUB_TOKEN environment variable"
  echo "Usage: GITHUB_TOKEN=ghp_xxxx ./deploy.sh"
  exit 1
fi

# Get the latest versions from GitHub
echo "Logging in to GitHub Container Registry..."
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

echo "Pulling the latest docker-compose.prod.yml from GitHub..."
REPO="openai-realtime-demo"
OWNER="rauda-ai"
ARTIFACT_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts"

# Get the latest artifact info
ARTIFACT_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$ARTIFACT_URL" | jq '.artifacts | sort_by(.created_at) | reverse | .[0]')
ARTIFACT_ID=$(echo $ARTIFACT_INFO | jq -r '.id')
ARTIFACT_NAME=$(echo $ARTIFACT_INFO | jq -r '.name')

if [ "$ARTIFACT_NAME" != "deployment-files" ]; then
  echo "Could not find deployment-files artifact"
  exit 1
fi

# Download the artifact
echo "Downloading artifact $ARTIFACT_ID..."
curl -s -L -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -o artifact.zip

# Extract the artifact
echo "Extracting deployment files..."
unzip -o artifact.zip
rm artifact.zip

# Check if we need to update env file
if [ ! -f .env ]; then
  echo "Creating .env file..."
  touch .env
  echo "IMPORTANT: Please update the .env file with your OPENAI_API_KEY and other configuration"
fi

# Stop any running containers
echo "Stopping any running containers..."
docker compose down || true

# Start with the new configuration
echo "Starting services with the new configuration..."
docker compose -f docker-compose.prod.yml up -d

echo "Deployment completed successfully!"
echo "Your application should be running at https://realtime.sandbox.rauda.ai"
