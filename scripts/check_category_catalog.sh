#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-category-catalog.$$.mojo
trap 'rm -f "$TMP"' EXIT HUP INT TERM
cp src/reta_mojo/category_theory.mojo "$TMP"
python3 tools/generate_category_theory.py --reference-root python_reference --output src/reta_mojo/category_theory.mojo >/dev/null
cmp "$TMP" src/reta_mojo/category_theory.mojo
printf '%s\n' 'Großer Kategorien-/Funktorenkatalog ist reproduzierbar.'
