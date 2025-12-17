#!/usr/bin/env python3
"""
Completely strip and rebuild ID3 tags for all albums
This ensures Plex sees consistent, clean metadata
"""

from mutagen.mp3 import MP3
from mutagen.flac import FLAC
from mutagen.id3 import ID3, TIT2, TPE1, TALB, TPE2, TRCK, TDRC
import os
import sys

MUSIC_DIR = "/home/dominick/Music"

def extract_track_number(filename):
    """Extract track number from filename"""
    # Try to get number from start of filename
    parts = filename.split('.')[0].split(' ')[0].split('-')[0]
    try:
        return parts.strip()
    except:
        return "1"

def extract_title(filename):
    """Extract title from filename"""
    name = filename.replace('.mp3', '').replace('.flac', '')
    # Remove track number prefix
    if ' - ' in name:
        return name.split(' - ', 1)[-1]
    elif '. ' in name and name[0].isdigit():
        return name.split('. ', 1)[-1] if len(name.split('. ')) > 1 else name
    return name

def process_mp3(filepath, artist, album):
    """Strip and rebuild MP3 tags"""
    try:
        audio = MP3(filepath)
        audio.delete()
        audio.save()
        
        audio = MP3(filepath)
        audio.tags = ID3()
        
        filename = os.path.basename(filepath)
        track_num = extract_track_number(filename)
        title = extract_title(filename)
        
        audio.tags.add(TPE1(encoding=3, text=artist))
        audio.tags.add(TPE2(encoding=3, text=artist))
        audio.tags.add(TALB(encoding=3, text=album))
        audio.tags.add(TRCK(encoding=3, text=track_num))
        audio.tags.add(TIT2(encoding=3, text=title))
        
        audio.save()
        return True
    except Exception as e:
        print(f"    ⚠️  Error: {e}")
        return False

def process_flac(filepath, artist, album):
    """Strip and rebuild FLAC tags"""
    try:
        audio = FLAC(filepath)
        audio.delete()
        
        filename = os.path.basename(filepath)
        track_num = extract_track_number(filename)
        title = extract_title(filename)
        
        audio['artist'] = artist
        audio['albumartist'] = artist
        audio['album'] = album
        audio['tracknumber'] = track_num
        audio['title'] = title
        
        audio.save()
        return True
    except Exception as e:
        print(f"    ⚠️  Error: {e}")
        return False

def main():
    print("=" * 50)
    print("Rebuild All Album Tags for Plex")
    print("=" * 50)
    print()
    
    if not os.path.exists(MUSIC_DIR):
        print(f"ERROR: Music directory not found: {MUSIC_DIR}")
        return 1
    
    total_albums = 0
    total_files = 0
    
    # Walk through Artist/Album structure
    for artist_name in sorted(os.listdir(MUSIC_DIR)):
        artist_path = os.path.join(MUSIC_DIR, artist_name)
        
        if not os.path.isdir(artist_path):
            continue
        
        for album_name in sorted(os.listdir(artist_path)):
            album_path = os.path.join(artist_path, album_name)
            
            if not os.path.isdir(album_path):
                continue
            
            print(f"Processing: {artist_name} / {album_name}")
            
            files = [f for f in os.listdir(album_path) 
                    if f.endswith(('.mp3', '.flac'))]
            
            if not files:
                print("  ⚠️  No audio files")
                continue
            
            success_count = 0
            for filename in sorted(files):
                filepath = os.path.join(album_path, filename)
                
                if filename.endswith('.mp3'):
                    if process_mp3(filepath, artist_name, album_name):
                        success_count += 1
                elif filename.endswith('.flac'):
                    if process_flac(filepath, artist_name, album_name):
                        success_count += 1
            
            print(f"  ✅ Rebuilt {success_count}/{len(files)} files")
            total_albums += 1
            total_files += success_count
    
    print()
    print("=" * 50)
    print("Rebuild Complete!")
    print("=" * 50)
    print(f"Albums processed: {total_albums}")
    print(f"Files rebuilt: {total_files}")
    print()
    print("Now refresh your Plex Music library!")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
