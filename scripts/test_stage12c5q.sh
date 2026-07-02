#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_runtime_compat_complete.mojo \
    -o target/tests/test_runtime_compat_complete_12c5q
./target/tests/test_runtime_compat_complete_12c5q

"$MOJO" build -I src tests/test_native_reta_utf8_html.mojo \
    -o target/tests/test_native_reta_utf8_html_12c5q
./target/tests/test_native_reta_utf8_html_12c5q

"$MOJO" build -I src tests/test_table_rendering.mojo \
    -o target/tests/test_table_rendering_12c5q
./target/tests/test_table_rendering_12c5q

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_runtime_compat_complete_source.py \
    tests/test_utf8_rendering_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5q UTF-8-safe rendering and complete native runtime compatibility surface complete'
