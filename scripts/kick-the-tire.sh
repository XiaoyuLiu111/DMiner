#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR: ${BASH_SOURCE[0]} failed at line $LINENO." >&2' ERR

DMINER_ROOT="${DMINER_ARTIFACT_ROOT:-/DMINER_Artifact/experiments}"
EUSOLVER_ROOT="${EUSOLVER_ROOT:-/EUSolver}"
Z3_DIR="$DMINER_ROOT/lib/z3-4.13.0-x64-glibc-2.31/bin"
CLASSPATH="target/classes:target/dependency/*:$Z3_DIR/com.microsoft.z3.jar"

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

run_dminer_smoke_test() {
  cd "$DMINER_ROOT"
  LD_LIBRARY_PATH="$Z3_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    java -Djava.library.path="$Z3_DIR" \
      -cp "$CLASSPATH" \
      synth.Main none 10 13 14
}

run_eusolver_smoke_test() {
  cd "$EUSOLVER_ROOT"
  source .venv/bin/activate
  python ./benchmarks/cypher/test_EUSolver.py
}

command -v java >/dev/null || { echo "java is required." >&2; exit 1; }
require_file "$DMINER_ROOT/target/classes/synth/Main.class"
require_file "$Z3_DIR/com.microsoft.z3.jar"
require_file "$EUSOLVER_ROOT/.venv/bin/python"
require_file "$EUSOLVER_ROOT/benchmarks/cypher/test_EUSolver.py"

run_step "DMiner smoke test" run_dminer_smoke_test
run_step "EUSolver smoke test" run_eusolver_smoke_test

echo "All smoke-test steps completed successfully."
