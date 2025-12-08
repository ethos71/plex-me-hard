#!/bin/bash
# Diagnostic script to check where Kingdom of Heaven movie is in the pipeline

echo "==================================================="
echo "Plex-Me-Hard - Diagnostic Check"
echo "==================================================="
echo ""

echo "Step 1: Checking if services are running..."
echo "---------------------------------------------------"
docker-compose ps
echo ""

echo "Step 2: Checking Google Drive for Kingdom of Heaven..."
echo "---------------------------------------------------"
echo "Looking for Kingdom of Heaven in Google Drive plex-me-hard folder:"
docker-compose run --rm converter rclone ls gdrive:plex-me-hard 2>/dev/null | grep -i "kingdom" || echo "❌ Not found in Google Drive folder"
echo ""

echo "Step 3: Checking input directory (downloaded from GDrive)..."
echo "---------------------------------------------------"
if [ -d "./input" ]; then
    echo "Files in input directory:"
    ls -lh ./input/ 2>/dev/null | grep -i "kingdom" || echo "❌ Not found in input directory"
else
    echo "❌ input directory doesn't exist yet"
fi
echo ""

echo "Step 4: Checking converted movies directory..."
echo "---------------------------------------------------"
if [ -d "./data/movies" ]; then
    echo "Files in data/movies directory:"
    ls -lh ./data/movies/ 2>/dev/null | grep -i "kingdom" || echo "❌ Not found in movies directory"
else
    echo "❌ data/movies directory doesn't exist yet"
fi
echo ""

echo "Step 5: Checking all directories for Kingdom of Heaven..."
echo "---------------------------------------------------"
find ./input ./data -name "*ingdom*" 2>/dev/null || echo "❌ File not found anywhere locally"
echo ""

echo "Step 6: Recent converter logs (last 30 lines)..."
echo "---------------------------------------------------"
docker-compose logs --tail=30 converter 2>/dev/null
echo ""

echo "==================================================="
echo "Diagnosis Summary"
echo "==================================================="
echo ""
echo "If file is in Google Drive but NOT in input/:"
echo "  → Run: ./sync-now.sh"
echo ""
echo "If file is in input/ but NOT converting:"
echo "  → Check logs: docker-compose logs -f converter"
echo "  → File may be downloading still"
echo ""
echo "If file is in data/movies/:"
echo "  → Refresh Plex library or wait for auto-scan"
echo "  → Visit: http://localhost:32400/web"
echo ""
