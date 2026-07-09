#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Reproduce the exact compiler failure reported after stage 12c5af.  The
# input-semantics facade must make the row-range recognizer explicit instead
# of relying on transitive wildcard re-exports, which Mojo does not provide.
printf '\n== build tests/test_input_semantics.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_input_semantics.mojo \
    -o "$TARGET/test_input_semantics_12c5ag"
printf '== run test_input_semantics_12c5ag ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_input_semantics_12c5ag"

# Compile the newly typed architecture registry separately so that metadata
# ownership cannot hide behind the much larger generated-table test target.
printf '\n== build tests/test_generated_columns_registry.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_generated_columns_registry.mojo \
    -o "$TARGET/test_generated_columns_registry_12c5ag"
printf '== run test_generated_columns_registry_12c5ag ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_generated_columns_registry_12c5ag"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_compile_status_reporting.py \
    tests/test_input_semantics_complete_source.py \
    tests/test_generated_columns_registry_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ag compiler visibility repair, status reporting and generated-column registry'
