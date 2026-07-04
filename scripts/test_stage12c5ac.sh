#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# First compile the exact value-type/list assertion that failed in 12c5ab.
"$MOJO" build -I src tests/test_legacy_libreta_prompt.mojo \
    -o target/tests/test_legacy_libreta_prompt_12c5ac
"$ROOT/bin/mojo-runtime-exec" \
    target/tests/test_legacy_libreta_prompt_12c5ac

# Then compile the completed prompt-preparation facade and its legacy aliases.
"$MOJO" build -I src tests/test_prompt_preparation.mojo \
    -o target/tests/test_prompt_preparation_12c5ac
"$ROOT/bin/mojo-runtime-exec" \
    target/tests/test_prompt_preparation_12c5ac

scripts/check_prompt_preparation_legacy_parity.sh
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_preparation_source.py \
    tests/test_legacy_libreta_prompt_source.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5ac Mojo trait regression and native prompt-preparation facade complete'
