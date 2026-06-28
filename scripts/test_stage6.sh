#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-stage6"}
mkdir -p "$TARGET"
for test_file in \
    tests/test_row_filtering.mojo \
    tests/test_row_filtering_reference.mojo \
    tests/test_csv_table.mojo \
    tests/test_csv_reference.mojo \
    tests/test_table_preparation.mojo \
    tests/test_generated_columns.mojo \
    tests/test_table_rendering.mojo \
    tests/test_native_reta_cli.mojo
do
    name=$(basename "$test_file" .mojo)
    printf '\n== build %s ==\n' "$test_file"
    "$ROOT/bin/mojo-real" build -I src -I tests "$test_file" -o "$TARGET/$name"
    printf '== run %s ==\n' "$name"
    "$TARGET/$name"
done
