#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

./bin/mojo-real run -I src tests/test_combi_join.mojo
scripts/check_combi_join_parity.sh
python3 -m pytest -q \
    tests/test_combi_join_source.py \
    tests/test_middle_alx_compare.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py
printf '%s\n' 'stage12c5g native Kombi join and unordered middle.alx parity complete'
