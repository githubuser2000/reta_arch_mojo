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
    "$ROOT/scripts/test_stage12c5ew.sh" -- "$@"
fi

printf '\n== prompt execution one-shot local result owner ==\n'
for test_name in prompt_execution prompt_runtime prompt_interaction prompt_legacy_echo prompt_table_execution legacy_mojo_bridge legacy_reta_prompt; do
    printf '\n== build tests/test_%s.mojo ==\n' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@" \
        -o "$TARGET/test_${test_name}_12c5ex"
    printf '== run test_%s_12c5ex ==\n' "$test_name"
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5ex"
done

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5ex_source.py \
    tests/test_stage12c5ew_source.py \
    tests/test_stage12c5ev_source.py \
    tests/test_stage12c5eu_source.py \
    tests/test_stage12c5et_source.py \
    tests/test_stage12c5es_source.py \
    tests/test_stage12c5er_source.py \
    tests/test_stage12c5eq_source.py \
    tests/test_stage12c5ep_source.py \
    tests/test_stage12c5eo_source.py \
    tests/test_stage12c5en_source.py \
    tests/test_stage12c5em_source.py \
    tests/test_stage12c5el_source.py \
    tests/test_stage12c5ek_source.py \
    tests/test_stage12c5ej_source.py \
    tests/test_stage12c5ei_source.py \
    tests/test_stage12c5eh_source.py \
    tests/test_stage12c5eg_source.py \
    tests/test_stage12c5ef_source.py \
    tests/test_stage12c5ee_source.py \
    tests/test_stage12c5ed_source.py \
    tests/test_stage12c5ec_source.py \
    tests/test_stage12c5eb_source.py \
    tests/test_stage12c5ea_source.py \
    tests/test_stage12c5dz_source.py \
    tests/test_stage12c5dy_source.py \
    tests/test_stage12c5dx_source.py \
    tests/test_stage12c5dw_source.py \
    tests/test_stage12c5dv_source.py \
    tests/test_stage12c5du_source.py \
    tests/test_stage12c5dt_source.py \
    tests/test_stage12c5ds_source.py \
    tests/test_stage12c5dr_source.py \
    tests/test_stage12c5dq_source.py \
    tests/test_stage12c5dp_source.py \
    tests/test_stage12c5do_source.py \
    tests/test_stage12c5dn_source.py \
    tests/test_stage12c5dm_source.py \
    tests/test_stage12c5dl_source.py \
    tests/test_stage12c5dk_source.py \
    tests/test_stage12c5dj_source.py \
    tests/test_stage12c5di_source.py \
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
    tests/test_prompt_execution_source.py \
    tests/test_prompt_execution_runtime_source.py \
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
printf '%s\n' 'stage12c5ex prompt execution one-shot local result owner complete'
