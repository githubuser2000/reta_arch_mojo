#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
mkdir -p target/tests

# Reproduce the user's failing import graph first.  This catches reserved Mojo
# identifiers in modules re-exported by reta_mojo/__init__.mojo.
"$MOJO" build -I src src/main.mojo \
    -o target/tests/reta-mojo-native-12c5w

"$MOJO" build -I src tests/test_input_semantics.mojo \
    -o target/tests/test_input_semantics_12c5w
./target/tests/test_input_semantics_12c5w

"$MOJO" build -I src src/schema_main.mojo \
    -o target/tests/reta-mojo-schema-12c5w
"$TEST_PYTHON" "$ROOT/scripts/check_input_semantics_parity.py" \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/target/tests/reta-mojo-schema-12c5w"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_input_semantics_complete_source.py \
    tests/test_concat_csv_source.py \
    tests/test_output_syntax_complete_source.py \
    tests/test_install_target_manifest.py \
    tests/test_install_layout.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
# Keep every source-only contract portable, not only the files changed here.
"$ROOT/scripts/run_pytest.sh" -q tests/test_*source.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5w compiler repair and complete native input semantics ownership'
