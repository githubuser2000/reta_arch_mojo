#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-column-zero-widths.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/column_zero_widths"
[ -x "$NATIVE" ] || {
    printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
    exit 1
}
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    shift
    fixture="$FIXTURES/$label.out"
    if [ "${RETA_REFRESH_COLUMN_ZERO_WIDTH_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Nullbreiten-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-34s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

for mode in shell html bbcode; do
    run_case "de-$mode-zero-first" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=0
    run_case "de-$mode-zero-first-plus" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=0,8
    run_case "de-$mode-zero-second" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=5,0
    run_case "de-$mode-zero-all" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=0,0
done

printf '%s\n' \
    'Explizite Nullbreiten: 12/12 im direkten Mojo-Tabellenkern.'
