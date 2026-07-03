#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
mkdir -p target/tests

# Compile the same aggregate import graph that failed in the user's build.
"$MOJO" build -I src src/main.mojo \
    -o target/tests/reta-mojo-native-12c5x
"$MOJO" build -I src src/table_generation_main.mojo \
    -o target/tests/reta-mojo-table-generation-12c5x

"$MOJO" build -I src tests/test_console_io_complete.mojo \
    -o target/tests/test_console_io_complete_12c5x
./target/tests/test_console_io_complete_12c5x

"$MOJO" build -I src src/console_io_main.mojo \
    -o target/tests/reta-mojo-console-io-12c5x
"$TEST_PYTHON" scripts/check_console_io_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/target/tests/reta-mojo-console-io-12c5x"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_mojo_relative_imports.py \
    tests/test_table_generation_complete_source.py \
    tests/test_console_io_complete_source.py \
    tests/test_install_target_manifest.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5x module-import repair and complete native console-io ownership'
