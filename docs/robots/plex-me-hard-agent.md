# Plex-Me-Hard Agent - Quick Reference

## What is @plex-me-hard?

@plex-me-hard is an AI agent for managing your Plex media server with automatic conversion.

## Usage

Use the `@plex-me-hard` mention in GitHub Copilot Chat to interact with the agent.

### Core Capabilities

- **Media Management**: Add and convert media files
- **System Monitoring**: Check service status and logs
- **Docker Operations**: Manage Plex and converter containers
- **Documentation**: Create and organize docs in `docs/robots/`

## Common Commands

### Check System Status
```bash
cd plex && docker compose ps
```

### View Conversion Logs
```bash
cd plex && docker compose logs -f converter
```

### View Plex Logs
```bash
cd plex && docker compose logs -f plex
```

### Restart Services
```bash
cd plex && docker compose restart plex
cd plex && docker compose restart converter
```

### List Movies
```bash
ls -lh data/movies/
```

## Adding Media

### From Local File
```bash
# Copy file to input folder
cp movie.mp4 input/

# Converter automatically processes it
# File appears in data/movies/
# Plex detects it automatically
```

## Server Information

- **Plex Web UI**: http://192.168.12.143:32400/web
- **Account**: dominick.do.campbell+1@gmail.com
- **Project Location**: /home/dominick/workspace/plex-me-hard

## Documentation Rules

- **All new docs** go in `docs/robots/`
- Use markdown format
- Include: Purpose, Usage, Examples, Troubleshooting

## Troubleshooting

### Plex Not Accessible
```bash
plex/troubleshoot-plex.sh
```

### Check File Pipeline
```bash
plex/check-status.sh
```

### Fix Permissions
```bash
sudo chown -R 1000:1000 data/
```

## Agent Files

- **Agent Definition**: `.github/agents/plex-me-hard.md`
- **System Prompt**: `.github/prompts/plex-me-hard.md`
- **Documentation**: `docs/robots/`

## Related Documentation

- **Installation**: `docs/robots/INSTALLATION.md`
- **Scripts Reference**: `docs/robots/SCRIPTS.md`
- **Samsung TV Setup**: `plex/SMART_TV_INSTALLATION.md`
