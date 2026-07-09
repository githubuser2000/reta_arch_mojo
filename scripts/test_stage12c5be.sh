#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Preserve the complete current-stage chain by default.  During diagnosis of
# this exact workflow repair, RETA_STAGE_SKIP_PREVIOUS=1 may be used to execute
# only the two compiler targets below.
if [ "${RETA_STAGE_SKIP_PREVIOUS:-0}" != "1" ]; then
    "$ROOT/scripts/test_stage12c5bd.sh"
fi

printf '\n== build tests/test_program_workflow.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_program_workflow.mojo \
    -o "$TARGET/test_program_workflow_12c5be"
printf '== run test_program_workflow_12c5be ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_program_workflow_12c5be"

printf '\n== build src/program_workflow_main.mojo ==\n'
"$MOJO" build -I src src/program_workflow_main.mojo \
    -o "$TARGET/reta-mojo-workflow-12c5be"
"$TEST_PYTHON" scripts/check_program_workflow_parity.py \
    --binary "$TARGET/reta-mojo-workflow-12c5be"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_program_workflow_source.py \
    tests/test_stage12c5be_source.py \
    tests/test_mojo_relative_imports.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' \
    'stage12c5be workflow root ownership and rich output synchronization complete'
