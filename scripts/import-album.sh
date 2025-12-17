#!/bin/bash

# Script to import album from zip file to Plex Music library
# Usage: ./import-album.sh "path/to/album.zip" "Artist Name" "Album Name"

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <zip_file> <artist_name> <album_name>"
    echo "Example: $0 '/path/to/album.zip' '311' 'Transistor'"
    exit 1
fi

ZIP_FILE="$1"
ARTIST_NAME="$2"
ALBUM_NAME="$3"
MUSIC_DIR="/home/dominick/Music"
DEST_DIR="$MUSIC_DIR/$ARTIST_NAME/$ALBUM_NAME"
TEMP_DIR="/tmp/album_import_$$"

echo "=========================================="
echo "Plex Album Import Script"
echo "=========================================="
echo "Zip File:    $ZIP_FILE"
echo "Artist:      $ARTIST_NAME"
echo "Album:       $ALBUM_NAME"
echo "Destination: $DEST_DIR"
echo ""

# Check if zip file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: Zip file not found: $ZIP_FILE"
    exit 1
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"
echo "Extracting files to temporary directory..."

# Extract zip file
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

# Find all audio files (mp3, flac, m4a, wav)
AUDIO_FILES=$(find "$TEMP_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a" -o -iname "*.wav" \) | sort)

if [ -z "$AUDIO_FILES" ]; then
    echo "ERROR: No audio files found in zip"
    rm -rf "$TEMP_DIR"
    exit 1
fi

FILE_COUNT=$(echo "$AUDIO_FILES" | wc -l)
echo "Found $FILE_COUNT audio files"

# Create destination directory
mkdir -p "$DEST_DIR"

# Process each audio file
echo ""
echo "Processing files..."
COUNTER=0

while IFS= read -r file; do
    COUNTER=$((COUNTER + 1))
    FILENAME=$(basename "$file")
    EXTENSION="${FILENAME##*.}"
    
    echo "[$COUNTER/$FILE_COUNT] $FILENAME"
    
    # Use id3v2 or mid3v2 to update metadata if available
    if command -v mid3v2 &> /dev/null; then
        mid3v2 --artist "$ARTIST_NAME" --album "$ALBUM_NAME" "$file" 2>/dev/null || true
    fi
    
    # Copy file to destination
    cp "$file" "$DEST_DIR/"
    
done <<< "$AUDIO_FILES"

# Copy cover art if exists
COVER_FILES=$(find "$TEMP_DIR" -type f \( -iname "cover.*" -o -iname "folder.*" -o -iname "*.jpg" -o -iname "*.png" \) | head -1)
if [ ! -z "$COVER_FILES" ]; then
    echo ""
    echo "Copying cover art..."
    cp "$COVER_FILES" "$DEST_DIR/" 2>/dev/null || true
fi

# Set proper permissions
chown -R dominick:dominick "$DEST_DIR"
chmod -R 755 "$DEST_DIR"

# Clean up
rm -rf "$TEMP_DIR"

# Validate that files were copied successfully
DEST_FILE_COUNT=$(find "$DEST_DIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.m4a" -o -iname "*.wav" \) | wc -l)

if [ "$DEST_FILE_COUNT" -eq "$FILE_COUNT" ]; then
    echo ""
    echo "Validation: All $FILE_COUNT files copied successfully"
    echo "Removing source zip file..."
    rm -f "$ZIP_FILE"
    echo "Zip file removed: $ZIP_FILE"
else
    echo ""
    echo "WARNING: File count mismatch! Expected $FILE_COUNT, found $DEST_FILE_COUNT"
    echo "Keeping zip file for safety: $ZIP_FILE"
fi

echo ""
echo "=========================================="
echo "Import Complete!"
echo "=========================================="
echo "Location: $DEST_DIR"
echo "Files:    $FILE_COUNT tracks"
echo ""
echo "Album is ready for Plex to scan!"
