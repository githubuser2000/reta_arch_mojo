#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-generated-aliases.$$.tsv
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp assets/generated_aliases.tsv "$TMP"
python3 scripts/generate_generated_aliases.py >/dev/null
cmp "$TMP" assets/generated_aliases.tsv
printf '%s\n' 'Nichtstandard-Aliaskatalog ist reproduzierbar (Last-write-wins).'
