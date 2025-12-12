#!/bin/bash

echo "=== Fresh Plex Installation Script ==="
echo "Starting fresh Plex setup..."

# Add Plex repository
echo "Adding Plex repository..."
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo "deb https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

# Update and install
echo "Installing Plex Media Server..."
sudo apt update
sudo apt install -y plexmediaserver

# Create directory structure on external drive
echo "Setting up directories on external drive..."
sudo mkdir -p /media/dominick/plex-me-hard/movies
sudo mkdir -p /media/dominick/plex-me-hard/music
sudo mkdir -p /media/dominick/plex-me-hard/tv
sudo mkdir -p /media/dominick/plex-me-hard/transcode

# Set permissions
echo "Setting permissions..."
sudo chown -R plex:plex /media/dominick/plex-me-hard/
sudo chmod -R 755 /media/dominick/plex-me-hard/

# Start Plex
echo "Starting Plex Media Server..."
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# Wait for Plex to start
echo "Waiting for Plex to initialize..."
sleep 10

# Check status
echo "Checking Plex status..."
sudo systemctl status plexmediaserver --no-pager

echo ""
echo "=== Setup Complete ==="
echo "Access Plex at: http://localhost:32400/web"
echo ""
echo "Next steps:"
echo "1. Open browser to http://localhost:32400/web"
echo "2. Sign in with: dominick.do.campbell+1@gmail.com"
echo "3. Add library pointing to /media/dominick/plex-me-hard/movies"
echo ""
