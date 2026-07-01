#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-markup-nocolor.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
FIXTURES="$ROOT/tests/fixtures/markup_nocolor"
[ -x "$NATIVE" ] || {
    printf 'Fehlender nativer Tabellenlauncher: %s\n' "$NATIVE" >&2
    exit 1
}
mkdir -p "$FIXTURES"

run_case() {
    label=$1
    shift
    fixture="$FIXTURES/$label.out"
    if [ "${RETA_REFRESH_MARKUP_NOCOLOR_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED="$HASH_SEED" COLUMNS=80 \
            "$REFERENCE_PY" python_reference/reta.py "$@" >"$fixture"
    fi
    [ -f "$fixture" ] || {
        printf 'Fehlendes Markup-nocolor-Fixture: %s\n' "$fixture" >&2
        exit 1
    }
    env COLUMNS=80 "$NATIVE" "$@" >"$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-34s bytegleich (%s Byte)\n' \
        "$label" "$(wc -c <"$TMP/$label.out")"
}

for mode in html bbcode; do
    run_case "de-$mode-basic" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --nocolor
    run_case "en-$mode-basic" \
        -language=english -lines --thisrangebefore=1 \
        -columns --religions=starpolygon --human=manipulation \
        -output --type="$mode" --width=12 --nocolor
    run_case "de-$mode-widths" \
        -zeilen --vorhervonausschnitt=1-2 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breiten=5,10 --nocolor
    run_case "de-$mode-zero-first" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=12 --breiten=0,8 --nocolor
    run_case "de-$mode-global-zero" \
        -zeilen --vorhervonausschnitt=1 \
        -spalten --religionen=sternpolygon --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=0 --breiten=5,10 --nocolor
    run_case "de-$mode-noempty" \
        -zeilen --vorhervonausschnitt=1-20 \
        -spalten --Menschliches=manipulation \
        -ausgabe --art="$mode" --breite=40 --onetable \
        --keineleereninhalte --nocolor
done

printf '%s\n' \
    'Rohes HTML/BBCode mit --nocolor: 12/12 im direkten Mojo-Tabellenkern.'
