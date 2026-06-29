#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
PYTHON=${PYTHON_BIN:-python3}
FIXTURES=tests/fixtures/prompt_distance_execution
TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-prompt-distance-parity.XXXXXX")
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
    if [[ ${RETA_REGENERATE_PROMPT_DISTANCE_FIXTURES:-0} == 1 ]]; then
        regenerate_case "$label" "$@"
    fi
    timeout --kill-after=10s 300s "$PROMPT" rpb "$@" </dev/null \
        > "$TMP/$label.mojo"
    if ! cmp "$FIXTURES/$label.expected" "$TMP/$label.mojo"; then
        echo "distance prompt parity failed: $label ($*)" >&2
        diff -u "$FIXTURES/$label.expected" "$TMP/$label.mojo" \
            | sed -n '1,180p' >&2 || true
        exit 1
    fi
    printf 'distance prompt parity: %s\n' "$label"
}

check_case three_ranges abstand 1-2 5-6 10-11
check_case three_ranges_prime abstandPrim 1-2 5-6 10-11
check_case duplicate_ranges abstand 1-2 1-2 5-6
check_case mixed_cardinality abstand 1-3 5 8-9
check_case six_scalars abstand 1 2 3 4 5 6
check_case nine_scalars abstand 1 2 3 4 5 6 7 8 9
check_case missing_normal abstand 1
check_case missing_prime abstandPrim 1

printf '%s\n' 'distance prompt execution fixtures: 8/8 byte-identical'
