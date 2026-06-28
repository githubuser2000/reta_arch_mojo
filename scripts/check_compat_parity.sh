#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMPDIR=${TMPDIR:-/tmp}
PY_OUT="$TMPDIR/reta-python-reference.$$"
MOJO_OUT="$TMPDIR/reta-mojo-compat.$$"
trap 'rm -f "$PY_OUT" "$MOJO_OUT"' EXIT HUP INT TERM
python python_reference/reta.py \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon --breite=40 >"$PY_OUT"
./bin/reta-mojo-compat \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon --breite=40 >"$MOJO_OUT"
cmp "$PY_OUT" "$MOJO_OUT"
printf '%s\n' 'Kompatibilitätsausgabe ist bytegleich.'
