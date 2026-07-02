#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_presheaves_complete.mojo \
    -o target/tests/test_presheaves_complete_12c5t
./target/tests/test_presheaves_complete_12c5t

"$MOJO" build -I src tests/test_sheaves_complete.mojo \
    -o target/tests/test_sheaves_complete_12c5t
./target/tests/test_sheaves_complete_12c5t

"$MOJO" build -I src src/sheaves_main.mojo \
    -o target/tests/reta-mojo-sheaves-12c5t
"$TEST_PYTHON" "$ROOT/scripts/check_presheaf_sheaf_parity.py" \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/target/tests/reta-mojo-sheaves-12c5t"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5t_source.py \
    tests/test_install_target_manifest.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5t native presheaves and sheaves complete'
