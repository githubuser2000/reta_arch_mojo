#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
mkdir -p target/tests

"$MOJO" build -I src tests/test_legacy_lib4tables_prepare.mojo \
    -o target/tests/test_legacy_lib4tables_prepare_12c5aa
"$ROOT/bin/mojo-runtime-exec" \
    target/tests/test_legacy_lib4tables_prepare_12c5aa

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_lib4tables_prepare_source.py \
    tests/test_stage_build_separation.py \
    tests/test_install_target_manifest.py \
    tests/test_mojo_relative_imports.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5aa native legacy prepare facade complete'
