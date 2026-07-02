#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_csv_table.mojo \
    -o target/tests/test_csv_table_12c5n
./target/tests/test_csv_table_12c5n

"$MOJO" build -I src tests/test_program_workflow.mojo \
    -o target/tests/test_program_workflow_12c5n
RETA_DATA_DIR="$ROOT/tests/fixtures/program_workflow_root/csv" \
    ./target/tests/test_program_workflow_12c5n

"$MOJO" build -I src tests/test_html_class_extractor.mojo \
    -o target/tests/test_html_class_extractor_12c5n
./target/tests/test_html_class_extractor_12c5n

"$MOJO" build -I src src/extract_html_classes_main.mojo \
    -o target/tests/reta-extract-html-classes-12c5n
"$TEST_PYTHON" scripts/check_html_class_extractor_parity.py \
    --binary target/tests/reta-extract-html-classes-12c5n

"$TEST_PYTHON" -m pytest -q \
    tests/test_html_class_extractor_source.py \
    tests/test_documented_python_defects.py \
    tests/test_program_workflow_source.py \
    tests/test_install_target_manifest.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5n CSV quote parity and native HTML class extraction complete'
