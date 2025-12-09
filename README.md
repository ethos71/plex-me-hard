# Plex Me Hard

Automated Plex media server with automatic media conversion and Google Drive sync.

## 🚀 Quick Start

```bash
# Start services
cd plex && docker compose up -d
```

## 📁 Project Structure

```
plex-me-hard/
├── .github/
│   ├── agents/           # AI agent definitions
│   └── prompts/          # System prompts
├── scripts/              # Installation and setup scripts
│   ├── get-docker.sh
│   ├── setup.sh
│   └── add-torrent.sh    # Torrent processing script
├── plex/                 # Plex server configuration
│   ├── docker-compose.yml
│   ├── check-status.sh
│   ├── troubleshoot-plex.sh
│   └── SMART_TV_INSTALLATION.md
├── converter/            # Media conversion service
│   ├── Dockerfile
│   ├── converter.py
│   └── requirements.txt
├── torrent/              # Torrent downloads
│   ├── downloads/       # Temporary download location
│   ├── watch/           # Drop .torrent files here
│   └── config/          # Transmission config
├── docs/
│   └── robots/          # Agent/robot documentation
│       ├── plex-me-hard-agent.md
│       ├── torrent-processing.md
│       ├── INSTALLATION.md
│       ├── SCRIPTS.md
│       └── PLEX_CREDENTIALS.md (gitignored)
├── data/
│   ├── movies/          # Plex movies library
│   ├── tv/              # TV shows
│   └── music/           # Music
└── input/               # Temp files for conversion
```
```

## 🎯 Features

- **Automatic Conversion**: Drop files in `input/`, get Plex-optimized media
- **Torrent Processing**: Download via magnet links, auto-convert, add to Plex
- **Samsung TV Ready**: Easy setup for streaming to Smart TVs
- **Docker Based**: Easy deployment and management

## 📖 Documentation

- **Agent**: `.github/agents/plex-me-hard.md`
- **Prompt**: `.github/prompts/plex-me-hard.md`
- **Robots**: `docs/robots/` - All agent/robot documentation
  - `plex-me-hard-agent.md` - Quick reference
  - `torrent-processing.md` - Torrent download guide
  - `INSTALLATION.md` - Installation guide
  - `SCRIPTS.md` - Scripts reference
- **Plex Setup**: `plex/SMART_TV_INSTALLATION.md`

## 🛠️ Management

**Docker Commands:**
```bash
cd plex
docker compose ps                    # Check status
docker compose logs -f [service]     # View logs
docker compose restart [service]     # Restart
docker compose up -d --build         # Rebuild and start
```

**File Operations:**
```bash
ls -lh data/movies/           # List movies
cp file.mp4 input/            # Add to converter
sudo chown -R 1000:1000 data/ # Fix permissions
```

**Torrent Operations:**
```bash
./scripts/add-torrent.sh 'magnet:?xt=...'  # Add torrent
# Access Transmission UI: http://localhost:9091
```

## 🔧 Setup

See `scripts/setup.sh` or `docs/robots/INSTALLATION.md` for detailed setup instructions.

## 📺 Access

- **Plex Web UI**: http://192.168.12.143:32400/web
- **Account**: See `PLEX_CREDENTIALS.md` (gitignored)

## 🤖 AI Agents

This project includes AI agent definitions for automated management:
- Agent definition: `.github/agents/plex-me-hard.md`
- System prompt: `.github/prompts/plex-me-hard.md`

All robot/agent documentation is stored in `docs/robots/`.

## Supported Formats

### Input (will be converted):
- **Video**: mp4, mkv, avi, mov, flv, wmv, m4v, mpg, mpeg, webm
- **Audio**: mp3, flac, wav, m4a, aac, ogg, wma, opus

### Output (optimized for Plex):
- **Video**: H.264/AAC MP4 (CRF 23, medium preset)
- **Audio**: MP3 320kbps

## 📝 License

Personal project - use at your own discretion.
