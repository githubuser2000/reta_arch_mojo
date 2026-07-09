#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the repaired parameter-runtime contract and native Py-Reta truths.
"$ROOT/scripts/test_stage12c5ap.sh"

printf '\n== verify original/refactored Python command matrix ==\n'
"$ROOT/scripts/run_pytest.sh" -q python_reference/tests/test_command_parity.py

printf '\n== check pinned native command parity assets ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_command_parity_assets.py --check

printf '\n== build tests/test_command_parity_native.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_command_parity_native.mojo \
    -o "$TARGET/test_command_parity_native_12c5aq"
printf '== run test_command_parity_native_12c5aq ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_command_parity_native_12c5aq"

if [ ! -x "$ROOT/target/bin/reta-native" ]; then
    printf '%s\n' \
        'Fehlendes Produktionsbinary: target/bin/reta-native. Vor dem Stage-Test bitte scripts/build.sh oder scripts/build-all.sh ausführen.' >&2
    exit 1
fi
printf '\n== native representative command parity ==\n'
"$TEST_PYTHON" scripts/check_command_parity_native.py

printf '\n== regenerate porting matrix ==\n'
PYTHONDONTWRITEBYTECODE=1 "$TEST_PYTHON" tools/generate_porting_matrix.py

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_command_parity_native_source.py \
    tests/test_py_reta_truth_native_source.py \
    tests/test_parameter_runtime_complete_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5aq generated-native representative command parity complete'
