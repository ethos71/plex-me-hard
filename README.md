# Plex Me Hard

Automated Plex media server with automatic media conversion from raw video/audio files.

## Features

- **Plex Media Server**: Full-featured Plex server for streaming your media
- **Automatic Conversion**: Watches `input/` directory and automatically converts:
  - Videos to H.264/AAC MP4 (optimized for streaming)
  - Audio to 320kbps MP3
- **File Watcher**: Automatically detects new files and processes them
- **Docker-based**: Easy deployment with Docker Compose

## Quick Start

### Option 1: Local Files

1. **Start the services:**
   ```bash
   docker-compose up -d
   ```

2. **Add media files:**
   - Drop raw video/audio files into the `input/` directory
   - The converter will automatically process them
   - Converted files appear in the appropriate `data/` subdirectory

### Option 2: Google Drive Sync (Recommended)

1. **Configure Google Drive:** (One-time setup)
   ```bash
   docker-compose run --rm converter rclone config
   ```
   See [Google Drive Setup Guide](docs/GOOGLE_DRIVE_SETUP.md) for detailed instructions.

2. **Create folder in Google Drive:**
   - Create a folder named `plex-me-hard` in your Google Drive

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

4. **Upload files:**
   - Upload videos/music to the `plex-me-hard` folder in Google Drive
   - Files automatically sync and convert every 5 minutes
   - Appear in your Plex library automatically

### Access Plex

- Open http://localhost:32400/web
- Complete the initial Plex setup
- Add libraries pointing to:
  - Movies: `/data/movies`
  - TV Shows: `/data/tv`
  - Music: `/data/music`

## Directory Structure

```
.
├── input/           # Drop raw media files here
├── data/
│   ├── movies/     # Converted movies (shown in Plex)
│   ├── tv/         # Converted TV shows (shown in Plex)
│   └── music/      # Converted music (shown in Plex)
├── config/         # Plex configuration
└── transcode/      # Plex transcoding cache
```

## Supported Formats

### Input (will be converted):
- **Video**: mp4, mkv, avi, mov, flv, wmv, m4v, mpg, mpeg, webm
- **Audio**: mp3, flac, wav, m4a, aac, ogg, wma, opus

### Output (optimized for Plex):
- **Video**: H.264/AAC MP4 (CRF 23, medium preset)
- **Audio**: MP3 320kbps

## Management

**View logs:**
```bash
docker-compose logs -f converter    # Media converter logs
docker-compose logs -f plex         # Plex server logs
```

**Restart services:**
```bash
docker-compose restart
```

**Stop services:**
```bash
docker-compose down
```

## Documentation

- **[Smart TV Installation Guide](docs/SMART_TV_INSTALLATION.md)** - How to install Plex on Samsung, LG, Sony, Roku, Apple TV, etc.
- **[Google Drive Setup Guide](docs/GOOGLE_DRIVE_SETUP.md)** - Configure automatic syncing from Google Drive

## Notes

- First-time setup requires completing Plex configuration in the web UI
- Large video files may take time to convert
- Conversion happens automatically when files are added to `input/` or synced from Google Drive
- Original files are not deleted automatically
- Google Drive sync runs every 5 minutes by default (configurable)
