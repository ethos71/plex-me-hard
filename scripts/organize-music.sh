#!/bin/bash

# Enhanced script to move and organize music files from Downloads to Music folder
# Uses MusicBrainz API to lookup metadata and organize properly

SOURCE_DIR="/home/dominick/Downloads"
DEST_DIR="/home/dominick/Music"
PYTHON_SCRIPT="/tmp/music_organizer.py"

echo "Creating Python metadata organizer..."

# Create Python script for metadata extraction and organization
cat > "$PYTHON_SCRIPT" << 'PYEOF'
#!/usr/bin/env python3
import os
import re
import json
import urllib.request
import urllib.parse
import time
from pathlib import Path

SOURCE_DIR = "/home/dominick/Downloads"
DEST_DIR = "/home/dominick/Music"

def extract_info_from_filename(filename):
    """Extract track number and title from filename"""
    # Remove extension
    name = os.path.splitext(filename)[0]
    
    # Try to extract track number and title
    # Pattern: "01 - Title" or "01 Title" or "01. Title"
    match = re.match(r'^(\d+)\s*[-.\s]+(.+)$', name)
    if match:
        track_num = match.group(1).zfill(2)
        title = match.group(2).strip()
        return track_num, title
    return None, name

def search_musicbrainz(track_title):
    """Search MusicBrainz for track information"""
    try:
        # Clean up title for search
        query = urllib.parse.quote(track_title)
        url = f"https://musicbrainz.org/ws/2/recording/?query={query}&fmt=json&limit=1"
        
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'PlexMusicOrganizer/1.0')
        
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            
            if data.get('recordings') and len(data['recordings']) > 0:
                recording = data['recordings'][0]
                
                # Extract artist and album
                artist = "Unknown Artist"
                album = "Unknown Album"
                
                if 'artist-credit' in recording and len(recording['artist-credit']) > 0:
                    artist = recording['artist-credit'][0].get('name', 'Unknown Artist')
                
                if 'releases' in recording and len(recording['releases']) > 0:
                    album = recording['releases'][0].get('title', 'Unknown Album')
                
                return artist, album
        
        time.sleep(1)  # Rate limiting
    except Exception as e:
        print(f"  API Error: {str(e)}")
    
    return None, None

def organize_music():
    """Main function to organize music files"""
    print("Scanning for music files...")
    print("=" * 60)
    
    # Find all music files
    music_files = []
    for ext in ['*.mp3', '*.flac', '*.m4a', '*.wav', '*.ogg']:
        music_files.extend(Path(SOURCE_DIR).glob(ext))
    
    if not music_files:
        print("No music files found in Downloads")
        return
    
    print(f"Found {len(music_files)} music files\n")
    
    moved_count = 0
    failed_count = 0
    
    for file_path in music_files:
        filename = file_path.name
        print(f"Processing: {filename}")
        
        # Extract info from filename
        track_num, title = extract_info_from_filename(filename)
        
        if title:
            print(f"  Track: {track_num or '??'} - {title}")
            
            # Search MusicBrainz
            print(f"  Searching MusicBrainz...")
            artist, album = search_musicbrainz(title)
            
            if artist and album:
                print(f"  Found: {artist} - {album}")
                
                # Create directory structure
                artist_dir = Path(DEST_DIR) / artist
                album_dir = artist_dir / album
                album_dir.mkdir(parents=True, exist_ok=True)
                
                # Move file
                dest_path = album_dir / filename
                if dest_path.exists():
                    print(f"  SKIP: File already exists")
                else:
                    try:
                        file_path.rename(dest_path)
                        print(f"  MOVED: {artist}/{album}/{filename}")
                        print(f"  DELETED from Downloads")
                        moved_count += 1
                    except Exception as e:
                        print(f"  ERROR: {str(e)}")
                        failed_count += 1
            else:
                print(f"  Could not find metadata, moving to Unknown Album")
                # Move to Unknown Album
                unknown_dir = Path(DEST_DIR) / "Unknown Album"
                unknown_dir.mkdir(parents=True, exist_ok=True)
                dest_path = unknown_dir / filename
                try:
                    file_path.rename(dest_path)
                    print(f"  DELETED from Downloads")
                    moved_count += 1
                except Exception as e:
                    print(f"  ERROR: {str(e)}")
                    failed_count += 1
        
        print()
    
    print("=" * 60)
    print(f"Organization complete!")
    print(f"Moved: {moved_count} files")
    print(f"Failed: {failed_count} files")

if __name__ == "__main__":
    organize_music()
PYEOF

# Run the Python script
echo "Running music organizer with MusicBrainz lookup..."
python3 "$PYTHON_SCRIPT"

# Set proper permissions for Plex
echo ""
echo "Setting permissions for Plex..."
sudo chown -R plex:plex "$DEST_DIR" 2>/dev/null || chown -R dominick:dominick "$DEST_DIR"

echo ""
echo "Done! Check $DEST_DIR for organized music."
echo ""
echo "Note: MusicBrainz lookups are best-effort. For better accuracy,"
echo "consider using MusicBrainz Picard for manual tagging."

# Clean up
rm -f "$PYTHON_SCRIPT"
