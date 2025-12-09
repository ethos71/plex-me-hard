# Quick Start Scripts

This directory includes helpful scripts to manage your Plex server.

## Troubleshooting

**Can't connect to Plex? Run this first:**
```bash
./troubleshoot-plex.sh
```

This will check:
- Docker installation
- Container status
- Port accessibility
- Plex logs
- Your server IP address

## Initial Setup

Run this once to configure Google Drive and start the services:

```bash
./setup.sh
```

This will:
1. Walk you through Google Drive authentication
2. Verify your connection
3. Check for the `plex-me-hard` folder
4. Start all services

## Check Movie Status

To see where your movie is in the pipeline:

```bash
./check-status.sh
```

## Manual Sync

To immediately sync files from Google Drive (instead of waiting for the automatic 5-minute interval):

```bash
./sync-now.sh
```

## Other Useful Commands

**View logs:**
```bash
# All logs
docker-compose logs -f

# Just converter
docker-compose logs -f converter

# Just Plex
docker-compose logs -f plex
```

**Check service status:**
```bash
docker-compose ps
```

**Restart services:**
```bash
docker-compose restart
```

**Stop everything:**
```bash
docker-compose down
```

**Rebuild after code changes:**
```bash
docker-compose up -d --build
```

**Check what's in your directories:**
```bash
# Files from Google Drive
ls -lh input/

# Converted movies
ls -lh data/movies/

# Converted music
ls -lh data/music/
```

## Accessing Plex

Once running, access Plex at: **http://localhost:32400/web**

First-time setup:
1. Create/login to Plex account
2. Add libraries:
   - Movies: `/data/movies`
   - TV Shows: `/data/tv`
   - Music: `/data/music`

## Troubleshooting

**Files not syncing?**
```bash
# Test Google Drive connection
docker-compose run --rm converter rclone lsd gdrive:plex-me-hard

# Check converter logs
docker-compose logs converter | grep -i sync
```

**Conversion not working?**
```bash
# Check if files are in input directory
docker-compose exec converter ls -lh /input

# Watch conversion in real-time
docker-compose logs -f converter
```

**Can't access Plex?**
```bash
# Check if Plex is running
docker-compose ps

# Check Plex logs
docker-compose logs plex | tail -50
```
