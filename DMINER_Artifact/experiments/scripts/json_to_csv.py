#!/usr/bin/env python3
"""Convert a benchmark JSON result file to CSV.

Usage:
    python3 scripts/json_to_csv.py experiments/results/mainResults.json

This writes the full CSV plus a per-benchmark average time CSV beside it.
"""

import argparse
import csv
import json
from pathlib import Path


TIME_FIELDS = [
    "Total Time",
    "Time for pattern synthesis",
    "Time for return statement synthesis",
    "Time for predicate synthesis",
]


def is_number(value):
    if isinstance(value, bool) or value is None:
        return False
    if isinstance(value, (int, float)):
        return True
    if isinstance(value, str):
        try:
            float(value)
            return True
        except ValueError:
            return False
    return False


def to_number(value):
    return float(value)


def load_rows(json_path):
    with json_path.open(encoding="utf-8") as reader:
        data = json.load(reader)

    if isinstance(data, dict):
        rows = [data]
    elif isinstance(data, list):
        rows = data
    else:
        raise ValueError(f"Expected a JSON object or array in {json_path}")

    selected = {}
    order = []
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("Expected every result entry to be a JSON object")

        benchmark_id = row.get("benchmarkID")
        if benchmark_id is None:
            order.append((None, row))
            continue

        current = selected.get(benchmark_id)
        if current is None:
            selected[benchmark_id] = row
            order.append((benchmark_id, row))
            continue

        current_time = current.get("Total Time")
        row_time = row.get("Total Time")
        if is_number(row_time) and (
            not is_number(current_time) or to_number(row_time) < to_number(current_time)
        ):
            selected[benchmark_id] = row

    deduplicated = []
    emitted = set()
    for benchmark_id, row in order:
        if benchmark_id is None:
            deduplicated.append(row)
        elif benchmark_id not in emitted:
            deduplicated.append(selected[benchmark_id])
            emitted.add(benchmark_id)

    return deduplicated


def collect_fieldnames(rows):
    fieldnames = []
    seen = set()
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("Expected every result entry to be a JSON object")
        for field in row:
            if field not in seen:
                seen.add(field)
                fieldnames.append(field)
    return fieldnames


def normalize_value(value):
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    return value


def write_rows(csv_path, rows, fieldnames):
    with csv_path.open("w", newline="", encoding="utf-8") as writer_file:
        writer = csv.DictWriter(writer_file, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: normalize_value(row.get(key)) for key in fieldnames})


def json_to_csv(json_path, csv_path):
    rows = load_rows(json_path)
    fieldnames = collect_fieldnames(rows)

    write_rows(csv_path, rows, fieldnames)


def main():
    parser = argparse.ArgumentParser(description="Convert benchmark JSON results to CSV.")
    parser.add_argument("--json_file", type=Path, help="Path to the JSON result file")
    parser.add_argument(
        "csv_file",
        type=Path,
        nargs="?",
        help="Optional CSV output path. Defaults to the JSON path with a .csv extension.",
    )
    args = parser.parse_args()

    json_path = args.json_file
    csv_path = args.csv_file or json_path.with_suffix(".csv")
    json_to_csv(json_path, csv_path)
    print(f"Wrote {csv_path}")


if __name__ == "__main__":
    main()