#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"

./scripts/check_all_columns_plan.sh
"$ROOT/bin/mojo-real" build -I src \
    tests/test_all_columns.mojo -o "$TEST_DIR/test-all-columns"
"$TEST_DIR/test-all-columns"

if [ -x "$ROOT/target/bin/generate-html-native" ] && \
   [ -x "$ROOT/target/bin/grundStrukHtml-native" ]; then
    ./scripts/check_html_parity.sh
else
    printf '%s\n' 'HTML-Binärparität übersprungen: zuerst scripts/build.sh ausführen.'
fi
printf '%s\n' 'stage12b native --alles/HTML bridge-removal tests complete'
