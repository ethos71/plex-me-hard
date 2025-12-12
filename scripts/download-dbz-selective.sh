#!/bin/bash

# Selective Dragon Ball Z Episode Downloader
# Only downloads Frieza Saga (episodes 75-107) and Cell Saga (episodes 142-194)

TORRENT_HASH="92a665fb276dff9dd2d25b0725559d61504bf739"

# Remove the stopped torrent first
sudo transmission-remote -t 6 -r

# Add torrent without starting, then select only specific files
echo "Adding Dragon Ball Z torrent (selective mode)..."

# Frieza Saga: Episodes 75-107 (DBZ episodes, approximately files for these)
# Cell Saga: Episodes 142-194 (DBZ episodes)

# We'll download in small batches of 10 episodes at a time
# Batch 1: Frieza Saga Start (episodes 75-84)

MAGNET="magnet:?xt=urn:btih:92a665fb276dff9dd2d25b0725559d61504bf739&dn=%5BTC%5D%20%5BSoM%5D%20Dragon%20Ball%20%2F%20Z%20%2F%20GT%20FUNi%20English%20Broadcasts%20Collection%20%5Bv2%5D%20-%20Toonami%2C%20CN%2C%20TV3"

# Add torrent in stopped mode
sudo transmission-remote -a "$MAGNET" --start-paused

# Wait for torrent to be added
sleep 5

# Get the torrent ID
TORRENT_ID=$(sudo transmission-remote -l | grep "Dragon Ball" | awk '{print $1}' | tr -d '*')

echo "Torrent added with ID: $TORRENT_ID"
echo "Listing all files to identify Frieza and Cell saga episodes..."

# List all files
sudo transmission-remote -t "$TORRENT_ID" -f

echo ""
echo "Please review the file list above."
echo "We need to identify files for:"
echo "  - Frieza Saga: DBZ episodes 75-107"
echo "  - Cell Saga: DBZ episodes 142-194"
echo ""
echo "Starting with first batch of 10 Frieza Saga episodes..."
