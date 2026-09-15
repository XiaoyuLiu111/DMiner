#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR: ${BASH_SOURCE[0]} failed at line $LINENO." >&2' ERR

DMINER_ROOT="${DMINER_ARTIFACT_ROOT:-/DMINER_Artifact}"
EUSOLVER_ROOT="${EUSOLVER_ROOT:-/EUSolver}"
CREATE_DB_SCRIPT="$DMINER_ROOT/experiments/scripts/createDB.sh"
LOAD_DB_SCRIPT="$DMINER_ROOT/experiments/scripts/loadDB.sh"
PYTHON_VERSION="3.6.15"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PATH="$PYENV_ROOT/bin:$PATH"

require_command() {
  command -v "$1" >/dev/null || { echo "$1 is required." >&2; exit 1; }
}

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

configure_neo4j() {
  local config_file="${NEO4J_HOME:?NEO4J_HOME must be set}/conf/neo4j.conf"
  if grep -q '^dbms\.max_databases=' "$config_file"; then
    sed -i 's/^dbms\.max_databases=.*/dbms.max_databases=1000/' "$config_file"
  else
    printf '%s\n' 'dbms.max_databases=1000' >> "$config_file"
  fi
}

create_databases() {
  chmod +x "$CREATE_DB_SCRIPT"
  "$CREATE_DB_SCRIPT"
}

load_databases() {
  chmod +x "$LOAD_DB_SCRIPT"
  "$LOAD_DB_SCRIPT"
}

build_dminer() {
  cd "$DMINER_ROOT/experiments"
  mvn clean compile
  mvn dependency:copy-dependencies -DoutputDirectory=target/dependency
  require_file "$DMINER_ROOT/experiments/target/classes/synth/Main.class"
}

configure_python() {
  eval "$(pyenv init -)"
  pyenv install -s "$PYTHON_VERSION"
  cd "$EUSOLVER_ROOT"
  pyenv local "$PYTHON_VERSION"
  python3 -m venv --clear .venv
  ./.venv/bin/python -m pip install -r requirements.txt
}

build_eusolver() {
  cd "$EUSOLVER_ROOT"
  mkdir -p ./thirdparty/libeusolver/build
  if [[ -f ./thirdparty/libeusolver/build/Makefile ]]; then
    make -C ./thirdparty/libeusolver/build clean
  fi
  PATH="$EUSOLVER_ROOT/.venv/bin:$PATH" ./build.sh
  ln -sfn libeusolver.so ./thirdparty/libeusolver/build/libeusolver.dylib
  require_file "$EUSOLVER_ROOT/thirdparty/libeusolver/build/libeusolver.so"
}

require_command grep
require_command sed
require_command neo4j
require_command cypher-shell
require_command neo4j-admin
require_command mvn
require_command java
require_command pyenv
require_command cmake
require_command make
require_file "$CREATE_DB_SCRIPT"
require_file "$LOAD_DB_SCRIPT"
require_file "$DMINER_ROOT/experiments/pom.xml"
require_file "$EUSOLVER_ROOT/requirements.txt"
require_file "$EUSOLVER_ROOT/build.sh"

# run_step "configure Neo4j" configure_neo4j
# run_step "create Neo4j databases" create_databases
# run_step "load Neo4j database dumps" load_databases
run_step "clean and build DMiner" build_dminer
run_step "create clean EUSolver Python environment" configure_python
run_step "clean and build EUSolver" build_eusolver

echo "All setup steps completed successfully."
