#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
PYTHON=${RETA_REFERENCE_PYTHON:-python3}
mkdir -p "$TEST_DIR" "$BIN_DIR"

"$PYTHON" tools/audit_native_boundaries.py
"$PYTHON" -m pytest -q tests/test_native_boundary_audit.py

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_execution_network.mojo \
    -o "$TEST_DIR/test-execution-network-thread"
"$TEST_DIR/test-execution-network-thread"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_execution_config.mojo \
    -o "$TEST_DIR/test-parallel-execution-config-thread"
"$TEST_DIR/test-parallel-execution-config-thread"


"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_thread_backend.mojo \
    -o "$TEST_DIR/test-parallel-thread-backend"
"$TEST_DIR/test-parallel-thread-backend"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_row_preparation.mojo \
    -o "$TEST_DIR/test-parallel-row-preparation"
"$TEST_DIR/test-parallel-row-preparation"

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
    tests/test_execution_network_persistence.mojo \
    -Xlinker -lsqlite3 -Xlinker -lcrypto \
    -o "$TEST_DIR/test-execution-network-persistence-thread"
"$TEST_DIR/test-execution-network-persistence-thread"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    src/architecture_execution_network_main.mojo \
    -o "$BIN_DIR/reta-mojo-execution-network"
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    src/architecture_parallel_execution_main.mojo \
    -o "$BIN_DIR/reta-mojo-parallel-execution"
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    src/architecture_parallel_row_preparation_main.mojo \
    -o "$BIN_DIR/reta-mojo-row-preparation"

./scripts/check_execution_network_parity.sh
./scripts/check_parallel_execution_parity.sh
./scripts/check_parallel_backend_parity.sh
./scripts/check_parallel_row_preparation_parity.sh
printf '%s\n' 'stage12a native thread migration tests complete'
