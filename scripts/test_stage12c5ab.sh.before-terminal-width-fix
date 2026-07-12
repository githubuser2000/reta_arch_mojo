#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
mkdir -p target/tests

"$MOJO" build -I src tests/test_legacy_lib4tables_prepare.mojo \
    -o target/tests/test_legacy_lib4tables_prepare_12c5ab
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    target/tests/test_legacy_lib4tables_prepare_12c5ab

"$MOJO" build -I src tests/test_legacy_libreta_prompt.mojo \
    -o target/tests/test_legacy_libreta_prompt_12c5ab
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    target/tests/test_legacy_libreta_prompt_12c5ab

"$MOJO" build -I src tests/legacy_libreta_prompt_probe.mojo \
    -o target/tests/legacy_libreta_prompt_probe_12c5ab
"$TEST_PYTHON" scripts/check_legacy_libreta_prompt_parity.py \
    target/tests/legacy_libreta_prompt_probe_12c5ab

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_legacy_lib4tables_prepare_source.py \
    tests/test_legacy_libreta_prompt_source.py \
    tests/test_stage_build_separation.py \
    tests/test_mojo_relative_imports.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5ab prepare regression and native LibRetaPrompt facade complete'
