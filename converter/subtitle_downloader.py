#!/usr/bin/env python3
"""
Subtitle Downloader for Plex-Me-Hard
Automatically downloads subtitles for all media files in data directories
Uses OpenSubtitles API via subliminal
"""

import os
import logging
from pathlib import Path
from subliminal import download_best_subtitles, save_subtitles, Video
from babelfish import Language

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Directories to scan
MOVIES_DIR = os.getenv('OUTPUT_MOVIES', '/output/movies')
TV_DIR = os.getenv('OUTPUT_TV', '/output/tv')
MUSIC_DIR = os.getenv('OUTPUT_MUSIC', '/output/music')

# Supported video extensions
VIDEO_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.m4v', '.wmv', '.flv'}

# Languages to download (default: English)
LANGUAGES = {Language('eng')}


def get_video_files(directory):
    """Get all video files in a directory"""
    video_files = []
    
    if not os.path.exists(directory):
        logger.warning(f"Directory does not exist: {directory}")
        return video_files
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if Path(file).suffix.lower() in VIDEO_EXTENSIONS:
                video_files.append(os.path.join(root, file))
    
    return video_files


def has_subtitles(video_path):
    """Check if video already has subtitle files"""
    base_path = os.path.splitext(video_path)[0]
    subtitle_extensions = ['.srt', '.sub', '.ass', '.ssa', '.vtt']
    
    for ext in subtitle_extensions:
        if os.path.exists(base_path + ext):
            return True
        # Check for language-specific subtitles
        if os.path.exists(base_path + '.en' + ext):
            return True
    
    return False


def download_subtitles_for_file(video_path):
    """Download subtitles for a single video file"""
    try:
        if has_subtitles(video_path):
            logger.info(f"Subtitles already exist for: {os.path.basename(video_path)}")
            return True
        
        logger.info(f"Downloading subtitles for: {os.path.basename(video_path)}")
        
        # Create Video object
        video = Video.fromname(video_path)
        
        # Download best subtitles
        subtitles = download_best_subtitles([video], LANGUAGES)
        
        if video in subtitles and subtitles[video]:
            # Save subtitles
            save_subtitles(video, subtitles[video])
            logger.info(f"✓ Successfully downloaded subtitles for: {os.path.basename(video_path)}")
            return True
        else:
            logger.warning(f"No subtitles found for: {os.path.basename(video_path)}")
            return False
            
    except Exception as e:
        logger.error(f"Error downloading subtitles for {video_path}: {e}")
        return False


def process_directory(directory, media_type):
    """Process all videos in a directory"""
    logger.info(f"Scanning {media_type} directory: {directory}")
    
    video_files = get_video_files(directory)
    
    if not video_files:
        logger.info(f"No video files found in {directory}")
        return
    
    logger.info(f"Found {len(video_files)} video file(s)")
    
    success_count = 0
    for video_path in video_files:
        if download_subtitles_for_file(video_path):
            success_count += 1
    
    logger.info(f"Subtitles downloaded for {success_count}/{len(video_files)} files in {media_type}")


def main():
    """Main function to process all media directories"""
    logger.info("Starting subtitle downloader...")
    
    # Process each directory
    process_directory(MOVIES_DIR, "Movies")
    process_directory(TV_DIR, "TV Shows")
    
    logger.info("Subtitle download complete!")


if __name__ == "__main__":
    main()
