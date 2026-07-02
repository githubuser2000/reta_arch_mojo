#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

"$MOJO" build --no-optimization -I src tests/test_prompt_language.mojo \
    -o target/tests/test_prompt_language_12c5b
target/tests/test_prompt_language_12c5b

./scripts/check_prompt_language_catalog.sh
./scripts/check_prompt_language_legacy_parity.sh
"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_reference_python_selector.py \
    tests/test_prompt_language_ownership.py \
    tests/test_porting_matrix_ownership.py
printf '%s\n' 'Stage 12c5b PromptLanguage-/PyPy3-Prüfungen bestanden.'
