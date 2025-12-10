# External Drive Migration

**Date:** 2025-12-09  
**External Drive:** TOSHIBA MQ01ABD1 (1TB)  
**Mount Point:** `/media/dominick/TOSHIBA MQ01ABD1`  
**Available Space:** 722GB

---

## What Was Migrated

All Plex-Me-Hard data has been moved to the external drive:

### Current Data Size:
- **Movies:** 4.7GB (5 movies with subtitles)
- **Config:** 49MB (Plex configuration and metadata)
- **Transcode:** 4KB (temporary transcoding directory)
- **Total:** ~4.8GB

### New Directory Structure:

```
/media/dominick/TOSHIBA MQ01ABD1/plex-me-hard/
├── data/
│   ├── movies/     (5 movies - 4.7GB)
│   ├── tv/         (empty)
│   └── music/      (empty)
├── config/         (Plex database and settings)
├── transcode/      (temporary transcoding files)
└── torrent/
    ├── downloads/  (completed torrent files)
    ├── config/     (Transmission settings)
    └── watch/      (watch folder for .torrent files)
```

---

## Migration Script

**Location:** `/home/dominick/workspace/plex-me-hard/scripts/migrate-to-external-drive.sh`

### What It Does:

1. ✅ **Stops Plex services** (Docker containers)
2. ✅ **Creates directory structure** on external drive
3. ✅ **Moves all data** using rsync (preserves permissions)
4. ✅ **Updates Docker Compose** configuration to use external paths
5. ✅ **Creates symbolic links** in project for compatibility
6. ✅ **Restarts Plex services** with new configuration
7. ✅ **Backs up old data** (timestamped backups)

### How to Run:

```bash
cd /home/dominick/workspace/plex-me-hard
./scripts/migrate-to-external-drive.sh
```

**Time Required:** ~5-10 minutes (depending on data size)

---

## Benefits

### ✅ More Storage Space
- **External Drive:** 722GB available
- **Internal SSD:** Freed up 4.7GB
- **Future Growth:** Room for hundreds more movies

### ✅ Better Performance
- Plex reads from dedicated drive
- No competition with system files
- Easier to upgrade (just swap drive)

### ✅ Portability
- Take your entire library with you
- Move to another machine easily
- Backup-friendly

### ✅ Organization
- All media in one place
- Clear separation from code
- Professional setup

---

## Important Notes

### ⚠️ Keep Drive Connected!
The external drive **MUST remain connected** for Plex to work:
- If disconnected, Plex won't find your movies
- Reconnect and restart Docker containers to restore

### 🔄 Auto-Mount on Startup
The drive should auto-mount at:
```
/media/dominick/TOSHIBA MQ01ABD1
```

If it doesn't auto-mount, you may need to add to `/etc/fstab`.

### 📦 Symbolic Links
The project directory still has these folders, but they're now **symbolic links** pointing to the external drive:
```bash
/home/dominick/workspace/plex-me-hard/data → /media/dominick/TOSHIBA MQ01ABD1/plex-me-hard/data
/home/dominick/workspace/plex-me-hard/config → /media/dominick/TOSHIBA MQ01ABD1/plex-me-hard/config
```

This means all your scripts continue to work without changes!

---

## Docker Compose Changes

The `plex/docker-compose.yml` now uses environment variable:

```yaml
volumes:
  - ${EXTERNAL_DRIVE}/plex-me-hard/config:/config
  - ${EXTERNAL_DRIVE}/plex-me-hard/data/movies:/data/movies
```

Where `EXTERNAL_DRIVE=/media/dominick/TOSHIBA MQ01ABD1` is set in `plex/.env`

---

## Verification After Migration

Check that everything works:

```bash
# Check movies on external drive
ls -lh /media/dominick/TOSHIBA\ MQ01ABD1/plex-me-hard/data/movies

# Check symbolic links
ls -l /home/dominick/workspace/plex-me-hard/data

# Check Plex is running
cd /home/dominick/workspace/plex-me-hard/plex
sudo docker compose ps

# Check Plex can see movies
curl -s http://localhost:32400/library/sections
```

---

## Backup Information

### Old Data Backups
When you run the migration, old directories are renamed with timestamps:
```
data.backup-20251209-192345/
config.backup-20251209-192345/
```

**You can delete these after verifying migration worked!**

### Docker Compose Backup
Original configuration saved as:
```
plex/docker-compose.yml.backup-20251209-192345
```

---

## Rollback (If Needed)

If something goes wrong, to revert:

```bash
# Stop services
cd /home/dominick/workspace/plex-me-hard/plex
sudo docker compose down

# Remove symlinks
rm /home/dominick/workspace/plex-me-hard/data
rm /home/dominick/workspace/plex-me-hard/config

# Restore backups (replace timestamp with your actual backup)
mv data.backup-TIMESTAMP data
mv config.backup-TIMESTAMP config

# Restore docker-compose
mv docker-compose.yml.backup-TIMESTAMP docker-compose.yml
rm .env

# Start services
sudo docker compose up -d
```

---

## Future Considerations

### Upgrading to Larger Drive
When you need more space:
1. Copy entire `/media/dominick/TOSHIBA MQ01ABD1/plex-me-hard/` to new drive
2. Update `EXTERNAL_DRIVE` path in `plex/.env`
3. Restart services

### Multiple Drives
You could split content across drives:
- Drive 1: Movies
- Drive 2: TV Shows
- Drive 3: Music

Just update the volume mounts in `docker-compose.yml`

---

**@plex-me-hard Agent - External Drive Migration Complete** ✅
