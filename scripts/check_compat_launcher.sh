#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"

"$ROOT/bin/mojo-real" build -j 4 -I src \
    src/compat_main.mojo -o "$TEST_DIR/reta-mojo-compat-bin"

if command -v readelf >/dev/null 2>&1 && \
   readelf -d "$TEST_DIR/reta-mojo-compat-bin" 2>/dev/null | \
       grep NEEDED | grep -qi libpython; then
    printf '%s\n' 'Kompatibilitätslauncher bindet unerwartet libpython ein.' >&2
    exit 1
fi

RETA_COMPAT_BINARY="$TEST_DIR/reta-mojo-compat-bin" \
PYTHONPATH=. python3 -m pytest -q tests/test_compat_launcher.py

printf '%s\n' 'Nativer Kompatibilitätslauncher: 13/13 ohne eingebettetes CPython.'
