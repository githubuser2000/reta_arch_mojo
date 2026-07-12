#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

build_and_run() {
    source=$1
    name=$(basename "$source" .mojo)
    "$MOJO" build -I src "$source" -o "target/tests/$name"
    "target/tests/$name"
}

build_and_run tests/test_csv_table.mojo
build_and_run tests/test_prompt_language.mojo
build_and_run tests/test_prompt_runtime.mojo
build_and_run tests/test_prompt_legacy_echo.mojo
build_and_run tests/test_prompt_fraction_execution.mojo
build_and_run tests/test_prompt_table_execution.mojo
build_and_run tests/test_native_reta_cli.mojo
build_and_run tests/test_table_rendering.mojo
./scripts/check_prompt_language_catalog.sh
./scripts/check_prompt_language_legacy_parity.sh
./scripts/check_prompt_fraction_parity.sh
./scripts/check_prompt_execution_fixtures.sh
./scripts/check_prompt_native_oneshot.sh
./scripts/check_prompt_width_oneshot.sh
./scripts/check_prompt_compact_execution_parity.sh
./scripts/check_prompt_numeric_execution_parity.sh
./scripts/check_prompt_numeric_oneshot.sh
./scripts/check_prompt_distance_execution_parity.sh
./scripts/check_prompt_distance_oneshot.sh
./scripts/check_prompt_compact_parity.sh
./scripts/check_prompt_preparation_parity.sh
./scripts/check_prompt_completion_fixtures.sh
./scripts/check_native_io_boundaries.sh
"$ROOT/scripts/require_built_targets.sh" scripts/build.sh reta-prompt-complete
REFERENCE_PYTHON=$("$ROOT/scripts/select_reference_python.sh")
"$REFERENCE_PYTHON" scripts/check_prompt_completion_worker.py
printf '%s\n' 'Stage 10 Prompt-Sprachprüfungen bestanden.'
