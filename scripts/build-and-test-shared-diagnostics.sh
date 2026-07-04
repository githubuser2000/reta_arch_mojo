#!/usr/bin/env sh
set -eu

report_shared_build_status() {
    status=$?
    trap - 0
    if [ -n "${TMP_COMPARE-}" ]; then
        rm -rf "$TMP_COMPARE"
    fi
    if [ "$status" -eq 0 ]; then
        printf '%s: JA\n' 'Kompilierung und Shared-Diagnostics-Prüfung erfolgreich'
    else
        printf '%s: NEIN (Exitstatus %s)\n' 'Kompilierung und Shared-Diagnostics-Prüfung erfolgreich' "$status" >&2
    fi
    exit "$status"
}
trap report_shared_build_status 0
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$("$ROOT/scripts/find_test_python.sh")
REFERENCE_PYTHON=${RETA_REFERENCE_PYTHON:-"$("$ROOT/scripts/select_reference_python.sh")"}
TMP_COMPARE=
mkdir -p target/tests

# Optional deep verification: rebuild the shared owner and its loader, then
# compare them with temporary standalone parity oracles.  The normal .so is
# already part of scripts/build.sh; this script is not required after every build.
"$ROOT/scripts/build_diagnostics_shared.sh"

# Build the former standalone programs only as temporary parity oracles. They
# are not part of the default install target set anymore.
"$MOJO" build -I src src/table_generation_main.mojo \
    -o target/tests/reta-mojo-table-generation-12c5z
"$MOJO" build -I src src/output_syntax_main.mojo \
    -o target/tests/reta-mojo-output-syntax-12c5z
"$MOJO" build -I src src/console_io_main.mojo \
    -o target/tests/reta-mojo-console-io-12c5z
"$MOJO" build -I src src/table_output_main.mojo \
    -o target/tests/reta-mojo-table-output-12c5z

TMP_COMPARE=$(mktemp -d "${TMPDIR:-/tmp}/reta-diagnostics-parity.XXXXXX")
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
compare_command() {
    public_launcher=$1
    standalone_binary=$2
    shift 2
    "$public_launcher" "$@" > "$TMP_COMPARE/shared.out"
    "$ROOT/bin/mojo-runtime-exec" "$standalone_binary" "$@" \
        > "$TMP_COMPARE/standalone.out"
    cmp "$TMP_COMPARE/shared.out" "$TMP_COMPARE/standalone.out"
}
compare_command "$ROOT/bin/reta-mojo-table-generation" \
    "$ROOT/target/tests/reta-mojo-table-generation-12c5z" --summary
compare_command "$ROOT/bin/reta-mojo-output-syntax" \
    "$ROOT/target/tests/reta-mojo-output-syntax-12c5z" --summary
compare_command "$ROOT/bin/reta-mojo-console-io" \
    "$ROOT/target/tests/reta-mojo-console-io-12c5z" --summary
compare_command "$ROOT/bin/reta-mojo-table-output" \
    "$ROOT/target/tests/reta-mojo-table-output-12c5z" --summary

# Existing Python parity checkers exercise the public compatibility launchers,
# which now route through the shared library.
"$TEST_PYTHON" scripts/check_table_generation_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/bin/reta-mojo-table-generation"
"$TEST_PYTHON" scripts/check_output_semantics_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/bin/reta-mojo-output-syntax"
"$TEST_PYTHON" scripts/check_console_io_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/bin/reta-mojo-console-io"
"$TEST_PYTHON" scripts/check_table_output_parity.py \
    --python "$REFERENCE_PYTHON" \
    --binary "$ROOT/bin/reta-mojo-table-output"

"$ROOT/scripts/run_pytest.sh" -q \
    tests/test_diagnostics_shared_library_source.py \
    tests/test_mojo_runtime_path.py \
    tests/test_table_generation_complete_source.py \
    tests/test_output_syntax_complete_source.py \
    tests/test_console_io_complete_source.py \
    tests/test_table_output_complete_source.py \
    tests/test_install_target_manifest.py \
    tests/test_mojo_relative_imports.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_source_archive_contract.py \
    tests/test_native_boundary_audit.py
"$TEST_PYTHON" tools/check_known_defects.py
printf '%s\n' 'Shared-Diagnostics-Build und Paritätsprüfung abgeschlossen.'
