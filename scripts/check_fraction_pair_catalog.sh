#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-fraction-pairs.$$.tsv
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp assets/fraction_pairs.tsv "$TMP"
env PYTHONHASHSEED=0 python3 scripts/generate_fraction_pair_catalog.py >/dev/null
cmp "$TMP" assets/fraction_pairs.tsv
printf '%s\n' 'Katalog der 71.820 geordneten Bruchrelationen ist reproduzierbar.'
