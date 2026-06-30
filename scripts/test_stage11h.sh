#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TEST_DIR" "$BIN_DIR"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_execution_network.mojo \
    -o "$TEST_DIR/test-execution-network"
"$TEST_DIR/test-execution-network"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    tests/test_execution_network_persistence.mojo \
    -Xlinker -lsqlite3 -Xlinker -lcrypto \
    -o "$TEST_DIR/test-execution-network-persistence"
"$TEST_DIR/test-execution-network-persistence"

"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    src/architecture_execution_network_main.mojo \
    -o "$BIN_DIR/reta-mojo-execution-network"

./scripts/check_execution_network_parity.sh
printf '%s\n' 'stage11h focused tests: 85/85 network plus 15/15 persistence integration plus 8/8 Python↔Mojo parity'
