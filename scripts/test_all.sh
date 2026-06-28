#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-all"}
mkdir -p "$TARGET"

for test_file in tests/test_*.mojo; do
    case "$test_file" in
        tests/test_category_theory.mojo|tests/test_schema_catalog_parity.mojo)
            if [ "${RETA_TEST_HEAVY:-0}" != "1" ]; then
                printf 'SKIP schweres Compilerziel: %s\n' "$test_file"
                continue
            fi
            ;;
    esac
    name=$(basename "$test_file" .mojo)
    printf '\n== build %s ==\n' "$test_file"
    "$ROOT/bin/mojo-real" build -I src -I tests "$test_file" -o "$TARGET/$name"
    printf '== run %s ==\n' "$name"
    "$TARGET/$name"
done
