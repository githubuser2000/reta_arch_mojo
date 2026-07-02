#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p target/tests
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
"$MOJO" build -I src tests/test_i18n_words.mojo -o target/tests/test_i18n_words_12c4x
target/tests/test_i18n_words_12c4x
scripts/check_i18n_words_catalog.sh
scripts/check_i18n_words_native_parity.sh
python3 -m pytest -q tests/test_i18n_words_source.py tests/test_known_defects.py tests/test_native_boundary_audit.py
python3 tools/check_known_defects.py
if [ "${RETA_RUN_FULL_ALL:-0}" = 1 ]; then
    scripts/check_full_all_parity.sh
else
    printf '%s\n' 'Vollständiges --alles-Gate: RETA_RUN_FULL_ALL=1 scripts/test_stage12c4x.sh'
fi
