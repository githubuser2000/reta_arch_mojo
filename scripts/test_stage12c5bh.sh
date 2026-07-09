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
    "$ROOT/scripts/test_stage12c5bg.sh"
fi

printf '\n== check pinned deterministic command parity assets ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_command_parity_assets.py --check

printf '\n== build tests/test_prompt_table_execution.mojo ==\n'
if mojo_has_thread_option "$@"; then
    "$MOJO" build --no-optimization -I src -I tests \
        tests/test_prompt_table_execution.mojo "$@" \
        -o "$TARGET/test_prompt_table_execution_12c5bh"
else
    "$MOJO" build --no-optimization -j 4 -I src -I tests \
        tests/test_prompt_table_execution.mojo \
        -o "$TARGET/test_prompt_table_execution_12c5bh"
fi
printf '== run test_prompt_table_execution_12c5bh ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    "$TARGET/test_prompt_table_execution_12c5bh"

printf '\n== zero/exclusion true-fraction runtime parity ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_split_test_pipeline.py \
    tests/test_command_parity_asset_environment.py \
    tests/test_command_parity_native_source.py \
    tests/test_prompt_fraction_integer_axes_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_prompt_historical_ownership_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_reciprocal_collision_source.py \
    tests/test_stage12c5bh_source.py \
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
    'stage12c5bh split test pipeline, legacy asset migration and non-positive fraction axes complete'
