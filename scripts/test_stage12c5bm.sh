#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
if [ "${1:-}" = "--" ]; then
    shift
fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5bl.sh" -- "$@"
fi

printf '\n== frozen multi-domain property/numeric outer order ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" scripts/check_prompt_multi_domain_extensions_reference.py

printf '\n== compile/run complete multi-domain property/numeric fraction probe ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bm_source.py \
    tests/test_prompt_multi_domain_extensions_source.py \
    tests/test_stage12c5bl_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_prompt_fraction_integer_axes_source.py \
    tests/test_prompt_positive_first_fraction_multiple_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bm multi-domain property and numeric fraction axes complete'
