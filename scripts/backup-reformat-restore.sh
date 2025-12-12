#!/bin/bash

# Backup, Reformat and Restore External Drive Script
# WARNING: This will completely wipe the external drive!

set -e

EXTERNAL_DRIVE="/media/dominick/TOSHIBA MQ01ABD1"
BACKUP_DIR="/home/dominick/plex-backup-temp"
DEVICE="/dev/sda1"

echo "=== External Drive Backup, Reformat & Restore ==="
echo ""
echo "WARNING: This will WIPE the external drive at $DEVICE"
echo "Current mount: $EXTERNAL_DRIVE"
echo ""

# Step 1: Identify plex-me-hard folder
echo "Step 1: Locating plex-me-hard folder..."
if [ -d "$EXTERNAL_DRIVE/plex-me-hard" ]; then
    PLEX_FOLDER="$EXTERNAL_DRIVE/plex-me-hard"
elif [ -d "$EXTERNAL_DRIVE/HPZ-Movies" ]; then
    PLEX_FOLDER="$EXTERNAL_DRIVE/HPZ-Movies"
else
    echo "Error: Could not find plex-me-hard folder on external drive"
    ls -la "$EXTERNAL_DRIVE/"
    exit 1
fi

echo "Found: $PLEX_FOLDER"
du -sh "$PLEX_FOLDER"
echo ""

# Step 2: Backup to local
echo "Step 2: Backing up to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
rsync -avh --progress "$PLEX_FOLDER/" "$BACKUP_DIR/"
echo "Backup complete!"
echo ""

# Step 3: Unmount drive
echo "Step 3: Unmounting external drive..."
sudo umount "$EXTERNAL_DRIVE" || echo "Drive not mounted or already unmounted"
sleep 2
echo ""

# Step 4: Format drive
echo "Step 4: Formatting drive as ext4..."
echo "Device: $DEVICE"
read -p "Are you sure you want to format $DEVICE? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted. Restoring from backup if needed..."
    exit 1
fi

sudo mkfs.ext4 -F "$DEVICE"
echo "Format complete!"
echo ""

# Step 5: Remount drive
echo "Step 5: Remounting drive..."
sudo mount "$DEVICE" "$EXTERNAL_DRIVE"
sudo chown -R dominick:dominick "$EXTERNAL_DRIVE"
echo ""

# Step 6: Restore plex-me-hard folder
echo "Step 6: Restoring plex-me-hard folder..."
mkdir -p "$EXTERNAL_DRIVE/plex-me-hard"
rsync -avh --progress "$BACKUP_DIR/" "$EXTERNAL_DRIVE/plex-me-hard/"
echo "Restore complete!"
echo ""

# Step 7: Cleanup
echo "Step 7: Cleaning up backup..."
rm -rf "$BACKUP_DIR"
echo "Cleanup complete!"
echo ""

# Step 8: Verify
echo "=== Verification ==="
echo "External drive contents:"
ls -lh "$EXTERNAL_DRIVE/"
echo ""
echo "plex-me-hard folder size:"
du -sh "$EXTERNAL_DRIVE/plex-me-hard"
echo ""
echo "Drive space:"
df -h "$EXTERNAL_DRIVE"
echo ""
echo "=== Process Complete! ==="
