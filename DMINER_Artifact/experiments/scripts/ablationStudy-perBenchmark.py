import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import pandas as pd
import warnings
warnings.filterwarnings('ignore')

candidate_pruning_df = pd.read_csv('/DMINER_Artifact/experiments/results/resultsCandidatePruning.csv')
analyze_df = pd.read_csv('/DMINER_Artifact/experiments/results/resultsDeductiveReasoning.csv')
all_df = pd.read_csv('/DMINER_Artifact/experiments/results/resultsAllAblation.csv')
results_36_df = pd.read_csv('/DMINER_Artifact/experiments/results/mainResults.csv')

benchmark_df = pd.merge(results_36_df[['benchmarkID', 'Total Time']], candidate_pruning_df[['benchmarkID', 'Total Time']], on='benchmarkID', suffixes=('', '_cp'))
benchmark_df = pd.merge(benchmark_df, analyze_df[['benchmarkID', 'Total Time']], on='benchmarkID', suffixes=('', '_ana'))
benchmark_df = pd.merge(benchmark_df, all_df[['benchmarkID', 'Total Time']], on='benchmarkID', suffixes=('', '_all'))

benchmark_df.columns = ['benchmarkID', 'DMiner', 'DMiner w/o necessary conditions', 'DMiner w/o deductive reasoning', 'DMiner w/o all']

plot_df = benchmark_df[~benchmark_df['benchmarkID'].isin([82, 83, 84])].copy()
for col in ['DMiner', 'DMiner w/o necessary conditions', 'DMiner w/o deductive reasoning', 'DMiner w/o all']:
    plot_df[col] = plot_df[col] / 1000.0

time_cols = [
    'DMiner',
    'DMiner w/o necessary conditions',
    'DMiner w/o deductive reasoning',
    'DMiner w/o all'
]

plot_df["benchmarkID"] -= 1
labels = plot_df["benchmarkID"].to_numpy()
mid_point = 45
df1 = plot_df[plot_df['benchmarkID'] <= mid_point]
df2 = plot_df[plot_df['benchmarkID'] > mid_point]

def draw_continuous_bars(df, includeLegend):
    fig, ax = plt.subplots(figsize=(30, 7))
    x = df['benchmarkID']
    width = 0.2

    # Use high contrast colors and distinct hatch patterns
    ax.bar(x - 1.5*width, df['DMiner'], width=width, label='DMiner', color='#2c3e50', hatch='...')
    ax.bar(x - 0.5*width, df['DMiner w/o necessary conditions'], width=width, label='DMiner w/o necessary conditions', color='#d35400', hatch='///')
    ax.bar(x + 0.5*width, df['DMiner w/o deductive reasoning'], width=width, label='DMiner w/o deductive reasoning', color='#2980b9', hatch='\\')
    ax.bar(x + 1.5*width, df['DMiner w/o all'], width=width, label='DMiner w/o all', color='#27ae60', hatch='xxx')

    ax.set_yscale('symlog', linthresh=30)
    ticks = [0, 5, 10, 15, 20, 25, 30, 100, 200, 300, 400, 500, 600]
    ax.set_yticks(ticks)
    ax.get_yaxis().set_major_formatter(plt.ScalarFormatter())

    ax.set_ylabel('Time (s)', fontsize=24, fontweight='bold')
    ax.set_xlabel('Benchmark ID', fontsize=24, fontweight='bold')

    # Tighten x-axis limits
    ax.set_xlim(x.min() - 0.6, x.max() + 0.6)
    ax.set_xticks(np.arange(x.min(), x.max() + 1, 1))

    ax.tick_params(axis='both', labelsize=12)
    if includeLegend:
        ax.legend(loc='upper left', prop={'size': 18, 'weight': 'bold'}, frameon=True)
    ax.grid(True, axis='y', linestyle='--', alpha=0.3)

    plt.margins(x=0)
    plt.show()
    return fig

fig1 = draw_continuous_bars(df1, True)
fig2 = draw_continuous_bars(df2, False)

with PdfPages("/DMINER_Artifact/experiments/results/tables_and_figures/Figure16.pdf") as pdf:
    pdf.savefig(fig1, bbox_inches='tight')
    pdf.savefig(fig2, bbox_inches='tight')
