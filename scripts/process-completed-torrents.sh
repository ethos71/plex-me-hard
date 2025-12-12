#!/bin/bash

# Process Completed Torrents Script
# Moves completed downloads to Plex, downloads subtitles, and cleans up

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TORRENT_COMPLETE="$PROJECT_ROOT/torrent/downloads/complete"
MOVIES_DIR="$PROJECT_ROOT/data/movies"
MUSIC_DIR="$PROJECT_ROOT/data/music"
TV_DIR="$PROJECT_ROOT/data/tv"
EXTERNAL_DRIVE="/media/dominick/TOSHIBA MQ01ABD1"
CRITICAL_THRESHOLD=45  # Alert at 45% to prevent drive failure at 50%

echo "=========================================="
echo "  Processing Completed Torrents"
echo "=========================================="
echo ""

# Check drive capacity before processing - CRITICAL: Drive fails at 50%
if [ -d "$EXTERNAL_DRIVE" ]; then
    DRIVE_USAGE=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "External Drive Capacity: ${DRIVE_USAGE}%"
    
    if [ "$DRIVE_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
        echo ""
        echo "⚠️  ═══════════════════════════════════════════════════════════"
        echo "⚠️  CRITICAL WARNING: Drive is at ${DRIVE_USAGE}% capacity!"
        echo "⚠️  This drive is KNOWN TO FAIL after 50% capacity."
        echo "⚠️  STOPPING - CANNOT PROCESS MORE FILES"
        echo "⚠️  ═══════════════════════════════════════════════════════════"
        echo ""
        echo "Required actions:"
        echo "  1. Clean up old/unwatched files"
        echo "  2. Compress existing files"
        echo "  3. Migrate to a new drive"
        echo ""
        exit 1
    elif [ "$DRIVE_USAGE" -ge 40 ]; then
        echo "⚠️  Warning: Drive at ${DRIVE_USAGE}% - approaching 45% threshold"
    fi
fi
echo ""

# Function to determine media type
get_media_type() {
    local filename="$1"
    
    # Check if it's a TV show (contains S##E## or S##)
    if [[ "$filename" =~ [Ss][0-9]{1,2}[Ee][0-9]{1,2} ]] || [[ "$filename" =~ [Ss][0-9]{1,2} ]]; then
        echo "tv"
    # Check if it's music (contains common music formats in path or album keywords)
    elif [[ "$filename" =~ \.(mp3|flac|m4a|wav|ogg)$ ]] || [[ "$filename" =~ [Aa]lbum|[Dd]iscography ]]; then
        echo "music"
    else
        echo "movies"
    fi
}

# Process completed torrents
if [ -d "$TORRENT_COMPLETE" ]; then
    echo "Scanning: $TORRENT_COMPLETE"
    echo ""
    
    # Find all video and audio files
    find "$TORRENT_COMPLETE" -type f \( \
        -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \
        -o -name "*.flv" -o -name "*.wmv" -o -name "*.m4v" -o -name "*.webm" \
        -o -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.wav" \
    \) | while read -r file; do
        filename=$(basename "$file")
        dirname=$(basename "$(dirname "$file")")
        
        echo "Found: $filename"
        
        # Determine destination
        media_type=$(get_media_type "$filename")
        
        case "$media_type" in
            movies)
                dest_dir="$MOVIES_DIR"
                ;;
            tv)
                dest_dir="$TV_DIR"
                ;;
            music)
                dest_dir="$MUSIC_DIR"
                ;;
        esac
        
        echo "  Type: $media_type"
        echo "  Destination: $dest_dir"
        
        # Move file to destination
        sudo mv "$file" "$dest_dir/"
        echo "  ✓ Moved to Plex"
        
        # Remove empty parent directory
        parent_dir=$(dirname "$file")
        if [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir")" ]; then
            sudo rm -rf "$parent_dir"
            echo "  ✓ Cleaned up torrent folder"
        fi
        
        echo ""
    done
    
    # Fix permissions
    sudo chown -R 1000:1000 "$MOVIES_DIR" "$MUSIC_DIR" "$TV_DIR" 2>/dev/null || true
    
    echo ""
    echo "=========================================="
    echo "  Stopping and Removing Completed Torrents"
    echo "=========================================="
    echo ""
    
    # Remove completed torrents from Transmission (stops seeding and removes magnet links)
    cd "$PROJECT_ROOT/plex"
    if sudo docker compose ps | grep -q "transmission.*Up"; then
        # Get list of completed torrents
        sudo docker compose exec transmission transmission-remote -l | grep "100%" | awk '{print $1}' | grep -v "^ID$" | while read -r torrent_id; do
            if [ -n "$torrent_id" ]; then
                echo "Stopping and removing torrent ID: $torrent_id (stops seeding)"
                sudo docker compose exec transmission transmission-remote -t "$torrent_id" --remove-and-delete
            fi
        done
        echo "✓ All completed torrents stopped and removed"
    else
        echo "⚠️  Transmission not running, cannot remove torrents"
    fi
    
    echo ""
    echo "✓ Processing complete!"
    echo ""
    echo "Files have been:"
    echo "  1. Moved to appropriate Plex directories"
    echo "  2. Torrents stopped (no longer seeding)"
    echo "  3. Magnet links and torrent files removed from Transmission"
    echo "  4. Downloaded data cleaned up"
    echo ""
    echo "Plex will automatically detect the new media!"
    
else
    echo "No completed torrents directory found"
fi
