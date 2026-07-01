#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-native-markup-onetable.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
COMPAT=${RETA_COMPAT_BINARY:-"$ROOT/target/bin/reta-mojo-compat-bin"}
FIXTURES="$ROOT/tests/fixtures/markup_onetable"
[ -x "$COMPAT" ] || {
    printf 'Fehlender Kompatibilitätslauncher: %s\n' "$COMPAT" >&2
    exit 1
}

refresh_fixture() {
    fixture=$1
    shift
    if [ "${RETA_REFRESH_MARKUP_ONETABLE_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" "$REFERENCE_PY" \
            python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Markup-oneTable-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
}

run_fixture() {
    label=$1
    fixture=$2
    shift 2
    env RETA_PYTHON=/definitely/not/available "$COMPAT" "$@" >"$TMP/native-$label"
    cmp "$fixture" "$TMP/native-$label"
    printf '  %-28s fixture-bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/native-$label")"
}

html_de40="$FIXTURES/html-de-width40.out"
html_en40="$FIXTURES/html-en-width40.out"
html_de0="$FIXTURES/html-de-width0.out"
bb_de40="$FIXTURES/bbcode-de-width40.out"
bb_en40="$FIXTURES/bbcode-en-width40.out"
bb_de0="$FIXTURES/bbcode-de-width0.out"

refresh_fixture "$html_de40" \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=html --breite=40 --onetable
refresh_fixture "$html_en40" \
    -language=english -lines --thisrangebefore=1-2 \
    -columns --religions=starpolygon \
    -output --type=html --width=40 --onetable
refresh_fixture "$html_de0" \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=html --breite=0 --onetable
refresh_fixture "$bb_de40" \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=40 --onetable
refresh_fixture "$bb_en40" \
    -language=english -lines --thisrangebefore=1-2 \
    -columns --religions=starpolygon \
    -output --type=bbcode --width=40 --onetable
refresh_fixture "$bb_de0" \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=0 --onetable

for alias in onetable endlessscreen endless dontwrap; do
    run_fixture "html-$alias-de" "$html_de40" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon \
        -ausgabe --art=html --breite=40 --"$alias"
    run_fixture "bbcode-$alias-de" "$bb_de40" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon \
        -ausgabe --art=bbcode --breite=40 --"$alias"
done
run_fixture html-onetable-en "$html_en40" \
    -language=english -lines --thisrangebefore=1-2 \
    -columns --religions=starpolygon \
    -output --type=html --width=40 --onetable
run_fixture bbcode-onetable-en "$bb_en40" \
    -language=english -lines --thisrangebefore=1-2 \
    -columns --religions=starpolygon \
    -output --type=bbcode --width=40 --onetable
run_fixture html-onetable-zero "$html_de0" \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=html --breite=0 --onetable
run_fixture bbcode-onetable-zero "$bb_de0" \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=0 --onetable

printf '%s\n' 'Native Markup-oneTable-Parität: 12/12 ohne Python-Kindprozess.'
