#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"

"$ROOT/bin/mojo-real" build -I src \
    tests/test_no_blank_contents.mojo \
    -o "$TEST_DIR/test-no-blank-contents"
"$TEST_DIR/test-no-blank-contents"

./scripts/check_no_blank_contents_parity.sh
printf '%s\n' 'No-blank-Rendererkern 3/3 und Python-Fixtures 13/13 bestanden.'
