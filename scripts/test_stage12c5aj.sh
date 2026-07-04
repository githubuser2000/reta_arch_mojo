#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Reproduce the locally reported 12c5ah/12c5ai parity failure first.  The
# parameter and pair registries must be sorted exactly like Python's sheaf.
printf '\n== build tests/test_parameter_semantics.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_parameter_semantics.mojo \
    -o "$TARGET/test_parameter_semantics_12c5aj"
printf '== run test_parameter_semantics_12c5aj ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_parameter_semantics_12c5aj"

printf '\n== build src/domain_probe_main.mojo ==\n'
"$MOJO" build -I src src/domain_probe_main.mojo \
    -o "$TARGET/reta-mojo-domain-probe-12c5aj"
printf '== parity reta-mojo-domain-probe-12c5aj ==\n'
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$TARGET/reta-mojo-domain-probe-12c5aj"

# Compile the first explicit native owner extracted from prompt_execution.py.
printf '\n== build tests/test_prompt_execution_helpers.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_execution_helpers.mojo \
    -o "$TARGET/test_prompt_execution_helpers_12c5aj"
printf '== run test_prompt_execution_helpers_12c5aj ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_prompt_execution_helpers_12c5aj"

printf '\n== build tests/test_prompt_execution.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_prompt_execution.mojo \
    -o "$TARGET/test_prompt_execution_12c5aj"
printf '== run test_prompt_execution_12c5aj ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_prompt_execution_12c5aj"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_parameter_semantics_order_source.py \
    tests/test_prompt_execution_helpers_source.py \
    tests/test_prompt_execution_source.py \
    tests/test_domain_probe_source.py \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_do_sh_fail_fast.py \
    tests/test_compile_status_reporting.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5aj canonical parameter order and native prompt-execution facade'
