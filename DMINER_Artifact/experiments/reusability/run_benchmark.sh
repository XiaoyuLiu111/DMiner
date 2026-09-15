#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <benchmarkID>" >&2
  exit 2
fi

benchmark_id=$1
if [[ ! $benchmark_id =~ ^[0-9]+$ ]]; then
  echo "Error: benchmarkID must be a non-negative integer." >&2
  exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv local 3.6.15
python -m pip install "neo4j==4.3.7"

next_benchmark_id=$((benchmark_id + 1))
DMINER_ROOT="${DMINER_ARTIFACT_ROOT:-/DMINER_Artifact/experiments}"
Z3_DIR="$DMINER_ROOT/lib/z3-4.13.0-x64-glibc-2.31/bin"
CLASSPATH="target/classes:target/dependency/*:$Z3_DIR/com.microsoft.z3.jar"

# This command must finish successfully before synthesis starts.
python "$script_dir/newData.py" --benchmarkID "$benchmark_id"
cd "$DMINER_ROOT"
LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
        java -Djava.library.path="$Z3_DIR" \
          -cp "$CLASSPATH" \
          synth.Main none 10 \
            "$benchmark_id" "$((benchmark_id + 1))" --newBenchmark

cd "$script_dir"
pyenv local 3.6.15
python "$script_dir/validate.py" --benchmarkID "$benchmark_id"

