# Torrent Processing for Plex-Me-Hard

**Created:** 2025-12-09  
**Description:** Automated torrent downloading and media processing system

## Purpose

Downloads media via torrent magnet links and automatically processes them through the Plex-Me-Hard converter pipeline.

## Components

### 1. Transmission BitTorrent Client
- **Container**: `transmission`
- **Web UI**: http://localhost:9091
- **Downloads to**: `torrent/downloads/`
- **Auto-processes to**: `input/` → converter → Plex

### 2. Torrent Script
- **Location**: `scripts/add-torrent.sh`
- **Purpose**: CLI tool for adding torrents

### 3. Directory Structure
```
torrent/
├── downloads/      # Temporary download location
├── watch/          # Drop .torrent files here for auto-download
└── config/         # Transmission configuration
```

## Usage

### Method 1: Using the Script

```bash
# Add a movie via magnet link
./scripts/add-torrent.sh 'magnet:?xt=urn:btih:HASH...'

# Specify media type
./scripts/add-torrent.sh 'magnet:?xt=urn:btih:HASH...' --type movies
```

### Method 2: Transmission Web UI

1. Open http://localhost:9091
2. Click "Open Torrent"
3. Paste magnet link or upload .torrent file
4. Files download to `torrent/downloads/`
5. Move completed files to `input/` for processing

### Method 3: Watch Folder

Drop `.torrent` files into `torrent/watch/` - they start automatically.

## Workflow

```
Magnet Link
    ↓
Transmission (downloads to torrent/downloads/)
    ↓
Script moves to input/
    ↓
Converter processes
    ↓
Files appear in data/movies|tv|music/
    ↓
Plex auto-detects
```

## Configuration

### Transmission Settings

Access web UI at http://localhost:9091 to configure:
- Download speed limits
- Upload speed limits
- Port forwarding
- Blocklists

### Auto-move Completed Files

Edit `torrent/config/settings.json`:
```json
{
  "script-torrent-done-enabled": true,
  "script-torrent-done-filename": "/scripts/move-completed.sh"
}
```

## Commands

### Start Services
```bash
cd plex && docker compose up -d
```

### View Transmission Logs
```bash
cd plex && docker compose logs -f transmission
```

### Check Downloads
```bash
ls -lh torrent/downloads/
```

### Manual Move to Input
```bash
mv torrent/downloads/*.mp4 input/
```

## Examples

### Download a Movie
```bash
./scripts/add-torrent.sh 'magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a'
```

### Download TV Show
```bash
./scripts/add-torrent.sh 'magnet:?xt=urn:btih:...' --type tv
```

### Download Music Album
```bash
./scripts/add-torrent.sh 'magnet:?xt=urn:btih:...' --type music
```

## Notes

- Torrent downloads can take time depending on seeders
- Conversion happens automatically after download completes
- Original torrent files are cleaned up after processing
- Use VPN if concerned about privacy
- Ensure you have rights to download the content

## Troubleshooting

**Issue:** Transmission container won't start  
**Solution:** Check port 9091 isn't already in use: `sudo lsof -i :9091`

**Issue:** Downloads not moving to input  
**Solution:** Check permissions: `sudo chown -R 1000:1000 torrent/ input/`

**Issue:** Slow download speeds  
**Solution:** 
- Check seeders/peers in Transmission UI
- Configure port forwarding on router (port 51413)
- Adjust speed limits in Transmission settings

**Issue:** Can't access Transmission Web UI  
**Solution:** Verify container is running: `cd plex && docker compose ps`

## Security

- Transmission Web UI has no password by default
- Configure authentication in `torrent/config/settings.json`
- Consider using a VPN container for privacy

## Related Documentation

- **Converter**: `converter/converter.py`
- **Scripts**: `docs/robots/SCRIPTS.md`
- **Plex Setup**: `plex/SMART_TV_INSTALLATION.md`

---

*Part of the Plex-Me-Hard (PMH) system*
