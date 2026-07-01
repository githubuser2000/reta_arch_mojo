#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-native-output-stream.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

COMPAT=${RETA_COMPAT_BINARY:-"$ROOT/target/test-bin/reta-mojo-compat-bin"}
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-"$ROOT/.venv/bin/python"}
[ -x "$REFERENCE_PY" ] || REFERENCE_PY=python3
[ -x "$COMPAT" ] || {
    printf 'Fehlender nativer Kompatibilitätslauncher: %s\n' "$COMPAT" >&2
    exit 1
}

run_pair() {
    label=$1
    shift
    env PYTHONHASHSEED=0 "$REFERENCE_PY" python_reference/reta.py "$@" \
        >"$TMP/python-$label" 2>"$TMP/python-$label.err"
    env RETA_PYTHON=/definitely/not/available "$COMPAT" "$@" \
        >"$TMP/mojo-$label" 2>"$TMP/mojo-$label.err"
    cmp "$TMP/python-$label" "$TMP/mojo-$label"
    cmp "$TMP/python-$label.err" "$TMP/mojo-$label.err"
    printf '  %-22s nativ und bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/mojo-$label")"
}

run_pair onetable-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=12 --nocolor --onetable
run_pair endlessscreen-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=12 --nocolor --endlessscreen
run_pair endless-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=12 --nocolor --endless
run_pair dontwrap-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=12 --nocolor --dontwrap
run_pair justtext-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=12 --justtext
run_pair onetable-en \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --religions=starpolygon \
    -output --type=shell --width=12 --nocolor --onetable
run_pair onetable-zero-width \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=0 --breite=80 --nocolor --onetable

printf '%s\n' 'Native Ausgabe-Stream-Parität: 7/7 ohne Python-Kindprozess.'
