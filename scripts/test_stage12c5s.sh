#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_native_reta_utf8_html.mojo \
    -o target/tests/test_native_reta_utf8_html_12c5s
./target/tests/test_native_reta_utf8_html_12c5s

"$MOJO" build -I src tests/test_legacy_table_handling.mojo \
    -o target/tests/test_legacy_table_handling_12c5s
./target/tests/test_legacy_table_handling_12c5s

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5s_source.py \
    tests/test_utf8_rendering_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5s stale-binary guard, UTF-8 HTML hardening and native tableHandling facade complete'
