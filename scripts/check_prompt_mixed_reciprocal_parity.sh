#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
EXPECTED="$ROOT/tests/fixtures/prompt_mixed_reciprocal.expected"
REFERENCE="$TEST_DIR/prompt-mixed-reciprocal.reference"
ACTUAL="$TEST_DIR/prompt-mixed-reciprocal.actual"
BINARY="$TEST_DIR/prompt-mixed-reciprocal-probe"

CASES=(
    "universum teiler 1/2"
    "universum vielfache 1/2"
    "universum vielfache teiler 1/2"
    "universum v1/2 teiler"
    "universum vielfache teiler 1/2,-1/4"
)

python3 scripts/prompt_mixed_reciprocal_reference.py "${CASES[@]}" > "$REFERENCE"
cmp "$EXPECTED" "$REFERENCE"
"$MOJO" build --no-optimization -j 4 -I src \
    tests/prompt_mixed_reciprocal_probe.mojo -o "$BINARY"
"$ROOT/bin/mojo-runtime-exec" "$BINARY" > "$ACTUAL"
cmp "$EXPECTED" "$ACTUAL"
printf '%s\n' 'mixed reciprocal Python↔Mojo plans: 5/5 byte-identical'
