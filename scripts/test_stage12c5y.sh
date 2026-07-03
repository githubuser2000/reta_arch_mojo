#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
mkdir -p target/tests

# Aggregate package import graph and the complete TableOutput owner.
"$MOJO" build -I src src/main.mojo \
    -o target/tests/reta-mojo-native-12c5y
"$MOJO" build -I src src/table_output_main.mojo \
    -o target/tests/reta-mojo-table-output-12c5y
"$MOJO" build -I src tests/test_table_output_complete.mojo \
    -o target/tests/test_table_output_complete_12c5y
./target/tests/test_table_output_complete_12c5y

# Re-run the underlying renderer suite because TableOutput delegates every
# serializer and the public ANSI colour policy to this owner.
"$MOJO" build -I src tests/test_table_rendering.mojo \
    -o target/tests/test_table_rendering_12c5y
./target/tests/test_table_rendering_12c5y

"$TEST_PYTHON" scripts/check_table_output_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/target/tests/reta-mojo-table-output-12c5y"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_table_output_complete_source.py \
    tests/test_all_columns_plan.py \
    tests/test_parameter_runtime_source.py \
    tests/test_mojo_relative_imports.py \
    tests/test_output_syntax_complete_source.py \
    tests/test_install_target_manifest.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5y complete native table-output ownership'
