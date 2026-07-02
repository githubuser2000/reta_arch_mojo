#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-column-widths.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/column_widths"
[ -x "$NATIVE" ] || {
    printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
    exit 1
}
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    shift
    fixture="$FIXTURES/$label.out"
    if [ "${RETA_REFRESH_COLUMN_WIDTH_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Spaltenbreiten-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-31s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

for mode in shell html bbcode; do
    run_case "de-$mode-basic" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breiten=5,10
    run_case "en-$mode-basic" \
        -language=english -lines --thisrangebefore=1-2 \
        -columns --religions=starpolygon --human=manipulation \
        -output --type="$mode" --widths=5,10
    run_case "de-$mode-global-zero" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=0 --breiten=5,10
    run_case "de-$mode-replaced" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breiten=3 --breiten=5,10
done

printf '%s\n' \
    'Individuelle positive Spaltenbreiten: 12/12 im direkten Mojo-Tabellenkern.'
