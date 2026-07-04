#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

# Reproduce the late full-suite parser failure reported for stage 12c5ag.
# Every test function that uses std.testing or checked indexing is explicitly
# allowed to propagate errors under Mojo 1.0.0b2.
printf '\n== build tests/test_legacy_table_handling.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_legacy_table_handling.mojo \
    -o "$TARGET/test_legacy_table_handling_12c5ai"
printf '== run test_legacy_table_handling_12c5ai ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_legacy_table_handling_12c5ai"

printf '\n== build tests/test_meta_columns_complete.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_meta_columns_complete.mojo \
    -o "$TARGET/test_meta_columns_complete_12c5ai"
printf '== run test_meta_columns_complete_12c5ai ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_meta_columns_complete_12c5ai"

printf '\n== build tests/test_output_semantics_complete.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_output_semantics_complete.mojo \
    -o "$TARGET/test_output_semantics_complete_12c5ai"
printf '== run test_output_semantics_complete_12c5ai ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_output_semantics_complete_12c5ai"

printf '\n== build tests/test_table_generation_complete.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_table_generation_complete.mojo \
    -o "$TARGET/test_table_generation_complete_12c5ai"
printf '== run test_table_generation_complete_12c5ai ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_table_generation_complete_12c5ai"

# Compile the newly native schema serializer independently and compare its
# complete compact JSON snapshot with the frozen Python reference asset.
printf '\n== build tests/test_schema_snapshot.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_schema_snapshot.mojo \
    -o "$TARGET/test_schema_snapshot_12c5ai"
printf '== run test_schema_snapshot_12c5ai ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_schema_snapshot_12c5ai"

printf '\n== build src/domain_probe_main.mojo ==\n'
"$MOJO" build -I src src/domain_probe_main.mojo \
    -o "$TARGET/reta-mojo-domain-probe-12c5ai"
printf '== parity reta-mojo-domain-probe-12c5ai ==\n'
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$TARGET/reta-mojo-domain-probe-12c5ai"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_mojo_test_effect_signatures.py \
    tests/test_schema_snapshot_source.py \
    tests/test_domain_probe_source.py \
    tests/test_do_sh_fail_fast.py \
    tests/test_compile_status_reporting.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ai Mojo test-effect repair and native schema-json snapshot'
