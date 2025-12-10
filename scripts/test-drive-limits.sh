#!/bin/bash

# Plex-Me-Hard: Drive Capacity Testing Script
# Tests external drive to find failure point before it happens in production

set -e

EXTERNAL_DRIVE="/media/dominick/TOSHIBA MQ01ABD1"
TEST_DIR="${EXTERNAL_DRIVE}/drive-test"
PROJECT_DIR="/home/dominick/workspace/plex-me-hard"
LOG_FILE="${PROJECT_DIR}/docs/robots/drive-test-log.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         PLEX-ME-HARD: DRIVE LIMIT TESTING                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Initialize log
echo "Drive Limit Test - $(date)" > "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Check if drive is mounted
if [ ! -d "$EXTERNAL_DRIVE" ]; then
    echo -e "${RED}❌ ERROR: External drive not found at $EXTERNAL_DRIVE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ External Drive Found${NC}"
echo ""

# Get current drive info
TOTAL_SIZE=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $2}')
USED_SIZE=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $3}')
AVAIL_SIZE=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')
USE_PERCENT=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 CURRENT DRIVE STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total Size:  $TOTAL_SIZE"
echo "  Used:        $USED_SIZE ($USE_PERCENT%)"
echo "  Available:   $AVAIL_SIZE"
echo ""

# Log initial status
echo "Initial Drive Status:" >> "$LOG_FILE"
echo "  Total: $TOTAL_SIZE" >> "$LOG_FILE"
echo "  Used: $USED_SIZE ($USE_PERCENT%)" >> "$LOG_FILE"
echo "  Available: $AVAIL_SIZE" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Warning if already past 50%
if [ "$USE_PERCENT" -gt 50 ]; then
    echo -e "${RED}⚠️  WARNING: Drive is already ${USE_PERCENT}% full!${NC}"
    echo -e "${YELLOW}   Drive is known to fail after 50% capacity.${NC}"
    echo -e "${YELLOW}   Proceeding with caution...${NC}"
    echo ""
    echo "WARNING: Drive already at ${USE_PERCENT}% capacity" >> "$LOG_FILE"
fi

# Check SMART health
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 CHECKING DRIVE HEALTH (SMART)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v smartctl &> /dev/null; then
    sudo smartctl -H /dev/sda >> "$LOG_FILE" 2>&1
    HEALTH_STATUS=$(sudo smartctl -H /dev/sda 2>/dev/null | grep "SMART overall-health" || echo "Unknown")
    echo "  $HEALTH_STATUS"
    
    # Get temperature
    TEMP=$(sudo smartctl -A /dev/sda 2>/dev/null | grep "Temperature_Celsius" | awk '{print $10}' || echo "N/A")
    if [ "$TEMP" != "N/A" ]; then
        echo "  Temperature: ${TEMP}°C"
        echo "  Temperature: ${TEMP}°C" >> "$LOG_FILE"
    fi
    
    # Get reallocated sectors
    REALLOC=$(sudo smartctl -A /dev/sda 2>/dev/null | grep "Reallocated_Sector" | awk '{print $10}' || echo "N/A")
    if [ "$REALLOC" != "N/A" ] && [ "$REALLOC" != "0" ]; then
        echo -e "  ${YELLOW}⚠️  Reallocated Sectors: $REALLOC${NC}"
        echo "  WARNING: Reallocated Sectors: $REALLOC" >> "$LOG_FILE"
    fi
else
    echo -e "${YELLOW}  ⚠️  smartctl not installed. Installing...${NC}"
    sudo apt-get update -qq && sudo apt-get install -y smartmontools -qq
    echo "  smartctl installed"
fi
echo ""

# Create test directory
mkdir -p "$TEST_DIR"
echo "✓ Test directory created: $TEST_DIR"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 INCREMENTAL CAPACITY TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Strategy: Write 10GB chunks until failure or limit reached"
echo "  Target: Find exact failure point (known issue >50%)"
echo ""

# Function to get current usage percent
get_usage_percent() {
    df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Function to write a test file
write_test_chunk() {
    local chunk_num=$1
    local chunk_size=$2  # in GB
    local test_file="${TEST_DIR}/test_chunk_${chunk_num}.dat"
    
    echo -n "  Testing Chunk #${chunk_num} (${chunk_size}GB)... "
    
    # Write using dd with progress
    if dd if=/dev/zero of="$test_file" bs=1M count=$((chunk_size * 1024)) status=progress 2>&1 | tail -1; then
        # Verify write succeeded
        if [ -f "$test_file" ]; then
            local file_size=$(du -h "$test_file" | cut -f1)
            local new_usage=$(get_usage_percent)
            echo -e "${GREEN}✓ SUCCESS${NC} - Written: $file_size, Usage: ${new_usage}%"
            echo "Chunk #${chunk_num}: SUCCESS - ${chunk_size}GB written, usage now ${new_usage}%" >> "$LOG_FILE"
            return 0
        else
            echo -e "${RED}✗ FAILED${NC} - File creation failed"
            echo "Chunk #${chunk_num}: FAILED - File not created" >> "$LOG_FILE"
            return 1
        fi
    else
        echo -e "${RED}✗ FAILED${NC} - Write operation failed"
        echo "Chunk #${chunk_num}: FAILED - Write operation failed" >> "$LOG_FILE"
        return 1
    fi
}

# Start incremental testing
echo "Starting incremental test..." >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

CHUNK_SIZE=10  # GB per chunk
CHUNK_NUM=1
MAX_USAGE=95  # Don't go beyond 95% to leave some safety margin

while true; do
    CURRENT_USAGE=$(get_usage_percent)
    
    # Check if we've reached the safe limit
    if [ "$CURRENT_USAGE" -ge "$MAX_USAGE" ]; then
        echo ""
        echo -e "${YELLOW}⚠️  Reached safe limit (${CURRENT_USAGE}%). Stopping test.${NC}"
        echo "Stopped at safe limit: ${CURRENT_USAGE}%" >> "$LOG_FILE"
        break
    fi
    
    # Check if we're approaching 50% (known failure zone)
    if [ "$CURRENT_USAGE" -ge 45 ] && [ "$CURRENT_USAGE" -lt 50 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  APPROACHING 50% THRESHOLD (Currently ${CURRENT_USAGE}%)${NC}"
        echo -e "${YELLOW}   Reducing chunk size to 1GB for precision testing${NC}"
        CHUNK_SIZE=1
        echo "Reduced chunk size to 1GB at ${CURRENT_USAGE}% usage" >> "$LOG_FILE"
    fi
    
    # Attempt to write chunk
    if ! write_test_chunk "$CHUNK_NUM" "$CHUNK_SIZE"; then
        echo ""
        echo -e "${RED}❌ FAILURE DETECTED at ${CURRENT_USAGE}% capacity${NC}"
        echo "FAILURE POINT: ${CURRENT_USAGE}%" >> "$LOG_FILE"
        break
    fi
    
    # Check filesystem health after write
    if ! df -h "$EXTERNAL_DRIVE" >/dev/null 2>&1; then
        echo ""
        echo -e "${RED}❌ FILESYSTEM ERROR DETECTED${NC}"
        echo "FILESYSTEM ERROR at chunk #${CHUNK_NUM}" >> "$LOG_FILE"
        break
    fi
    
    CHUNK_NUM=$((CHUNK_NUM + 1))
    sleep 2  # Brief pause between writes
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 FINAL TEST RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FINAL_USAGE=$(get_usage_percent)
FINAL_USED=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $3}')
FINAL_AVAIL=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')
TEST_DATA_SIZE=$(du -sh "$TEST_DIR" 2>/dev/null | cut -f1 || echo "N/A")

echo "  Maximum Safe Capacity Reached: ${FINAL_USAGE}%"
echo "  Currently Used: $FINAL_USED"
echo "  Still Available: $FINAL_AVAIL"
echo "  Test Data Written: $TEST_DATA_SIZE"
echo ""

# Write final results to log
echo "" >> "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"
echo "FINAL RESULTS:" >> "$LOG_FILE"
echo "  Maximum Safe Capacity: ${FINAL_USAGE}%" >> "$LOG_FILE"
echo "  Used: $FINAL_USED" >> "$LOG_FILE"
echo "  Available: $FINAL_AVAIL" >> "$LOG_FILE"
echo "  Test Data: $TEST_DATA_SIZE" >> "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"

# Provide recommendation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 RECOMMENDATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FINAL_USAGE" -lt 50 ]; then
    SAFE_LIMIT=45
    echo -e "  ${GREEN}✓ Safe Operating Limit: ${SAFE_LIMIT}% capacity${NC}"
    echo "  RECOMMENDATION: Safe limit is ${SAFE_LIMIT}%" >> "$LOG_FILE"
elif [ "$FINAL_USAGE" -lt 70 ]; then
    SAFE_LIMIT=60
    echo -e "  ${YELLOW}⚠️  Safe Operating Limit: ${SAFE_LIMIT}% capacity${NC}"
    echo "  RECOMMENDATION: Safe limit is ${SAFE_LIMIT}%" >> "$LOG_FILE"
else
    SAFE_LIMIT=50
    echo -e "  ${RED}⚠️  Safe Operating Limit: ${SAFE_LIMIT}% capacity (conservative)${NC}"
    echo "  RECOMMENDATION: Safe limit is ${SAFE_LIMIT}% (conservative)" >> "$LOG_FILE"
fi

echo ""
echo "  📝 Set up monitoring to alert when reaching ${SAFE_LIMIT}%"
echo "  🗑️  Plan to clean up or move data before reaching limit"
echo "  💾 Consider backup solution or replacement drive"
echo ""

# Cleanup test files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -n "  Removing test data... "

if rm -rf "$TEST_DIR"; then
    echo -e "${GREEN}✓ Done${NC}"
    AFTER_CLEANUP=$(get_usage_percent)
    echo "  Drive usage after cleanup: ${AFTER_CLEANUP}%"
    echo "Cleanup complete. Usage: ${AFTER_CLEANUP}%" >> "$LOG_FILE"
else
    echo -e "${RED}✗ Failed${NC}"
    echo "  You may need to manually remove: $TEST_DIR"
    echo "Cleanup failed - manual removal needed" >> "$LOG_FILE"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ TEST COMPLETE                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📄 Full log saved to: $LOG_FILE"
echo ""
echo "🎯 Action Items:"
echo "   1. Review log file for detailed results"
echo "   2. Set up drive monitoring (see below)"
echo "   3. Plan capacity management strategy"
echo ""
