#!/bin/bash

# Script to fix and standardize album metadata for Plex
# Ensures all tracks in an album have consistent artist, album, and album artist tags

set -e

MUSIC_DIR="/home/dominick/Music"

if [ ! -d "$MUSIC_DIR" ]; then
    echo "ERROR: Music directory not found: $MUSIC_DIR"
    exit 1
fi

echo "=========================================="
echo "Fix Album Metadata for Plex"
echo "=========================================="
echo ""

# Check if mid3v2 is installed
if ! command -v mid3v2 &> /dev/null; then
    echo "ERROR: mid3v2 not found. Installing..."
    sudo apt-get update && sudo apt-get install -y python3-mutagen
fi

FIXED_COUNT=0
ALBUM_COUNT=0

# Find all artist directories
find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d | sort | while read -r artist_dir; do
    ARTIST_NAME=$(basename "$artist_dir")
    
    # Find all album directories
    find "$artist_dir" -mindepth 1 -maxdepth 1 -type d | sort | while read -r album_dir; do
        ALBUM_NAME=$(basename "$album_dir")
        ALBUM_COUNT=$((ALBUM_COUNT + 1))
        
        echo "Processing: $ARTIST_NAME / $ALBUM_NAME"
        
        # Count audio files
        AUDIO_FILES=$(find "$album_dir" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a" \) | wc -l)
        
        if [ "$AUDIO_FILES" -eq 0 ]; then
            echo "  ⚠️  No audio files found, skipping..."
            continue
        fi
        
        # Process each audio file
        find "$album_dir" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a" \) | sort | while read -r file; do
            FILENAME=$(basename "$file")
            EXTENSION="${file##*.}"
            
            # Update metadata based on file type
            if [ "$EXTENSION" = "mp3" ]; then
                # For MP3 files, ensure TPE1 (Artist), TALB (Album), and TPE2 (Album Artist) are set
                mid3v2 --artist "$ARTIST_NAME" --album "$ALBUM_NAME" --TPE2 "$ARTIST_NAME" "$file" 2>/dev/null
                FIXED_COUNT=$((FIXED_COUNT + 1))
            elif [ "$EXTENSION" = "flac" ]; then
                # For FLAC files, use metaflac
                if command -v metaflac &> /dev/null; then
                    metaflac --remove-tag=ARTIST --remove-tag=ALBUM --remove-tag=ALBUMARTIST \
                             --set-tag="ARTIST=$ARTIST_NAME" \
                             --set-tag="ALBUM=$ALBUM_NAME" \
                             --set-tag="ALBUMARTIST=$ARTIST_NAME" "$file" 2>/dev/null
                    FIXED_COUNT=$((FIXED_COUNT + 1))
                fi
            fi
        done
        
        echo "  ✅ Updated $AUDIO_FILES files"
    done
done

echo ""
echo "=========================================="
echo "Metadata Fix Complete!"
echo "=========================================="
echo "Fixed metadata for all albums"
echo ""
echo "Plex should now properly recognize all albums."
echo "Refresh your Plex library to see the changes."
