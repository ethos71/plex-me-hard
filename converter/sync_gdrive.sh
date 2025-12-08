#!/bin/bash

# Sync files from Google Drive to input directory
# This runs continuously in the background

GDRIVE_FOLDER="${GDRIVE_FOLDER:-plex-me-hard}"
SYNC_INTERVAL="${SYNC_INTERVAL:-300}"  # 5 minutes default

echo "Starting Google Drive sync..."
echo "Google Drive folder: $GDRIVE_FOLDER"
echo "Sync interval: $SYNC_INTERVAL seconds"

while true; do
    echo "[$(date)] Syncing from Google Drive..."
    
    # Copy files from Google Drive to input directory
    rclone copy "gdrive:$GDRIVE_FOLDER" /input --verbose --transfers 4 --checkers 8
    
    if [ $? -eq 0 ]; then
        echo "[$(date)] Sync completed successfully"
    else
        echo "[$(date)] Sync failed with error code $?"
    fi
    
    sleep $SYNC_INTERVAL
done
