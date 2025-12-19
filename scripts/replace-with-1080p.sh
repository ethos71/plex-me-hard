#!/bin/bash
# Replace original videos with upscaled 1080p versions
# SAFETY: Creates backups before replacing

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

UPSCALED_DIR="/home/dominick/Videos/Upscaled_1080p"
VIDEOS_DIR="/home/dominick/Videos"
BACKUP_DIR="/home/dominick/Videos/Originals_Backup"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Replace original videos with upscaled 1080p versions"
    echo ""
    echo "Options:"
    echo "  --dry-run       Show what would be replaced without making changes"
    echo "  --backup        Create backup of originals (default)"
    echo "  --no-backup     Skip backup (NOT recommended)"
    echo "  --file FILE     Replace only specific file"
    echo "  --all           Replace all upscaled files"
    echo "  --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --dry-run                    # Preview what will be replaced"
    echo "  $0 --file \"Bullitt (1968)\"      # Replace only Bullitt"
    echo "  $0 --all                        # Replace all (with backup)"
    echo "  $0 --all --no-backup            # Replace all (no backup - dangerous!)"
    exit 1
}

# Default options
DRY_RUN=false
BACKUP=true
REPLACE_ALL=false
SPECIFIC_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --backup)
            BACKUP=true
            shift
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --all)
            REPLACE_ALL=true
            shift
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Check if upscaled directory exists
if [ ! -d "$UPSCALED_DIR" ]; then
    echo -e "${RED}Error: Upscaled directory not found: $UPSCALED_DIR${NC}"
    exit 1
fi

# Count upscaled files
upscaled_count=$(ls -1 "$UPSCALED_DIR"/*.mkv 2>/dev/null | wc -l)
if [ "$upscaled_count" -eq 0 ]; then
    echo -e "${RED}Error: No upscaled files found in $UPSCALED_DIR${NC}"
    exit 1
fi

echo "=========================================="
echo "  Video Replacement Tool"
echo "=========================================="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

if [ "$BACKUP" = true ] && [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}✅ Backup enabled - originals will be saved to:${NC}"
    echo "   $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    echo ""
fi

echo "Upscaled files available: $upscaled_count"
echo ""

# Function to get original filename from upscaled filename
get_original_file() {
    local upscaled_file="$1"
    local basename=$(basename "$upscaled_file" "_1080p.mkv")
    
    # Check for different extensions
    for ext in mp4 mkv avi mpg mpeg mov wmv; do
        if [ -f "$VIDEOS_DIR/${basename}.${ext}" ]; then
            echo "$VIDEOS_DIR/${basename}.${ext}"
            return 0
        fi
    done
    
    return 1
}

# Function to compare file sizes
compare_files() {
    local original="$1"
    local upscaled="$2"
    
    orig_size=$(stat -f%z "$original" 2>/dev/null || stat -c%s "$original" 2>/dev/null)
    new_size=$(stat -f%z "$upscaled" 2>/dev/null || stat -c%s "$upscaled" 2>/dev/null)
    
    orig_mb=$((orig_size / 1024 / 1024))
    new_mb=$((new_size / 1024 / 1024))
    
    echo "$orig_mb → $new_mb MB"
}

# Function to replace a single file
replace_file() {
    local upscaled_file="$1"
    local upscaled_name=$(basename "$upscaled_file" "_1080p.mkv")
    
    # Find original file
    original_file=$(get_original_file "$upscaled_file")
    
    if [ $? -ne 0 ] || [ ! -f "$original_file" ]; then
        echo -e "${YELLOW}⚠️  No original found for: $upscaled_name${NC}"
        return 1
    fi
    
    original_name=$(basename "$original_file")
    size_info=$(compare_files "$original_file" "$upscaled_file")
    
    echo -e "${CYAN}📹 $upscaled_name${NC}"
    echo "   Original: $original_name"
    echo "   Size: $size_info"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "   ${YELLOW}[DRY RUN]${NC} Would replace"
        echo ""
        return 0
    fi
    
    # Backup original if enabled
    if [ "$BACKUP" = true ]; then
        echo "   Creating backup..."
        cp "$original_file" "$BACKUP_DIR/"
        if [ $? -ne 0 ]; then
            echo -e "   ${RED}❌ Backup failed!${NC}"
            return 1
        fi
    fi
    
    # Get original extension and filename without extension
    original_ext="${original_file##*.}"
    original_base="${original_file%.*}"
    
    # Remove original
    rm "$original_file"
    
    # Copy upscaled file with original filename but .mkv extension
    # We keep .mkv because that's the output format from upscaling
    cp "$upscaled_file" "${original_base}.mkv"
    
    # Set proper permissions
    sudo chown dominick:dominick "${original_base}.mkv"
    sudo chmod 775 "${original_base}.mkv"
    
    if [ $? -eq 0 ]; then
        echo -e "   ${GREEN}✅ Replaced successfully${NC}"
        
        # If original extension was different, note it
        if [ "$original_ext" != "mkv" ]; then
            echo -e "   ${BLUE}ℹ️  Note: Extension changed from .$original_ext to .mkv${NC}"
        fi
    else
        echo -e "   ${RED}❌ Replacement failed${NC}"
        
        # Restore from backup if it exists
        if [ "$BACKUP" = true ] && [ -f "$BACKUP_DIR/$original_name" ]; then
            echo "   Restoring from backup..."
            cp "$BACKUP_DIR/$original_name" "$original_file"
        fi
        return 1
    fi
    
    echo ""
    return 0
}

# Main logic
if [ ! -z "$SPECIFIC_FILE" ]; then
    # Replace specific file
    upscaled_file="$UPSCALED_DIR/${SPECIFIC_FILE}_1080p.mkv"
    
    if [ ! -f "$upscaled_file" ]; then
        echo -e "${RED}Error: Upscaled file not found: $upscaled_file${NC}"
        exit 1
    fi
    
    replace_file "$upscaled_file"
    
elif [ "$REPLACE_ALL" = true ]; then
    # Replace all files
    echo "=========================================="
    echo "  Processing All Files"
    echo "=========================================="
    echo ""
    
    if [ "$DRY_RUN" = false ] && [ "$BACKUP" = false ]; then
        echo -e "${RED}⚠️  WARNING: No backup will be created!${NC}"
        echo -e "${RED}   Original files will be permanently deleted!${NC}"
        echo ""
        read -p "Are you SURE you want to continue? (type 'yes' to confirm): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Aborted."
            exit 0
        fi
        echo ""
    fi
    
    total=0
    success=0
    failed=0
    skipped=0
    
    for upscaled_file in "$UPSCALED_DIR"/*.mkv; do
        ((total++))
        
        if replace_file "$upscaled_file"; then
            ((success++))
        else
            if [ -f "$(get_original_file "$upscaled_file")" ]; then
                ((failed++))
            else
                ((skipped++))
            fi
        fi
    done
    
    echo "=========================================="
    echo "  Summary"
    echo "=========================================="
    echo "Total files processed: $total"
    echo -e "${GREEN}Successful replacements: $success${NC}"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}Failed: $failed${NC}"
    fi
    if [ $skipped -gt 0 ]; then
        echo -e "${YELLOW}Skipped (no original): $skipped${NC}"
    fi
    
    if [ "$BACKUP" = true ] && [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Originals backed up to: $BACKUP_DIR"
        echo "Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"
    fi
    
else
    # Show available files
    echo "=========================================="
    echo "  Available Upscaled Files"
    echo "=========================================="
    echo ""
    
    for upscaled_file in "$UPSCALED_DIR"/*.mkv; do
        upscaled_name=$(basename "$upscaled_file" "_1080p.mkv")
        original_file=$(get_original_file "$upscaled_file")
        
        if [ $? -eq 0 ] && [ -f "$original_file" ]; then
            size_info=$(compare_files "$original_file" "$upscaled_file")
            echo -e "${GREEN}✅${NC} $upscaled_name"
            echo "   Size: $size_info"
        else
            echo -e "${YELLOW}⚠️${NC} $upscaled_name (no original found)"
        fi
        echo ""
    done
    
    echo "=========================================="
    echo "  Next Steps"
    echo "=========================================="
    echo ""
    echo "1. Review upscaled files in: $UPSCALED_DIR"
    echo "2. Test quality by watching a few files"
    echo "3. When ready, replace files:"
    echo ""
    echo "   # Preview what will happen (safe)"
    echo "   $0 --dry-run --all"
    echo ""
    echo "   # Replace specific file"
    echo "   $0 --file \"Bullitt (1968)\""
    echo ""
    echo "   # Replace all files (with backup)"
    echo "   $0 --all"
    echo ""
    echo "Tip: Originals will be backed up to: $BACKUP_DIR"
    echo ""
fi
