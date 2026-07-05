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
    "$ROOT/scripts/test_stage12c5bk.sh" -- "$@"
fi

printf '\n== terminal-independent native representative command parity ==\n'
if [ ! -x "$ROOT/target/bin/reta-native" ]; then
    printf '%s\n' \
        'Fehlendes Produktionsbinary: target/bin/reta-native. Vor dem Stage-Test bitte scripts/build-all.sh ausführen.' >&2
    exit 1
fi
env \
    COLUMNS=197 \
    LINES=71 \
    RETA_ROOT=/__reta_parity_must_ignore__/root \
    RETA_SHARE_DIR=/__reta_parity_must_ignore__/share \
    RETA_DATA_DIR=/__reta_parity_must_ignore__/csv \
    RETA_ASSET_DIR=/__reta_parity_must_ignore__/assets \
    RETA_REFERENCE_DIR=/__reta_parity_must_ignore__/python \
    "$TEST_PYTHON" scripts/check_command_parity_native.py

printf '\n== frozen classic/fraction outer-composition reference ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" scripts/check_prompt_classic_fraction_composition.py

printf '\n== compile/run complete true-fraction and classic composition probe ==\n'
"$ROOT/scripts/check_prompt_true_fraction_multiples.sh" -- "$@"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bl_source.py \
    tests/test_command_parity_environment.py \
    tests/test_stage12c5bk_source.py \
    tests/test_prompt_multi_domain_fraction_source.py \
    tests/test_prompt_fraction_integer_axes_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5bl classic integer and corrected multi-domain fraction composition complete'
