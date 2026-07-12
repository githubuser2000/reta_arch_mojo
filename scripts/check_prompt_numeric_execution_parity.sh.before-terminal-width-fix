#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
PYTHON=${PYTHON_BIN:-python3}
FIXTURES=tests/fixtures/prompt_numeric_execution
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-numeric-parity.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p target/bin "$FIXTURES"
if [[ ! -x "$PROMPT" ]]; then
    "$MOJO" build -I src src/prompt_main.mojo -o "$PROMPT"
fi

regenerate_case() {
    local label=$1
    shift
    PYTHONHASHSEED=0 "$PYTHON" python_reference/rpb "$@" \
        > "$FIXTURES/$label.expected"
}

check_case() {
    local label=$1
    shift
    if [[ ${RETA_REGENERATE_PROMPT_NUMERIC_FIXTURES:-0} == 1 ]]; then
        regenerate_case "$label" "$@"
    fi
    "$PROMPT" rpb "$@" > "$TMP/$label.mojo"
    if ! cmp "$FIXTURES/$label.expected" "$TMP/$label.mojo"; then
        echo "numeric prompt parity failed: $label ($*)" >&2
        diff -u "$FIXTURES/$label.expected" "$TMP/$label.mojo" \
            | sed -n '1,180p' >&2 || true
        exit 1
    fi
    printf 'numeric prompt parity: %s\n' "$label"
}

check_case number_one 1
check_case number_fifteen 15
check_case number_range 1-3
check_case reciprocal 1/2
check_case proper_fraction 3/2
check_case number_list 2,3
check_case basic_13 15_13 13
check_case multiverse_2 16_2 2
check_case basic_via_16_15 16_15_13 13
check_case set_order 15_5 15_2 15_13 2-3
check_case combined_families 15_13 16_2 2
check_case duplicate_basic_15 15_ 16_15 15

printf '%s\n' 'numeric prompt execution fixtures: 12/12 byte-identical'
