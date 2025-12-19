#!/bin/bash
# Video Upscaler to 1080p using FFmpeg
# Uses high-quality Lanczos algorithm for upscaling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="/home/dominick/Videos/Upscaled_1080p"
SCALE_ALGO="lanczos"  # Options: lanczos, bicubic, bilinear, neighbor, spline
PRESET="medium"        # FFmpeg preset: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
CRF=18                 # Quality: 0-51, lower = better quality (18 is visually lossless)

usage() {
    echo "Usage: $0 [OPTIONS] <input_file_or_directory>"
    echo ""
    echo "Options:"
    echo "  -o DIR       Output directory (default: $OUTPUT_DIR)"
    echo "  -a ALGO      Scale algorithm: lanczos, bicubic, bilinear, neighbor, spline"
    echo "               lanczos = best quality (default)"
    echo "               bicubic = good quality, faster"
    echo "  -p PRESET    FFmpeg preset: ultrafast to veryslow (default: medium)"
    echo "  -q CRF       Quality 0-51, lower=better (default: 18)"
    echo "  -h           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 video.avi                           # Upscale single file"
    echo "  $0 /home/dominick/Videos               # Upscale all videos in directory"
    echo "  $0 -a bicubic -p fast video.mpg       # Fast upscale with bicubic"
    echo "  $0 -q 20 video.avi                     # Lower quality, smaller file"
    exit 1
}

# Parse arguments
while getopts "o:a:p:q:h" opt; do
    case $opt in
        o) OUTPUT_DIR="$OPTARG" ;;
        a) SCALE_ALGO="$OPTARG" ;;
        p) PRESET="$OPTARG" ;;
        q) CRF="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No input file or directory specified${NC}"
    usage
fi

INPUT="$1"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "Video Upscaler to 1080p"
echo "=========================================="
echo "Algorithm: $SCALE_ALGO"
echo "Preset: $PRESET"
echo "Quality (CRF): $CRF"
echo "Output: $OUTPUT_DIR"
echo "=========================================="
echo ""

upscale_video() {
    local input_file="$1"
    local filename=$(basename "$input_file")
    local name="${filename%.*}"
    local output_file="$OUTPUT_DIR/${name}_1080p.mkv"
    
    # Check if already upscaled
    if [ -f "$output_file" ]; then
        echo -e "${YELLOW}⚠️  Skipping (already exists): $filename${NC}"
        return
    fi
    
    # Get current resolution
    resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$input_file" 2>/dev/null)
    width=$(echo $resolution | cut -d'x' -f1)
    height=$(echo $resolution | cut -d'x' -f2)
    
    echo -e "${GREEN}📹 Processing: $filename${NC}"
    echo "   Current: ${width}x${height}"
    
    # Only upscale if resolution is less than 1080p
    if [ "$height" -ge 1080 ]; then
        echo -e "${YELLOW}   ⚠️  Already 1080p or higher, skipping...${NC}"
        return
    fi
    
    echo "   Target: 1920x1080"
    echo "   Upscaling..."
    
    # Calculate minimum bitrate based on resolution increase
    # For old/low-quality sources, ensure adequate bitrate
    min_bitrate="4000k"  # Minimum 4 Mbps for 1080p
    
    # Upscale to 1080p with high quality settings
    # Using both CRF and minrate to ensure quality for low-bitrate sources
    ffmpeg -i "$input_file" \
        -vf "scale=1920:1080:flags=$SCALE_ALGO" \
        -c:v libx264 \
        -preset "$PRESET" \
        -crf "$CRF" \
        -minrate "$min_bitrate" \
        -bufsize "8000k" \
        -c:a copy \
        -movflags +faststart \
        "$output_file" \
        -hide_banner \
        -loglevel error \
        -stats
    
    if [ $? -eq 0 ]; then
        # Get file sizes
        input_size=$(du -h "$input_file" | cut -f1)
        output_size=$(du -h "$output_file" | cut -f1)
        echo -e "${GREEN}   ✅ Complete: $output_file${NC}"
        echo "   Size: $input_size → $output_size"
    else
        echo -e "${RED}   ❌ Failed to upscale $filename${NC}"
    fi
    echo ""
}

# Process input
if [ -f "$INPUT" ]; then
    # Single file
    upscale_video "$INPUT"
elif [ -d "$INPUT" ]; then
    # Directory - find all video files
    total=0
    processed=0
    
    # Count total videos
    while IFS= read -r -d '' file; do
        ((total++))
    done < <(find "$INPUT" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" \) -print0)
    
    echo "Found $total video files to process"
    echo ""
    
    # Process each video
    while IFS= read -r -d '' file; do
        ((processed++))
        echo "[$processed/$total]"
        upscale_video "$file"
    done < <(find "$INPUT" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" \) -print0)
else
    echo -e "${RED}Error: Input is neither a file nor directory: $INPUT${NC}"
    exit 1
fi

echo "=========================================="
echo "Upscaling Complete!"
echo "=========================================="
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "You can now move these files to your Videos folder:"
echo "  mv $OUTPUT_DIR/*.mkv /home/dominick/Videos/"
