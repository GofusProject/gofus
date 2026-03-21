#!/usr/bin/env python3
"""
Usage: python3 copy_animations.py --source <character_folder> --dest <output_folder>

Copies all PNGs starting with 'run', 'walk', or 'static' from the character folder
to the output folder, preserving the folder structure.
"""

import os
import shutil
import argparse

# Config
PREFIXES = ["static"]

def copy_animations(source_dir, dest_dir):
    total_files = 0
    copied_files = 0

    # Count total files to process
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith('.png') and any(file.lower().startswith(prefix) for prefix in PREFIXES):
                total_files += 1

    print(f"Found {total_files} files to copy.")

    # Copy files
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith('.png') and any(file.lower().startswith(prefix) for prefix in PREFIXES):
                source_path = os.path.join(root, file)
                rel_path = os.path.relpath(root, source_dir)
                dest_path = os.path.join(dest_dir, rel_path)

                os.makedirs(dest_path, exist_ok=True)
                shutil.copy2(source_path, dest_path)

                copied_files += 1
                print(f"Copied: {source_path} -> {dest_path}/{file} ({copied_files}/{total_files})")

    print(f"Done. Copied {copied_files} files.")

def main():
    parser = argparse.ArgumentParser(description="Copy animation PNGs from character folder.")
    parser.add_argument("--source", required=True, help="Source character folder")
    parser.add_argument("--dest", required=True, help="Destination folder")
    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"Error: Source folder '{args.source}' does not exist.")
        return

    copy_animations(args.source, args.dest)

if __name__ == "__main__":
    main()
