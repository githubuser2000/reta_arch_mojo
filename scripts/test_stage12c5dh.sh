#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"
if [ "${1:-}" = "--" ]; then shift; fi
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != 1 ]; then
    "$ROOT/scripts/test_stage12c5dg.sh" -- "$@"
fi

printf '\n== prompt external shell argv plan ==\n'
for test_name in prompt_interaction prompt_external_commands legacy_mojo_bridge legacy_reta_prompt; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5dh"
    printf '== run test_%s_12c5dh ==\n' "$test_name"
    "$ROOT/bin/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5dh"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5dh_source.py \
    tests/test_stage12c5dg_source.py \
    tests/test_stage12c5df_source.py \
    tests/test_stage12c5de_source.py \
    tests/test_stage12c5dd_source.py \
    tests/test_stage12c5dc_source.py \
    tests/test_stage12c5db_source.py \
    tests/test_stage12c5da_source.py \
    tests/test_stage12c5cz_source.py \
    tests/test_stage12c5cy_source.py \
    tests/test_stage12c5cx_source.py \
    tests/test_stage12c5cu_source.py \
    tests/test_stage12c5cv_source.py \
    tests/test_prompt_interaction_source.py \
    tests/test_prompt_external_source.py \
    tests/test_legacy_reta_prompt_source.py \
    tests/test_legacy_mojo_bridge_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5dh prompt external shell argv plan complete'
