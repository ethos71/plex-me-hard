#!/bin/bash

# Plex-Me-Hard: Migrate to External Drive
# This script moves all Plex data to an external hard drive

set -e

EXTERNAL_DRIVE="/media/dominick/TOSHIBA MQ01ABD1"
PROJECT_DIR="/home/dominick/workspace/plex-me-hard"
PLEX_DATA_DIR="${EXTERNAL_DRIVE}/plex-me-hard"
CRITICAL_THRESHOLD=45  # Alert at 45% to prevent drive failure at 50%

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     PLEX-ME-HARD: MIGRATE TO EXTERNAL DRIVE                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if external drive is mounted
if [ ! -d "$EXTERNAL_DRIVE" ]; then
    echo "❌ ERROR: External drive not found at $EXTERNAL_DRIVE"
    echo "Please ensure your external drive is connected and mounted."
    exit 1
fi

# Check drive capacity - CRITICAL: Drive fails at 50%
DRIVE_USAGE=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $5}' | sed 's/%//')
echo "✓ External Drive Found: $EXTERNAL_DRIVE"
echo "  Available Space: $(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')"
echo "  Current Usage: ${DRIVE_USAGE}%"

if [ "$DRIVE_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
    echo ""
    echo "⚠️  ═══════════════════════════════════════════════════════════"
    echo "⚠️  CRITICAL WARNING: Drive is at ${DRIVE_USAGE}% capacity!"
    echo "⚠️  This drive is KNOWN TO FAIL after 50% capacity."
    echo "⚠️  STOPPING MIGRATION - IMMEDIATE ACTION REQUIRED"
    echo "⚠️  ═══════════════════════════════════════════════════════════"
    echo ""
    echo "Options to resolve:"
    echo "  1. Clean up old/unwatched files"
    echo "  2. Compress existing files"
    echo "  3. Migrate to a new drive"
    echo ""
    exit 1
elif [ "$DRIVE_USAGE" -ge 40 ]; then
    echo "⚠️  Warning: Drive at ${DRIVE_USAGE}% - approaching 45% threshold"
fi
echo ""

# Stop Plex services
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Stopping Plex Services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "${PROJECT_DIR}/plex"
sudo docker compose down
echo "✓ Plex services stopped"
echo ""

# Create directory structure on external drive
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Creating Directory Structure..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
mkdir -p "${PLEX_DATA_DIR}/data/movies"
mkdir -p "${PLEX_DATA_DIR}/data/tv"
mkdir -p "${PLEX_DATA_DIR}/data/music"
mkdir -p "${PLEX_DATA_DIR}/config"
mkdir -p "${PLEX_DATA_DIR}/transcode"
mkdir -p "${PLEX_DATA_DIR}/torrent/downloads"
mkdir -p "${PLEX_DATA_DIR}/torrent/config"
mkdir -p "${PLEX_DATA_DIR}/torrent/watch"
echo "✓ Directory structure created on external drive"
echo ""

# Move data if it exists
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Migrating Data to External Drive..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "${PROJECT_DIR}/data" ]; then
    echo "   → Moving movie library..."
    if [ "$(ls -A ${PROJECT_DIR}/data/movies 2>/dev/null)" ]; then
        rsync -ah --progress "${PROJECT_DIR}/data/movies/" "${PLEX_DATA_DIR}/data/movies/"
        echo "   ✓ Movies moved"
    fi
    
    echo "   → Moving TV shows..."
    if [ "$(ls -A ${PROJECT_DIR}/data/tv 2>/dev/null)" ]; then
        rsync -ah --progress "${PROJECT_DIR}/data/tv/" "${PLEX_DATA_DIR}/data/tv/"
        echo "   ✓ TV shows moved"
    fi
    
    echo "   → Moving music..."
    if [ "$(ls -A ${PROJECT_DIR}/data/music 2>/dev/null)" ]; then
        rsync -ah --progress "${PROJECT_DIR}/data/music/" "${PLEX_DATA_DIR}/data/music/"
        echo "   ✓ Music moved"
    fi
fi

if [ -d "${PROJECT_DIR}/config" ]; then
    echo "   → Moving Plex configuration..."
    rsync -ah --progress "${PROJECT_DIR}/config/" "${PLEX_DATA_DIR}/config/"
    echo "   ✓ Configuration moved"
fi

if [ -d "${PROJECT_DIR}/torrent" ]; then
    echo "   → Moving torrent data..."
    if [ "$(ls -A ${PROJECT_DIR}/torrent/downloads 2>/dev/null)" ]; then
        rsync -ah --progress "${PROJECT_DIR}/torrent/downloads/" "${PLEX_DATA_DIR}/torrent/downloads/"
    fi
    if [ "$(ls -A ${PROJECT_DIR}/torrent/config 2>/dev/null)" ]; then
        rsync -ah --progress "${PROJECT_DIR}/torrent/config/" "${PLEX_DATA_DIR}/torrent/config/"
    fi
    echo "   ✓ Torrent data moved"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Updating Docker Compose Configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup original docker-compose
cp "${PROJECT_DIR}/plex/docker-compose.yml" "${PROJECT_DIR}/plex/docker-compose.yml.backup-$(date +%Y%m%d-%H%M%S)"

# Update docker-compose.yml to use external drive
cat > "${PROJECT_DIR}/plex/docker-compose.yml" << 'EOF'
services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ${EXTERNAL_DRIVE}/plex-me-hard/config:/config
      - ${EXTERNAL_DRIVE}/plex-me-hard/transcode:/transcode
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/movies:/data/movies
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/tv:/data/tv
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/music:/data/music
    restart: unless-stopped

  converter:
    build: ../converter
    container_name: media-converter
    volumes:
      - ../input:/input
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/movies:/output/movies
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/tv:/output/tv
      - ${EXTERNAL_DRIVE}/plex-me-hard/data/music:/output/music
    environment:
      - INPUT_DIR=/input
      - OUTPUT_MOVIES=/output/movies
      - OUTPUT_TV=/output/tv
      - OUTPUT_MUSIC=/output/music
    restart: unless-stopped

  transmission:
    image: lscr.io/linuxserver/transmission:latest
    container_name: transmission
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ${EXTERNAL_DRIVE}/plex-me-hard/torrent/config:/config
      - ${EXTERNAL_DRIVE}/plex-me-hard/torrent/downloads:/downloads
      - ${EXTERNAL_DRIVE}/plex-me-hard/torrent/watch:/watch
      - ../input:/input
    ports:
      - 9091:9091
      - 51413:51413
      - 51413:51413/udp
    restart: unless-stopped
EOF

# Create .env file for docker-compose
cat > "${PROJECT_DIR}/plex/.env" << EOF
EXTERNAL_DRIVE=/media/dominick/TOSHIBA MQ01ABD1
EOF

echo "✓ Docker Compose configuration updated"
echo ""

# Create symbolic links for backward compatibility
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  Creating Symbolic Links..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup and remove old directories
for dir in data config transcode torrent; do
    if [ -d "${PROJECT_DIR}/${dir}" ]; then
        sudo mv "${PROJECT_DIR}/${dir}" "${PROJECT_DIR}/${dir}.backup-$(date +%Y%m%d-%H%M%S)"
    fi
done

# Create symlinks
ln -sf "${PLEX_DATA_DIR}/data" "${PROJECT_DIR}/data"
ln -sf "${PLEX_DATA_DIR}/config" "${PROJECT_DIR}/config"
ln -sf "${PLEX_DATA_DIR}/transcode" "${PROJECT_DIR}/transcode"
ln -sf "${PLEX_DATA_DIR}/torrent" "${PROJECT_DIR}/torrent"

echo "✓ Symbolic links created"
echo ""

# Update scripts to use external drive
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  Verifying Migration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "   Movies on external drive: $(ls -1 ${PLEX_DATA_DIR}/data/movies | wc -l) files"
echo "   Total size: $(du -sh ${PLEX_DATA_DIR}/data | awk '{print $1}')"
echo "   Available space: $(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')"
echo ""

# Start services
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  Starting Plex Services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "${PROJECT_DIR}/plex"
sudo docker compose up -d
echo "✓ Services started"
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ MIGRATION COMPLETE!                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Summary:"
echo "   • Plex data moved to: ${PLEX_DATA_DIR}"
echo "   • Old data backed up in project directory with timestamp"
echo "   • Symbolic links created for compatibility"
echo "   • Docker services restarted with new paths"
echo ""
echo "🎬 Your Plex library is now on the external drive!"
echo "   All future downloads will go directly to the external drive."
echo ""
echo "⚠️  IMPORTANT: Keep the external drive connected!"
echo "   If you disconnect it, Plex won't be able to find your media."
echo ""
