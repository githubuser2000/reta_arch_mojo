#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}

"$MOJO" build -I src tests/test_prompt_preparation.mojo \
    -o target/tests/test_prompt_preparation_12c4w
target/tests/test_prompt_preparation_12c4w

"$MOJO" build -I src tests/test_generated_table_columns.mojo \
    -o target/tests/test_generated_table_columns_12c4w
target/tests/test_generated_table_columns_12c4w

scripts/check_prompt_preparation_parity.sh
scripts/check_prompt_preparation_full_parity.sh
scripts/check_prompt_language_catalog.sh
for pytest_file in \
    tests/test_prompt_preparation_source.py \
    tests/test_known_defects.py \
    tests/test_completion_native_ownership.py \
    tests/test_prompt_session_source.py \
    tests/test_native_boundary_audit.py
do
    "$ROOT/scripts/run_pytest.sh" -q "$pytest_file"
done
python3 tools/check_known_defects.py

if [ "${RETA_RUN_FULL_ALL:-0}" = 1 ]; then
    scripts/check_full_all_parity.sh
else
    printf '%s\n' 'Vollständiges --alles-Gate: RETA_RUN_FULL_ALL=1 scripts/test_stage12c4w.sh'
fi
