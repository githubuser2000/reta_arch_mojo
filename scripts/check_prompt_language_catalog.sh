#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/reta-prompt-language-catalog.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
# Diese Snapshot-Dateien bilden absichtlich die stabile CPython-Reihenfolge ab.
# PyPy enthält dieselben Werte, ordnet jedoch set-basierte Teilfolgen anders.
# Ein expliziter Override bleibt für Diagnosezwecke möglich.
PYTHON=${RETA_PROMPT_CATALOG_PYTHON:-python3}
command -v "$PYTHON" >/dev/null 2>&1 || {
    printf 'Prompt-Kataloginterpreter ist nicht ausführbar: %s\n' "$PYTHON" >&2
    exit 127
}
RETA_PROMPT_CATALOG_OUT="$TMP" PYTHONHASHSEED=0 \
    "$PYTHON" scripts/generate_prompt_nested_catalog.py >/dev/null
PYTHONHASHSEED=0 "$PYTHON" tools/generate_prompt_language_legacy_catalog.py \
    --output "$TMP/prompt_language_legacy.tsv" >/dev/null
for name in \
    prompt_nested_completion.tsv \
    prompt_command_aliases.tsv \
    prompt_shortcut_replacements.tsv \
    prompt_numeric_shortcuts.tsv \
    prompt_vocabulary.tsv \
    prompt_preparation_domains.tsv \
    prompt_language_legacy.tsv
do
    cmp "assets/$name" "$TMP/$name"
done
printf '%s\n' 'Mehrsprachiger Prompt-Katalog ist reproduzierbar.'
