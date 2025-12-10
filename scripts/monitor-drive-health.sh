#!/bin/bash

# Plex-Me-Hard: Drive Health Monitor
# Continuously monitors external drive and alerts when approaching failure threshold

EXTERNAL_DRIVE="/media/dominick/TOSHIBA MQ01ABD1"
PROJECT_DIR="/home/dominick/workspace/plex-me-hard"
ALERT_LOG="${PROJECT_DIR}/docs/robots/drive-alerts.log"
SAFE_LIMIT=45  # Default: Alert at 45% (adjust after testing)
CRITICAL_LIMIT=50  # Known failure zone

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if drive is mounted
if [ ! -d "$EXTERNAL_DRIVE" ]; then
    echo -e "${RED}❌ ERROR: External drive not mounted${NC}"
    exit 1
fi

# Get current usage
USAGE_PERCENT=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $5}' | sed 's/%//')
USED=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $3}')
AVAIL=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')
TOTAL=$(df -h "$EXTERNAL_DRIVE" | awk 'NR==2 {print $2}')

# Create header
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         PLEX-ME-HARD: DRIVE HEALTH MONITOR                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Drive: TOSHIBA MQ01ABD1 (1TB)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Display capacity bar
echo -n "Capacity: "
if [ "$USAGE_PERCENT" -ge "$CRITICAL_LIMIT" ]; then
    echo -e "${RED}${USAGE_PERCENT}% ⚠️  CRITICAL${NC}"
elif [ "$USAGE_PERCENT" -ge "$SAFE_LIMIT" ]; then
    echo -e "${YELLOW}${USAGE_PERCENT}% ⚠️  WARNING${NC}"
else
    echo -e "${GREEN}${USAGE_PERCENT}% ✓ HEALTHY${NC}"
fi

echo ""
echo "  Total:     $TOTAL"
echo "  Used:      $USED"
echo "  Available: $AVAIL"
echo ""

# Visual capacity bar
BARS=$((USAGE_PERCENT / 2))
echo -n "  ["
for i in $(seq 1 50); do
    if [ $i -le $BARS ]; then
        if [ "$USAGE_PERCENT" -ge "$CRITICAL_LIMIT" ]; then
            echo -n -e "${RED}█${NC}"
        elif [ "$USAGE_PERCENT" -ge "$SAFE_LIMIT" ]; then
            echo -n -e "${YELLOW}█${NC}"
        else
            echo -n -e "${GREEN}█${NC}"
        fi
    else
        echo -n "░"
    fi
done
echo "] $USAGE_PERCENT%"
echo ""

# Alert thresholds
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📏 Thresholds:"
echo "  Safe Limit:     ${SAFE_LIMIT}% (warning zone)"
echo "  Critical Limit: ${CRITICAL_LIMIT}% (known failure point)"
echo ""

# Status and recommendations
if [ "$USAGE_PERCENT" -ge "$CRITICAL_LIMIT" ]; then
    echo -e "${RED}🚨 CRITICAL ALERT${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${RED}Drive is in FAILURE ZONE (>${CRITICAL_LIMIT}%)${NC}"
    echo ""
    echo "⚠️  IMMEDIATE ACTION REQUIRED:"
    echo "  1. Stop adding new content immediately"
    echo "  2. Delete old/unwatched content"
    echo "  3. Move content to another drive"
    echo "  4. Consider reformatting drive to restore capacity"
    echo ""
    
    # Log critical alert
    echo "$(date): CRITICAL - Drive at ${USAGE_PERCENT}%" >> "$ALERT_LOG"
    
elif [ "$USAGE_PERCENT" -ge "$SAFE_LIMIT" ]; then
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}Drive approaching safe limit (${USAGE_PERCENT}% / ${SAFE_LIMIT}% threshold)${NC}"
    echo ""
    echo "📋 Recommended Actions:"
    echo "  1. Review content library - delete unwatched items"
    echo "  2. Compress or re-encode large files"
    echo "  3. Archive old content to backup storage"
    echo "  4. Monitor daily until usage drops below ${SAFE_LIMIT}%"
    echo ""
    
    # Log warning
    echo "$(date): WARNING - Drive at ${USAGE_PERCENT}%" >> "$ALERT_LOG"
    
else
    echo -e "${GREEN}✅ HEALTHY${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Drive is operating within safe parameters"
    echo ""
    REMAINING_PERCENT=$((SAFE_LIMIT - USAGE_PERCENT))
    echo "📊 Capacity until warning: ${REMAINING_PERCENT}%"
    
    # Calculate approximate movies remaining
    AVG_MOVIE_SIZE=1  # GB
    AVAIL_GB=$(echo "$AVAIL" | sed 's/G//')
    if [[ "$AVAIL_GB" =~ ^[0-9]+$ ]]; then
        MOVIES_LEFT=$((AVAIL_GB / AVG_MOVIE_SIZE))
        SAFE_MOVIES=$((REMAINING_PERCENT * 10 / AVG_MOVIE_SIZE))  # Rough estimate
        echo "   Estimated movies remaining (1GB avg): ~${MOVIES_LEFT}"
        echo "   Safe to add before ${SAFE_LIMIT}%: ~${SAFE_MOVIES} movies"
    fi
    echo ""
fi

# SMART health check
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 SMART Health Status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v smartctl &> /dev/null; then
    HEALTH=$(sudo smartctl -H /dev/sda 2>/dev/null | grep "SMART overall-health" || echo "Unknown")
    echo "  $HEALTH"
    
    # Temperature
    TEMP=$(sudo smartctl -A /dev/sda 2>/dev/null | grep "Temperature_Celsius" | awk '{print $10}' || echo "N/A")
    if [ "$TEMP" != "N/A" ]; then
        if [ "$TEMP" -gt 50 ]; then
            echo -e "  Temperature: ${RED}${TEMP}°C (HIGH)${NC}"
        else
            echo -e "  Temperature: ${GREEN}${TEMP}°C${NC}"
        fi
    fi
    
    # Reallocated sectors (bad sectors)
    REALLOC=$(sudo smartctl -A /dev/sda 2>/dev/null | grep "Reallocated_Sector" | awk '{print $10}' || echo "0")
    if [ "$REALLOC" != "0" ] && [ "$REALLOC" != "N/A" ]; then
        echo -e "  ${RED}⚠️  Reallocated Sectors: $REALLOC (Drive degrading)${NC}"
    fi
else
    echo "  smartctl not available"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Last checked: $(date)"
echo "Alert log: $ALERT_LOG"
echo ""
