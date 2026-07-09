#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != "1" ]; then
    "$ROOT/scripts/test_stage12c5bf.sh"
fi

printf '\n== deterministic generated command parity assets ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_command_parity_assets.py --check

if [ ! -x "$ROOT/target/bin/reta-native" ]; then
    printf '%s\n' \
        'Fehlendes Produktionsbinary: target/bin/reta-native. Vor dem Stage-Test bitte scripts/build-all.sh ausführen.' >&2
    exit 1
fi
printf '\n== native representative command parity ==\n'
"$TEST_PYTHON" scripts/check_command_parity_native.py

printf '\n== build tests/test_prompt_table_execution.mojo ==\n'
"$MOJO" build --no-optimization -j 4 -I src -I tests \
    tests/test_prompt_table_execution.mojo \
    -o "$TARGET/test_prompt_table_execution_12c5bg"
printf '== run test_prompt_table_execution_12c5bg ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    "$TARGET/test_prompt_table_execution_12c5bg"

printf '\n== positive integer/fraction-axis runtime parity ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_command_parity_asset_environment.py \
    tests/test_command_parity_native_source.py \
    tests/test_prompt_fraction_integer_axes_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_prompt_historical_ownership_source.py \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_prompt_reciprocal_collision_source.py \
    tests/test_stage12c5bg_source.py \
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
    'stage12c5bg deterministic command parity and positive integer/fraction axes complete'
