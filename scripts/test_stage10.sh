#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests target/bin
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

build_and_run() {
    source=$1
    name=$(basename "$source" .mojo)
    "$MOJO" build -I src "$source" -o "target/tests/$name"
    "target/tests/$name"
}

build_and_run tests/test_prompt_language.mojo
build_and_run tests/test_prompt_runtime.mojo
build_and_run tests/test_prompt_fraction_execution.mojo
./scripts/check_prompt_language_catalog.sh
./scripts/check_prompt_fraction_parity.sh
./scripts/check_prompt_execution_fixtures.sh
./scripts/check_prompt_compact_parity.sh
./scripts/check_prompt_preparation_parity.sh
./scripts/check_prompt_completion_fixtures.sh
if [ ! -x target/bin/reta-prompt-complete ]; then
    "$MOJO" build -I src src/prompt_completion_main.mojo -o target/bin/reta-prompt-complete
fi
.venv/bin/python scripts/check_prompt_completion_worker.py
printf '%s\n' 'Stage 10 Prompt-Sprachprüfungen bestanden.'
