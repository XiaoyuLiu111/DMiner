#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR: ${BASH_SOURCE[0]} failed at line $LINENO." >&2' ERR

DMINER_ROOT="${DMINER_ARTIFACT_ROOT:-/DMINER_Artifact/experiments}"
TIMEOUT_MINUTES="${1:-10}"
STUDIES_ARG="${2:-candidatePruning,deductiveReasoning,all,none}"
START_BENCHMARK_ID="${3:-}"
END_BENCHMARK_ID="${4:-}"
Z3_DIR="$DMINER_ROOT/lib/z3-4.13.0-x64-glibc-2.31/bin"
CLASSPATH="target/classes:target/dependency/*:$Z3_DIR/com.microsoft.z3.jar"
SKIPPED_SCRIPT="$DMINER_ROOT/scripts/run-skipped-benchmarks.sh"

usage() {
  echo "Usage: $0 [timeout-limit] [studies] [start-benchmarkID] [endBenchmarkID]" >&2
  echo "  studies: comma-separated subset of none,deductiveReasoning,candidatePruning,all" >&2
}

if [[ $# -gt 4 ]]; then
  usage
  exit 2
fi

if [[ ! "$TIMEOUT_MINUTES" =~ ^[1-9][0-9]*$ ]]; then
  echo "timeout-limit must be a positive integer." >&2
  usage
  exit 2
fi

if [[ -n "$START_BENCHMARK_ID" || -n "$END_BENCHMARK_ID" ]]; then
  if [[ ! "$START_BENCHMARK_ID" =~ ^[0-9]+$ || ! "$END_BENCHMARK_ID" =~ ^[0-9]+$ ]]; then
    echo "start-benchmarkID and endBenchmarkID must both be non-negative integers." >&2
    usage
    exit 2
  fi
  if (( START_BENCHMARK_ID >= END_BENCHMARK_ID )); then
    echo "start-benchmarkID must be less than endBenchmarkID (the end is exclusive)." >&2
    exit 2
  fi
fi

IFS=',' read -r -a STUDIES <<< "$STUDIES_ARG"
if [[ ${#STUDIES[@]} -eq 0 ]]; then
  echo "studies must not be empty." >&2
  usage
  exit 2
fi

for study in "${STUDIES[@]}"; do
  case "$study" in
    none|deductiveReasoning|candidatePruning|all) ;;
    *)
      echo "Unknown study: $study" >&2
      usage
      exit 2
      ;;
  esac
done

require_file() {
  [[ -f "$1" ]] || { echo "Required file not found: $1" >&2; exit 1; }
}

run_step() {
  local description="$1"
  shift
  echo "=== START: $description ==="
  "$@"
  echo "=== COMPLETE: $description ==="
}

run_study() {
  local study="$1"
  cd "$DMINER_ROOT"

  if [[ -n "$START_BENCHMARK_ID" && "$study" != "none" ]]; then
    local benchmark_id
    for ((benchmark_id = START_BENCHMARK_ID; benchmark_id < END_BENCHMARK_ID; benchmark_id++)); do
      echo "=== Running benchmark $benchmark_id for $study ==="
      LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
        java -Djava.library.path="$Z3_DIR" \
          -cp "$CLASSPATH" \
          synth.Main "$study" "$TIMEOUT_MINUTES" \
            "$benchmark_id" "$((benchmark_id + 1))"
    done
  elif [[ -n "$START_BENCHMARK_ID" ]]; then
    LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
      java -Djava.library.path="$Z3_DIR" \
        -cp "$CLASSPATH" \
        synth.Main "$study" "$TIMEOUT_MINUTES" \
          "$START_BENCHMARK_ID" "$END_BENCHMARK_ID"
  else
    LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
      java -Djava.library.path="$Z3_DIR" \
        -cp "$CLASSPATH" \
        synth.Main "$study" "$TIMEOUT_MINUTES"
  fi
}

run_skipped_benchmarks() {
  local study="$1"
  "$SKIPPED_SCRIPT" "$study" "$TIMEOUT_MINUTES"
}

command -v java >/dev/null || { echo "java is required." >&2; exit 1; }
require_file "$DMINER_ROOT/target/classes/synth/Main.class"
require_file "$Z3_DIR/com.microsoft.z3.jar"
require_file "$SKIPPED_SCRIPT"

for study in "${STUDIES[@]}"; do
  run_step "$study evaluation" run_study "$study"
  if [[ -z "$START_BENCHMARK_ID" && ( "$study" == "candidatePruning" || "$study" == "all" ) ]]; then
    run_step "$study sequential benchmarks" run_skipped_benchmarks "$study"
  fi
done

echo "All evaluation steps completed successfully."
