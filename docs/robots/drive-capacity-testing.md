# Drive Capacity Testing & Monitoring

**Created:** 2025-12-09  
**Issue:** TOSHIBA MQ01ABD1 drive fails after reaching ~50% capacity  
**Current Status:** 200GB used / 916GB total (22% full)

---

## ⚠️ Known Issue

This external drive has a **known defect** where it becomes unreliable or fails after reaching approximately **50% capacity**. The exact failure point is unknown, so we've created testing and monitoring tools to:

1. **Find the exact failure threshold** before it happens in production
2. **Monitor capacity** to prevent data loss
3. **Alert when approaching** the danger zone

---

## 🧪 Testing Tools

### 1. Drive Limit Test Script

**Location:** `/home/dominick/workspace/plex-me-hard/scripts/test-drive-limits.sh`

**Purpose:** Safely test the drive to find exactly when it starts failing.

**What it does:**
- ✅ Writes test data in 10GB increments
- ✅ Monitors drive health at each step
- ✅ Switches to 1GB increments near 50%
- ✅ Stops at first sign of failure or 95% full
- ✅ Logs all results with timestamps
- ✅ Cleans up test data when done
- ✅ Provides safe operating limit recommendation

**How to run:**
```bash
cd /home/dominick/workspace/plex-me-hard
./scripts/test-drive-limits.sh
```

**Time Required:** 30-60 minutes depending on drive speed

**Output:** Creates detailed log at `docs/robots/drive-test-log.txt`

**Safety:** Non-destructive - only writes test files, doesn't touch Plex data

---

### 2. Drive Health Monitor

**Location:** `/home/dominick/workspace/plex-me-hard/scripts/monitor-drive-health.sh`

**Purpose:** Check current drive health and capacity status.

**What it shows:**
- 📊 Current capacity usage with visual bar
- ⚠️ Warning/critical alerts based on thresholds
- 🔍 SMART health status
- 🌡️ Drive temperature
- 💾 Estimated movies remaining
- 📋 Actionable recommendations

**How to run:**
```bash
cd /home/dominick/workspace/plex-me-hard
./scripts/monitor-drive-health.sh
```

**Time Required:** Instant

**Alerts:**
- **GREEN (0-44%):** Healthy - safe to add content
- **YELLOW (45-49%):** Warning - approaching limit
- **RED (50%+):** Critical - in failure zone!

---

## 📊 Current Drive Status

**As of 2025-12-09:**
```
Total:     916GB
Used:      200GB (22%)
Available: 716GB
Status:    ✅ HEALTHY
```

**Estimated Capacity:**
- Room for ~700 more movies at 1GB each (720p)
- Room for ~350 more movies at 2GB each (1080p)
- **Safe until:** ~410GB used (45% threshold)

---

## 🎯 Recommended Safe Limits

Based on known issues, we recommend:

| Threshold | Capacity | Status | Action |
|-----------|----------|--------|--------|
| **0-45%** | 0-412GB | ✅ Safe | Add content freely |
| **45-50%** | 412-458GB | ⚠️ Warning | Monitor closely |
| **50%+** | 458GB+ | 🚨 Critical | Stop adding, clean up |

**Conservative Limit:** Keep below **45%** (412GB used)  
**Known Failure Zone:** Above **50%** (458GB used)

---

## 🔍 Testing Strategy

### Phase 1: Incremental Testing (10GB chunks)
- Start at current 22% (200GB)
- Write 10GB test files incrementally
- Monitor for any errors or slowdowns
- Continue until approaching 45%

### Phase 2: Precision Testing (1GB chunks)
- Switch to 1GB increments at 45%
- Carefully test through 45-55% range
- Watch for:
  - Write failures
  - Filesystem errors
  - SMART warnings
  - Performance degradation

### Phase 3: Results & Recommendation
- Document exact failure point
- Set safe operating limit
- Update monitoring thresholds
- Create capacity management plan

---

## 📋 What to Expect from Test

### Possible Outcomes:

**Best Case:** Drive works fine beyond 50%
- Issue may have been fixed or misidentified
- Can use full capacity safely
- Update documentation

**Expected Case:** Failure around 50-60%
- Confirms known issue
- Set safe limit at 45%
- Implement strict monitoring

**Worst Case:** Failure before 50%
- More serious than expected
- Lower safe limit accordingly
- Consider drive replacement

---

## 🚨 Emergency Procedures

### If Drive Fills Beyond Safe Limit:

**Option 1: Delete Old Content**
```bash
# View largest files
du -ah /media/dominick/TOSHIBA\ MQ01ABD1/plex-me-hard/data/movies | sort -rh | head -20

# Delete unwatched or low-priority content
# (Manual selection recommended)
```

**Option 2: Move Content to Backup**
```bash
# Archive old movies to another location
rsync -ah --remove-source-files /path/to/old/movies /backup/location/
```

**Option 3: Reformat Drive** (Last Resort)
```bash
# ⚠️ DESTROYS ALL DATA - backup first!
# This allegedly "fixes" the capacity issue
# See reformatting guide in emergency docs
```

---

## 📊 Monitoring Schedule

### Manual Checks:
- **Daily:** Run `monitor-drive-health.sh` 
- **Weekly:** Review alert log for trends
- **Monthly:** Check SMART health status

### Automated Monitoring (Future):
Set up cron job to check hourly:
```bash
# Add to crontab
0 * * * * /home/dominick/workspace/plex-me-hard/scripts/monitor-drive-health.sh >> /tmp/drive-health.log
```

---

## 🔧 SMART Health Monitoring

### Installing SMART Tools:
```bash
sudo apt-get update
sudo apt-get install smartmontools
```

### Manual SMART Check:
```bash
# Overall health
sudo smartctl -H /dev/sda

# Detailed attributes
sudo smartctl -A /dev/sda

# Full info
sudo smartctl -a /dev/sda
```

### Key SMART Attributes to Watch:
- **Reallocated Sectors:** Should be 0 (bad sectors)
- **Pending Sectors:** Should be 0 (sectors waiting to be reallocated)
- **Temperature:** Should be <50°C
- **Power-On Hours:** Drive age indicator

---

## 📝 Test Results Log

After running `test-drive-limits.sh`, results will be saved to:
```
/home/dominick/workspace/plex-me-hard/docs/robots/drive-test-log.txt
```

Log includes:
- Initial drive status
- Each test chunk result
- Failure point (if encountered)
- SMART health data
- Final recommendations
- Cleanup confirmation

---

## 🎯 Next Steps

### Before Running Test:
1. ✅ **Backup important data** (Plex config especially)
2. ✅ **Schedule downtime** (30-60 minutes)
3. ✅ **Stop Plex temporarily** (optional, for safety)
4. ✅ **Review test script** (understand what it does)

### Running the Test:
```bash
cd /home/dominick/workspace/plex-me-hard
./scripts/test-drive-limits.sh
```

### After Test:
1. Review log file: `docs/robots/drive-test-log.txt`
2. Update monitoring thresholds based on results
3. Document safe capacity limit
4. Set up monitoring schedule
5. Plan capacity management strategy

---

## 💡 Capacity Management Strategy

### Short Term (Current: 22%):
- ✅ Safe to add content
- Monitor weekly
- No immediate concerns

### Medium Term (Approaching 45%):
- ⚠️ Start being selective about downloads
- Delete unwatched content
- Re-encode large files to smaller formats
- Monitor daily

### Long Term (Beyond 45%):
- 🚨 Stop adding new content
- Aggressive cleanup required
- Consider drive replacement
- Plan data migration

---

## 🔄 Alternative Solutions

### Option 1: Get Second Drive
- Add another 1TB drive
- Split content: Movies on Drive A, TV on Drive B
- Doubles capacity, no single point of failure

### Option 2: Upgrade to Larger Drive
- 2TB or 4TB external drive
- Migrate all content
- Solve problem long-term

### Option 3: Network Storage (NAS)
- Synology or similar NAS
- Multiple drives with redundancy
- Professional solution

---

**@plex-me-hard Agent - Drive Testing System Ready** ✅

**Current Status:** 200GB / 916GB (22%) - ✅ HEALTHY  
**Safe Until:** ~410GB (45%)  
**Test Ready:** Yes - run `test-drive-limits.sh` when convenient
