#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")

# Recompile the previously failing runtime-owner test.  Explicit imports keep
# Python-style underscore helpers out of wildcard-import ambiguity.
"$MOJO" build -I src tests/test_table_runtime_complete.mojo \
    -o target/tests/test_table_runtime_complete_12c5ae
"$ROOT/bin/mojo-runtime-exec" target/tests/test_table_runtime_complete_12c5ae

# Compile the now-complete typed ProgramWorkflow owner and run it against the
# small deterministic CSV fixture instead of the full production data set.
"$MOJO" build -I src tests/test_program_workflow.mojo \
    -o target/tests/test_program_workflow_12c5ae
RETA_DATA_DIR="$ROOT/tests/fixtures/program_workflow_root/csv" \
    "$ROOT/bin/mojo-runtime-exec" target/tests/test_program_workflow_12c5ae

# Rebuild the diagnostic main so the package export and all new methods are
# parsed and type-checked by the real Mojo compiler.
"$MOJO" build -I src src/program_workflow_main.mojo \
    -o target/tests/reta-mojo-workflow-12c5ae
"$TEST_PYTHON" scripts/check_program_workflow_parity.py \
    --binary target/tests/reta-mojo-workflow-12c5ae

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_test_all_link_flags.py \
    tests/test_table_runtime_complete_source.py \
    tests/test_program_workflow_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_mojo_relative_imports.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5ae complete native program workflow and full-test linker contracts'
