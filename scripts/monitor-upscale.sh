#!/bin/bash
# Monitor video upscaling progress

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOG_FILE="/tmp/upscale-1080p.log"
OUTPUT_DIR="/home/dominick/Videos/Upscaled_1080p"

clear
echo "=========================================="
echo "  Video Upscaling Progress Monitor"
echo "=========================================="
echo ""

# Check if process is running
if pgrep -f "upscale-to-1080p.sh" > /dev/null; then
    echo -e "${GREEN}✅ Upscaling process is RUNNING${NC}"
    PID=$(pgrep -f "upscale-to-1080p.sh")
    echo "   PID: $PID"
else
    echo -e "${YELLOW}⚠️  Upscaling process is NOT running${NC}"
    echo ""
    echo "Check log file: tail -f $LOG_FILE"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Statistics"
echo "=========================================="

# Count total videos that need upscaling
cd /home/dominick/Videos
total=0
for file in *.{mp4,mkv,avi,mpg,mpeg}; do 
  if [ -f "$file" ]; then
    height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$file" 2>/dev/null)
    if [ ! -z "$height" ] && [ "$height" -lt 1080 ]; then
      ((total++))
    fi
  fi
done 2>/dev/null

# Count completed
if [ -d "$OUTPUT_DIR" ]; then
    completed=$(ls -1 "$OUTPUT_DIR"/*.mkv 2>/dev/null | wc -l)
else
    completed=0
fi

# Calculate progress
if [ $total -gt 0 ]; then
    percent=$(echo "scale=1; $completed * 100 / $total" | bc)
else
    percent=0
fi

remaining=$((total - completed))

echo -e "${BLUE}Total videos to upscale:${NC} $total"
echo -e "${GREEN}Completed:${NC} $completed"
echo -e "${YELLOW}Remaining:${NC} $remaining"
echo -e "${CYAN}Progress:${NC} $percent%"

# Progress bar
bar_length=40
filled=$(echo "$completed * $bar_length / $total" | bc 2>/dev/null || echo "0")
empty=$((bar_length - filled))

printf "["
printf "%${filled}s" | tr ' ' '='
printf "%${empty}s" | tr ' ' '-'
printf "]\n"

echo ""
echo "=========================================="
echo "  Currently Processing"
echo "=========================================="

# Get last few lines of log to see current file
if [ -f "$LOG_FILE" ]; then
    current=$(tail -20 "$LOG_FILE" | grep -E "Processing:|Current:|Target:" | tail -5)
    if [ ! -z "$current" ]; then
        echo "$current"
    else
        echo "Initializing..."
    fi
else
    echo "No log file found at $LOG_FILE"
fi

echo ""
echo "=========================================="
echo "  Completed Files"
echo "=========================================="
if [ $completed -gt 0 ]; then
    ls -1h "$OUTPUT_DIR"/*.mkv 2>/dev/null | tail -5 | while read file; do
        filename=$(basename "$file")
        size=$(du -h "$file" | cut -f1)
        echo "  ✅ $filename ($size)"
    done
    if [ $completed -gt 5 ]; then
        echo "  ... and $((completed - 5)) more"
    fi
else
    echo "  None yet"
fi

echo ""
echo "=========================================="
echo "  Time Estimate"
echo "=========================================="

# Calculate estimated time remaining
if [ $completed -gt 0 ]; then
    # Get process start time
    start_time=$(ps -p $PID -o lstart= | xargs -I {} date -d "{}" +%s 2>/dev/null || echo "0")
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    
    if [ $elapsed -gt 0 ]; then
        # Time per video
        time_per_video=$((elapsed / completed))
        
        # Estimate remaining time
        remaining_seconds=$((time_per_video * remaining))
        
        # Convert to human readable
        days=$((remaining_seconds / 86400))
        hours=$(( (remaining_seconds % 86400) / 3600 ))
        minutes=$(( (remaining_seconds % 3600) / 60 ))
        
        elapsed_hours=$((elapsed / 3600))
        elapsed_minutes=$(( (elapsed % 3600) / 60 ))
        
        echo "Elapsed time: ${elapsed_hours}h ${elapsed_minutes}m"
        echo "Average time per video: $((time_per_video / 60)) minutes"
        echo ""
        if [ $days -gt 0 ]; then
            echo -e "${CYAN}Estimated time remaining: ${days}d ${hours}h ${minutes}m${NC}"
        else
            echo -e "${CYAN}Estimated time remaining: ${hours}h ${minutes}m${NC}"
        fi
        
        # Estimated completion
        completion_time=$(date -d "@$((current_time + remaining_seconds))" "+%Y-%m-%d %H:%M")
        echo "Estimated completion: $completion_time"
    else
        echo "Calculating... (not enough data yet)"
    fi
else
    echo "No files completed yet - unable to estimate"
    echo ""
    echo "Expected total time: 8-12 days"
    echo "(~73.4 hours of video content)"
fi

echo ""
echo "=========================================="
echo "  Commands"
echo "=========================================="
echo "Watch live log:  tail -f $LOG_FILE"
echo "Stop process:    kill $PID"
echo "Refresh stats:   $0"
echo "=========================================="
