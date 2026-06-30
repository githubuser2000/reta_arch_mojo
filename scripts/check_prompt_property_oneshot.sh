#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-property.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p "$ROOT/target/bin" "$TMP/python_reference"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi
ln -s "$ROOT/assets" "$TMP/assets"
ln -s "$ROOT/python_reference/csv" "$TMP/python_reference/csv"

(
    cd "$TMP"
    "$PROMPT" rpb EIGNgut 2 --art=csv --nocolor > eign.actual
    grep -F -- '--konzept=gut' eign.actual >/dev/null
    grep -F 'Generiert: nach innen: gut' eign.actual >/dev/null

    "$PROMPT" rpb EIGNgut EIGNehrlich 2 --art=csv --nocolor \
        > eign-set.actual
    grep -F -- '--konzept=ehrlich,gut' eign-set.actual >/dev/null
    grep -F 'Generiert: Ehrlich vs. Höflich' eign-set.actual >/dev/null

    "$PROMPT" rpb EIGRwerte 2 --art=csv --nocolor > eigr.actual
    grep -F -- '--konzept2=werte' eigr.actual >/dev/null
    grep -F -- '-zeilen --vorhervonausschnitt=2 --oberesmaximum=1025' \
        eigr.actual >/dev/null
    grep -F 'gesellschaftliche Werte' eigr.actual >/dev/null

    "$PROMPT" rpb EIGRwerte 2 1/3 --art=csv --nocolor > eigr-mixed.actual
    grep -F -- '--vorhervonausschnitt=3' eigr-mixed.actual >/dev/null
    grep -F -- '-zeilen --vorhervonausschnitt=2 --oberesmaximum=1025' \
        eigr-mixed.actual >/dev/null

    "$PROMPT" rpb EIGNgut 2/3 > eign-proper.actual
    [[ ! -s eign-proper.actual ]]
    "$PROMPT" rpb EIGRwerte 2/3 > eigr-proper.actual
    [[ ! -s eigr-proper.actual ]]
    [[ ! -e target/bin/reta-native ]]
)
printf '%s\n' 'native EIGN/EIGR one-shot ownership: 6/6 without Python modules or reta-native child process'
