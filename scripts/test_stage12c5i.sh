#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

./bin/mojo-real run -I src tests/test_table_adapters.mojo
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_table_adapters_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_architecture_exports_catalog.py \
    tests/test_install_target_manifest.py \
    tests/test_install_layout.py \
    tests/test_known_defects.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5i native architecture table adapters complete'
