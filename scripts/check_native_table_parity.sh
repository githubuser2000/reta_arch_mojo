#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMPDIR_BASE=${TMPDIR:-/tmp}/reta-native-parity.$$
mkdir -p "$TMPDIR_BASE"
trap 'rm -rf "$TMPDIR_BASE"' EXIT HUP INT TERM
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || NATIVE="$ROOT/bin/reta-native"

run_pair() {
    label=$1
    mode=$2
    shift 2
    REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
    "$REFERENCE_PY" python_reference/reta.py "$@" -ausgabe "--art=$mode" --breite=40 >"$TMPDIR_BASE/python-$label"
    "$NATIVE" "$@" -ausgabe "--art=$mode" --breite=40 >"$TMPDIR_BASE/mojo-$label"
    cmp "$TMPDIR_BASE/python-$label" "$TMPDIR_BASE/mojo-$label"
    printf '  %-18s bytegleich (%s Byte)\n' "$label" "$(wc -c <"$TMPDIR_BASE/mojo-$label")"
}

COMMON='-zeilen --vorhervonausschnitt=1-3 -spalten --religionen=sternpolygon'
# Deliberate word splitting: each token is a separate CLI argument.
# shellcheck disable=SC2086
run_pair deutsch-csv csv $COMMON
# shellcheck disable=SC2086
run_pair deutsch-markdown markdown $COMMON
# shellcheck disable=SC2086
run_pair deutsch-emacs emacs $COMMON

REFERENCE_PY=$("$ROOT/scripts/select_reference_python.sh")
"$REFERENCE_PY" python_reference/reta.py \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --religions=starpolygon -output --type=csv --width=40 \
    >"$TMPDIR_BASE/python-englisch-csv"
"$NATIVE" \
    -language=english -lines --thisrangebefore=1-3 \
    -columns --religions=starpolygon -output --type=csv --width=40 \
    >"$TMPDIR_BASE/mojo-englisch-csv"
cmp "$TMPDIR_BASE/python-englisch-csv" "$TMPDIR_BASE/mojo-englisch-csv"
printf '  %-18s bytegleich (%s Byte)\n' englisch-csv "$(wc -c <"$TMPDIR_BASE/mojo-englisch-csv")"

if [ "${RETA_SKIP_NATIVE_SWITCH:-0}" != 1 ]; then
    RETA_NATIVE=1 ./reta -zeilen --vorhervonausschnitt=1-3 \
        -spalten --religionen=sternpolygon -ausgabe --art=csv --breite=40 \
        >"$TMPDIR_BASE/native-switch"
    cmp "$TMPDIR_BASE/python-deutsch-csv" "$TMPDIR_BASE/native-switch"
    printf '%s\n' 'Native Reta-Tabellenparität und RETA_NATIVE-Schalter bestanden.'
else
    printf '%s\n' 'Native Reta-Tabellenparität bestanden; Wrapper-Schalter gezielt ausgelassen.'
fi
