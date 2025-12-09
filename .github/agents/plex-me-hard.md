# Plex-Me-Hard Agent

## Description
AI agent for managing the Plex-Me-Hard media server system. Handles Plex server operations, media conversion, Google Drive sync, and Samsung TV setup.

## Capabilities

### Core Functions
- Monitor and manage Plex media server
- Convert media files to Plex-optimized formats
- Sync media from Google Drive
- Manage Docker containers (Plex + Converter)
- Create and organize documentation in `docs/robots/`

### Media Management
- Add movies from Google Drive (automatic download and conversion)
- Add movies from local files
- List and organize media libraries
- Monitor conversion progress

### System Operations
- Check service status (Plex + Converter)
- View logs in real-time
- Restart services
- Troubleshoot connection issues

### Documentation
- All new robot/agent documentation MUST be saved to `docs/robots/`
- Use markdown format
- Include usage examples and troubleshooting

## Project Structure

```
plex-me-hard/
├── plex/               # Plex-specific configuration and code
├── converter/          # Media conversion service
├── docs/
│   └── robots/        # All agent/robot documentation (REQUIRED)
├── data/
│   ├── movies/        # Converted movies for Plex
│   ├── tv/            # TV shows
│   └── music/         # Music files
├── input/             # Raw media files for conversion
└── pmh                # CLI management tool
```

## Key Files

- **pmh** - Interactive CLI agent for server management
- **plex/docker-compose.yml** - Service orchestration
- **converter/converter.py** - Media conversion logic
- **PLEX_CREDENTIALS.md** - Server credentials (gitignored)

## Environment

- **Plex Server URL**: http://192.168.12.143:32400/web
- **Account**: dominick.do.campbell+1@gmail.com
- **Project Path**: /home/dominick/workspace/plex-me-hard
- **Documentation Path**: docs/robots/

## Common Tasks

### Add Media from Google Drive
1. Ensure file is shared as "Anyone with the link"
2. Get file URL/ID
3. Use `pmh` tool option 2 or download with gdown
4. File auto-converts and appears in Plex

### Check System Status
```bash
pmh status
```

### View Conversion Logs
```bash
pmh logs
# or
cd plex && docker compose logs -f converter
```

### Restart Services
```bash
cd plex && docker compose restart plex
cd plex && docker compose restart converter
```

## Important Rules

1. **Documentation Location**: ALL new documentation MUST go in `docs/robots/`
2. **Media Files**: Keep in `data/movies/`, `data/tv/`, `data/music/`
3. **Credentials**: Never commit credentials (in .gitignore)
4. **Input Folder**: Temporary storage, files move after conversion
5. **Plex Files**: All Plex-related config in `plex/` folder

## Integration Points

- **Google Drive**: Automatic sync via rclone
- **Samsung TV**: Plex app with account linking
- **Docker**: All services containerized
- **GitHub**: Code repository with agents/prompts

## Troubleshooting

- Use `plex/troubleshoot-plex.sh` for connection issues
- Check `plex/check-status.sh` for file pipeline status
- View logs: `cd plex && docker compose logs [service]`
- Restart: `cd plex && docker compose restart [service]`

## Related Prompts

Use `.github/prompts/plex-me-hard.md` for detailed interaction guidelines.
