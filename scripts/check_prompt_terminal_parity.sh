#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
"$ROOT/bin/mojo-real" build -I src \
    tests/test_terminal_geometry.mojo -o "$TEST_DIR/test-terminal-geometry"
"$TEST_DIR/test-terminal-geometry"
"$ROOT/bin/mojo-real" build -I src \
    tests/terminal_geometry_probe.mojo -o "$TEST_DIR/terminal-geometry-probe"
python3 -m pytest -q tests/test_prompt_fixture_integrity.py
RETA_TERMINAL_GEOMETRY_PROBE="$TEST_DIR/terminal-geometry-probe" \
    python3 -m pytest -q tests/test_prompt_terminal_parity.py
