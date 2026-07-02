#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
BIN=${RETA_ROW_PREPARATION_BIN:-"$ROOT/target/bin/reta-mojo-row-preparation"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
TMP=${TMPDIR:-/tmp}/reta-row-preparation-parity.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
PYTHONPATH="$ROOT/python_reference${PYTHONPATH:+:$PYTHONPATH}" \
    "$PYTHON" scripts/check_parallel_row_preparation_parity.py > "$TMP/python.out"
"$BIN" --parity-fixture serial > "$TMP/mojo-serial.out"
"$BIN" --parity-fixture threads > "$TMP/mojo-threads.out"
cmp "$TMP/python.out" "$TMP/mojo-serial.out"
cmp "$TMP/python.out" "$TMP/mojo-threads.out"
printf '%s\n' 'parallel row preparation Python/serial/thread parity: 2 / 2'
