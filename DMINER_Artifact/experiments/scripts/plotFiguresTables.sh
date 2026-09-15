#!/usr/bin/env bash
cd /DMINER_Artifact/experiments/scripts
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv local 3.6.15
pip install -r requirements.txt

python json_to_csv.py --json_file=/DMINER_Artifact/experiments/results/mainResults.json
python json_to_csv.py --json_file=/DMINER_Artifact/experiments/results/resultsDeductiveReasoning.json
python json_to_csv.py --json_file=/DMINER_Artifact/experiments/results/resultsCandidatePruning.json
python json_to_csv.py --json_file=/DMINER_Artifact/experiments/results/resultsAllAblation.json
python stats.py
python boxPlot.py
python ablationStudy.py
python ablationStudy-perBenchmark.py
python baselines.py
