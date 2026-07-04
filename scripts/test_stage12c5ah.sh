#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

printf '\n== build src/domain_probe_main.mojo ==\n'
"$MOJO" build -I src src/domain_probe_main.mojo \
    -o "$TARGET/reta-mojo-domain-probe-12c5ah"
printf '== parity reta-mojo-domain-probe-12c5ah ==\n'
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$TARGET/reta-mojo-domain-probe-12c5ah"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_do_sh_fail_fast.py \
    tests/test_compile_status_reporting.py \
    tests/test_domain_probe_source.py \
    tests/test_porting_metrics.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5ah fail-fast do.sh and native domain-probe column/html surfaces'
