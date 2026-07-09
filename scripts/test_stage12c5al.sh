#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests"}
mkdir -p "$TARGET"

printf '\n== generate/check canonical architecture probe assets ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$TEST_PYTHON" tools/generate_architecture_probe_assets.py --check

printf '\n== build tests/test_architecture_probe_assets.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_architecture_probe_assets.mojo \
    -o "$TARGET/test_architecture_probe_assets_12c5al"
printf '== run test_architecture_probe_assets_12c5al ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_architecture_probe_assets_12c5al"

printf '\n== build src/architecture_probe_main.mojo ==\n'
"$MOJO" build -I src src/architecture_probe_main.mojo \
    -Xlinker -lcrypto \
    -o "$TARGET/reta-mojo-architecture-probe-12c5al"
printf '== parity reta-mojo-architecture-probe-12c5al ==\n'
"$TEST_PYTHON" scripts/check_architecture_probe_parity.py \
    --python "$TEST_PYTHON" \
    --binary "$TARGET/reta-mojo-architecture-probe-12c5al"

printf '\n== build src/domain_probe_main.mojo ==\n'
"$MOJO" build -I src src/domain_probe_main.mojo \
    -o "$TARGET/reta-mojo-domain-probe-12c5al"
printf '== parity reta-mojo-domain-probe-12c5al ==\n'
"$TEST_PYTHON" scripts/check_domain_probe_parity.py \
    --python "$TEST_PYTHON" \
    --binary "$TARGET/reta-mojo-domain-probe-12c5al"

printf '\n== regenerate/check complete i18n catalog ==\n'
PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1 \
    "$ROOT/scripts/check_i18n_words_catalog.sh"

printf '\n== build tests/test_i18n_words.mojo ==\n'
"$MOJO" build -I src -I tests tests/test_i18n_words.mojo \
    -o "$TARGET/test_i18n_words_12c5al"
printf '== run test_i18n_words_12c5al ==\n'
"$ROOT/tools/wrappers/mojo-runtime-exec" "$TARGET/test_i18n_words_12c5al"

printf '\n== build src/i18n_words_main.mojo ==\n'
"$MOJO" build -I src src/i18n_words_main.mojo \
    -o "$TARGET/reta-mojo-i18n-12c5al"
printf '== parity reta-mojo-i18n-12c5al ==\n'
for language in deutsch english vietnamese chinese korean; do
    "$ROOT/tools/wrappers/mojo-runtime-exec" \
        "$TARGET/reta-mojo-i18n-12c5al" --dump "$language" \
        > "$TARGET/i18n-$language-12c5al.dump"
    cmp "$TARGET/i18n-$language-12c5al.dump" \
        "assets/i18n_words/$language.tsv"
done
printf '%s\n' 'native complete i18n parity: 5/5 languages, 68265/68265 rows'

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_architecture_probe_assets_source.py \
    tests/test_domain_probe_source.py \
    tests/test_i18n_words_source.py \
    tests/test_porting_metrics.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_install_target_manifest.py \
    tests/test_stage_build_separation.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py
"$TEST_PYTHON" tools/check_known_defects.py
"$TEST_PYTHON" tools/porting_metrics.py
printf '%s\n' 'stage12c5al complete native legacy i18n monolith facade'
