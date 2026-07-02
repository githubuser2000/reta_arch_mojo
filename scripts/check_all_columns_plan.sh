#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-all-columns.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
PYTHONHASHSEED=0 python3 scripts/generate_all_columns_plan.py --emit > "$TMP/all_columns_plan.tsv"
cmp assets/all_columns_plan.tsv "$TMP/all_columns_plan.tsv"
"$ROOT/scripts/run_pytest.sh" -q tests/test_all_columns_plan.py tests/test_native_boundary_audit.py
printf '%s\n' 'Der --alles-Spaltenplan ist reproduzierbar und generate_html besitzt keine Laufzeitbrücke.'
