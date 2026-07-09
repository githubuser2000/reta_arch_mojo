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
    "$ROOT/scripts/test_stage12c5bw.sh" -- "$@"
fi

printf '\n== frozen stored-output addition boundary ==\n'
"$TEST_PYTHON" scripts/check_prompt_storage_output_reference.py

printf '\n== build tests/test_prompt_interaction.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_interaction.mojo "$@" \
    -o "$TARGET/test_prompt_interaction_12c5bx"
printf '== run test_prompt_interaction_12c5bx ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_prompt_interaction_12c5bx"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_stage12c5bx_source.py \
    tests/test_stage12c5bw_source.py \
    tests/test_prompt_interaction_source.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5bx stored-output ownership complete'
