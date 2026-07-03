#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_table_generation_complete.mojo \
    -o target/tests/test_table_generation_complete_12c5u
./target/tests/test_table_generation_complete_12c5u

"$MOJO" build -I src src/table_generation_main.mojo \
    -o target/tests/reta-mojo-table-generation-12c5u
"$TEST_PYTHON" "$ROOT/scripts/check_table_generation_parity.py" \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/target/tests/reta-mojo-table-generation-12c5u"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_table_generation_complete_source.py \
    tests/test_install_target_manifest.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5u native table generation gluing complete'
