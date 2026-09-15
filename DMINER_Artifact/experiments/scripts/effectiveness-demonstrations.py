#!/usr/bin/env python3
"""Summarize the four user-study result CSVs into a comparison table."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


DEFAULT_NL = Path("/DMINER_Artifact/experiments/results/LLM-comparisons - userStudy-NL.csv")
DEFAULT_GRAPHS_NL = Path(
    "/DMINER_Artifact/experiments/results/LLM-comparisons - userStudy-inputGraphs+NL.csv"
)
DEFAULT_DEMOS_NL = Path(
    "/DMINER_Artifact/experiments/results/LLM-comparisons - userStudy-demos+NL.csv"
)
DEFAULT_DEMOS = Path(
    "/DMINER_Artifact/experiments/results/LLM-comparisons - userStudy-demos.csv"
)


def is_true(value: object) -> bool:
    return str(value).strip().lower() in {"true"}


def summarize(path: Path) -> tuple[int, int, int, int]:
    with path.open(newline="", encoding="utf-8-sig") as source:
        rows = list(csv.DictReader(source))

    required = {"correct_or_not", "desired_or_not"}
    missing = required.difference(rows[0] if rows else {})
    if missing:
        raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")

    contradictory = [
        index
        for index, row in enumerate(rows, start=2)
        if is_true(row["desired_or_not"]) and not is_true(row["correct_or_not"])
    ]
    if contradictory:
        raise ValueError(
            f"{path} marks an incorrect result as desired on CSV row(s): "
            + ", ".join(map(str, contradictory))
        )

    desired = sum(is_true(row["desired_or_not"]) for row in rows)
    plausible = sum(
        is_true(row["correct_or_not"]) and not is_true(row["desired_or_not"])
        for row in rows
    )
    incorrect = sum(not is_true(row["correct_or_not"]) for row in rows)

    if desired + incorrect + plausible != len(rows):
        raise ValueError(f"Classification counts do not reconcile for {path}")
    return len(rows), desired, incorrect, plausible


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--nl", type=Path, default=DEFAULT_NL)
    parser.add_argument("--input-graphs-nl", type=Path, default=DEFAULT_GRAPHS_NL)
    parser.add_argument("--demos-nl", type=Path, default=DEFAULT_DEMOS_NL)
    parser.add_argument("--demos", type=Path, default=DEFAULT_DEMOS)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("/DMINER_Artifact/experiments/results/tables_and_figures/Table3.csv"),
        help="Destination CSV path (default: Table3.csv).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    settings = [
        ("With only user provided demonstrations", args.demos),
        ("With user provided demonstrations + NL description of tasks", args.demos_nl),
        ("With user provided input graphs + NL description of tasks", args.input_graphs_nl),
        ("With only NL description of tasks", args.nl),
    ]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.writer(destination)
        writer.writerow(["Setting", "Tasks", "Desired", "Incorrect", "Plausible"])
        for setting, path in settings:
            writer.writerow([setting, *summarize(path)])

    print(args.output)


if __name__ == "__main__":
    main()
