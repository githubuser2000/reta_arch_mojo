#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# Compile the complete native table-preparation owner surface.
"$MOJO" build -I src tests/test_table_preparation_complete.mojo \
    -o target/tests/test_table_preparation_complete_12c5ad
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    target/tests/test_table_preparation_complete_12c5ad

# Compile one small snapshot probe and compare it with the Python reference.
"$MOJO" build -I src tests/table_preparation_complete_probe.mojo \
    -o target/tests/table_preparation_complete_probe_12c5ad
"$TEST_PYTHON" scripts/check_table_preparation_complete_parity.py \
    --python "$TEST_PYTHON" \
    --binary target/tests/table_preparation_complete_probe_12c5ad

if command -v pypy3 >/dev/null 2>&1; then
    "$TEST_PYTHON" scripts/check_table_preparation_complete_parity.py \
        --python "$(command -v pypy3)" \
        --binary target/tests/table_preparation_complete_probe_12c5ad
fi

# Compile the complete Tables/TableRuntimeBundle owner and its snapshot probe.
"$MOJO" build -I src tests/test_table_runtime_complete.mojo \
    -o target/tests/test_table_runtime_complete_12c5ad
"$ROOT/tools/wrappers/mojo-runtime-exec" \
    target/tests/test_table_runtime_complete_12c5ad

"$MOJO" build -I src tests/table_runtime_complete_probe.mojo \
    -o target/tests/table_runtime_complete_probe_12c5ad
"$TEST_PYTHON" scripts/check_table_runtime_complete_parity.py \
    --python "$TEST_PYTHON" \
    --binary target/tests/table_runtime_complete_probe_12c5ad

if command -v pypy3 >/dev/null 2>&1; then
    "$TEST_PYTHON" scripts/check_table_runtime_complete_parity.py \
        --python "$(command -v pypy3)" \
        --binary target/tests/table_runtime_complete_probe_12c5ad
fi

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_table_preparation_complete_source.py \
    tests/test_table_runtime_complete_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_mojo_relative_imports.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5ad complete native table-preparation and table-runtime owners'
