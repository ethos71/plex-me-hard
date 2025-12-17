#!/bin/bash

# Monitor torrent progress - Dragon Ball Z
# This script monitors active torrents and reports their status

echo "=== Torrent Monitoring Script ==="
echo "Checking active torrents..."
echo ""

# Check if transmission-daemon is running
if ! pgrep -x "transmission-da" > /dev/null; then
    echo "⚠️  Transmission daemon is not running"
    exit 1
fi

# Get torrent list
transmission-remote -l 2>/dev/null || {
    echo "⚠️  Could not connect to transmission daemon"
    echo "Trying with authentication..."
    transmission-remote -n 'transmission:transmission' -l
}

echo ""
echo "=== Torrent Details ==="
echo ""

# Get detailed info for each torrent
transmission-remote -t all -i 2>/dev/null || {
    transmission-remote -n 'transmission:transmission' -t all -i
}

echo ""
echo "=== Quick Status ==="
transmission-remote -l 2>/dev/null | grep -E "Done|Downloading|Seeding" || {
    transmission-remote -n 'transmission:transmission' -l | grep -E "Done|Downloading|Seeding"
}

echo ""
echo "Script complete. Run this script anytime to check torrent progress."
