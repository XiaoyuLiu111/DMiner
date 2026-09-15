#!/usr/bin/env bash
set -euo pipefail

DMINER_ROOT="${DMINER_ARTIFACT_ROOT:-/DMINER_Artifact/experiments}"
Z3_DIR="$DMINER_ROOT/lib/z3-4.13.0-x64-glibc-2.31/bin"
CLASSPATH="target/classes:target/dependency/*:$Z3_DIR/com.microsoft.z3.jar"

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <candidatePruning|all> <timeoutMinutes>" >&2
  exit 2
fi

study="$1"
timeout_minutes="$2"

if [[ "$study" != "candidatePruning" && "$study" != "all" ]]; then
  echo "Study must be either 'candidatePruning' or 'all'." >&2
  exit 2
fi

if [[ ! "$timeout_minutes" =~ ^[1-9][0-9]*$ ]]; then
  echo "timeoutMinutes must be a positive integer." >&2
  exit 2
fi

script_checkout_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${DMINER_ARTIFACT_ROOT:-}" ]]; then
  project_root="$DMINER_ARTIFACT_ROOT"
elif [[ -d /DMINER_Artifact ]]; then
  # Docker mounts /scripts and /DMINER_Artifact separately.
  project_root=/DMINER_Artifact/experiments
else
  project_root="$script_checkout_root"
fi

benchmarks=(5 7 44 65 66 68 69 70 72 75 79)

cd "$project_root"
if [[ ! -f target/classes/synth/Main.class ]]; then
  echo "Cannot find $project_root/target/classes/synth/Main.class." >&2
  echo "Build the project first with: cd $project_root && mvn compile" >&2
  exit 1
fi

for benchmark_id in "${benchmarks[@]}"; do
  echo "=== Running sequential benchmark $benchmark_id for $study ==="
  LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    java -Djava.library.path="$Z3_DIR" \
      -cp "$CLASSPATH" \
      synth.Main "$study" "$timeout_minutes" "$benchmark_id" "$((benchmark_id + 1))"
done
