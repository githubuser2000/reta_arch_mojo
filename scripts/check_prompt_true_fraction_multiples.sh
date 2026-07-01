#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
BINARY="$TEST_DIR/prompt-true-fraction-multiple-probe"
"$MOJO" build --no-optimization -j 4 -I src \
    tests/prompt_true_fraction_multiple_probe.mojo -o "$BINARY"
python3 scripts/check_prompt_true_fraction_multiples.py \
    "$BINARY" "$ROOT/bin/reta-native"
