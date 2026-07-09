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
    "$ROOT/scripts/test_stage12c5cr.sh" -- "$@"
fi

printf '
== legacy bridge reta argument ownership ==
'
for test_name in legacy_mojo_bridge prompt_interaction legacy_reta_prompt; do
    printf '
== build tests/test_%s.mojo ==
' "$test_name"
    "$MOJO" build -I src -I tests "tests/test_${test_name}.mojo" "$@"         -o "$TARGET/test_${test_name}_12c5cs"
    printf '== run test_%s_12c5cs ==
' "$test_name"
    "$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_${test_name}_12c5cs"
done

"$ROOT/scripts/run_pytest.sh" -q     tests/test_stage12c5cs_source.py     tests/test_stage12c5cr_source.py     tests/test_stage12c5cq_source.py     tests/test_stage12c5cp_source.py     tests/test_stage12c5co_source.py     tests/test_stage12c5cn_source.py     tests/test_stage12c5cm_source.py     tests/test_stage12c5cl_source.py     tests/test_stage12c5ck_source.py     tests/test_stage12c5cj_source.py     tests/test_stage12c5ci_source.py     tests/test_stage12c5ch_source.py     tests/test_stage12c5cg_source.py     tests/test_stage12c5cf_source.py     tests/test_stage12c5ce_source.py     tests/test_stage12c5cd_source.py     tests/test_stage12c5cc_source.py     tests/test_prompt_external_source.py     tests/test_prompt_interaction_source.py     tests/test_prompt_companion_effects_source.py     tests/test_prompt_historical_ownership_source.py     tests/test_table_adapters_source.py     tests/test_known_defects.py     tests/test_documented_python_defects.py     tests/test_porting_metrics.py     tests/test_porting_matrix_ownership.py     tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s
' 'stage12c5cs legacy bridge reta argument ownership complete'
