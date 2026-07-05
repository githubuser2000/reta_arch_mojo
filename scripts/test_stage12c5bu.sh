#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
PROMPT=${RETA_PROMPT_NATIVE:-"$ROOT/target/bin/reta-prompt-native"}
mkdir -p "$TARGET" "$(dirname "$PROMPT")"
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bt.sh" -- "$@"
fi

printf '\n== frozen compound-clear effect order and line count ==\n'
"$TEST_PYTHON" scripts/check_prompt_companion_effects.py

printf '\n== build tests/test_prompt_historical_ownership.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_historical_ownership.mojo "$@" \
    -o "$TARGET/test_prompt_historical_ownership_12c5bu"
printf '== run test_prompt_historical_ownership_12c5bu ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_prompt_historical_ownership_12c5bu"

printf '\n== build tests/test_terminal_geometry.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_terminal_geometry.mojo "$@" \
    -o "$TARGET/test_terminal_geometry_12c5bu"
printf '== run test_terminal_geometry_12c5bu ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_terminal_geometry_12c5bu"

if [ ! -x "$PROMPT" ]; then
    printf '\n== build src/prompt_main.mojo ==\n'
    "$MOJO" build -I src src/prompt_main.mojo "$@" -o "$PROMPT"
fi
printf '\n== native compound clear runtime ==\n'
RETA_PROMPT_NATIVE="$PROMPT" \
    "$TEST_PYTHON" scripts/check_prompt_compound_clear_native.py

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bu_source.py \
    tests/test_terminal_geometry_source.py \
    tests/test_prompt_companion_effects_source.py \
    tests/test_prompt_historical_ownership_source.py \
    tests/test_stage12c5bt_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5bu native compound clear complete'
