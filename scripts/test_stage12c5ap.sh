#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the complete program/setup ownership stage and its repaired
# List[String] parameter-runtime contract.
"$ROOT/scripts/test_stage12c5ao.sh"

printf '\n== build tests/test_py_reta_truth_native.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_py_reta_truth_native.mojo \
    -o "$TARGET/test_py_reta_truth_native_12c5ap"
printf '== run test_py_reta_truth_native_12c5ap ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_py_reta_truth_native_12c5ap"

printf '\n== regenerate porting matrix ==\n'
PYTHONDONTWRITEBYTECODE=1 "$TEST_PYTHON" tools/generate_porting_matrix.py

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_py_reta_truth_native_source.py \
    tests/test_parameter_runtime_complete_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_legacy_mojo_bridge_source.py \
    tests/test_legacy_reta_prompt_source.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ap native Py-Reta truth matrix and output invariants complete'
