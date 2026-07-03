#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-execution-network reta-mojo-parallel-execution \
    reta-mojo-row-preparation

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

./scripts/check_execution_network_parity.sh
./scripts/check_parallel_execution_parity.sh
./scripts/check_parallel_backend_parity.sh
./scripts/check_parallel_row_preparation_parity.sh
printf '%s\n' 'stage12a native thread migration tests complete'
