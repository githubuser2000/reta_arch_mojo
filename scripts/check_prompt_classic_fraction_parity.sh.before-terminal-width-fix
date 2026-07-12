#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
REFERENCE="$TEST_DIR/prompt-classic-fraction.reference"
NATIVE="$TEST_DIR/prompt-classic-fraction.native"
BINARY="$TEST_DIR/prompt-classic-fraction-probe"
EXPECTED="$ROOT/tests/fixtures/prompt_classic_fraction.expected"

CASES=(
    "mond 1/2"
    "richtung 2/3"
    "primzahlkreuz 2/4"
    "alles -1/2"
    "thomas 1/2,-1/4"
    "mond 2/2"
    "alles 4/2"
    "mond 1/2,3"
)

python3 scripts/prompt_classic_fraction_reference.py "${CASES[@]}" > "$REFERENCE"
cmp "$EXPECTED" "$REFERENCE"
"$MOJO" build --no-optimization -j 4 -I src \
    tests/prompt_classic_fraction_probe.mojo -o "$BINARY"
"$BINARY" > "$NATIVE"
cmp "$REFERENCE" "$NATIVE"
printf '%s\n' 'classic fraction Python↔Mojo plans: 8/8 byte-identical'
