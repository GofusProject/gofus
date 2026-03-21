#!/usr/bin/env python3
"""
Usage: python3 remove_animations.py --source <character_folder>

Removes all PNGs except those exactly named 'staticR.png' or 'staticL.png' from the character folder,
preserving the folder structure.
"""

import os
import argparse

# Config
ALLOWED_FILES = {"staticR.png", "staticL.png"}

def remove_animations(source_dir):
    total_files = 0
    removed_files = 0

    # Count total files to process
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith('.png'):
                total_files += 1

    print(f"Found {total_files} PNG files to process.")

    # Remove files
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith('.png'):
                if file not in ALLOWED_FILES:
                    file_path = os.path.join(root, file)
                    os.remove(file_path)
                    removed_files += 1
                    print(f"Removed: {file_path} ({removed_files}/{total_files})")

    print(f"Done. Removed {removed_files} files.")

def main():
    parser = argparse.ArgumentParser(description="Remove animation PNGs from character folder.")
    parser.add_argument("--source", required=True, help="Source character folder")
    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"Error: Source folder '{args.source}' does not exist.")
        return

    remove_animations(args.source)

if __name__ == "__main__":
    main()
