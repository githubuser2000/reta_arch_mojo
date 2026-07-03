#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh \
    reta-mojo-execution-network

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_execution_network.mojo \
    -o "$TEST_DIR/test-execution-network"
"$TEST_DIR/test-execution-network"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_execution_network_persistence.mojo \
    -Xlinker -lsqlite3 -Xlinker -lcrypto \
    -o "$TEST_DIR/test-execution-network-persistence"
"$TEST_DIR/test-execution-network-persistence"

./scripts/check_execution_network_parity.sh
printf '%s\n' 'stage11h focused tests: 85/85 network plus 15/15 persistence integration plus 8/8 Python↔Mojo parity'
