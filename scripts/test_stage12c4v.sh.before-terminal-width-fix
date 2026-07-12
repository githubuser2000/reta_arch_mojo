#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

build_run() {
    source=$1
    output=$2
    "$MOJO" build -I src "$source" -o "target/tests/$output"
    "target/tests/$output"
}

build_run tests/test_prompt_runtime.mojo test_prompt_runtime_12c4v
build_run tests/test_prompt_session.mojo test_prompt_session_12c4v
build_run tests/test_prompt_runtime_contract.mojo test_prompt_runtime_contract_12c4v
build_run tests/test_native_prompt_input.mojo test_native_prompt_input_12c4v

scripts/check_prompt_session_parity.sh
scripts/check_prompt_runtime_catalog.sh
scripts/check_prompt_runtime_parity.sh
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_prompt_session_source.py \
    tests/test_known_defects.py \
    tests/test_prompt_external_source.py \
    tests/test_prompt_native_input_source.py \
    tests/test_completion_native_ownership.py \
    tests/test_native_boundary_audit.py \
    tests/test_install_layout.py \
    tests/test_prompt_fixture_integrity.py \
    tests/test_sanitize_mojo_runpath.py
python3 tools/check_known_defects.py

if [ -x target/bin/reta-prompt-native ]; then
    scripts/check_prompt_session_pty_prefix.py target/bin/reta-prompt-native
fi
