#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_completion_batch_probe.mojo -o target/tests/prompt_completion_batch_probe
"$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null
python3 "$ROOT/tools/sanitize_mojo_runpath.py" target/tests/prompt_completion_batch_probe >/dev/null
TMP=${TMPDIR:-/tmp}/reta-completion-nested-parity.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
TOTAL=0
for language in deutsch english; do
    contexts="tests/fixtures/prompt_completion_extended/$language.tsv"
    PYTHONHASHSEED=0 python3 scripts/prompt_completion_reference_batch.py \
        "$language" "$contexts" > "$TMP/$language.python"
    target/tests/prompt_completion_batch_probe \
        "$language" "$contexts" > "$TMP/$language.mojo"
    cmp "$TMP/$language.python" "$TMP/$language.mojo"
    COUNT=$(grep -c '^@@@' "$TMP/$language.mojo")
    TOTAL=$((TOTAL + COUNT))
    printf '%-10s %3s verschachtelte Kontexte bytegleich\n' "$language" "$COUNT"
done
printf '%s\n' "Erweiterte Nested-Completion-Parität: $TOTAL/$TOTAL Kontexte."
