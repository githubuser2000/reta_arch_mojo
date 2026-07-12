#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/prompt_completion_batch_probe.mojo -o target/tests/prompt_completion_batch_probe
TMP=${TMPDIR:-/tmp}/reta-prompt-completion-fixtures.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
for language in english deutsch; do
    target/tests/prompt_completion_batch_probe \
        "$language" "tests/fixtures/prompt_completion/$language.tsv" \
        > "$TMP/$language.actual"
    cmp "tests/fixtures/prompt_completion/$language.expected" "$TMP/$language.actual"
done
printf '%s\n' '12 verschachtelte Completion-Fixtures stimmen bytegleich.'
