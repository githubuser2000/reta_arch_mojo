#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=${RETA_REFERENCE_PYTHON:-"$(scripts/select_reference_python.sh)"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_concat_csv.mojo \
    -o target/tests/test_concat_csv_12c5e
./target/tests/test_concat_csv_12c5e

"$MOJO" build -I src tests/test_legacy_lib4tables_concat.mojo \
    -o target/tests/test_legacy_lib4tables_concat_12c5e
./target/tests/test_legacy_lib4tables_concat_12c5e

"$ROOT/scripts/build_concat_csv_probe.sh"
PYTHONDONTWRITEBYTECODE=1 "$PYTHON" scripts/check_concat_csv_parity.py

python3 -m pytest -q \
    tests/test_concat_csv_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py
python3 tools/check_known_defects.py
printf '%s\n' 'stage12c5e native concat CSV and legacy concat facade complete'
