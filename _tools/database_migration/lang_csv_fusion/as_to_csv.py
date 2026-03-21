import re
import csv
import sys
from pathlib import Path


def parse_as_file(input_path: str, output_path: str):
    """
    Parses an ActionScript .as file and extracts entries of the form:
        N.d[632] = {a:[3],n:"Le Grandapan"};
    Into a CSV with columns: id, actions, name
    """
    pattern = re.compile(
        r'N\.d\[(\d+)\]\s*=\s*\{a:\[([^\]]*)\],\s*n:"([^"]+)"\}'
    )

    rows = []

    with open(input_path, "r", encoding="utf-8") as f:
        for line in f:
            match = pattern.search(line)
            if match:
                entry_id = match.group(1)
                # Actions can be a comma-separated list like [3,5] — join as string
                actions_raw = match.group(2).strip()
                actions = actions_raw if actions_raw else ""
                name = match.group(3)
                rows.append({"id": entry_id, "actions": actions, "name": name})

    if not rows:
        print("⚠️  No matching entries found. Please check the format of your .as file.")
        return

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["id", "actions", "name"])
        writer.writeheader()
        writer.writerows(rows)

    print(f"✅ Done! {len(rows)} entries written to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python as_to_csv.py <input.as> [output.csv]")
        print("Example: python as_to_csv.py script.as output.csv")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else Path(input_file).stem + ".csv"

    if not Path(input_file).exists():
        print(f"❌ File not found: {input_file}")
        sys.exit(1)

    parse_as_file(input_file, output_file)
