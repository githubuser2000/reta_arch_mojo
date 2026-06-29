#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-native-oneshot.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$TMP/python_reference"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

(
    cd "$TMP"
    "$PROMPT" rpb prim 60 > prime.actual
    [[ $(cat prime.actual) == '60: 2^2 3 5' ]]
    "$PROMPT" retaPrompt -befehl multis 12 > multis.actual
    [[ $(cat multis.actual) == '12: [(6, 2), (4, 3), (12, 1)]' ]]
    "$PROMPT" rpb abc Test > abc.actual
    [[ $(cat abc.actual) == '20 5 19 20' ]]
    "$PROMPT" rpb leeren > clear.actual
    printf '\033[2J\033[H' > clear.expected
    cmp clear.expected clear.actual
    "$PROMPT" rpb universum 1/2 --nocolor --breite=0 > table.actual
    grep -F 'reta -zeilen --vorhervonausschnitt=2' table.actual >/dev/null
    grep -F '1 / 2 Art und Weise' table.actual >/dev/null
    [[ ! -e target/bin/reta-native ]]
    "$PROMPT" rpb reta -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon -ausgabe --art=csv --nocolor \
        > raw-reta.actual
    grep -F ';Religionen der Föderation' raw-reta.actual >/dev/null
    if "$PROMPT" rpb reta -ausgabe --onetable > fallback.actual 2> fallback.err; then
        echo 'unported raw reta command unexpectedly bypassed compatibility' >&2
        exit 1
    fi
    grep -F "No module named 'mojo_bridge'" fallback.actual >/dev/null
    if "$PROMPT" rpb a 2 > compact.actual 2> compact.err; then
        echo 'compact echo command unexpectedly bypassed compatibility' >&2
        exit 1
    fi
    grep -F "No module named 'mojo_bridge'" compact.actual >/dev/null
)
printf '%s\n' 'native one-shot prompt boundary: 6 native commands without Python; raw and compact fallbacks remain isolated'
