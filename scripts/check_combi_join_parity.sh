#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PYTHON=${RETA_REFERENCE_PYTHON:-"$(scripts/select_reference_python.sh)"}
TMP=${TMPDIR:-/tmp}/reta-combi-join-parity-$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
PYTHONDONTWRITEBYTECODE=1 PYTHONHASHSEED=0 "$PYTHON" \
    tools/probe_combi_join_reference.py > "$TMP/python.lines"
./bin/mojo-real run -I src tests/probe_combi_join.mojo > "$TMP/mojo.lines"
diff -u "$TMP/python.lines" "$TMP/mojo.lines"
printf '%s\n' 'KombiJoin Python↔Mojo: 15/15 stabile Zeilen identisch'
