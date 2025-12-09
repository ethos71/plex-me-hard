#!/bin/bash

# Plex-Me-Hard Complete Pipeline Status
# Shows status of all files from torrents through to Plex

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         PLEX-ME-HARD COMPLETE PIPELINE STATUS               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
date
echo ""

# ============================================================
# SECTION 1: TORRENT STATUS
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 TRANSMISSION - ACTIVE TORRENTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_ROOT/plex"
if sudo docker compose ps | grep -q "transmission.*Up"; then
    sudo docker compose exec transmission transmission-remote -l
    echo ""
    
    # Count torrents by status
    torrent_list=$(sudo docker compose exec transmission transmission-remote -l)
    total_torrents=$(echo "$torrent_list" | grep -v "^ID" | grep -v "^Sum:" | wc -l)
    downloading=$(echo "$torrent_list" | grep "Downloading" | wc -l)
    idle=$(echo "$torrent_list" | grep "Idle" | wc -l)
    complete=$(echo "$torrent_list" | grep "100%" | wc -l)
    
    echo "Summary:"
    echo "  Total Torrents: $total_torrents"
    echo "  ⏬ Downloading: $downloading"
    echo "  ⏸️  Idle/Seeding: $idle"
    echo "  ✅ Complete: $complete"
else
    echo "❌ Transmission is not running"
fi
echo ""

# ============================================================
# SECTION 2: TORRENT DOWNLOADS FOLDER
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 TORRENT DOWNLOADS - STAGING AREA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TORRENT_COMPLETE="$PROJECT_ROOT/torrent/downloads/complete"
TORRENT_INCOMPLETE="$PROJECT_ROOT/torrent/downloads/incomplete"

if [ -d "$TORRENT_COMPLETE" ]; then
    complete_count=$(find "$TORRENT_COMPLETE" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.mp3" -o -name "*.flac" \) 2>/dev/null | wc -l)
    
    echo "📁 Complete Downloads (ready to process): $complete_count files"
    if [ $complete_count -gt 0 ]; then
        echo ""
        find "$TORRENT_COMPLETE" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.mp3" -o -name "*.flac" \) 2>/dev/null | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            filename=$(basename "$file")
            echo "  ✓ $filename ($size)"
        done
    else
        echo "  (No completed files waiting to be processed)"
    fi
else
    echo "  (Download directory not found)"
fi

echo ""

if [ -d "$TORRENT_INCOMPLETE" ]; then
    incomplete_count=$(find "$TORRENT_INCOMPLETE" -type f 2>/dev/null | wc -l)
    echo "📁 Incomplete Downloads (in progress): $incomplete_count files"
    if [ $incomplete_count -gt 0 ]; then
        echo ""
        find "$TORRENT_INCOMPLETE" -type f 2>/dev/null | head -10 | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            filename=$(basename "$file")
            echo "  ⏳ $filename ($size)"
        done
    fi
fi

echo ""

# ============================================================
# SECTION 3: PLEX MEDIA LIBRARIES
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎬 PLEX MEDIA LIBRARIES - FINAL DESTINATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Movies
MOVIES_DIR="$PROJECT_ROOT/data/movies"
if [ -d "$MOVIES_DIR" ]; then
    movie_count=$(find "$MOVIES_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) 2>/dev/null | wc -l)
    subtitle_count=$(find "$MOVIES_DIR" -type f -name "*.srt" 2>/dev/null | wc -l)
    
    echo "🎥 MOVIES: $movie_count files ($subtitle_count with subtitles)"
    echo ""
    
    find "$MOVIES_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) 2>/dev/null | sort | while read -r file; do
        size=$(du -h "$file" | cut -f1)
        filename=$(basename "$file")
        basename_no_ext="${filename%.*}"
        
        # Check for subtitle
        subtitle_marker=""
        if [ -f "$MOVIES_DIR/$basename_no_ext.en.srt" ] || [ -f "$MOVIES_DIR/$basename_no_ext.srt" ]; then
            subtitle_marker=" [📝 Subtitles]"
        fi
        
        echo "  🎬 $filename ($size)$subtitle_marker"
    done
fi

echo ""

# TV Shows
TV_DIR="$PROJECT_ROOT/data/tv"
if [ -d "$TV_DIR" ]; then
    tv_count=$(find "$TV_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) 2>/dev/null | wc -l)
    
    echo "📺 TV SHOWS: $tv_count files"
    if [ $tv_count -gt 0 ]; then
        echo ""
        find "$TV_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) 2>/dev/null | sort | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            filename=$(basename "$file")
            echo "  📺 $filename ($size)"
        done
    fi
fi

echo ""

# Music
MUSIC_DIR="$PROJECT_ROOT/data/music"
if [ -d "$MUSIC_DIR" ]; then
    music_count=$(find "$MUSIC_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" \) 2>/dev/null | wc -l)
    
    echo "🎵 MUSIC: $music_count files"
    if [ $music_count -gt 0 ]; then
        echo ""
        find "$MUSIC_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" \) 2>/dev/null | head -20 | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            filename=$(basename "$file")
            echo "  🎵 $filename ($size)"
        done
        if [ $music_count -gt 20 ]; then
            echo "  ... and $(($music_count - 20)) more files"
        fi
    fi
fi

echo ""

# ============================================================
# SECTION 4: PIPELINE SUMMARY
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 PIPELINE SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

total_in_plex=$((movie_count + tv_count + music_count))
echo "Pipeline Flow:"
echo "  1️⃣  Torrents Active: $total_torrents"
echo "  2️⃣  Downloads Complete (waiting): $complete_count files"
echo "  3️⃣  In Plex (ready to watch): $total_in_plex files"
echo ""

if [ $complete_count -gt 0 ]; then
    echo "⚠️  ACTION REQUIRED:"
    echo "   Run: ./scripts/process-completed-torrents.sh"
    echo "   This will move $complete_count file(s) to Plex and clean up torrents"
    echo ""
fi

# ============================================================
# SECTION 5: MAGNET LINK HISTORY
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 MAGNET LINK HISTORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

MAGNET_FILE="$PROJECT_ROOT/torrent/magnet-links.md"
if [ -f "$MAGNET_FILE" ]; then
    magnet_count=$(grep -c "^###" "$MAGNET_FILE" 2>/dev/null || echo "0")
    echo "Total magnet links added: $magnet_count"
    echo ""
    echo "Recent additions:"
    grep "^###" "$MAGNET_FILE" | tail -5
else
    echo "No magnet link history found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Status check complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
