#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=${TMPDIR:-/tmp}/reta-prompt-width.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/python_reference"
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

test -x "$PROMPT" || {
    printf 'Fehlendes Prompt-Binary: %s\n' "$PROMPT" >&2
    exit 1
}

run_case() {
    mode=$1
    fixture=$2
    (
        cd "$TMP"
        "$PROMPT" rpb reta \
            -zeilen --vorhervonausschnitt=1-2 \
            -spalten --religionen=sternpolygon \
            -ausgabe --art="$mode" --breite=40 > "$mode.actual"
    )
    cmp "$ROOT/$fixture" "$TMP/$mode.actual"
}

run_case shell tests/fixtures/shell/shell-de-width40.out
run_case html tests/fixtures/markup/html-de-width40.out
run_case bbcode tests/fixtures/markup/bbcode-de-width40.out

test ! -e "$TMP/python_reference/reta.py"
test ! -e "$TMP/target/bin/reta-native"
printf '%s\n' 'Positive Shell-, HTML- und BBCode-Breiten laufen im Prompt bytegleich ohne Python- oder reta-native-Kindprozess.'
