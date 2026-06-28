#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_ALIAS=${TMPDIR:-/tmp}/reta-kombi-aliases.$$.tsv
TMP_REL=${TMPDIR:-/tmp}/reta-kombi-relations.$$.tsv
trap 'rm -f "$TMP_ALIAS" "$TMP_REL"' EXIT HUP INT TERM
cp assets/kombi_aliases.tsv "$TMP_ALIAS"
cp assets/kombi_relation_order.tsv "$TMP_REL"
PYTHONHASHSEED=0 python3 scripts/generate_kombi_catalogs.py >/dev/null
cmp "$TMP_ALIAS" assets/kombi_aliases.tsv
cmp "$TMP_REL" assets/kombi_relation_order.tsv
[ "$(wc -l < assets/kombi_aliases.tsv)" -eq 173 ]
[ "$(wc -l < assets/kombi_relation_order.tsv)" -eq 151 ]
printf '%s\n' 'Kombi-Alias- und Relationskataloge sind reproduzierbar.'
