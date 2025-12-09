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

echo "=========================================="
echo "  Processing Completed Torrents"
echo "=========================================="
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
    
    echo "=========================================="
    echo "  Downloading Subtitles"
    echo "=========================================="
    echo ""
    
    # Download subtitles for new movies/TV shows
    cd "$PROJECT_ROOT/plex"
    if sudo docker compose ps | grep -q "converter.*Up"; then
        sudo docker compose exec converter python3 /app/subtitle_downloader.py || echo "Subtitle download completed with warnings"
    else
        echo "Converter not running, skipping subtitle download"
    fi
    
    echo ""
    echo "=========================================="
    echo "  Removing Completed Torrents"
    echo "=========================================="
    echo ""
    
    # Remove completed torrents from Transmission
    cd "$PROJECT_ROOT/plex"
    if sudo docker compose ps | grep -q "transmission.*Up"; then
        # Get list of completed torrents
        sudo docker compose exec transmission transmission-remote -l | grep "100%" | awk '{print $1}' | grep -v "^ID$" | while read -r torrent_id; do
            if [ -n "$torrent_id" ]; then
                echo "Removing torrent ID: $torrent_id"
                sudo docker compose exec transmission transmission-remote -t "$torrent_id" --remove-and-delete
            fi
        done
    fi
    
    echo ""
    echo "✓ Processing complete!"
    echo ""
    echo "Files have been:"
    echo "  1. Moved to appropriate Plex directories"
    echo "  2. Subtitles downloaded (where available)"
    echo "  3. Torrent files removed from Transmission"
    echo "  4. Downloaded data cleaned up"
    echo ""
    echo "Plex will automatically detect the new media!"
    
else
    echo "No completed torrents directory found"
fi
