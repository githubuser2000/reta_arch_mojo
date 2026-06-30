#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
BIN_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TEST_DIR" "$BIN_DIR"

LINK_FLAGS='-Xlinker -lsqlite3 -Xlinker -lcrypto'
# shellcheck disable=SC2086
"$ROOT/bin/mojo-real" build -I src tests/test_persistence.mojo $LINK_FLAGS -o "$TEST_DIR/test-persistence"
"$TEST_DIR/test-persistence"
# This controller is compact and can remain optimized.
# shellcheck disable=SC2086
"$ROOT/bin/mojo-real" build -I src src/architecture_persistence_main.mojo $LINK_FLAGS -o "$BIN_DIR/reta-mojo-persistence"

./scripts/check_persistence_parity.sh
printf '%s\n' 'stage11g focused tests: 47/47 plus 5/5 Python↔Mojo persistence parity/interoperability'
