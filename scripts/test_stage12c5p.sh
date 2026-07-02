#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_morphisms.mojo \
    -o target/tests/test_morphisms_12c5p
./target/tests/test_morphisms_12c5p

"$MOJO" build -I src tests/test_morphisms_complete.mojo \
    -o target/tests/test_morphisms_complete_12c5p
./target/tests/test_morphisms_complete_12c5p

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_morphisms_complete_source.py \
    tests/test_test_python_setup.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5p complete native morphism bundle and unified pytest resolver complete'
