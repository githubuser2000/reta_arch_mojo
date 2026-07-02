#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p target/tests

"$MOJO" build -I src tests/test_program_workflow.mojo \
    -o target/tests/test_program_workflow_12c5m
RETA_DATA_DIR="$ROOT/tests/fixtures/program_workflow_root/csv" \
    ./target/tests/test_program_workflow_12c5m

"$MOJO" build -I src src/program_workflow_main.mojo \
    -o target/tests/reta-mojo-workflow-12c5m
"$TEST_PYTHON" scripts/check_program_workflow_parity.py \
    --binary target/tests/reta-mojo-workflow-12c5m

"$MOJO" build -I src src/domain_probe_main.mojo \
    -o target/tests/reta-mojo-domain-probe-12c5m
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary target/tests/reta-mojo-domain-probe-12c5m

"$TEST_PYTHON" -m pytest -q \
    tests/test_program_workflow_source.py \
    tests/test_domain_probe_source.py \
    tests/test_test_python_setup.py \
    tests/test_mojo_resolver_source.py \
    tests/test_project_content_profiles.py \
    tests/test_architecture_facade_source.py \
    tests/test_architecture_exports_catalog.py \
    tests/test_concat_csv_probe_build_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py \
    tests/test_install_target_manifest.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'stage12c5m workflow precedence, pytest environment, and native domain probe core complete'
