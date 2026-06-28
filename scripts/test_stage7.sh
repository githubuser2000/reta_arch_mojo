#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-stage7"}
mkdir -p "$TARGET"
for test_file in \
    tests/test_generated_columns.mojo \
    tests/test_generated_aliases.mojo \
    tests/test_generated_table_columns.mojo \
    tests/test_prime_effect_columns.mojo \
    tests/test_prime_universe_columns.mojo \
    tests/test_table_rendering.mojo \
    tests/test_native_reta_cli.mojo
do
    name=$(basename "$test_file" .mojo)
    printf '\n== build %s ==\n' "$test_file"
    "$ROOT/bin/mojo-real" build -I src -I tests "$test_file" -o "$TARGET/$name"
    printf '== run %s ==\n' "$name"
    "$TARGET/$name"
done

printf '\n== generated runtime assets ==\n'
"$ROOT/scripts/check_generated_alias_catalog.sh"
"$ROOT/scripts/check_fraction_pair_catalog.sh"

printf '\n== native generated-column parity ==\n'
"$ROOT/scripts/check_generated_column_parity.sh"
