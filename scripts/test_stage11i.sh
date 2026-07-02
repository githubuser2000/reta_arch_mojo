#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
mkdir -p "$TEST_DIR" "$BIN_DIR"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_prompt_legacy_echo.mojo \
    -o "$TEST_DIR/test-prompt-legacy-echo"
"$TEST_DIR/test-prompt-legacy-echo"

"$PYTHON" -m pytest -q tests/test_prompt_fixture_integrity.py

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_execution_config.mojo \
    -o "$TEST_DIR/test-parallel-execution-config"
"$TEST_DIR/test-parallel-execution-config"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_row_threads.mojo \
    -o "$TEST_DIR/test-parallel-row-threads"
"$TEST_DIR/test-parallel-row-threads"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_number_threads.mojo \
    -o "$TEST_DIR/test-parallel-number-threads"
"$TEST_DIR/test-parallel-number-threads"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_table_execution.mojo \
    -o "$TEST_DIR/test-parallel-table-execution"
"$TEST_DIR/test-parallel-table-execution"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    src/architecture_parallel_execution_main.mojo \
    -o "$BIN_DIR/reta-mojo-parallel-execution"

./scripts/check_parallel_execution_parity.sh
printf '%s\n' 'stage11i focused tests complete'
