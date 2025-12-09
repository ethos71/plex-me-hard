# PMH Agent - Quick Reference

## What is PMH?

PMH (Plex-Me-Hard) is your command-line agent for managing your Plex media server.

## Usage

Simply type `pmh` from anywhere in your terminal to launch the interactive menu.

### Quick Commands

```bash
pmh              # Launch interactive menu
pmh status       # Check system status
pmh logs         # View converter logs
pmh movies       # List all movies
pmh info         # Show server information
```

### Interactive Menu Options

1. **Check status** - View running services and media counts
2. **Add media from Google Drive** - Download and convert from Google Drive
3. **Add media from local file** - Copy local file to converter
4. **View converter logs** - Watch conversion progress in real-time
5. **View Plex logs** - Monitor Plex server activity
6. **List movies in library** - See all movies ready to stream
7. **Restart Plex** - Restart the Plex server
8. **Restart converter** - Restart the media converter
9. **Get Plex server info** - Display server details and TV setup instructions
0. **Exit** - Close the agent

## Examples

### Adding a Movie from Google Drive

```bash
pmh
# Choose option 2
# Enter the Google Drive file URL when prompted
# The file will download and convert automatically
```

### Checking Conversion Progress

```bash
pmh logs
# Watch the converter in real-time
# Press Ctrl+C to exit
```

### Quick Status Check

```bash
pmh status
```

## Server Information

- **Plex Web UI**: http://192.168.12.143:32400/web
- **Account**: dominick.do.campbell+1@gmail.com
- **Project Location**: /home/dominick/workspace/plex-me-hard

## Troubleshooting

If PMH doesn't work:
```bash
cd /home/dominick/workspace/plex-me-hard
./pmh
```

Or reinstall the symlink:
```bash
sudo ln -sf /home/dominick/workspace/plex-me-hard/pmh /usr/local/bin/pmh
```
