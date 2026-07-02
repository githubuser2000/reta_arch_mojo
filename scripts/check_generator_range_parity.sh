#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-generator-ranges.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/generator_ranges"
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    shift
    fixture="$FIXTURES/$label.out"
    if [ "${RETA_REFRESH_GENERATOR_RANGE_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Generatorbereich-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    if [ "${RETA_GENERATOR_RANGE_FIXTURES_ONLY:-0}" = 1 ]; then
        printf '  %-30s erzeugt (%s Byte)\n' \
            "$label" "$(wc -c <"$fixture")"
        return
    fi
    [ -x "$NATIVE" ] || {
        printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-30s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

run_case de-comprehension-csv \
    -zeilen '--vorhervonausschnitt={2*n for n in range(2,5)},10' \
    --oberesmaximum=20 \
    -spalten --Menschliches=motivation \
    -ausgabe --art=csv --breite=0

run_case en-comprehension-csv \
    -language=english \
    -lines '--thisrangebefore={2*n for n in range(2,5)},10' \
    --uppermaximum=20 \
    -columns --human=motifs \
    -output --type=csv --width=0

run_case de-arithmetic-markdown \
    -zeilen '--vorhervonausschnitt=[2*3],10' --oberesmaximum=20 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=markdown --breite=0

run_case de-subtractive-csv \
    -zeilen '--vorhervonausschnitt=1-10,-{2*n for n in range(2,5)}' \
    --oberesmaximum=20 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=csv --breite=0

run_case de-negative-step-emacs \
    -zeilen '--vorhervonausschnitt=[n for n in range(9,0,-3)]' \
    --oberesmaximum=20 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=emacs --breite=0

run_case de-generator-column-order \
    -zeilen --vorhervonausschnitt=1 \
    -spalten --Bedeutung=gestirn \
    -ausgabe '--spaltenreihenfolgeundnurdiese=[n for n in range(1,3)]' \
    --art=csv --breite=0

if [ "${RETA_GENERATOR_RANGE_FIXTURES_ONLY:-0}" = 1 ]; then
    printf '%s\n' 'Generatorbereich-Fixtures: 6/6 erzeugt.'
else
    printf '%s\n' 'Generatorbereiche und -Spaltenordnung: 6/6 bytegleich.'
fi
