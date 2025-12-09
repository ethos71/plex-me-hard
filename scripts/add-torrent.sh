#!/bin/bash
# Torrent Processing Script for Plex-Me-Hard
# Downloads torrents via magnet links and adds them directly to Plex

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TORRENT_DIR="$PROJECT_DIR/torrent/downloads"
MOVIES_DIR="$PROJECT_DIR/data/movies"
TV_DIR="$PROJECT_DIR/data/tv"
MUSIC_DIR="$PROJECT_DIR/data/music"
MAGNET_LOG="$PROJECT_DIR/torrent/magnet-links.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <magnet-link> [--type movies|tv|music]"
    echo ""
    echo "Examples:"
    echo "  $0 'magnet:?xt=urn:btih:...' --type movies"
    echo "  $0 'magnet:?xt=urn:btih:...' --type tv"
    echo "  $0 'magnet:?xt=urn:btih:...' --type music"
    echo ""
    echo "Options:"
    echo "  --type     Specify media type (movies, tv, music). Required."
    exit 1
}

extract_name_from_magnet() {
    local magnet_link="$1"
    # Extract the name from the dn= parameter
    echo "$magnet_link" | grep -oP '(?<=dn=)[^&]+' | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))" || echo "Unknown"
}

log_magnet_link() {
    local magnet_link="$1"
    local media_type="$2"
    local name=$(extract_name_from_magnet "$magnet_link")
    local timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    local date_header=$(date '+%Y-%m-%d')
    
    # Create log file if it doesn't exist
    if [ ! -f "$MAGNET_LOG" ]; then
        cat > "$MAGNET_LOG" << 'EOF'
# Torrent Magnet Links History
# Auto-generated list of all torrent magnet links added to Plex-Me-Hard

## Format
Each entry includes:
- Date/Time added
- Movie/Show name (extracted from magnet link)
- Media type
- Magnet link

---

EOF
    fi
    
    # Append the new entry
    cat >> "$MAGNET_LOG" << EOF

## $date_header

### $name
- **Added:** $timestamp
- **Type:** $media_type
- **Magnet Link:**
\`\`\`
$magnet_link
\`\`\`

---

EOF
    
    echo -e "${GREEN}✓ Magnet link logged to: $MAGNET_LOG${NC}"
}

check_dependencies() {
    if ! command -v transmission-cli &> /dev/null; then
        echo -e "${RED}Error: transmission-cli is not installed${NC}"
        echo "Install with: sudo apt-get install transmission-cli transmission-daemon"
        exit 1
    fi
}

download_torrent() {
    local magnet_link="$1"
    
    echo -e "${GREEN}Starting torrent download...${NC}"
    echo "Download directory: $TORRENT_DIR"
    
    # Download using transmission-cli
    transmission-cli \
        --download-dir "$TORRENT_DIR" \
        "$magnet_link"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Download complete!${NC}"
        return 0
    else
        echo -e "${RED}✗ Download failed${NC}"
        return 1
    fi
}

move_to_plex() {
    local media_type="$1"
    local dest_dir=""
    
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
        *)
            echo -e "${RED}Error: Invalid media type${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}Moving files to Plex library: $media_type${NC}"
    
    # Find all media files and move to appropriate directory
    find "$TORRENT_DIR" -type f \( \
        -iname "*.mp4" -o \
        -iname "*.mkv" -o \
        -iname "*.avi" -o \
        -iname "*.mov" -o \
        -iname "*.mp3" -o \
        -iname "*.flac" -o \
        -iname "*.wav" -o \
        -iname "*.m4a" \
    \) -exec mv {} "$dest_dir/" \;
    
    echo -e "${GREEN}✓ Files moved to $dest_dir${NC}"
    echo "Plex will automatically detect them."
}

cleanup_torrent_dir() {
    echo -e "${YELLOW}Cleaning up torrent directory...${NC}"
    rm -rf "$TORRENT_DIR"/*
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

main() {
    if [ "$#" -lt 2 ]; then
        usage
    fi
    
    local magnet_link="$1"
    local media_type=""
    
    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type)
                media_type="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                usage
                ;;
        esac
    done
    
    if [ -z "$media_type" ]; then
        echo -e "${RED}Error: --type is required${NC}"
        usage
    fi
    
    # Validate magnet link
    if [[ ! "$magnet_link" =~ ^magnet:\?xt=urn: ]]; then
        echo -e "${RED}Error: Invalid magnet link${NC}"
        usage
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create directories if they don't exist
    mkdir -p "$TORRENT_DIR" "$MOVIES_DIR" "$TV_DIR" "$MUSIC_DIR"
    
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Plex-Me-Hard Torrent Processor${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    
    # Log the magnet link
    log_magnet_link "$magnet_link" "$media_type"
    echo ""
    
    # Download torrent
    if download_torrent "$magnet_link"; then
        # Move files directly to Plex library
        move_to_plex "$media_type"
        
        # Cleanup
        cleanup_torrent_dir
        
        echo ""
        echo -e "${GREEN}==================================${NC}"
        echo -e "${GREEN}✓ Process Complete!${NC}"
        echo -e "${GREEN}==================================${NC}"
        echo ""
        echo "Files have been added to your Plex library!"
        echo "Media type: $media_type"
        echo "Location: data/$media_type/"
        echo ""
        echo "Open Plex to watch: http://192.168.12.143:32400/web"
    else
        echo -e "${RED}Failed to process torrent${NC}"
        exit 1
    fi
}

main "$@"
