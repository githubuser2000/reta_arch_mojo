#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp assets/html_cell_catalog.tsv "$TMP"
python3 scripts/generate_html_cell_catalog.py >/dev/null
cmp "$TMP" assets/html_cell_catalog.tsv
printf '%s\n' 'HTML-Zellmetadaten reproduzierbar (1496 Einträge).'
