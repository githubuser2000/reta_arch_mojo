#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-shell-parity.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || NATIVE="$ROOT/bin/reta-native"
REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")

run_pair() {
    label=$1
    shift
    fixture="$ROOT/tests/fixtures/shell/$label.out"
    if [ "${RETA_REFRESH_SHELL_FIXTURES:-0}" = 1 ]; then
        env PYTHONHASHSEED=0 "$REFERENCE_PY" python_reference/reta.py "$@" > "$fixture"
    fi
    [ -f "$fixture" ] || { printf 'Fehlendes Shell-Fixture: %s\n' "$fixture" >&2; exit 1; }
    "$NATIVE" "$@" > "$TMP/$label.out"
    cmp "$fixture" "$TMP/$label.out"
    printf '  %-24s bytegleich (%s Byte)\n' "$label" "$(wc -c < "$TMP/$label.out")"
}

run_pair shell-de-width0 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=0
run_pair shell-de-width40 \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=40
run_pair shell-en-width40 \
    -language=english -lines --thisrangebefore=1-2 -columns --religions=starpolygon \
    -output --type=shell --width=40
run_pair shell-de-no-number \
    -zeilen --vorhervonausschnitt=1-2 -spalten --religionen=sternpolygon \
    -ausgabe --art=shell --breite=40 --keinenummerierung
run_pair shell-prime-effect \
    -zeilen --vorhervonausschnitt=1-4 -spalten --primzahlwirkung=absicht \
    -ausgabe --art=shell --breite=0

printf '%s\n' 'ANSI-Shell-Parität gegen geprüfte Python-Fixtures bestanden.'
