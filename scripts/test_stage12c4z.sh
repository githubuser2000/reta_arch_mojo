#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

FULL_NATIVE_HTML=${RETA_NATIVE_HTML-}
unset RETA_NATIVE_HTML

for pytest_file in \
    tests/test_generate_html_cli.py \
    tests/test_generate_html_source_contract.py \
    tests/test_full_all_reference_workflow.py \
    tests/test_source_archive_contract.py
 do
    "$ROOT/scripts/run_pytest.sh" -q "$pytest_file"
 done
"$ROOT/scripts/run_pytest.sh" -q tests/test_known_defects.py tests/test_documented_python_defects.py
python3 tools/check_known_defects.py
sh -n tools/wrappers/generate_html scripts/install.sh scripts/uninstall.sh \
    scripts/check_full_all_against_reference.sh \
    scripts/create_full_all_reference_bundle.sh

if [ -x target/bin/generate-html-native ]; then
    "$ROOT/scripts/run_pytest.sh" -q tests/test_install_layout.py
    scripts/check_html_parity.sh
    scripts/check_native_io_boundaries.sh
    scripts/check_install_layout.sh
else
    printf '%s\n' 'Native generate_html-Gates übersprungen: zuerst scripts/build.sh ausführen.'
fi

if [ -n "$FULL_NATIVE_HTML" ]; then
    RETA_NATIVE_HTML=$FULL_NATIVE_HTML scripts/check_full_all_against_reference.sh
elif [ "${RETA_RUN_FULL_ALL:-0}" = 1 ]; then
    scripts/check_full_all_against_reference.sh
else
    printf '%s\n' 'Vollständiges --alles-Gate: RETA_RUN_FULL_ALL=1 scripts/test_stage12c4z.sh'
fi
