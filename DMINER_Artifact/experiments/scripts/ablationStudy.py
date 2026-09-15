import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import json
import warnings
warnings.filterwarnings('ignore')
import pandas as pd
candidate_pruning_df = pd.read_csv("/DMINER_Artifact/experiments/results/resultsCandidatePruning.csv")
candidate_pruning_df.rename(columns={"Total Time": "Total time candidate pruning ablation"}, inplace=True)
analyze_df = pd.read_csv("/DMINER_Artifact/experiments/results/resultsDeductiveReasoning.csv")
analyze_df.rename(columns={"Total Time": "Total time analyze ablation"}, inplace=True)
all_df = pd.read_csv("/DMINER_Artifact/experiments/results/resultsAllAblation.csv")
all_df.rename(columns={"Total Time": "Total time all ablation"}, inplace=True)
results_df = pd.read_csv("/DMINER_Artifact/experiments/results/mainResults.csv")

benchmark_df = pd.merge(results_df[['benchmarkID', 'Total Time']],
                        candidate_pruning_df[['benchmarkID', 'Total time candidate pruning ablation']],
                        on='benchmarkID',
                        how='inner')
benchmark_df = pd.merge(benchmark_df[['benchmarkID', 'Total Time', 'Total time candidate pruning ablation']],
                        analyze_df[['benchmarkID', 'Total time analyze ablation']],
                        on='benchmarkID',
                        how='inner')
benchmark_df = pd.merge(benchmark_df[['benchmarkID', 'Total Time', 'Total time candidate pruning ablation', "Total time analyze ablation"]],
                        all_df[['benchmarkID', 'Total time all ablation']],
                        on='benchmarkID',
                        how='inner')
benchmark_df = benchmark_df[~benchmark_df["benchmarkID"].isin([82, 83, 84])]

noAblation = np.log10(benchmark_df["Total Time"][benchmark_df["Total Time"]!=600000])
dataAblation = np.log10(benchmark_df["Total time candidate pruning ablation"][benchmark_df["Total time candidate pruning ablation"]!=600000])
analyzeConflict = np.log10(benchmark_df["Total time analyze ablation"][benchmark_df["Total time analyze ablation"]!=600000])
all = np.log10(benchmark_df["Total time all ablation"][benchmark_df["Total time all ablation"]!=600000])

noAblationS = np.sort(noAblation)
dataAblationS = np.sort(dataAblation)
analyzeConflictS = np.sort(analyzeConflict)
allS = np.sort(all)

fig, ax = plt.subplots(figsize=(30, 8))

ax.plot(np.arange(1, len(noAblationS) + 1), noAblationS, linestyle='-', marker='D', markersize=5, label="DMiner", color='black')
ax.plot(np.arange(1, len(dataAblationS) + 1), dataAblationS, linestyle='-', markersize=5, marker='v', label="DMiner w/o necessary conditions", color='red')
ax.plot(np.arange(1, len(analyzeConflictS) + 1), analyzeConflictS, linestyle='-', marker='s', markersize=5, label="DMiner w/o deductive reasoning", color='blue')
ax.plot(np.arange(1, len(allS) + 1), allS, linestyle='-', marker='*', markersize=5, label="DMiner w/o all", color='purple')

ax.set_ylim(0, 6)
ax.set_xlim(0, 95)

ax.set_xlabel("Benchmarks Solved", fontsize=35, fontweight='bold')
ax.set_ylabel("log10(Time) (ms)", fontsize=32, fontweight='bold')

ax.spines['left'].set_position('zero')
ax.spines['bottom'].set_position('zero')
ax.spines['right'].set_color('none')
ax.spines['top'].set_color('none')

ax.xaxis.set_ticks_position('bottom')
ax.set_xticks(np.arange(0, 95, 5))
ax.yaxis.set_ticks_position('left')
ax.tick_params(axis='both', labelsize=24)

ax.legend(loc='upper left',                  # position
          prop={'weight': 'bold','size': 30})
ax.grid(True)

plt.show()
fig.savefig("/DMINER_Artifact/experiments/results/tables_and_figures/Figure15.pdf", format='pdf')
