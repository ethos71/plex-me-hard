#!/bin/bash
# Subtitle Downloader Script for Plex-Me-Hard
# Downloads subtitles for all existing media files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "  Subtitle Downloader for Plex-Me-Hard"
echo "=========================================="
echo ""

echo "Downloading subtitles for all media files..."
echo ""

# Run subtitle downloader via Docker
cd "$PROJECT_DIR/plex" && docker compose exec -T converter python3 /app/subtitle_downloader.py

echo ""
echo "✓ Subtitle download complete!"
echo ""
echo "Subtitles have been added to all media files."
echo "Plex will automatically detect them."
