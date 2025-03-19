#!/bin/bash
# Script to deploy the latest version from GitHub Container Registry for a public repository

set -e

# Get repository details from remote URL
echo "Detecting repository information..."
REMOTE_URL=$(git config --get remote.origin.url || echo "")
if [ -z "$REMOTE_URL" ]; then
  # Ask for repository info if not in a git repo
  read -p "Enter GitHub repository (format: owner/repo): " REPO_PATH
else
  REPO_PATH=$(echo $REMOTE_URL | sed -E 's|.*/([^/]*/[^/]*)(\.git)?|\1|')
fi

OWNER=$(echo $REPO_PATH | cut -d '/' -f 1)
REPO=$(echo $REPO_PATH | cut -d '/' -f 2)

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  echo "Error: Could not determine repository owner and name"
  echo "Please provide a valid repository in the format owner/repo"
  exit 1
fi

echo "Using repository: $OWNER/$REPO"

# For public repositories, we can pull images without authentication
echo "Configuring for public repository access..."

# Check for required tools
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required for JSON parsing"
  echo "Install jq with: apt-get install jq or sudo apt install jq"
  exit 1
fi

if ! command -v unzip &> /dev/null; then
  echo "Error: unzip is required for artifact extraction"
  echo "Install unzip with: apt-get install unzip or sudo apt install unzip"
  exit 1
fi

# Get artifacts without authentication for public repos
echo "Fetching latest deployment artifacts..."
ARTIFACT_URL="https://api.github.com/repos/$OWNER/$REPO/actions/artifacts"
ARTIFACT_JSON=$(curl -s "$ARTIFACT_URL")

# Debug the response
echo "Debugging API response..."
echo "$ARTIFACT_JSON" | grep -q "message" && echo "API response contains a message/error"

# Check for errors or empty responses
if [ -z "$ARTIFACT_JSON" ]; then
  echo "Error: Empty response from GitHub API"
  exit 1
fi

if echo "$ARTIFACT_JSON" | grep -q "message.*API rate limit"; then
  echo "Warning: GitHub API rate limit reached. Using anonymous access may have stricter rate limits."
  echo "Consider setting GITHUB_TOKEN if you continue to experience issues."
  exit 1
fi

if echo "$ARTIFACT_JSON" | grep -q "message.*Not Found"; then
  echo "Error: Repository not found or you don't have access to it."
  echo "Please check the repository name and your permissions."
  echo "Repository: $OWNER/$REPO"
  exit 1
fi

# Safer jq parsing with error checking
if ! echo "$ARTIFACT_JSON" | jq -e '.artifacts' > /dev/null 2>&1; then
  echo "Error: Could not parse artifacts from API response"
  echo "Response may be invalid or repository might not have any artifacts."
  
  # Create a simple docker-compose file manually instead
  echo "Creating a basic docker-compose.prod.yml manually..."
  cat > docker-compose.prod.yml << EOF
services:
  websocket-server:
    image: ghcr.io/$OWNER/$REPO-websocket-server:latest
    environment:
      - PORT=8081
      - PUBLIC_URL=\${PUBLIC_URL:-https://realtime.sandbox.rauda.ai}
    restart: unless-stopped
    networks:
      - app-network

  webapp:
    image: ghcr.io/$OWNER/$REPO-webapp:latest
    environment:
      - WEBSOCKET_SERVER_URL=http://websocket-server:8081
      - NEXT_PUBLIC_WEBSOCKET_SERVER_URL=\${PUBLIC_URL:-https://realtime.sandbox.rauda.ai}
    restart: unless-stopped
    networks:
      - app-network

  caddy:
    image: caddy:2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - app-network
    depends_on:
      - webapp
      - websocket-server

networks:
  app-network:
    driver: bridge

volumes:
  caddy_data:
  caddy_config:
EOF

  # Skip artifact download
  echo "Skipping artifact download and using default images."
  echo "NOTE: You should run the GitHub workflow before deployment."
  
  # Check if Caddyfile exists
  if [ ! -f Caddyfile ]; then
    echo "Creating a basic Caddyfile..."
    cat > Caddyfile << EOF
realtime.sandbox.rauda.ai {
    # TLS with automatic HTTPS
    tls {
        protocols tls1.2 tls1.3
    }
    
    # WebSocket server endpoints (no auth)
    @websocket {
        path /call/* /logs/* /twiml /tools /public-url
    }
    
    handle @websocket {
        reverse_proxy websocket-server:8081
    }

    # Web application (with auth)
    handle_path /* {
        basicauth {
            admin \$2a\$04\$E5B82evgUf3FIXcEGKC7I.Ek4rquocMfpPpg5Xm1Cb4hjKz6/LyT2
        }
        reverse_proxy webapp:3000
    }

    log {
        output stdout
    }
}
EOF
  fi
  
  # Skip to the docker-compose section
  echo "Continuing with deployment using default configuration..."
  SKIP_ARTIFACT=true
else
  # Normal artifact handling
  ARTIFACT_INFO=$(echo "$ARTIFACT_JSON" | jq -e '.artifacts | map(select(.name == "deployment-files")) | sort_by(.created_at) | reverse | .[0]' 2>/dev/null || echo "null")
  if [ "$ARTIFACT_INFO" = "null" ]; then
    echo "Error: Could not find deployment-files artifact in repository $OWNER/$REPO"
    echo "Please ensure GitHub Actions workflow has run successfully."
    exit 1
  fi

  ARTIFACT_ID=$(echo $ARTIFACT_INFO | jq -r '.id')
  SKIP_ARTIFACT=false
fi

# Only download artifacts if we didn't skip earlier
if [ "$SKIP_ARTIFACT" != "true" ]; then
  # Download the artifact - for public repos, we can often download without a token
  echo "Downloading artifact $ARTIFACT_ID..."
  curl -s -L -o artifact.zip "https://nightly.link/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID.zip"

  # If nightly.link fails, suggest using a token
  if [ ! -s artifact.zip ]; then
    echo "Warning: Could not download artifact using public access."
    echo "For GitHub Actions artifacts, you may need to use a personal access token."
    echo "Try: GITHUB_TOKEN=your_token ./deploy.sh"
    
    # If GITHUB_TOKEN is available, try with authentication
    if [ ! -z "$GITHUB_TOKEN" ]; then
      echo "Attempting download with provided GITHUB_TOKEN..."
      curl -s -L -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
        -o artifact.zip
      
      if [ ! -s artifact.zip ]; then
        echo "Error: Failed to download artifact even with authentication."
        echo "Using default configuration instead..."
        SKIP_ARTIFACT=true
      fi
    else
      echo "Using default configuration instead..."
      SKIP_ARTIFACT=true
    fi
  fi

  # Only extract if we have an artifact
  if [ "$SKIP_ARTIFACT" != "true" ]; then
    # Extract the artifact
    echo "Extracting deployment files..."
    unzip -o artifact.zip
    rm artifact.zip
  fi
fi

# Check if we need to update env file
if [ ! -f .env ]; then
  echo "Creating .env file..."
  touch .env
  echo "IMPORTANT: Please update the .env file with your OPENAI_API_KEY and other configuration"
fi

# Since this is a public repository, we don't need authentication for pulling images
echo "Setting up to pull from public registry..."

# Check if we need to pull explicitly
echo "Pulling Docker images..."
docker-compose -f docker-compose.prod.yml pull || {
  echo "Warning: Failed to pull images directly."
  echo "For public packages, make sure they have been published with public visibility."
  
  if [ ! -z "$GITHUB_TOKEN" ] && [ ! -z "$GITHUB_USERNAME" ]; then
    echo "Attempting to authenticate with provided credentials..."
    echo -n "$GITHUB_USERNAME:$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
  fi
}

# Stop any running containers
echo "Stopping any running containers..."
docker-compose down || true

# Start with the new configuration
echo "Starting services with the new configuration..."
docker-compose -f docker-compose.prod.yml up -d

echo "Deployment completed successfully!"
echo "Your application should be running at https://realtime.sandbox.rauda.ai"
