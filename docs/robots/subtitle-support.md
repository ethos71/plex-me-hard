# Subtitle Support for Plex-Me-Hard

**Created:** 2025-12-09  
**Description:** Automatic subtitle downloading system for all media files

## Purpose

Automatically downloads subtitles for all video files added to the Plex library using OpenSubtitles.

## How It Works

### Automatic (For Converted Files)
When media files are converted via the `input/` folder:
1. File is converted to Plex-optimized format
2. Subtitles are automatically downloaded
3. Subtitle files (.srt) are saved next to the video file
4. Plex detects and displays them

### Manual (For Existing Files)
For files added directly to `data/movies/`, `data/tv/`, or via torrents:

```bash
./scripts/download-subtitles.sh
```

This scans all media directories and downloads missing subtitles.

## Subtitle Languages

Default: **English (eng)**

To add more languages, edit `converter/subtitle_downloader.py`:

```python
# Change this line to add languages
LANGUAGES = {Language('eng'), Language('spa'), Language('fra')}
```

Common language codes:
- `eng` - English
- `spa` - Spanish
- `fra` - French
- `ger` - German
- `ita` - Italian
- `jpn` - Japanese
- `kor` - Korean

## Subtitle Formats

Supported formats:
- `.srt` (SubRip) - Most common
- `.sub` (MicroDVD)
- `.ass` (Advanced SubStation)
- `.ssa` (SubStation Alpha)
- `.vtt` (WebVTT)

## File Naming

Subtitles are saved with matching names:

```
Movie.mp4           → Video file
Movie.en.srt        → English subtitles
Movie.es.srt        → Spanish subtitles (if configured)
```

## Usage

### Download Subtitles for All Media

```bash
# From project root
./scripts/download-subtitles.sh
```

### Check If File Has Subtitles

```bash
ls -la data/movies/*.srt
```

### Manually Download for Specific File

```bash
# Via Docker
cd plex && docker compose exec converter python3 -c "
from subtitle_downloader import download_subtitles_for_file
download_subtitles_for_file('/output/movies/YourMovie.mp4')
"
```

## Viewing in Plex

1. Play a video in Plex
2. Click the **subtitle icon** (CC)
3. Select the subtitle track
4. Subtitles appear on screen

## Troubleshooting

**Issue:** No subtitles found  
**Solution:** 
- Check if video has correct metadata (title, year)
- Try renaming file to match movie/show name
- Some content may not have subtitles available

**Issue:** Wrong language downloaded  
**Solution:** Edit `LANGUAGES` setting in `converter/subtitle_downloader.py`

**Issue:** Subtitles out of sync  
**Solution:** 
- Most subtitle files are pre-synced
- Use Plex's subtitle offset feature
- Or download different subtitle file

**Issue:** Subtitle downloader not running  
**Solution:** 
```bash
cd plex && docker compose restart converter
docker compose logs -f converter
```

## Advanced Configuration

### Custom Subtitle Providers

Edit `converter/subtitle_downloader.py`:

```python
from subliminal import download_best_subtitles
from subliminal.providers.opensubtitles import OpenSubtitlesProvider

# Add provider configuration
providers = ['opensubtitles', 'podnapisi', 'thesubdb']
```

### Subtitle File Location

Subtitles are saved in the same directory as video files:
- `data/movies/` - Movie subtitles
- `data/tv/` - TV show subtitles

### Automatic Re-scan

The converter watches for new files and downloads subtitles automatically. To force a re-scan:

```bash
./scripts/download-subtitles.sh
```

## OpenSubtitles Integration

This system uses OpenSubtitles.org via the `subliminal` library:
- Free and open source
- Large subtitle database
- Multiple languages
- No API key required for basic use

For better results, consider:
- Creating an OpenSubtitles account
- Configuring API credentials in the code

## Notes

- Subtitle quality varies by source
- Not all content has subtitles available
- Converted files get subtitles automatically
- Directly added files need manual download via script
- Plex supports multiple subtitle tracks per video

## Related Documentation

- **Converter**: `converter/converter.py`
- **Torrent Processing**: `docs/robots/torrent-processing.md`
- **Scripts**: `docs/robots/SCRIPTS.md`

---

*Part of the Plex-Me-Hard (PMH) system*
