#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-flat-column-widths.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/flat_column_widths"
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    shift
    fixture="$FIXTURES/$label.out"
    if [ "${RETA_REFRESH_FLAT_COLUMN_WIDTH_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes flaches Spaltenbreiten-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    if [ "${RETA_FLAT_COLUMN_WIDTH_FIXTURES_ONLY:-0}" = 1 ]; then
        printf '  %-31s erzeugt (%s Byte)\n' \
            "$label" "$(wc -c <"$fixture")"
        return
    fi
    [ -x "$NATIVE" ] || {
        printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-31s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

for mode in csv markdown emacs; do
    run_case "de-$mode-basic" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breiten=5,10
    run_case "en-$mode-basic" \
        -language=english -lines --thisrangebefore=1-2 \
        -columns --religions=starpolygon --human=manipulation \
        -output --type="$mode" --widths=5,10
    run_case "de-$mode-zero-first" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=0,8
    run_case "de-$mode-replaced" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breiten=3 --breiten=5,10
done

run_case "de-csv-unnumbered-nohead" \
    -zeilen --vorhervonausschnitt=1 \
    -spalten --religionen=sternpolygon --Menschliches=manipulation \
    -ausgabe --art=csv --breiten=5,10 \
    --keineueberschriften --keinenummerierung

if [ "${RETA_FLAT_COLUMN_WIDTH_FIXTURES_ONLY:-0}" = 1 ]; then
    printf '%s\n' 'Flache Spaltenbreiten-Fixtures: 13/13 erzeugt.'
else
    printf '%s\n' \
        'CSV-/Markdown-/Emacs-Spaltenbreiten: 13/13 im direkten Mojo-Tabellenkern.'
fi
