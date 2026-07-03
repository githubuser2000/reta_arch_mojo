#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-parallel-execution reta-mojo-row-preparation

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_execution_config.mojo \
    -o "$TEST_DIR/test-parallel-execution-config"
"$TEST_DIR/test-parallel-execution-config"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_thread_backend.mojo \
    -o "$TEST_DIR/test-parallel-thread-backend"
"$TEST_DIR/test-parallel-thread-backend"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_parallel_row_preparation.mojo \
    -o "$TEST_DIR/test-parallel-row-preparation"
"$TEST_DIR/test-parallel-row-preparation"

"$BIN_DIR/reta-mojo-row-preparation" --demo 2 1 >/dev/null
./scripts/check_parallel_row_preparation_parity.sh
./scripts/check_parallel_backend_parity.sh
printf '%s\n' 'stage11j focused tests complete'
