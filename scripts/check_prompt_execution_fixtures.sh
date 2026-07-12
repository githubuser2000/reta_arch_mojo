#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
PROMPT=${RETA_PROMPT_NATIVE:-target/bin/reta-prompt-native}
RETA=${RETA_NATIVE:-target/bin/reta-native}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/bin target/tests
if [ ! -x "$RETA" ]; then
    "$MOJO" build -I src src/reta_native_main.mojo -o "$RETA"
fi
if [ ! -x "$PROMPT" ]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
check() {
    local name=$1; shift
    "$PROMPT" rpb "$@" > "target/tests/prompt-exec-$name.actual"
    cmp "tests/fixtures/prompt_execution/$name.expected" "target/tests/prompt-exec-$name.actual"
}
check prime-compare-basic primfaktorenvergleich 12 18
check prime-compare-range primfaktorenvergleich 12-14 18
check distance-range abstand 7 17-19
check distance-prime-range abstandPrim 7 17-19
check distance-bidirectional abstand 7-8 17-19
check moon-table mond 1-3
check direction richtung 1-2
printf 'native prompt execution fixtures: 7/7 byte-identical\n'
