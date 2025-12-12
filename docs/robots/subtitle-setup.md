# Plex Automatic Subtitle Setup

## Overview
Configure Plex to automatically download subtitles for all media files.

## Steps to Enable

### 1. Access Plex Settings
1. Open Plex web UI: http://localhost:32400/web
2. Click Settings (wrench icon)
3. Go to "Agents" section

### 2. Enable OpenSubtitles
1. Under "Movies" → Expand "Plex Movie"
2. Check "OpenSubtitles.org"
3. Drag it to top priority
4. Repeat for "TV Shows" → "TheTVDB"

### 3. Configure Library Settings
1. Go to Settings → Libraries
2. For each library (Movies, TV Shows):
   - Click the three dots → "Edit"
   - Go to "Advanced" tab
   - Enable "Search for missing subtitles automatically"
   - Set language preferences (e.g., English)
   - Click "Save Changes"

### 4. Trigger Subtitle Downloads

**Automatic:**
- Plex scans new files and downloads subtitles within minutes

**Manual:**
- Go to library → Movie/Show
- Click the three dots → "Scan Library Files"
- Or hover over item → three dots → "Match" → "Search Options" → Download subtitles

## Verification

1. Add a new movie to Plex
2. Wait 2-5 minutes
3. Play the movie
4. Click subtitle button (CC icon)
5. Should see subtitle options available

## Troubleshooting

**No subtitles appearing:**
- Check OpenSubtitles agent is enabled and at top priority
- Verify "Search for missing subtitles" is enabled in library settings
- Manually trigger library scan
- Check Plex logs: `sudo journalctl -u plexmediaserver -n 50 | grep subtitle`

**Wrong language:**
- Go to Settings → Languages
- Set preferred subtitle language
- Re-scan library

## Notes
- Subtitles download automatically for new content
- No manual intervention needed after initial setup
- Works for both movies and TV shows
- OpenSubtitles is free but may require account for unlimited downloads
