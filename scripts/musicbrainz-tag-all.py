#!/usr/bin/env python3
"""
Use MusicBrainz to standardize all album metadata
This queries MusicBrainz for official album data and applies it consistently to all tracks
"""

import musicbrainzngs
import os
import sys
import time
from mutagen.mp3 import MP3
from mutagen.flac import FLAC
from mutagen.id3 import ID3, TIT2, TPE1, TALB, TPE2, TRCK, TDRC, TPOS

MUSIC_DIR = "/home/dominick/Music"

# Set up MusicBrainz API
musicbrainzngs.set_useragent("plex-me-hard", "1.0", "https://github.com/ethos71/plex-me-hard")

def search_album(artist, album):
    """Search MusicBrainz for album information"""
    try:
        print(f"  🔍 Searching MusicBrainz for: {artist} - {album}")
        result = musicbrainzngs.search_releases(artist=artist, release=album, limit=5)
        
        if not result.get('release-list'):
            print(f"  ⚠️  No results found")
            return None
        
        # Get the first result (usually most relevant)
        release = result['release-list'][0]
        release_id = release['id']
        
        # Get full release details including tracks
        print(f"  📀 Found: {release.get('title')} by {release.get('artist-credit-phrase', 'Unknown')}")
        full_release = musicbrainzngs.get_release_by_id(release_id, includes=['recordings', 'artist-credits'])
        
        return full_release['release']
    except Exception as e:
        print(f"  ⚠️  MusicBrainz error: {e}")
        return None

def apply_musicbrainz_tags(album_path, mb_data):
    """Apply MusicBrainz metadata to all files in album folder"""
    if not mb_data:
        return False
    
    album_title = mb_data.get('title', '')
    artist_name = mb_data.get('artist-credit-phrase', '')
    release_date = mb_data.get('date', '')
    year = release_date.split('-')[0] if release_date else ''
    
    # Get track list
    tracks = []
    if 'medium-list' in mb_data:
        for medium in mb_data['medium-list']:
            if 'track-list' in medium:
                for track in medium['track-list']:
                    recording = track.get('recording', {})
                    tracks.append({
                        'position': track.get('position', ''),
                        'title': recording.get('title', ''),
                        'number': track.get('number', '')
                    })
    
    if not tracks:
        print(f"  ⚠️  No track information found")
        return False
    
    print(f"  📝 Applying tags: {artist_name} - {album_title} ({year})")
    print(f"  📋 {len(tracks)} tracks found in MusicBrainz")
    
    # Get all audio files
    audio_files = sorted([f for f in os.listdir(album_path) 
                         if f.endswith(('.mp3', '.flac'))])
    
    # Apply tags to each file
    success_count = 0
    for i, filename in enumerate(audio_files):
        filepath = os.path.join(album_path, filename)
        
        # Try to match with MusicBrainz track
        mb_track = tracks[i] if i < len(tracks) else None
        track_title = mb_track['title'] if mb_track else filename.replace('.mp3', '').replace('.flac', '')
        track_num = mb_track['number'] if mb_track else str(i + 1)
        
        try:
            if filename.endswith('.mp3'):
                audio = MP3(filepath)
                audio.delete()
                audio.save()
                
                audio = MP3(filepath)
                audio.tags = ID3()
                
                audio.tags.add(TPE1(encoding=3, text=artist_name))
                audio.tags.add(TPE2(encoding=3, text=artist_name))
                audio.tags.add(TALB(encoding=3, text=album_title))
                audio.tags.add(TIT2(encoding=3, text=track_title))
                audio.tags.add(TRCK(encoding=3, text=track_num))
                if year:
                    audio.tags.add(TDRC(encoding=3, text=year))
                
                audio.save()
                success_count += 1
                
            elif filename.endswith('.flac'):
                audio = FLAC(filepath)
                audio.delete()
                
                audio['artist'] = artist_name
                audio['albumartist'] = artist_name
                audio['album'] = album_title
                audio['title'] = track_title
                audio['tracknumber'] = track_num
                if year:
                    audio['date'] = year
                
                audio.save()
                success_count += 1
        except Exception as e:
            print(f"    ⚠️  Error processing {filename}: {e}")
    
    print(f"  ✅ Tagged {success_count}/{len(audio_files)} files")
    return success_count > 0

def main():
    print("=" * 60)
    print("MusicBrainz Album Metadata Standardization")
    print("=" * 60)
    print()
    print("This will query MusicBrainz for each album and apply")
    print("official metadata to ensure consistency.")
    print()
    
    if not os.path.exists(MUSIC_DIR):
        print(f"ERROR: Music directory not found: {MUSIC_DIR}")
        return 1
    
    total_albums = 0
    tagged_albums = 0
    
    # Walk through Artist/Album structure
    for artist_name in sorted(os.listdir(MUSIC_DIR)):
        artist_path = os.path.join(MUSIC_DIR, artist_name)
        
        if not os.path.isdir(artist_path):
            continue
        
        for album_name in sorted(os.listdir(artist_path)):
            album_path = os.path.join(artist_path, album_name)
            
            if not os.path.isdir(album_path):
                continue
            
            print(f"\n{'='*60}")
            print(f"Processing: {artist_name} / {album_name}")
            print('='*60)
            
            total_albums += 1
            
            # Search MusicBrainz
            mb_data = search_album(artist_name, album_name)
            
            # Apply tags
            if mb_data and apply_musicbrainz_tags(album_path, mb_data):
                tagged_albums += 1
            
            # Rate limiting - be nice to MusicBrainz servers
            time.sleep(1.5)
    
    print()
    print("=" * 60)
    print("MusicBrainz Tagging Complete!")
    print("=" * 60)
    print(f"Total albums: {total_albums}")
    print(f"Successfully tagged: {tagged_albums}")
    print(f"Failed/Skipped: {total_albums - tagged_albums}")
    print()
    print("Now refresh your Plex Music library!")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
