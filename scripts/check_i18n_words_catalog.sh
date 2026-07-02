#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
PYTHONHASHSEED=0 "$PYTHON" tools/generate_i18n_words_catalog.py --output "$TMP/i18n_words" >/dev/null
for language in deutsch english vietnamese chinese korean; do
    cmp "$TMP/i18n_words/$language.tsv" "assets/i18n_words/$language.tsv"
done
cmp "$TMP/i18n_words/manifest.json" assets/i18n_words/manifest.json
printf '%s\n' 'i18n.words catalog regeneration: 5/5 languages byte-identical'
