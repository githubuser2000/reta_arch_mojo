#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the generated-native command parity and every earlier owner.
"$ROOT/scripts/test_stage12c5aq.sh"

printf '\n== regenerate/check exact architecture-refactor contract inventory ==\n'
PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_architecture_refactor_contracts.py --check

printf '\n== build tests/test_architecture_refactor_native.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_architecture_refactor_native.mojo \
    -o "$TARGET/test_architecture_refactor_native_12c5ar"
printf '== run test_architecture_refactor_native_12c5ar ==\n'
"$ROOT/bin/mojo-runtime-exec" \
    "$TARGET/test_architecture_refactor_native_12c5ar"

printf '\n== regenerate porting matrix ==\n'
PYTHONDONTWRITEBYTECODE=1 "$TEST_PYTHON" tools/generate_porting_matrix.py

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_architecture_refactor_native_source.py \
    tests/test_command_parity_native_source.py \
    tests/test_py_reta_truth_native_source.py \
    tests/test_parameter_runtime_complete_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ar generated-native architecture-refactor regression inventory complete'
