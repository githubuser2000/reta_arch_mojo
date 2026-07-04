#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# Preserve the complete positive-first fraction runtime/parity chain first.
"$ROOT/scripts/test_stage12c5bb.sh"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_installed_launcher_fallback_source.py \
    tests/test_stage12c5bc_source.py \
    tests/test_install_layout.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_stage12c5bb_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bc installed launcher missing-target boundary and positive-first fraction port'
