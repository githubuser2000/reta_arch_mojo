#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-parameter-aliases.$$.tsv
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp assets/parameter_aliases.tsv "$TMP"
python3 tools/generate_runtime_alias_catalog.py >/dev/null
cmp "$TMP" assets/parameter_aliases.tsv
printf '%s\n' 'Deutscher/englischer Laufzeit-Aliaskatalog ist reproduzierbar.'
