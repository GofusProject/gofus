#!/usr/bin/env python3
# Usage: python as_to_csv.py [--input-folder INPUT_FOLDER] [--output-folder OUTPUT_FOLDER]
#
# Converts ActionScript map area definition files (.as) into structured CSV files.
# Produces 6 CSVs: lang (id+name) and data (full fields) for super-areas, areas, and subareas.

import re
import csv
import os
import argparse
from pathlib import Path

# ─── CONFIG ───────────────────────────────────────────────────────────────────
DEFAULT_INPUT_FOLDER  = "./as"
DEFAULT_OUTPUT_FOLDER = "./output"
# ──────────────────────────────────────────────────────────────────────────────

def parse_args():
    parser = argparse.ArgumentParser(
        description="Convert ActionScript map area definitions to CSV files."
    )
    parser.add_argument(
        "--input-folder", "-i",
        default=DEFAULT_INPUT_FOLDER,
        help=f"Folder containing .as source files (default: {DEFAULT_INPUT_FOLDER})"
    )
    parser.add_argument(
        "--output-folder", "-o",
        default=DEFAULT_OUTPUT_FOLDER,
        help=f"Folder where CSV files will be written (default: {DEFAULT_OUTPUT_FOLDER})"
    )
    return parser.parse_args()


def collect_as_files(folder: str) -> list[Path]:
    folder_path = Path(folder)
    if not folder_path.exists():
        raise FileNotFoundError(f"Input folder not found: {folder}")
    files = list(folder_path.rglob("*.as"))
    print(f"[scan] Found {len(files)} .as file(s) in '{folder}'")
    return files


def parse_file(filepath: Path) -> tuple[dict, dict, dict]:
    """Parse a single .as file. Returns (super_areas, areas, sub_areas)."""
    super_areas = {}  # id -> name
    areas       = {}  # id -> {n, sua}
    sub_areas   = {}  # id -> {n, a, m, v}

    # Patterns
    re_sua = re.compile(r'MA\.sua\[(\d+)\]\s*=\s*"([^"]+)"')
    re_a   = re.compile(r'MA\.a\[(\d+)\]\s*=\s*\{([^}]+)\}')
    re_sa  = re.compile(r'MA\.sa\[(\d+)\]\s*=\s*\{([^}]+)\}')

    def parse_props(body: str) -> dict:
        """Parse key:value pairs from an AS object literal body."""
        props = {}
        # n:"some name"
        m = re.search(r'n:"([^"]+)"', body)
        if m:
            props['n'] = m.group(1)
        # sua:0
        m = re.search(r'sua:(\d+)', body)
        if m:
            props['sua'] = int(m.group(1))
        # a:7
        m = re.search(r'\ba:(\d+)', body)
        if m:
            props['a'] = int(m.group(1))
        # m:[116] or m:[1,2,3]  (entries may be "null")
        m = re.search(r'm:\[([^\]]*)\]', body)
        if m:
            raw = m.group(1).strip()
            props['m'] = [int(x) for x in raw.split(',') if x.strip() and x.strip() != 'null'] if raw else []
        # v:[37,38]  (entries may be "null")
        m = re.search(r'v:\[([^\]]*)\]', body)
        if m:
            raw = m.group(1).strip()
            props['v'] = [int(x) for x in raw.split(',') if x.strip() and x.strip() != 'null'] if raw else []
        return props

    # Try strict decoders first (they raise on bad bytes -> safe to test).
    # latin-1 accepts every byte value so it NEVER raises; keep it as the
    # final byte-safe fallback so it cannot shadow a valid UTF-8 file.
    for encoding in ('utf-8-sig', 'utf-8', 'cp1252'):
        try:
            with open(filepath, encoding=encoding) as fh:
                lines = fh.readlines()
            print(f"  [enc] read with {encoding}")
            break
        except UnicodeDecodeError:
            print(f"  [enc] {encoding} failed, trying next...")
    else:
        with open(filepath, encoding='latin-1') as fh:
            lines = fh.readlines()
        print(f"  [enc] read with latin-1 (fallback)")

    for lineno, line in enumerate(lines, 1):
        line = line.strip()
        if not line or line.startswith('//'):
            continue

        m = re_sua.search(line)
        if m:
            sid, name = int(m.group(1)), m.group(2)
            super_areas[sid] = name
            print(f"  [sua] id={sid:>5}  '{name}'")
            continue

        m = re_a.search(line)
        if m:
            aid, body = int(m.group(1)), m.group(2)
            props = parse_props(body)
            areas[aid] = props
            print(f"  [a]   id={aid:>5}  sua={props.get('sua','?')}  '{props.get('n','')}'")
            continue

        m = re_sa.search(line)
        if m:
            said, body = int(m.group(1)), m.group(2)
            props = parse_props(body)
            sub_areas[said] = props
            print(f"  [sa]  id={said:>5}  a={props.get('a','?')}  '{props.get('n','')}'")
            continue

    return super_areas, areas, sub_areas


def merge(dest_sua, dest_a, dest_sa, src_sua, src_a, src_sa, filepath):
    """Merge parsed data into master dicts, warning on conflicts."""
    for k, v in src_sua.items():
        if k in dest_sua and dest_sua[k] != v:
            print(f"  [warn] super-area id={k} redefined in {filepath.name}")
        dest_sua[k] = v

    for k, v in src_a.items():
        if k in dest_a and dest_a[k] != v:
            print(f"  [warn] area id={k} redefined in {filepath.name}")
        dest_a[k] = v

    for k, v in src_sa.items():
        if k in dest_sa and dest_sa[k] != v:
            print(f"  [warn] subarea id={k} redefined in {filepath.name}")
        dest_sa[k] = v


def write_csv(path: Path, headers: list, rows: list):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, 'w', newline='', encoding='utf-8') as fh:
        w = csv.writer(fh)
        w.writerow(headers)
        w.writerows(rows)
    print(f"  [csv] wrote {len(rows)} row(s) → {path}")


def export_csvs(output_folder: str, super_areas: dict, areas: dict, sub_areas: dict):
    out = Path(output_folder)

    # ── Super-areas ───────────────────────────────────────────────────────────
    print("\n[export] Super-areas …")
    sua_rows = sorted(super_areas.items())  # [(id, name), ...]
    write_csv(out / "lang_super_area.csv",
              ["id", "name"],
              sua_rows)
    write_csv(out / "data_super_area.csv",
              ["id", "name"],
              sua_rows)   # same content – extend if more fields arrive later

    # ── Areas ─────────────────────────────────────────────────────────────────
    print("\n[export] Areas …")
    a_lang_rows = sorted(
        [(aid, d.get('n', '')) for aid, d in areas.items()]
    )
    a_data_rows = sorted(
        [(aid, d.get('sua', ''), d.get('n', '')) for aid, d in areas.items()]
    )
    write_csv(out / "lang_area.csv",
              ["id", "name"],
              a_lang_rows)
    write_csv(out / "data_area.csv",
              ["id", "super_area_id", "name"],
              a_data_rows)

    # ── Sub-areas ─────────────────────────────────────────────────────────────
    print("\n[export] Sub-areas …")
    sa_lang_rows = sorted(
        [(said, d.get('n', '')) for said, d in sub_areas.items()]
    )
    sa_data_rows = sorted(
        [
            (
                said,
                d.get('a', ''),
                "|".join(str(x) for x in d.get('m', [])),
                "|".join(str(x) for x in d.get('v', []))
            )
            for said, d in sub_areas.items()
        ]
    )
    write_csv(out / "lang_subarea.csv",
              ["id", "name"],
              sa_lang_rows)
    write_csv(out / "data_subarea.csv",
              ["id", "area_id", "music_track_ids", "neighboring_subarea_ids"],
              sa_data_rows)


def main():
    args = parse_args()
    print(f"[config] input  folder : {args.input_folder}")
    print(f"[config] output folder : {args.output_folder}")

    files = collect_as_files(args.input_folder)
    if not files:
        print("[warn] No .as files found. Exiting.")
        return

    all_sua, all_a, all_sa = {}, {}, {}

    for filepath in files:
        print(f"\n[parse] {filepath}")
        sua, a, sa = parse_file(filepath)
        merge(all_sua, all_a, all_sa, sua, a, sa, filepath)

    print(f"\n[summary] super-areas: {len(all_sua)}  |  areas: {len(all_a)}  |  sub-areas: {len(all_sa)}")

    export_csvs(args.output_folder, all_sua, all_a, all_sa)

    print("\n[done] All CSV files written successfully.")


if __name__ == "__main__":
    main()