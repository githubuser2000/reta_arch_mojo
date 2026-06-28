#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-table-runtime.$$.mojo
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp tests/test_generated_table_runtime_parity.mojo "$TMP" 2>/dev/null || true
python3 tools/generate_table_runtime_parity.py >/dev/null
if [ -s "$TMP" ]; then
    cmp "$TMP" tests/test_generated_table_runtime_parity.mojo
fi
"$ROOT/bin/mojo-real" run -I src -I tests tests/test_generated_table_runtime_parity.mojo
printf '%s\n' 'Tabellenzustand, Umbruch und Ausgabe-Modi stimmen mit der Python-Referenz überein.'
