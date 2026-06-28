#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMPDIR_BASE=${TMPDIR:-/tmp}/reta-kombi-parity.$$
mkdir -p "$TMPDIR_BASE"
trap 'rm -rf "$TMPDIR_BASE"' EXIT HUP INT TERM
REFERENCE_PY=${RETA_REFERENCE_PYTHON:-python3}
PYTHON_HASH_SEED=${RETA_REFERENCE_HASH_SEED:-0}
NATIVE=${RETA_NATIVE_BINARY:-"$ROOT/target/bin/reta-native"}
[ -x "$NATIVE" ] || NATIVE="$ROOT/bin/reta-native"

run_pair() {
    label=$1
    shift
    env PYTHONHASHSEED="$PYTHON_HASH_SEED" "$REFERENCE_PY" python_reference/reta.py "$@" >"$TMPDIR_BASE/python-$label"
    "$NATIVE" "$@" >"$TMPDIR_BASE/mojo-$label"
    cmp "$TMPDIR_BASE/python-$label" "$TMPDIR_BASE/mojo-$label"
    printf '  %-25s bytegleich (%s Byte)\n' "$label" "$(wc -c <"$TMPDIR_BASE/mojo-$label")"
}

run_pair galaxy-animals-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=tiere \
    -ausgabe --art=csv --breite=40
run_pair galaxy-jobs-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=berufe \
    -ausgabe --art=csv --breite=40
run_pair universe-animals-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --universum=tiere \
    -ausgabe --art=csv --breite=40
run_pair universe-transcendence-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --universum=transzendenz \
    -ausgabe --art=csv --breite=40
run_pair galaxy-multi-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=tiere,berufe \
    -ausgabe --art=csv --breite=40
run_pair mixed-kombi-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=tiere,berufe --universum=tiere,transzendenz \
    -ausgabe --art=csv --breite=40
run_pair galaxy-negative-de \
    -zeilen --vorhervonausschnitt=1-3 \
    -kombination --galaxie=tiere,-berufe \
    -ausgabe --art=csv --breite=40
run_pair galaxy-animals-en \
    -language=english -lines --thisrangebefore=1-3 \
    -combination --galaxy=animals \
    -output --type=csv --width=40
run_pair universe-transcendence-en \
    -language=english -lines --thisrangebefore=1-3 \
    -combination --universe=transcendence \
    -output --type=csv --width=40

printf '%s\n' 'Native Kombi-Join-Parität bestanden.'
