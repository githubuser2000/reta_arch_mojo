#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-stage8"}
mkdir -p "$TARGET"
for test_file in \
    tests/test_meta_columns.mojo \
    tests/test_fraction_concat_columns.mojo \
    tests/test_kombi_join_columns.mojo \
    tests/test_generated_aliases.mojo \
    tests/test_native_reta_cli.mojo \
    tests/test_generated_table_columns.mojo \
    tests/test_table_rendering.mojo
do
    name=$(basename "$test_file" .mojo)
    printf '\n== build %s ==\n' "$test_file"
    "$ROOT/bin/mojo-real" build -I src -I tests "$test_file" -o "$TARGET/$name"
    printf '== run %s ==\n' "$name"
    "$TARGET/$name"
done

printf '\n== Stage-8 runtime assets ==\n'
"$ROOT/scripts/check_generated_alias_catalog.sh"
"$ROOT/scripts/check_fraction_pair_catalog.sh"
"$ROOT/scripts/check_meta_request_order.sh"
"$ROOT/scripts/check_kombi_catalogs.sh"

printf '\n== Stage-8 byte parity ==\n'
"$ROOT/scripts/check_generated_column_parity.sh"
"$ROOT/scripts/check_kombi_parity.sh"
