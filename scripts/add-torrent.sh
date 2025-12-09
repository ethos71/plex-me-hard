#!/bin/bash
# Torrent Processing Script for Plex-Me-Hard
# Downloads torrents via magnet links and processes them through the converter

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TORRENT_DIR="$PROJECT_DIR/torrent/downloads"
INPUT_DIR="$PROJECT_DIR/input"

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
    echo "  $0 'magnet:?xt=urn:btih:...'"
    echo ""
    echo "Options:"
    echo "  --type     Specify media type (movies, tv, music). Auto-detects if not specified."
    exit 1
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
        --finish "$INPUT_DIR" \
        "$magnet_link"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Download complete!${NC}"
        return 0
    else
        echo -e "${RED}✗ Download failed${NC}"
        return 1
    fi
}

move_to_input() {
    echo -e "${GREEN}Moving files to converter input...${NC}"
    
    # Find all downloaded files and move to input
    find "$TORRENT_DIR" -type f \( \
        -iname "*.mp4" -o \
        -iname "*.mkv" -o \
        -iname "*.avi" -o \
        -iname "*.mov" -o \
        -iname "*.mp3" -o \
        -iname "*.flac" -o \
        -iname "*.wav" \
    \) -exec mv {} "$INPUT_DIR/" \;
    
    echo -e "${GREEN}✓ Files moved to input folder for processing${NC}"
    echo "The converter will automatically process them."
}

cleanup_torrent_dir() {
    echo -e "${YELLOW}Cleaning up torrent directory...${NC}"
    rm -rf "$TORRENT_DIR"/*
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

main() {
    if [ "$#" -lt 1 ]; then
        usage
    fi
    
    local magnet_link="$1"
    local media_type="${2:-auto}"
    
    # Validate magnet link
    if [[ ! "$magnet_link" =~ ^magnet:\?xt=urn: ]]; then
        echo -e "${RED}Error: Invalid magnet link${NC}"
        usage
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create directories if they don't exist
    mkdir -p "$TORRENT_DIR" "$INPUT_DIR"
    
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Plex-Me-Hard Torrent Processor${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    
    # Download torrent
    if download_torrent "$magnet_link"; then
        # Move files to input for conversion
        move_to_input
        
        # Cleanup
        cleanup_torrent_dir
        
        echo ""
        echo -e "${GREEN}==================================${NC}"
        echo -e "${GREEN}✓ Process Complete!${NC}"
        echo -e "${GREEN}==================================${NC}"
        echo ""
        echo "Files are now being processed by the converter."
        echo "Check conversion progress with:"
        echo "  cd plex && docker compose logs -f converter"
        echo ""
        echo "Files will appear in Plex shortly!"
    else
        echo -e "${RED}Failed to process torrent${NC}"
        exit 1
    fi
}

main "$@"
