#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve every previous compiler/runtime and static ownership gate first.
"$ROOT/scripts/test_stage12c5ay.sh"

printf '\n== build tests/test_prompt_table_execution.mojo ==\n'
"$MOJO" build --no-optimization -j 4 -I src -I tests \
    tests/test_prompt_table_execution.mojo \
    -o "$TARGET/test_prompt_table_execution_12c5az"
printf '== run test_prompt_table_execution_12c5az ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_prompt_table_execution_12c5az"

"$ROOT/scripts/check_prompt_true_fraction_multiples.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_mixed_fraction_multiple_source.py \
    tests/test_prompt_execution_source.py \
    tests/test_prompt_execution_runtime_source.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5az mixed reciprocal and true-fraction multiple axes'
