#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5br.sh" -- "$@"
fi

printf '\n== frozen position-independent prompt effects ==\n'
"$TEST_PYTHON" scripts/check_prompt_position_independent_effects.py

printf '\n== build tests/test_prompt_runtime.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_runtime.mojo "$@" \
    -o "$TARGET/test_prompt_runtime_12c5bs"
printf '== run test_prompt_runtime_12c5bs ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_prompt_runtime_12c5bs"

printf '\n== build tests/test_prompt_historical_ownership.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_historical_ownership.mojo "$@" \
    -o "$TARGET/test_prompt_historical_ownership_12c5bs"
printf '== run test_prompt_historical_ownership_12c5bs ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_prompt_historical_ownership_12c5bs"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bs_source.py \
    tests/test_prompt_position_independent_effects_source.py \
    tests/test_prompt_historical_ownership_source.py \
    tests/test_stage12c5br_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bs position-independent abc and logging effects complete'
