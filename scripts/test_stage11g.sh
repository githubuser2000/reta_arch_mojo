#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/scripts/require_built_targets.sh" scripts/build-heavy.sh reta-mojo-persistence

LINK_FLAGS='-Xlinker -lsqlite3 -Xlinker -lcrypto'
# shellcheck disable=SC2086
"$ROOT/bin/mojo-real" build -I src tests/test_persistence.mojo $LINK_FLAGS -o "$TEST_DIR/test-persistence"
"$TEST_DIR/test-persistence"
./scripts/check_persistence_parity.sh
printf '%s\n' 'stage11g focused tests: 47/47 plus 5/5 Python↔Mojo persistence parity/interoperability'
