#!/bin/bash

# Plex-Me-Hard: New Drive Setup Script
# Detects, formats, and configures new external drives for Plex storage

set -e

echo "==================================================================="
echo "  Plex-Me-Hard: New Drive Setup"
echo "==================================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display drives
show_drives() {
    echo -e "${BLUE}Current drives detected:${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL,VENDOR
    echo ""
}

# Function to check for new drives
detect_new_drives() {
    echo -e "${BLUE}Scanning for available drives...${NC}"
    echo ""
    
    # Get list of unmounted drives (excluding system drive)
    AVAILABLE_DRIVES=$(lsblk -ndo NAME,SIZE,TYPE | grep "disk" | grep -v "nvme0n1")
    
    if [ -z "$AVAILABLE_DRIVES" ]; then
        echo -e "${RED}No external drives detected.${NC}"
        echo ""
        echo "Please ensure:"
        echo "  1. Drive is properly connected"
        echo "  2. Drive has power (if external enclosure)"
        echo "  3. USB cable is functional"
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}Available drives:${NC}"
    echo "$AVAILABLE_DRIVES" | nl
    echo ""
}

# Show current state
show_drives

# Detect available drives
detect_new_drives

# Prompt for drive selection
echo -e "${YELLOW}Which drive would you like to format for Plex storage?${NC}"
echo ""
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL | grep -E "NAME|sd[b-z]"
echo ""
read -p "Enter drive name (e.g., sdb): " DRIVE_NAME

# Validate drive selection
if [ -z "$DRIVE_NAME" ]; then
    echo -e "${RED}No drive name provided. Exiting.${NC}"
    exit 1
fi

DRIVE_PATH="/dev/$DRIVE_NAME"

if [ ! -b "$DRIVE_PATH" ]; then
    echo -e "${RED}Error: $DRIVE_PATH is not a valid block device.${NC}"
    exit 1
fi

# Safety check - don't format system drive
if [[ "$DRIVE_NAME" == "nvme0n1" ]] || [[ "$DRIVE_NAME" == "sda" ]]; then
    echo -e "${RED}ERROR: Cannot format system drive or primary external drive!${NC}"
    echo "Drive $DRIVE_NAME appears to be:"
    lsblk "$DRIVE_PATH" -o NAME,SIZE,MOUNTPOINT,FSTYPE
    exit 1
fi

# Show what will be done
echo ""
echo -e "${YELLOW}WARNING: This will ERASE ALL DATA on $DRIVE_PATH${NC}"
lsblk "$DRIVE_PATH" -o NAME,SIZE,TYPE,FSTYPE,MODEL
echo ""
echo "The drive will be:"
echo "  1. Partitioned with a single ext4 partition"
echo "  2. Formatted as ext4 filesystem"
echo "  3. Labeled as 'PLEX-STORAGE-2'"
echo "  4. Mounted at /media/dominick/PLEX-STORAGE-2"
echo "  5. Added to Plex library configuration"
echo ""
read -p "Are you absolutely sure? Type 'YES' to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo -e "${YELLOW}Cancelled. No changes made.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting drive setup...${NC}"
echo ""

# Unmount if mounted
echo "→ Unmounting any existing partitions..."
sudo umount "${DRIVE_PATH}"* 2>/dev/null || true

# Wipe existing partition table
echo "→ Wiping existing partition table..."
sudo wipefs -a "$DRIVE_PATH"

# Create new partition table and partition
echo "→ Creating new GPT partition table..."
sudo parted "$DRIVE_PATH" --script mklabel gpt
sudo parted "$DRIVE_PATH" --script mkpart primary ext4 0% 100%

# Wait for partition to be created
sleep 2

# Format as ext4
PARTITION="${DRIVE_PATH}1"
echo "→ Formatting $PARTITION as ext4..."
sudo mkfs.ext4 -L "PLEX-STORAGE-2" "$PARTITION"

# Create mount point
MOUNT_POINT="/media/dominick/PLEX-STORAGE-2"
echo "→ Creating mount point at $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"

# Get UUID
UUID=$(sudo blkid -s UUID -o value "$PARTITION")
echo "→ Drive UUID: $UUID"

# Add to fstab for auto-mounting
echo "→ Adding to /etc/fstab for auto-mount..."
FSTAB_ENTRY="UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2"

# Check if entry already exists
if grep -q "$UUID" /etc/fstab; then
    echo "  (Entry already exists in fstab)"
else
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
fi

# Mount the drive
echo "→ Mounting drive..."
sudo mount "$PARTITION"

# Set ownership
echo "→ Setting ownership to dominick..."
sudo chown -R dominick:dominick "$MOUNT_POINT"

# Create plex-me-hard directory structure
echo "→ Creating plex-me-hard directory structure..."
mkdir -p "$MOUNT_POINT/plex-me-hard/data/movies"
mkdir -p "$MOUNT_POINT/plex-me-hard/data/tv"
mkdir -p "$MOUNT_POINT/plex-me-hard/data/music"
mkdir -p "$MOUNT_POINT/plex-me-hard/torrent/downloads"
mkdir -p "$MOUNT_POINT/plex-me-hard/config"

# Show final result
echo ""
echo -e "${GREEN}==================================================================="
echo "  Drive Setup Complete! ✅"
echo "===================================================================${NC}"
echo ""
echo "New drive information:"
lsblk "$PARTITION" -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL
echo ""
df -h "$MOUNT_POINT"
echo ""
echo "Directory structure created:"
tree -L 3 "$MOUNT_POINT/plex-me-hard" 2>/dev/null || ls -lR "$MOUNT_POINT/plex-me-hard"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Update Plex library to include: $MOUNT_POINT/plex-me-hard/data/movies"
echo "  2. Configure torrent script to use both drives"
echo "  3. Run drive health monitor on new drive"
echo ""
echo "Commands to add to Plex:"
echo "  Movies: $MOUNT_POINT/plex-me-hard/data/movies"
echo "  TV:     $MOUNT_POINT/plex-me-hard/data/tv"
echo "  Music:  $MOUNT_POINT/plex-me-hard/data/music"
echo ""
echo -e "${GREEN}Drive is ready for use!${NC}"
