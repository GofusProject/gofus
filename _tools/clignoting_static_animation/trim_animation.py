#!/usr/bin/env python3
"""
Usage: python3 trim_static_sprites.py --source <character_folder> --metadata <character_sprite_metadata.json>

Trims 'staticR.png' and 'staticL.png' sprite sheets to their first frame,
updates the metadata JSON to set frame count to 1 for trimmed sprite sheets.
"""

import os
import json
import argparse
from PIL import Image

def trim_sprite_sheet(image_path, frame_count):
    """Trims the sprite sheet to the first frame and saves it back."""
    if frame_count <= 1:
        print(f"Skipping {image_path}: frame count is {frame_count} (no trimming needed).")
        return False

    try:
        img = Image.open(image_path)
        width, height = img.size
        frame_width = width // frame_count
        first_frame = img.crop((0, 0, frame_width, height))
        first_frame.save(image_path)
        print(f"Trimmed {image_path}: kept first frame of {frame_count}.")
        return True
    except Exception as e:
        print(f"Error trimming {image_path}: {e}")
        return False

def process_sprite_folder(folder_path, sprite_id, metadata, updated_metadata):
    """Processes 'staticR.png' and 'staticL.png' in the given folder and updates metadata."""
    static_files = ["staticR.png", "staticL.png"]
    updated = False

    for file in static_files:
        file_path = os.path.join(folder_path, file)
        if os.path.exists(file_path):
            animation_key = file.replace(".png", "")
            frame_count = metadata.get(sprite_id, {}).get(animation_key, {}).get("frames", 1)
            print(f"Processing {file_path}: frame count in metadata is {frame_count}.")
            if trim_sprite_sheet(file_path, frame_count):
                if sprite_id not in updated_metadata:
                    updated_metadata[sprite_id] = {}
                if animation_key not in updated_metadata[sprite_id]:
                    updated_metadata[sprite_id][animation_key] = {}
                updated_metadata[sprite_id][animation_key] = metadata[sprite_id][animation_key].copy()
                updated_metadata[sprite_id][animation_key]["frames"] = 1
                updated = True
                print(f"Updated metadata for {sprite_id}/{animation_key}: frames set to 1.")
        else:
            print(f"File not found: {file_path}")

    return updated

def trim_static_sprites(source_dir, metadata_path):
    """Trims static sprite sheets and updates metadata."""
    print(f"Loading metadata from {metadata_path}...")
    with open(metadata_path, "r") as f:
        metadata = json.load(f)
    print("Metadata loaded.")

    updated_metadata = {}

    print(f"Scanning folders in {source_dir}...")
    for folder_name in os.listdir(source_dir):
        folder_path = os.path.join(source_dir, folder_name)
        if os.path.isdir(folder_path) and folder_name.isdigit():
            print(f"Processing folder: {folder_name}...")
            process_sprite_folder(folder_path, folder_name, metadata, updated_metadata)

    # Merge updated_metadata into metadata
    for sprite_id, animations in updated_metadata.items():
        if sprite_id not in metadata:
            metadata[sprite_id] = {}
        for animation_key, animation_data in animations.items():
            metadata[sprite_id][animation_key] = animation_data
            print(f"Metadata updated for {sprite_id}/{animation_key}.")

    print(f"Saving updated metadata to {metadata_path}...")
    with open(metadata_path, "w") as f:
        json.dump(metadata, f, indent=2)
    print("Metadata saved.")

def main():
    parser = argparse.ArgumentParser(description="Trim static sprite sheets and update metadata.")
    parser.add_argument("--source", required=True, help="Source character folder")
    parser.add_argument("--metadata", required=True, help="Path to character_sprite_metadata.json")
    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"Error: Source folder '{args.source}' does not exist.")
        return
    if not os.path.exists(args.metadata):
        print(f"Error: Metadata file '{args.metadata}' does not exist.")
        return

    trim_static_sprites(args.source, args.metadata)
    print("Done.")

if __name__ == "__main__":
    main()
