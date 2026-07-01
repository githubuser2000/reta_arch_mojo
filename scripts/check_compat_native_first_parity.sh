#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-compat-native-first.$$
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
    printf '  %-24s nativ und bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/mojo-$label")"
}

GROUP=${RETA_COMPAT_PARITY_GROUP:-all}
COUNT=0

if [ "$GROUP" = all ] || [ "$GROUP" = 1 ]; then
run_pair physical-csv-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=csv --breite=40
run_pair physical-markdown-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=markdown --breite=40
run_pair physical-english \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --religions=starpolygon \
    -output --type=csv --width=40
run_pair generated-gestirn \
    -zeilen --vorhervonausschnitt=1-6 \
    -spalten --bedeutung=gestirn \
    -ausgabe --art=csv --breite=40
run_pair modal-love \
    -language=english -lines --thisrangebefore=1-16 \
    -columns --basic_structures=love \
    -output --type=csv --width=40
run_pair prime-cross \
    -zeilen --vorhervonausschnitt=1-20 \
    -spalten --bedeutung=primzahlkreuz \
    -ausgabe --art=csv --breite=40
COUNT=$((COUNT + 6))
fi

if [ "$GROUP" = all ] || [ "$GROUP" = 2 ]; then
run_pair prime-effect \
    -zeilen --vorhervonausschnitt=1-12 \
    -spalten --primzahlwirkung=absicht \
    -ausgabe --art=csv --breite=40
run_pair meta \
    -zeilen --vorhervonausschnitt=1-8 \
    -spalten --universummetakonkret=meta \
    -ausgabe --art=csv --breite=40
run_pair fraction \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --fractional_universe_n/m=2 \
    -output --type=html --width=0
run_pair kombi \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=tiere,berufe --universum=transzendenz \
    -ausgabe --art=csv --breite=40
run_pair bbcode \
    -zeilen --vorhervonausschnitt=1-2 \
    -spalten --religionen=sternpolygon \
    -ausgabe --art=bbcode --breite=40
run_pair explicit-order \
    -zeilen --vorhervonausschnitt=1-3 \
    -spalten --bedeutung=gestirn \
    -ausgabe --art=csv --breite=40 --spaltenreihenfolgeundnurdiese=3-6
COUNT=$((COUNT + 6))
fi

[ "$COUNT" -gt 0 ] || {
    printf 'Unbekannte Paritätsgruppe: %s\n' "$GROUP" >&2
    exit 2
}
printf 'Native-first Kompatibilitätsparität: %s/%s ohne Python-Kindprozess.\n' "$COUNT" "$COUNT"
