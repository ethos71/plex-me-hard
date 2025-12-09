#!/bin/bash
# Quick command to manually trigger sync from Google Drive

echo "Manually syncing from Google Drive..."
docker-compose exec converter rclone copy gdrive:plex-me-hard /input --verbose --progress

echo ""
echo "Sync complete! Files are now in the input directory."
echo "Converter will automatically process them."
echo ""
echo "Check conversion progress:"
echo "  docker-compose logs -f converter"
