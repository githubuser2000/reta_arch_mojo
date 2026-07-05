#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bh.sh" -- "$@"
fi

printf '\n== build tests/test_native_prompt_input.mojo ==\n'
if mojo_has_thread_option "$@"; then
    "$MOJO" build -I src -I tests tests/test_native_prompt_input.mojo "$@" \
        -o "$TARGET/test_native_prompt_input_12c5bi"
else
    "$MOJO" build -j 4 -I src -I tests tests/test_native_prompt_input.mojo \
        -o "$TARGET/test_native_prompt_input_12c5bi"
fi
printf '== run test_native_prompt_input_12c5bi ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_native_prompt_input_12c5bi"

printf '\n== build tests/test_prompt_table_execution.mojo ==\n'
if mojo_has_thread_option "$@"; then
    "$MOJO" build --no-optimization -I src -I tests \
        tests/test_prompt_table_execution.mojo "$@" \
        -o "$TARGET/test_prompt_table_execution_12c5bi"
else
    "$MOJO" build --no-optimization -j 4 -I src -I tests \
        tests/test_prompt_table_execution.mojo \
        -o "$TARGET/test_prompt_table_execution_12c5bi"
fi
printf '== run test_prompt_table_execution_12c5bi ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_prompt_table_execution_12c5bi"

printf '\n== corrected true-fraction integer/divider runtime parity ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bi_source.py \
    tests/test_stage12c5bh_source.py \
    tests/test_split_test_pipeline.py \
    tests/test_prompt_fraction_integer_axes_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_prompt_historical_ownership_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_reciprocal_collision_source.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bi compiler option forwarding, prompt input String ownership and fraction divider axes complete'
