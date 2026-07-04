#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve every preceding compiler/runtime and static ownership gate first.
"$ROOT/scripts/test_stage12c5aw.sh"

printf '\n== build tests/test_prompt_historical_ownership.mojo ==\n'
"$MOJO" build -I src -I tests \
    tests/test_prompt_historical_ownership.mojo \
    -o "$TARGET/test_prompt_historical_ownership_12c5ax"
printf '== run test_prompt_historical_ownership_12c5ax ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_prompt_historical_ownership_12c5ax"

"$ROOT/scripts/check_prompt_historical_families_parity.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_historical_ownership_source.py \
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
    'stage12c5ax native historical compact prompt table families'
