#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-native-startup.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
COMPAT=${RETA_COMPAT_BINARY:-$ROOT/target/bin/reta-mojo-compat-bin}

[ -x "$COMPAT" ] || {
    printf 'Fehlendes Kompatibilitätsbinary: %s\n' "$COMPAT" >&2
    exit 2
}

compare() {
    label=$1
    shift
    (
        cd "$ROOT/python_reference"
        PYTHONHASHSEED=0 "$REFERENCE_PY" reta.py "$@"
    ) >"$TMP/reference-$label" 2>"$TMP/reference-$label.err"
    env RETA_PYTHON=/definitely/not/available \
        "$ROOT/bin/mojo-runtime-exec" "$COMPAT" "$@" \
        >"$TMP/native-$label" 2>"$TMP/native-$label.err"
    cmp "$TMP/reference-$label" "$TMP/native-$label"
    cmp "$TMP/reference-$label.err" "$TMP/native-$label.err"
    printf '%-28s %7s Byte\n' "$label" "$(wc -c <"$TMP/native-$label")"
}

GROUP=${RETA_STARTUP_PARITY_GROUP:-all}
case "$GROUP" in
    1)
        compare empty
        compare language-english -language=english
        compare language-german -language=german
        compare help-german -h
        compare help-english -language=english -help
        count=5
        ;;
    2)
        compare help-duplicate -help -h
        compare help-first-language -h -language=english -language=german
        compare debug-german -debug
        compare debug-english -debug -language=english
        compare debug-help -debug -h
        count=5
        ;;
    3)
        compare nothing-only -nichts
        compare nothing-help -nichts -h
        compare nothing-table -nichts -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon
        compare debug-nothing-table -debug -nichts -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon
        compare explicit-output-wins -nichts -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon -ausgabe --art=csv
        count=5
        ;;
    all)
        RETA_STARTUP_PARITY_GROUP=1 "$0"
        RETA_STARTUP_PARITY_GROUP=2 "$0"
        RETA_STARTUP_PARITY_GROUP=3 "$0"
        printf '%s\n' 'Native Start-/Hilfe-/Kontroll-Parität: 15/15.'
        exit 0
        ;;
    *)
        printf 'Unbekannte RETA_STARTUP_PARITY_GROUP: %s\n' "$GROUP" >&2
        exit 2
        ;;
esac

printf 'Native Start-/Hilfe-/Kontroll-Parität Gruppe %s: %s/5.\n' "$GROUP" "$count"
