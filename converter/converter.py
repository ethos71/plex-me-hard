#!/usr/bin/env python3
import os
import subprocess
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

INPUT_DIR = os.getenv('INPUT_DIR', '/input')
OUTPUT_MOVIES = os.getenv('OUTPUT_MOVIES', '/output/movies')
OUTPUT_TV = os.getenv('OUTPUT_TV', '/output/tv')
OUTPUT_MUSIC = os.getenv('OUTPUT_MUSIC', '/output/music')

VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.flv', '.wmv', '.m4v', '.mpg', '.mpeg', '.webm'}
AUDIO_EXTENSIONS = {'.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg', '.wma', '.opus'}

class MediaConverter(FileSystemEventHandler):
    def __init__(self):
        self.processing = set()
        
    def on_created(self, event):
        if event.is_directory:
            return
        self.process_file(event.src_path)
    
    def process_file(self, filepath):
        if filepath in self.processing:
            return
            
        file_path = Path(filepath)
        ext = file_path.suffix.lower()
        
        if ext not in VIDEO_EXTENSIONS and ext not in AUDIO_EXTENSIONS:
            return
        
        # Wait for file to finish writing
        time.sleep(2)
        
        self.processing.add(filepath)
        
        try:
            if ext in AUDIO_EXTENSIONS:
                self.convert_audio(file_path)
            elif ext in VIDEO_EXTENSIONS:
                self.convert_video(file_path)
        finally:
            self.processing.discard(filepath)
    
    def convert_video(self, input_file):
        print(f"Converting video: {input_file}")
        
        # Determine output directory (movies by default)
        output_dir = Path(OUTPUT_MOVIES)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        output_file = output_dir / f"{input_file.stem}.mp4"
        
        # Convert to H.264/AAC for broad compatibility
        cmd = [
            'ffmpeg', '-i', str(input_file),
            '-c:v', 'libx264',
            '-preset', 'medium',
            '-crf', '23',
            '-c:a', 'aac',
            '-b:a', '192k',
            '-movflags', '+faststart',
            '-y',
            str(output_file)
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"Successfully converted: {output_file}")
        except subprocess.CalledProcessError as e:
            print(f"Error converting {input_file}: {e}")
    
    def convert_audio(self, input_file):
        print(f"Converting audio: {input_file}")
        
        output_dir = Path(OUTPUT_MUSIC)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        output_file = output_dir / f"{input_file.stem}.mp3"
        
        # Convert to MP3 for broad compatibility
        cmd = [
            'ffmpeg', '-i', str(input_file),
            '-c:a', 'libmp3lame',
            '-b:a', '320k',
            '-y',
            str(output_file)
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"Successfully converted: {output_file}")
        except subprocess.CalledProcessError as e:
            print(f"Error converting {input_file}: {e}")

def process_existing_files():
    """Process any files that already exist in the input directory"""
    converter = MediaConverter()
    input_path = Path(INPUT_DIR)
    
    if not input_path.exists():
        input_path.mkdir(parents=True, exist_ok=True)
        return
    
    print(f"Scanning {INPUT_DIR} for existing files...")
    for file_path in input_path.rglob('*'):
        if file_path.is_file():
            converter.process_file(str(file_path))

if __name__ == "__main__":
    print("Starting media converter...")
    print(f"Watching directory: {INPUT_DIR}")
    
    # Start Google Drive sync in background if enabled
    if os.getenv('ENABLE_GDRIVE_SYNC', 'false').lower() == 'true':
        print("Starting Google Drive sync...")
        subprocess.Popen(['/app/sync_gdrive.sh'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    # Process existing files first
    process_existing_files()
    
    # Set up file watcher
    event_handler = MediaConverter()
    observer = Observer()
    observer.schedule(event_handler, INPUT_DIR, recursive=True)
    observer.start()
    
    print("Media converter is running. Waiting for files...")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    
    observer.join()
