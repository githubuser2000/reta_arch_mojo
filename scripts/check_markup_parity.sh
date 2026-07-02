#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-markup-parity.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || NATIVE="$ROOT/bin/reta-native"

run_pair() {
    label=$1
    shift
    fixture="$ROOT/tests/fixtures/markup/$label.out"
    mkdir -p "$(dirname "$fixture")"
    if [ "${RETA_REFRESH_MARKUP_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Markup-Referenzfixture: %s\n' "$fixture" >&2
        exit 1
    }
    "$NATIVE" "$@" >"$TMP/mojo-$label"
    cmp "$fixture" "$TMP/mojo-$label"
    printf '  %-25s fixture-bytegleich (%s Byte)\n' "$label" "$(wc -c <"$TMP/mojo-$label")"
}
run_pair bbcode-de-width0 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=0
run_pair bbcode-de-width40 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=40
run_pair bbcode-en-width40 \
    -language=english -lines --thisrangebefore=1-2 -columns --religions=starpolygon \
    -output --type=bbcode --width=40
run_pair html-de-width0 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=html --breite=0
run_pair html-de-width40 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=html --breite=40
run_pair html-en-width40 \
    -language=english -lines --thisrangebefore=1-2 -columns --religions=starpolygon \
    -output --type=html --width=40
run_pair html-meta-de \
    -zeilen --vorhervonausschnitt=1-4 -spalten --universummetakonkret=meta \
    -ausgabe --art=html --breite=0
run_pair html-fraction-en \
    -language=english -lines --thisrangebefore=1-3 -columns --fractional_universe_n/m=2 \
    -output --type=html --width=0

if [ "${RETA_MARKUP_EXTENDED:-0}" = 1 ]; then
    run_pair bbcode-no-number \
        -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
        -ausgabe --art=bbcode --breite=40 --keinenummerierung
    run_pair bbcode-no-heading \
        -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
        -ausgabe --art=bbcode --breite=40 --keineueberschriften
    run_pair html-no-number \
        -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
        -ausgabe --art=html --breite=40 --keinenummerierung
    run_pair html-no-heading \
        -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
        -ausgabe --art=html --breite=40 --keineueberschriften
    run_pair html-prime-effect-de \
        -zeilen --vorhervonausschnitt=1-4 -spalten --primzahlwirkung=absicht \
        -ausgabe --art=html --breite=0
    run_pair html-prime-effect-en \
        -language=english -lines --thisrangebefore=1-4 -columns --prime_effect=intentions \
        -output --type=html --width=0
    run_pair html-meta-en \
        -language=english -lines --thisrangebefore=1-4 -columns --universeMetaConcrete=meta \
        -output --type=html --width=0
    run_pair html-fraction-de \
        -zeilen --vorhervonausschnitt=1-3 -spalten --gebrochenuniversum=2 \
        -ausgabe --art=html --breite=0
fi

printf '%s\n' 'BBCode- und HTML-Parität gegen geprüfte Python-Fixtures bestanden.'
