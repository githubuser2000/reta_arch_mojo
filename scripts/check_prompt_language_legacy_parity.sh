#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
PROBE="$ROOT/target/tests/prompt_language_legacy_probe"
mkdir -p "$ROOT/target/tests"
"$MOJO" build --no-optimization -I src tests/prompt_language_legacy_probe.mojo -o "$PROBE"
TMP=${TMPDIR:-/tmp}/reta-prompt-language-legacy.$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
for language in deutsch english vietnamese chinese korean; do
    PYTHONHASHSEED=0 PYTHONPATH="$ROOT/python_reference" \
        "$PYTHON" scripts/prompt_language_legacy_reference.py "$language" \
        > "$TMP/$language.python"
    "$PROBE" "$language" > "$TMP/$language.mojo"
    if ! cmp "$TMP/$language.python" "$TMP/$language.mojo"; then
        diff -u "$TMP/$language.python" "$TMP/$language.mojo" || true
        exit 1
    fi
    printf '%-12s %2s prompt-language legacy records byte-identical\n' \
        "$language" "$(wc -l < "$TMP/$language.mojo" | tr -d ' ')"
done
printf '%s\n' 'Historische PromptLanguageBundle-Oberfläche ist in 5 Sprachen bytegleich.'
