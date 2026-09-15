#!/usr/bin/env python3
"""Generate a comparison table from EUSolver and LLM CSV results."""

import argparse
import csv
import io
import json
from pathlib import Path
from statistics import mean
from typing import Dict, List, Tuple


DEFAULT_RESULTS = Path(
    "/EUSolver/benchmarks/cypher/results.out"
)
DEFAULT_FEW_SHOT = Path("/DMINER_Artifact/experiments/results/LLM-comparisons-few-shot.csv")
DEFAULT_COT = Path("/DMINER_Artifact/experiments/results/LLM-comparisons-cot.csv")
DEFAULT_AGENTIC = Path("/DMINER_Artifact/experiments/results/LLM-comparisons-agentic.csv")
DEFAULT_COMPLEXITY = Path("/DMINER_Artifact/experiments/results/complexity.csv")


def is_true(value: object) -> bool:
    """Accept common spreadsheet representations of true."""
    return str(value).strip().lower() in {"true"}


def load_complex_benchmark_ids(path: Path) -> set:
    """Return benchmark IDs meeting any of the complexity thresholds."""
    with path.open(newline="", encoding="utf-8-sig") as source:
        rows = list(csv.DictReader(source))

    required = {"benchmarkID", "Pattern Size", "Predicate Size", "Return Size"}
    missing = required.difference(rows[0] if rows else {})
    if missing:
        raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")

    return {
        int(row["benchmarkID"])
        for row in rows
        if int(row["Pattern Size"]) >= 5
        or int(row["Return Size"]) >= 4
        or int(row["Predicate Size"]) >= 3
    }


def summarize_eusolver(path: Path, complex_ids: set) -> Dict[str, object]:
    records = []
    with path.open(encoding="utf-8") as source:
        for line_number, line in enumerate(source, start=1):
            if not line.strip():
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as exc:
                raise ValueError(f"Invalid JSON on {path}:{line_number}") from exc

    synthesized = [row for row in records if row.get("program") is not None]
    times_ms = [float(row["time"]) * 1000 for row in synthesized]
    task_ids = [int(row["index"]) for row in records]
    total_tasks = max(task_ids) - min(task_ids) + 1 if task_ids else 0
    return {
        "timeouts": total_tasks - len(synthesized),
        "plausible": sum(int(row["index"]) in {16, 37} for row in synthesized),
        "desired": sum(int(row["index"]) not in {16, 37} for row in synthesized),
        "incorrect": "--",
        "avg_ms": round(mean(times_ms)) if times_ms else "--",
        "max_ms": round(max(times_ms)) if times_ms else "--",
        "complex": sum(
            int(row["index"]) not in {16, 37}
            and int(row["index"]) in complex_ids
            for row in synthesized
        ),
    }


def summarize_llm(path: Path, complex_ids: set) -> Dict[str, object]:
    with path.open(newline="", encoding="utf-8-sig") as source:
        rows = list(csv.DictReader(source))

    required = {"correct_or_not", "desired_or_not"}
    missing = required.difference(rows[0] if rows else {})
    if missing:
        raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")

    id_columns = [
        column
        for column in (rows[0] if rows else {})
        if column.lower() in {"taskid", "benchmark_id", "benchmarkid"}
    ]
    if not id_columns:
        raise ValueError(f"{path} is missing a task/benchmark ID column")
    id_column = id_columns[0]

    desired = sum(is_true(row["desired_or_not"]) for row in rows)
    plausible = sum(
        is_true(row["correct_or_not"]) and not is_true(row["desired_or_not"])
        for row in rows
    )
    incorrect = sum(not is_true(row["correct_or_not"]) for row in rows)
    if desired + plausible + incorrect != len(rows):
        raise ValueError(f"Classification counts do not reconcile for {path}")

    return {
        "timeouts": "--",
        "plausible": plausible,
        "desired": desired,
        "incorrect": incorrect,
        "avg_ms": "--",
        "max_ms": "--",
        "complex": sum(
            is_true(row["desired_or_not"])
            and int(row[id_column]) in complex_ids
            for row in rows
        ),
    }


def make_csv(rows: List[Tuple[str, Dict[str, object]]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.writer(output)
    writer.writerow(
        [
            "Baseline",
            "#T",
            "#P",
            "#D",
            "#I",
            "Time avg (ms)",
            "Time max (ms)",
            "#c",
        ]
    )
    for name, stats in rows:
        writer.writerow(
            [
                name,
                stats["timeouts"],
                stats["plausible"],
                stats["desired"],
                stats["incorrect"],
                stats["avg_ms"],
                stats["max_ms"],
                stats["complex"],
            ]
        )
    return output.getvalue()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results", type=Path, default=DEFAULT_RESULTS)
    parser.add_argument("--few-shot", type=Path, default=DEFAULT_FEW_SHOT)
    parser.add_argument("--cot", type=Path, default=DEFAULT_COT)
    parser.add_argument("--agentic", type=Path, default=DEFAULT_AGENTIC)
    parser.add_argument("--complexity", type=Path, default=DEFAULT_COMPLEXITY)
    parser.add_argument(
        "--format",
        choices=("csv", "latex"),
        help="Output format; defaults to the --output extension, or CSV.",
    )
    parser.add_argument(
        "--output", default= "/DMINER_Artifact/experiments/results/tables_and_figures/Table2.csv", type=Path, help="Write the table here instead of standard output."
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    complex_ids = load_complex_benchmark_ids(args.complexity)
    rows = [
        ("Enumerative Search", summarize_eusolver(args.results, complex_ids)),
        ("Few-shot learning (GPT-5.4)", summarize_llm(args.few_shot, complex_ids)),
        ("Chain-of-thought (GPT-5.4)", summarize_llm(args.cot, complex_ids)),
        ("Agentic loop (Claude Code + Opus 4.7)", summarize_llm(args.agentic, complex_ids)),
    ]
    output_format = args.format
    if output_format is None:
        output_format = "latex" if args.output and args.output.suffix == ".tex" else "csv"
    table = make_csv(rows) if output_format == "csv" else make_latex(rows) + "\n"
    if args.output:
        args.output.write_text(table, encoding="utf-8")
    else:
        print(table, end="")


if __name__ == "__main__":
    main()
