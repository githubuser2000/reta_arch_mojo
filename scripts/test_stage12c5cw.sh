#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
if [ "${1:-}" = "--" ]; then shift; fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5cv.sh" -- "$@"
fi

printf '\n== current stage source guard normalization ==\n'
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5cw_source.py \
    tests/test_py_reta_truth_native_source.py \
    tests/test_parallel_runtime_boundaries_source.py \
    tests/test_stage12c5ba_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_stage12c5b*_source.py \
    tests/test_stage12c5cv_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5cw current stage source guard normalization complete'
