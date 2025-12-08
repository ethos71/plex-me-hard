# Google Drive Setup Guide

This guide explains how to set up automatic syncing from Google Drive to your Plex server.

## Overview

The converter service automatically syncs files from a Google Drive folder (`plex-me-hard` by default) to the local `input/` directory, where they are then converted and added to Plex.

## One-Time Setup

### Step 1: Configure rclone with Google Drive

1. **Run rclone configuration:**
   ```bash
   docker-compose run --rm converter rclone config
   ```

2. **Create a new remote:**
   - Choose: `n` (New remote)
   - Name: `gdrive`
   - Storage type: Find and select `Google Drive` (usually option 15-18)
   - Client ID: Press Enter (leave blank for default)
   - Client Secret: Press Enter (leave blank)
   - Scope: Choose `1` (Full access)
   - Root folder: Press Enter (leave blank)
   - Service Account: Press Enter (no)
   - Advanced config: `n` (no)
   - Auto config: `n` (no, because we're in Docker)

3. **You'll see a URL like:**
   ```
   https://accounts.google.com/o/oauth2/auth?client_id=...
   ```

4. **On your local machine:**
   - Copy the URL to your browser
   - Log in to your Google account
   - Grant permissions to rclone
   - Copy the verification code

5. **Paste the code** back in the terminal

6. **Configure team drive:**
   - Team drive: `n` (no, unless you're using a team drive)

7. **Confirm:**
   - Review settings
   - Type `y` (yes, this is OK)
   - Type `q` (quit)

### Step 2: Verify Configuration

The configuration should now be saved in `./rclone/rclone.conf`

Test the connection:
```bash
docker-compose run --rm converter rclone lsd gdrive:
```

You should see your Google Drive folders listed.

### Step 3: Create the Google Drive Folder

In your Google Drive, create a folder named `plex-me-hard` (or whatever you set in `GDRIVE_FOLDER`).

### Step 4: Start the Services

```bash
docker-compose up -d
```

The converter will now:
1. Sync files from `gdrive:plex-me-hard` every 5 minutes (configurable)
2. Automatically convert new files
3. Add them to your Plex library

## Adding Files

Simply upload files to the `plex-me-hard` folder in Google Drive. Within 5 minutes (default), they will:
1. Download to the server
2. Convert to Plex-optimized format
3. Appear in your Plex library

## Configuration Options

Edit `docker-compose.yml` to customize:

```yaml
environment:
  - ENABLE_GDRIVE_SYNC=true           # Enable/disable sync
  - GDRIVE_FOLDER=plex-me-hard        # Google Drive folder name
  - SYNC_INTERVAL=300                  # Sync every 5 minutes (in seconds)
```

## Manual Sync

To trigger an immediate sync:
```bash
docker-compose exec converter rclone copy gdrive:plex-me-hard /input --verbose
```

## Monitoring

View sync logs:
```bash
docker-compose logs -f converter
```

You should see messages like:
```
[2024-12-08 21:30:00] Syncing from Google Drive...
[2024-12-08 21:30:15] Sync completed successfully
```

## Troubleshooting

### Files not syncing

1. **Check rclone config exists:**
   ```bash
   ls -la rclone/
   ```

2. **Test connection:**
   ```bash
   docker-compose run --rm converter rclone lsd gdrive:plex-me-hard
   ```

3. **Check logs:**
   ```bash
   docker-compose logs converter | grep -i sync
   ```

### Re-authenticate Google Drive

If authentication expires:
```bash
docker-compose run --rm converter rclone config reconnect gdrive:
```

### Clear and reconfigure

```bash
rm -rf rclone/
# Then repeat Step 1
```

## Notes

- First sync may take time depending on file sizes
- Large files may take multiple sync cycles
- rclone only downloads new/changed files (incremental sync)
- Original files remain in Google Drive (not deleted)
- Set `SYNC_INTERVAL` higher (e.g., 600) to reduce API calls
