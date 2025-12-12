#!/bin/bash

echo "=== Fixing Duplicate Plex Servers ==="

# Stop the current Plex container
echo "Stopping Plex container..."
sudo docker stop plex

# Unclaim the server (this removes it from your Plex account)
echo "Unclaiming server from Plex account..."
sudo rm -f /mnt/external-drive/plex/config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml

# Restart Plex
echo "Restarting Plex..."
sudo docker start plex

echo ""
echo "Waiting for Plex to start..."
sleep 10

echo ""
echo "=== Next Steps ==="
echo "1. Go to http://localhost:32400/web"
echo "2. Sign in with your Plex account: dominick.do.campbell+1@gmail.com"
echo "3. This will claim THIS server as your only server"
echo "4. The duplicate should disappear from your account"
echo ""
echo "If you still see duplicates on plex.tv:"
echo "  - Go to https://app.plex.tv/desktop/#!/settings/servers"
echo "  - Delete any old/offline servers manually"
