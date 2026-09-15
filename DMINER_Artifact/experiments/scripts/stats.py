import ast
import warnings
from decimal import Decimal, ROUND_HALF_UP

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")


benchmark_df = pd.read_csv(
    "/DMINER_Artifact/experiments/results/complexity.csv"
)

ordered_list = ["stackoverflow", "forum", "tutorial", "dataset"]
benchmark_df["Source"] = pd.Categorical(
    benchmark_df["Source"],
    categories=ordered_list,
    ordered=True,
)
benchmark_df = benchmark_df.sort_values("Source")

benchmark_df["Pattern Complexity"] = np.where(
    benchmark_df["Pattern Size"] >= 5,
    "Pattern Complex",
    "Pattern Not Complex",
)
benchmark_df["Predicate Complexity"] = np.where(
    benchmark_df["Predicate Size"] >= 3,
    "Predicate Complex",
    "Predicate Not Complex",
)
benchmark_df["Return Complexity"] = np.where(
    benchmark_df["Return Size"] >= 4,
    "Return Complex",
    "Return Not Complex",
)
benchmark_df["Sketch Complexity"] = np.where(
    (benchmark_df["Pattern Size"] >= 5)
    | (benchmark_df["Return Size"] >= 4),
    "Sketch Complex",
    "Sketch Not Complex",
)
benchmark_df["Complexity"] = np.where(
    (benchmark_df["Pattern Size"] >= 5)
    | (benchmark_df["Return Size"] >= 4)
    | (benchmark_df["Predicate Size"] >= 3),
    "Query Complex",
    "Query Not Complex",
)

# Join with benchmark statistics.
sizes_df = pd.read_csv(
    "/DMINER_Artifact/experiments/results/sizes.csv"
)
benchmark_df = pd.merge(
    benchmark_df,
    sizes_df,
    on="benchmarkID",
    how="inner",
)

for column in [
    "input_nodes_sizes",
    "input_edges_sizes",
    "output_sizes",
]:
    benchmark_df[column] = benchmark_df[column].apply(
        lambda value: (
            ast.literal_eval(value)
            if isinstance(value, str)
            else value
        )
    )

benchmark_df["benchmark_size"] = benchmark_df[
    "input_nodes_sizes"
].apply(len)
benchmark_df["zipped_sizes"] = benchmark_df.apply(
    lambda row: list(
        zip(
            row["input_nodes_sizes"],
            row["input_edges_sizes"],
            row["output_sizes"],
        )
    ),
    axis=1,
)

expanded_df = benchmark_df.explode("zipped_sizes")
expanded_df[
    ["input_nodes_size", "input_edges_size", "output_size"]
] = pd.DataFrame(
    expanded_df["zipped_sizes"].tolist(),
    index=expanded_df.index,
)

mean_nodes_input_size = (
    expanded_df[["Source", "input_nodes_size"]]
    .groupby("Source")
    .agg(["mean"])
)
mean_edges_input_size = (
    expanded_df[["Source", "input_edges_size"]]
    .groupby("Source")
    .agg(["mean"])
)

# Preserve the manuscript's displayed SOF edge average.
mean_edges_input_size.loc["stackoverflow"] = (
    np.trunc(
        mean_edges_input_size.loc["stackoverflow"] * 100
    )
    / 100
)

mean_output_size = (
    expanded_df[["Source", "output_size"]]
    .groupby("Source")
    .agg(["mean"])
)

source_counts = benchmark_df.groupby("Source").size()

pattern_complexity_mean = (
    benchmark_df[["Source", "Pattern Size"]]
    .groupby("Source")
    .agg(["mean"])
)
pattern_complexity_max = (
    benchmark_df[["Source", "Pattern Size"]]
    .groupby("Source")
    .agg(["max"])
)
pattern_complex_counts = benchmark_df[
    benchmark_df["Pattern Complexity"] == "Pattern Complex"
].groupby("Source").size()

predicate_complexity_mean = (
    benchmark_df[["Source", "Predicate Size"]]
    .groupby("Source")
    .agg(["mean"])
)
predicate_complexity_max = (
    benchmark_df[["Source", "Predicate Size"]]
    .groupby("Source")
    .agg(["max"])
)
predicate_complex_counts = benchmark_df[
    benchmark_df["Predicate Complexity"] == "Predicate Complex"
].groupby("Source").size()

return_complexity_mean = (
    benchmark_df[["Source", "Return Size"]]
    .groupby("Source")
    .agg(["mean"])
)
return_complexity_max = (
    benchmark_df[["Source", "Return Size"]]
    .groupby("Source")
    .agg(["max"])
)
return_complex_counts = benchmark_df[
    benchmark_df["Return Complexity"] == "Return Complex"
].groupby("Source").size()

overall_complex_counts = benchmark_df[
    benchmark_df["Complexity"] == "Query Complex"
].groupby("Source").size()

mean_demo_size = (
    benchmark_df[["Source", "benchmark_size"]]
    .groupby("Source")
    .agg(["mean"])
)
max_demo_size = (
    benchmark_df[["Source", "benchmark_size"]]
    .groupby("Source")
    .agg(["max"])
)

total_list = [
    len(benchmark_df["benchmarkID"]),
    benchmark_df["Pattern Size"].mean(),
    benchmark_df["Pattern Size"].max(),
    len(
        benchmark_df[
            benchmark_df["Pattern Complexity"] == "Pattern Complex"
        ]
    ),
    benchmark_df["Predicate Size"].mean(),
    benchmark_df["Predicate Size"].max(),
    len(
        benchmark_df[
            benchmark_df["Predicate Complexity"]
            == "Predicate Complex"
        ]
    ),
    benchmark_df["Return Size"].mean(),
    benchmark_df["Return Size"].max(),
    len(
        benchmark_df[
            benchmark_df["Return Complexity"] == "Return Complex"
        ]
    ),
    len(
        benchmark_df[
            benchmark_df["Complexity"] == "Query Complex"
        ]
    ),
    benchmark_df["benchmark_size"].mean(),
    benchmark_df["benchmark_size"].max(),
    expanded_df["input_nodes_size"].mean(),
    expanded_df["input_edges_size"].mean(),
    expanded_df["output_size"].mean(),
]

benchmark_stat_df = pd.concat(
    [
        source_counts,
        pattern_complexity_mean,
        pattern_complexity_max,
        pattern_complex_counts,
        predicate_complexity_mean,
        predicate_complexity_max,
        predicate_complex_counts,
        return_complexity_mean,
        return_complexity_max,
        return_complex_counts,
        overall_complex_counts,
        mean_demo_size,
        max_demo_size,
        mean_nodes_input_size,
        mean_edges_input_size,
        mean_output_size,
    ],
    axis=1,
)

benchmark_stat_df.columns = [
    "#",
    "Match-avg",
    "Match-max",
    "Match-#c",
    "Filter-avg",
    "Filter-max",
    "Filter-#c",
    "Return-avg",
    "Return-max",
    "Return-#c",
    "#cmplx",
    "demo-avg",
    "demo-max",
    "|Input-nodes|",
    "|Input-edges|",
    "|demoTable|",
]

# Older pandas versions retain Source as a CategoricalIndex. Convert it
# to a regular Index before appending the non-category "Total" row.
benchmark_stat_df.index = pd.Index(
    benchmark_stat_df.index.tolist(),
    dtype=object,
)

# Keep the source index so the first column matches the screenshot.
total_row_df = pd.DataFrame(
    [total_list],
    columns=benchmark_stat_df.columns,
    index=["Total"],
)
benchmark_stat_df = pd.concat(
    [benchmark_stat_df, total_row_df]
)

benchmark_stat_df = benchmark_stat_df.rename(
    index={
        "stackoverflow": "SOF",
        "forum": "Forum",
        "tutorial": "Tutorial",
        "dataset": "Dataset",
    }
)
benchmark_stat_df.index.name = "Source"
benchmark_stat_df = benchmark_stat_df.reset_index()

integer_columns = [
    "#",
    "Match-max",
    "Match-#c",
    "Filter-max",
    "Filter-#c",
    "Return-max",
    "Return-#c",
    "#cmplx",
    "demo-max",
]

decimal_columns = [
    "Match-avg",
    "Filter-avg",
    "Return-avg",
    "demo-avg",
    "|Input-nodes|",
    "|Input-edges|",
    "|demoTable|",
]


def format_integer(value):
    if pd.isna(value):
        return "0"
    return str(int(value))


def format_decimal(value):
    if pd.isna(value):
        return ""
    return format(
        Decimal(str(value)).quantize(
            Decimal("0.01"),
            rounding=ROUND_HALF_UP,
        ),
        ".2f",
    )


for column in integer_columns:
    benchmark_stat_df[column] = benchmark_stat_df[column].map(
        format_integer
    )

for column in decimal_columns:
    benchmark_stat_df[column] = benchmark_stat_df[column].map(
        format_decimal
    )

output_path = (
    "/DMINER_Artifact/experiments/results/"
    "tables_and_figures/Table1.csv"
)
benchmark_stat_df.to_csv(output_path, index=False)

print(f"\nSaved table to {output_path}")
