#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

printf '\n== generate/check architecture probe assets ==\n'
PYTHONHASHSEED=0 "$REFERENCE_PYTHON" tools/generate_architecture_probe_assets.py --check

printf '\n== build tests/test_architecture_probe_assets.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_architecture_probe_assets.mojo \
    -o "$TARGET/test_architecture_probe_assets_12c5ak"
printf '== run test_architecture_probe_assets_12c5ak ==\n'
"$ROOT/bin/mojo-runtime-exec" "$TARGET/test_architecture_probe_assets_12c5ak"

printf '\n== build src/architecture_probe_main.mojo ==\n'
"$MOJO" build -I src src/architecture_probe_main.mojo \
    -Xlinker -lcrypto \
    -o "$TARGET/reta-mojo-architecture-probe-12c5ak"
printf '== parity reta-mojo-architecture-probe-12c5ak ==\n'
"$TEST_PYTHON" scripts/check_architecture_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$TARGET/reta-mojo-architecture-probe-12c5ak"

printf '\n== build src/domain_probe_main.mojo ==\n'
"$MOJO" build -I src src/domain_probe_main.mojo \
    -o "$TARGET/reta-mojo-domain-probe-12c5ak"
printf '== parity reta-mojo-domain-probe-12c5ak ==\n'
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$TARGET/reta-mojo-domain-probe-12c5ak"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_architecture_probe_assets_source.py \
    tests/test_domain_probe_source.py \
    tests/test_install_target_manifest.py \
    tests/test_stage_build_separation.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ak native architecture/domain probes and portable snapshot assets'
