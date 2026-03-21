"""
Sprite Sheet Generator
======================
For each character folder (e.g. 100, 101, 102...):
  - Finds all animation folders (e.g. anim0L, anim0R...) inside <char>/frames/<char>/frames/
  - Merges individual PNGs into a horizontal sprite sheet named <animFolder>.png
  - Saves sprite sheets to: output/<char>/
  - Updates character_sprite_metadata.json at the output root with frame count per animation

Usage:
  python sprite_sheet_generator.py --input /path/to/characters --output /path/to/output
  Or just drop this script next to your character folders and run it with no arguments —
  it will auto-detect character folders in the current directory.
"""
# =============================================================================
# CONFIGURATION — edit these paths if you're not using command-line arguments
# =============================================================================
DEFAULT_INPUT_FOLDER  = r"D:\Perso\Gamemaking\sprite_extraction\extract_sprites_output"           # Root folder containing character folders
DEFAULT_OUTPUT_FOLDER = r"D:\Perso\Gamemaking\sprite_extraction\sprite_sheet_generator_output"          # Output folder; None = <input>/output
# =============================================================================
import os
import re
import json
import argparse
from pathlib import Path
from PIL import Image

def find_character_folders(root: Path) -> list[Path]:
    """Return folders whose name is a number (e.g. 100, 101...)."""
    return sorted(
        [p for p in root.iterdir() if p.is_dir() and p.name.isdigit()],
        key=lambda p: int(p.name)
    )

def find_anim_folders(char_folder: Path) -> list[Path]:
    """
    Locate the frames directory for a character and return its animation subfolders.
    Expected path: <char>/frames/<char>/frames/
    Falls back to any nested 'frames' directory containing anim* folders.
    """
    char_id = char_folder.name
    # Primary expected path
    primary = char_folder / "frames" / char_id / "frames"
    if primary.is_dir():
        return sorted(
            [p for p in primary.iterdir() if p.is_dir()],
            key=lambda p: p.name
        )
    # Fallback: walk to find any folder containing subfolders with PNGs
    for dirpath, dirnames, _ in os.walk(char_folder):
        dp = Path(dirpath)
        sub_dirs = [dp / d for d in dirnames]
        anim_dirs = [d for d in sub_dirs if any(d.glob("*.png"))]
        if anim_dirs:
            return sorted(anim_dirs, key=lambda p: p.name)
    return []

def natural_sort_key(path: Path) -> list:
    """Sort 1.png, 2.png, ... 10.png correctly (natural order)."""
    parts = re.split(r"(\d+)", path.stem)
    return [int(p) if p.isdigit() else p.lower() for p in parts]

def build_sprite_sheet(anim_folder: Path) -> tuple[Image.Image, int] | tuple[None, 0]:
    """
    Load all PNGs from an animation folder (natural order) and stitch into a horizontal strip.
    Returns (sprite_sheet_image, frame_count) or (None, 0) if no valid frames found.
    """
    png_files = sorted(
        [f for f in anim_folder.iterdir() if f.suffix.lower() == ".png"],
        key=natural_sort_key
    )
    if not png_files:
        return None, 0
    frames = []
    for png in png_files:
        try:
            img = Image.open(png).convert("RGBA")
            frames.append(img)
        except Exception as e:
            print(f"    ⚠ Could not open {png.name}: {e}")
    if not frames:
        return None, 0
    max_w = max(f.width for f in frames)
    max_h = max(f.height for f in frames)
    total_w = max_w * len(frames)
    sheet = Image.new("RGBA", (total_w, max_h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * max_w, 0))
    return sheet, len(frames)

def process_character(char_folder: Path, output_root: Path) -> dict:
    """
    Process a single character folder.
    Returns the metadata dict for this character (keyed by anim name),
    or an empty dict if nothing was generated.
    """
    char_id = char_folder.name
    print(f"\n📁 Character {char_id}")

    anim_folders = find_anim_folders(char_folder)
    if not anim_folders:
        print(f"  ⚠ No animation folders found, skipping.")
        return {}

    out_dir = output_root / char_id
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load existing bounds.json from the source folder (if present)
    bounds_path = char_folder / "bounds.json"
    if bounds_path.exists():
        with open(bounds_path, "r", encoding="utf-8") as f:
            bounds = json.load(f)
    else:
        print(f"  ⚠ bounds.json not found, will build metadata from scratch.")
        bounds = {}

    frame_counts = {}
    for anim_folder in anim_folders:
        anim_name = anim_folder.name
        print(f"  🎞 {anim_name} ...", end=" ")
        sheet, count = build_sprite_sheet(anim_folder)
        if sheet is None:
            print("no PNGs found, skipped.")
            continue
        out_path = out_dir / f"{anim_name}.png"
        sheet.save(out_path, "PNG")
        frame_counts[anim_name] = count
        print(f"{count} frame(s) → {out_path.relative_to(output_root.parent)}")

    if not frame_counts:
        print(f"  ⚠ No sprite sheets generated for character {char_id}.")
        return {}

    # Merge frame counts into bounds data
    for anim_name, count in frame_counts.items():
        if anim_name not in bounds:
            bounds[anim_name] = {}
        if isinstance(bounds[anim_name], dict):
            bounds[anim_name]["frames"] = count
        else:
            bounds[anim_name] = {"frames": count}

    return bounds

def main():
    parser = argparse.ArgumentParser(description="Sprite Sheet Generator")
    parser.add_argument(
        "--input", "-i",
        type=Path,
        default=Path(DEFAULT_INPUT_FOLDER),
        help="Root folder containing character folders (default: current directory)"
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        default=Path(DEFAULT_OUTPUT_FOLDER) if DEFAULT_OUTPUT_FOLDER else None,
        help="Output folder for sprite sheets (default: <input>/output)"
    )
    args = parser.parse_args()

    input_root  = args.input.resolve()
    output_root = (args.output or input_root / "output").resolve()

    print(f"🔍 Scanning: {input_root}")
    print(f"📤 Output:   {output_root}")

    char_folders = find_character_folders(input_root)
    if not char_folders:
        print("❌ No character folders (numeric names) found.")
        return

    print(f"Found {len(char_folders)} character folder(s): {[c.name for c in char_folders]}")

    # Collect all metadata across characters: { "1207": { "anim0L": {...}, ... }, ... }
    all_metadata = {}
    for char_folder in char_folders:
        char_meta = process_character(char_folder, output_root)
        if char_meta:
            all_metadata[char_folder.name] = char_meta

    # Write single combined metadata file at the output root
    if all_metadata:
        output_root.mkdir(parents=True, exist_ok=True)
        meta_path = output_root / "character_sprite_metadata.json"
        with open(meta_path, "w", encoding="utf-8") as f:
            json.dump(all_metadata, f, indent=2, ensure_ascii=False)
        print(f"\n✅ Metadata written → {meta_path}")
    else:
        print("\n⚠ No metadata to write.")

    print("\n✨ Done!")

if __name__ == "__main__":
    main()