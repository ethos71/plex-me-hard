# Plex-Me-Hard Agent

## Description
AI agent for managing the Plex-Me-Hard media server system. Handles Plex server operations, media conversion, and Samsung TV setup.

## Capabilities

### Core Functions
- Monitor and manage Plex media server
- Convert media files to Plex-optimized formats
- Manage Docker containers (Plex + Converter)
- Create and organize documentation in `docs/robots/`

### Media Management
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
│   ├── docker-compose.yml
│   ├── setup.sh
│   └── SMART_TV_INSTALLATION.md
├── converter/          # Media conversion service
├── docs/
│   └── robots/        # All agent/robot documentation (REQUIRED)
├── data/
│   ├── movies/        # Converted movies for Plex
│   ├── tv/            # TV shows
│   └── music/         # Music files
└── input/             # Raw media files for conversion
```

## Key Files

- **plex/docker-compose.yml** - Service orchestration
- **converter/converter.py** - Media conversion logic
- **PLEX_CREDENTIALS.md** - Server credentials (gitignored)

## Environment

- **Plex Server URL**: http://192.168.12.143:32400/web
- **Account**: dominick.do.campbell+1@gmail.com
- **Project Path**: /home/dominick/workspace/plex-me-hard
- **Documentation Path**: docs/robots/

## Common Tasks

### Add Media from Local File
1. Copy media file to `input/` folder
2. Converter auto-processes to appropriate folder
3. File appears in Plex

### Check System Status
```bash
cd plex && docker compose ps
```

### View Conversion Logs
```bash
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
