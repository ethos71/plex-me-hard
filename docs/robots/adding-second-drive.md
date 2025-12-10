# Adding a Second Drive to Plex-Me-Hard

**Created:** 2025-12-10  
**Purpose:** Expand storage capacity with additional external drive  
**Status:** Drive detected, awaiting full initialization

---

## 🔍 Current Drive Status

### **Drive 1: TOSHIBA MQ01ABD1** (Primary)
- **Device:** `/dev/sda`
- **Size:** 931.5GB
- **Used:** 200GB (22%)
- **Mount:** `/media/dominick/TOSHIBA MQ01ABD1`
- **Status:** ✅ Active and healthy
- **Issue:** Known to fail after 50% capacity
- **Safe Limit:** Keep below 45% (412GB)

### **Drive 2: New USB Drive** (Secondary)
- **Device:** Not yet assigned (will be `/dev/sdb`)
- **Status:** ⏳ Initializing (detected as scsi host1)
- **Mount:** Will be `/media/dominick/PLEX-STORAGE-2`
- **Purpose:** Overflow storage when Drive 1 approaches limit

---

## 🚀 Setup Process

### **Step 1: Wait for Drive Detection**

The new drive was detected but is still initializing. Check if it's ready:

```bash
# Check if drive appears
lsblk

# Look for /dev/sdb or similar
ls -la /dev/sd*
```

**If you see `/dev/sdb`:** Proceed to Step 2  
**If you don't see it:** Try:
1. Unplug and reconnect the drive
2. Wait 10-15 seconds
3. Check `dmesg | tail -50` for errors
4. Ensure drive has external power (if needed)

---

### **Step 2: Run Setup Script**

Once the drive appears, run the automated setup script:

```bash
cd /home/dominick/workspace/plex-me-hard
./scripts/setup-new-drive.sh
```

**The script will:**
- ✅ Show all available drives
- ✅ Prompt you to select the new drive
- ✅ Confirm before formatting (safety check)
- ✅ Wipe existing data
- ✅ Create GPT partition table
- ✅ Format as ext4 filesystem
- ✅ Label as "PLEX-STORAGE-2"
- ✅ Mount at `/media/dominick/PLEX-STORAGE-2`
- ✅ Add to `/etc/fstab` for auto-mount
- ✅ Create plex-me-hard directory structure
- ✅ Set proper permissions

**Time Required:** 2-5 minutes

---

### **Step 3: Verify Setup**

After setup completes, verify the drive is working:

```bash
# Check drive is mounted
df -h | grep PLEX-STORAGE-2

# Verify directory structure
ls -la /media/dominick/PLEX-STORAGE-2/plex-me-hard/

# Test write permissions
touch /media/dominick/PLEX-STORAGE-2/plex-me-hard/test.txt
rm /media/dominick/PLEX-STORAGE-2/plex-me-hard/test.txt
```

---

### **Step 4: Update Plex Libraries**

Add the new drive locations to Plex:

**Via Plex Web Interface:**
1. Open Plex: http://localhost:32400/web
2. Go to Settings → Libraries
3. Select "Movies" library
4. Click "Add Folder"
5. Add: `/media/dominick/PLEX-STORAGE-2/plex-me-hard/data/movies`
6. Repeat for TV and Music if needed

**Via Docker (if using docker-compose):**
Update volumes in `plex/docker-compose.yml`:
```yaml
volumes:
  - /media/dominick/TOSHIBA MQ01ABD1/plex-me-hard/data:/data
  - /media/dominick/PLEX-STORAGE-2/plex-me-hard/data:/data2
```

---

## 🎯 Multi-Drive Strategy

With two drives, you have options for managing content:

### **Option 1: Overflow Storage** (Recommended)
- **Drive 1 (TOSHIBA):** Primary storage until 40% full
- **Drive 2 (New):** Overflow storage after Drive 1 reaches 40%
- **Benefit:** Keeps problem drive below failure threshold

### **Option 2: Content Type Split**
- **Drive 1:** Movies only
- **Drive 2:** TV shows and Music
- **Benefit:** Organize by content type

### **Option 3: Quality Split**
- **Drive 1:** High-priority / frequently watched content
- **Drive 2:** Archive / rarely watched content
- **Benefit:** Optimize performance

### **Option 4: Date-Based**
- **Drive 1:** Newer content (last 6 months)
- **Drive 2:** Older content (archive)
- **Benefit:** Easier to manage and clean up

---

## 🔄 Updated Torrent Processing

The torrent scripts will need updating to support multiple drives:

### **Smart Drive Selection**

Update `scripts/process-torrent.sh` to:
1. Check Drive 1 capacity
2. If Drive 1 > 40% full, use Drive 2
3. If both drives > 80% full, warn user
4. Always track which drive has which content

### **Configuration File**

Create `/home/dominick/workspace/plex-me-hard/config/storage-config.json`:
```json
{
  "drives": [
    {
      "name": "TOSHIBA-PRIMARY",
      "path": "/media/dominick/TOSHIBA MQ01ABD1/plex-me-hard",
      "max_usage_percent": 40,
      "priority": 1,
      "has_known_issues": true
    },
    {
      "name": "PLEX-STORAGE-2",
      "path": "/media/dominick/PLEX-STORAGE-2/plex-me-hard",
      "max_usage_percent": 85,
      "priority": 2,
      "has_known_issues": false
    }
  ],
  "selection_strategy": "fill_priority_first"
}
```

---

## 📊 Monitoring Both Drives

### **Updated Health Monitor**

The `monitor-drive-health.sh` script will be updated to show:
- Status of both drives
- Total capacity across all drives
- Which drive is receiving new content
- Alerts for any drive reaching limits

### **Combined Capacity Dashboard**

```
Drive 1 (TOSHIBA):     [████░░░░░░] 22% (200GB/916GB) ✅ HEALTHY
Drive 2 (STORAGE-2):   [░░░░░░░░░░]  0% (0GB/XXXGB)   ✅ READY

Total Capacity:        200GB / XXXXGB used
Total Available:       XXXXGB
Estimated Movies:      XXXX more at 1GB each
```

---

## 🛠️ Troubleshooting New Drive

### **Drive not appearing**

**Problem:** USB drive detected but no `/dev/sdb` device

**Solutions:**
```bash
# 1. Check dmesg for errors
dmesg | tail -50

# 2. Check USB device info
lsusb -v

# 3. Force rescan
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan

# 4. Check if drive needs power
# Some enclosures need external power supply
```

---

### **Drive appears but won't mount**

**Problem:** Device exists but mount fails

**Solutions:**
```bash
# 1. Check for filesystem errors
sudo fsck /dev/sdb1

# 2. Try manual mount
sudo mount /dev/sdb1 /media/dominick/test

# 3. Check partition table
sudo parted /dev/sdb print
```

---

### **Permission denied errors**

**Problem:** Can't write to mounted drive

**Solutions:**
```bash
# Fix ownership
sudo chown -R dominick:dominick /media/dominick/PLEX-STORAGE-2

# Fix permissions
sudo chmod -R 755 /media/dominick/PLEX-STORAGE-2
```

---

## 📋 Post-Setup Checklist

After setting up the new drive:

- [ ] Drive detected and assigned device name
- [ ] Drive formatted with ext4
- [ ] Drive mounted at correct location
- [ ] Auto-mount configured in /etc/fstab
- [ ] Directory structure created
- [ ] Permissions set correctly
- [ ] Plex library updated with new paths
- [ ] Test file write successful
- [ ] Torrent scripts updated for multi-drive
- [ ] Health monitoring updated
- [ ] Documentation updated

---

## 🎯 Next Steps

1. **Wait for drive to appear** as `/dev/sdb`
2. **Run setup script**: `./scripts/setup-new-drive.sh`
3. **Update Plex libraries** with new paths
4. **Update torrent processing** to use both drives
5. **Test with a movie** download to new drive
6. **Monitor both drives** regularly

---

## 💾 Drive Capacity Planning

### **With Two Drives:**

Assuming new drive is 1TB:
- **Total Capacity:** ~2TB
- **Safe Capacity:** ~1.5TB (accounting for Drive 1 limit)
- **Estimated Movies:** ~1500 at 1GB each
- **Estimated Years:** 5+ at current download rate

### **Backup Strategy:**

With two drives, consider:
- **Redundancy:** Keep important content on both drives
- **Rotation:** Regularly archive old content
- **External Backup:** Critical config files to cloud/USB

---

**@plex-me-hard Agent - Multi-Drive Support Ready** ✅

**Current Status:** Waiting for new drive to fully initialize  
**Next Action:** Run `./scripts/setup-new-drive.sh` when drive appears  
**Expected Device:** `/dev/sdb`
