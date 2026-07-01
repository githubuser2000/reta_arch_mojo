#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-paginated-rendering.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
FIXTURES="$ROOT/tests/fixtures/paginated_rendering"
[ -x "$NATIVE" ] || {
    printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
    exit 1
}
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    language=$2
    mode=$3
    fixture="$FIXTURES/$label.out"
    if [ "$language" = de ]; then
        set -- \
            -zeilen --vorhervonausschnitt=1-20 \
            -spalten --religionen=sternpolygon,gleichfoermigespolygon \
            -ausgabe --art="$mode" --breite=21 --keineleereninhalte
    else
        set -- \
            -language=english -lines --thisrangebefore=1-12 \
            -columns --religions=starpolygon,uniformpolygon \
            -output --type="$mode" --width=21 --noblankcontents
    fi
    if [ "${RETA_REFRESH_PAGINATED_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes paginiertes Renderer-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-20s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

for mode in shell html bbcode; do
    run_case "$mode-de-paged" de "$mode"
    run_case "$mode-en-paged" en "$mode"
done
printf '%s\n' 'Paginierte Shell-/HTML-/BBCode-Parität: 6/6 im direkten Mojo-Tabellenkern.'
