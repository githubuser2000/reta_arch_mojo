#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
PYTHON=${RETA_REFERENCE_PYTHON:-"$(scripts/select_reference_python.sh)"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_legacy_center.mojo \
    -o target/tests/test_legacy_center_12c5d
./target/tests/test_legacy_center_12c5d

"$MOJO" build -I src tests/test_legacy_lib4tables.mojo \
    -o target/tests/test_legacy_lib4tables_12c5d
./target/tests/test_legacy_lib4tables_12c5d

"$MOJO" build -I src tests/legacy_facades_probe.mojo \
    -o target/tests/legacy_facades_probe
PYTHONDONTWRITEBYTECODE=1 "$PYTHON" scripts/check_legacy_facades_parity.py

python3 tools/generate_unicode_digits.py --check
python3 tools/generate_legacy_help_assets.py --check
python3 -m pytest -q \
    tests/test_legacy_facades_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
printf '%s\n' 'stage12c5d native center/lib4tables facades complete'
