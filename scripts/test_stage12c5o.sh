#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_meta_columns.mojo \
    -o target/tests/test_meta_columns_12c5o
./target/tests/test_meta_columns_12c5o

"$MOJO" build -I src tests/test_prime_effect_columns.mojo \
    -o target/tests/test_prime_effect_columns_12c5o
./target/tests/test_prime_effect_columns_12c5o

"$MOJO" build -I src tests/test_meta_columns_complete.mojo \
    -o target/tests/test_meta_columns_complete_12c5o
./target/tests/test_meta_columns_complete_12c5o

"$TEST_PYTHON" -m pytest -q \
    tests/test_meta_columns_complete_source.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5o native meta-columns surface and exact fraction catalog complete'
