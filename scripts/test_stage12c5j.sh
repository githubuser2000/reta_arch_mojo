#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_architecture_exports.mojo \
    -o target/tests/test_architecture_exports_12c5j
./target/tests/test_architecture_exports_12c5j

"$MOJO" build -I src tests/test_architecture_facade.mojo \
    -o target/tests/test_architecture_facade_12c5j
./target/tests/test_architecture_facade_12c5j

python3 -m pytest -q \
    tests/test_architecture_exports_catalog.py \
    tests/test_architecture_facade_source.py \
    tests/test_concat_csv_probe_build_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py \
    tests/test_install_target_manifest.py
python3 tools/check_known_defects.py
printf '%s\n' 'stage12c5j ownership fix and native architecture facade graph complete'
