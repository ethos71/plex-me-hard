#!/bin/bash
# Script to move media files from Downloads to Plex libraries

set -e

DOWNLOADS_DIR="/home/dominick/Downloads"
MOVIES_DIR="/var/lib/plexmediaserver/Movies"
TV_DIR="/var/lib/plexmediaserver/TV Shows"
MUSIC_DIR="/var/lib/plexmediaserver/Music"

if [ -z "$1" ]; then
    echo "Usage: $0 <filename> [movies|tv|music]"
    echo "Example: $0 'Kingdom of Heaven.mp4' movies"
    exit 1
fi

FILENAME="$1"
TYPE="${2:-movies}"

SOURCE="$DOWNLOADS_DIR/$FILENAME"

if [ ! -f "$SOURCE" ]; then
    echo "Error: File not found: $SOURCE"
    exit 1
fi

case "$TYPE" in
    movies)
        DEST_DIR="$MOVIES_DIR"
        ;;
    tv)
        DEST_DIR="$TV_DIR"
        ;;
    music)
        DEST_DIR="$MUSIC_DIR"
        ;;
    *)
        echo "Error: Invalid type. Use: movies, tv, or music"
        exit 1
        ;;
esac

echo "Moving $FILENAME to $DEST_DIR..."
sudo mv "$SOURCE" "$DEST_DIR/"

echo "Fixing permissions..."
sudo chown plex:plex "$DEST_DIR/$FILENAME"

echo "File moved successfully!"
echo "Plex will scan and add it automatically within a few minutes."
echo "You can also manually scan the library in Plex web UI."
