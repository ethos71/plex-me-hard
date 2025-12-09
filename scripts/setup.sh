#!/bin/bash
# Quick setup script to configure Google Drive and start syncing

set -e

echo "==================================================="
echo "Plex-Me-Hard - Google Drive Setup & Sync"
echo "==================================================="
echo ""

# Step 1: Configure Google Drive
echo "Step 1: Configuring Google Drive access..."
echo "---------------------------------------------------"
echo "You'll need to:"
echo "1. Choose 'n' for new remote"
echo "2. Name it 'gdrive'"
echo "3. Select 'Google Drive' (usually option 15-18)"
echo "4. Press Enter for default client ID/secret"
echo "5. Choose scope '1' (full access)"
echo "6. Say 'n' to auto config (we're in Docker)"
echo "7. Follow the authentication URL in your browser"
echo "8. Paste the verification code back"
echo ""
read -p "Press Enter to start rclone config..."

docker-compose run --rm converter rclone config

# Step 2: Verify connection
echo ""
echo "Step 2: Verifying Google Drive connection..."
echo "---------------------------------------------------"
echo "Listing your Google Drive folders:"
docker-compose run --rm converter rclone lsd gdrive:

# Step 3: Check for the plex-me-hard folder
echo ""
echo "Step 3: Checking for 'plex-me-hard' folder..."
echo "---------------------------------------------------"
if docker-compose run --rm converter rclone lsd gdrive:plex-me-hard &>/dev/null; then
    echo "✓ Found 'plex-me-hard' folder!"
    echo ""
    echo "Files in plex-me-hard folder:"
    docker-compose run --rm converter rclone ls gdrive:plex-me-hard
else
    echo "⚠ Warning: 'plex-me-hard' folder not found in Google Drive"
    echo "Please create this folder and upload your files to it"
fi

# Step 4: Start services
echo ""
echo "Step 4: Starting Plex and converter services..."
echo "---------------------------------------------------"
docker-compose up -d

echo ""
echo "==================================================="
echo "Setup Complete!"
echo "==================================================="
echo ""
echo "What's happening now:"
echo "  • Google Drive sync: Every 5 minutes"
echo "  • File conversion: Automatic when detected"
echo "  • Plex access: http://localhost:32400/web"
echo ""
echo "Useful commands:"
echo "  • View logs: docker-compose logs -f converter"
echo "  • Manual sync: docker-compose exec converter rclone copy gdrive:plex-me-hard /input -v"
echo "  • Check status: docker-compose ps"
echo ""
echo "Your movie 'Kingdom of Heaven' will appear in Plex once:"
echo "  1. Synced from Google Drive (within 5 min)"
echo "  2. Converted to MP4 format (may take 10-30 min depending on size)"
echo "  3. Detected by Plex (automatic)"
echo ""
