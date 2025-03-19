#!/bin/bash

# This script installs and starts the realtime-demo service

echo "Installing realtime-demo service..."

# Copy service file to system directory
sudo cp realtime-demo.service /etc/systemd/system/

# Create directory for environment overrides
sudo mkdir -p /etc/systemd/system/realtime-demo.service.d/

# Create the override file for environment variables
cat > override.conf << EOF
[Service]
# Uncomment and set your environment variables below
# Environment="OPENAI_API_KEY=your_key_here"
EOF

sudo cp override.conf /etc/systemd/system/realtime-demo.service.d/
rm override.conf

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable realtime-demo.service

# Start the service
sudo systemctl start realtime-demo.service

echo "Service installed and started. Check status with: sudo systemctl status realtime-demo.service"
echo "View logs with: sudo journalctl -u realtime-demo.service -f"