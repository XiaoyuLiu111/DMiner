import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import json
import warnings
warnings.filterwarnings('ignore')

benchmark_df = pd.read_csv("/DMINER_Artifact/experiments/results/mainResults.csv")
complexity_df=pd.read_csv("/DMINER_Artifact/experiments/results/complexity.csv")
benchmark_df = pd.merge(benchmark_df, complexity_df, on='benchmarkID', how='inner')
print(f"Rows: {benchmark_df.shape[0]}, Columns: {benchmark_df.shape[1]}")
benchmark_df["Pattern Complexity"] = np.where(benchmark_df['Pattern Size'] >= 5, "Pattern Complex","Pattern Not Complex")
benchmark_df["Filter Complexity"] = np.where(benchmark_df['Predicate Size'] >= 3, "Filter Complex","Filter Not Complex")
benchmark_df["Return Complexity"] = np.where(benchmark_df['Return Size'] >= 4, "Return Complex","Return Not Complex")
benchmark_df["Sketch Complexity"] = np.where((benchmark_df['Pattern Size'] >= 5) | (benchmark_df['Return Size'] >= 4), "Sketch Complex","Sketch Not Complex")
benchmark_df["Query Complexity"] = np.where((benchmark_df['Pattern Size'] >= 5) | (benchmark_df['Return Size'] >= 4) | (benchmark_df['Predicate Size'] >= 3), "Query Complex","Query Not Complex")

# Excluding benchmarks not producing desired results
benchmark_df = benchmark_df[~benchmark_df["benchmarkID"].isin([82, 83, 84])]

fig, axes = plt.subplots(1, 3, figsize=(10, 4))
y_range = (0, 5)
logged_benchmark_df = benchmark_df.copy()
logged_benchmark_df['Total Time'] = np.log10(logged_benchmark_df['Total Time'])
logged_benchmark_df['Time for pattern synthesis'] = np.log10(logged_benchmark_df['Time for pattern synthesis'])
logged_benchmark_df['Time for predicate synthesis'] = np.log10(logged_benchmark_df[logged_benchmark_df["Time for predicate synthesis"]>0]['Time for predicate synthesis'])

sns.boxplot(
    x='Pattern Complexity', y='Time for pattern synthesis',
    data=logged_benchmark_df,
    palette='pastel',
    linewidth=1.2,
    width=0.6,
    ax=axes[1]
)

axes[1].set_xlabel('Pattern Complexity', fontsize=12, weight='bold')
axes[1].set_ylabel('log10(Pattern Synthesis Time) (ms)', fontsize=12, weight='bold')
axes[1].grid(axis='y', linestyle='--', linewidth=0.7, alpha=0.6)
axes[1].set_ylim(y_range)

sns.boxplot(
    x='Filter Complexity', y='Time for predicate synthesis',
    data=logged_benchmark_df,
    palette='pastel',
    linewidth=1.2,
    width=0.6,
    ax=axes[2]
)

axes[2].set_xlabel('Filter Complexity', fontsize=12, weight='bold')
axes[2].set_ylabel('log10(Filter Synthesis Time) (ms)', fontsize=12, weight='bold')
axes[2].grid(axis='y', linestyle='--', linewidth=0.7, alpha=0.6)
axes[2].set_ylim(y_range)


sns.boxplot(
    x='Query Complexity', y='Total Time',
    data=logged_benchmark_df,
    palette='pastel',
    linewidth=1.2,
    width=0.6,
    ax=axes[0]
)

axes[0].set_xlabel('Query Complexity', fontsize=12, weight='bold')
axes[0].set_ylabel('log10(Synthesis Time) (ms)', fontsize=12, weight='bold')
axes[0].grid(axis='y', linestyle='--', linewidth=0.7, alpha=0.6)
axes[0].set_ylim(y_range)

plt.tight_layout()
plt.show()
fig.savefig("/DMINER_Artifact/experiments/results/tables_and_figures/Figure14.pdf", format='pdf')