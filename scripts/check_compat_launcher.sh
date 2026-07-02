#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TEST_DIR=${RETA_TEST_TARGET_DIR:-"$ROOT/target/test-bin"}
mkdir -p "$TEST_DIR"
MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'
"$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

if [ "${RETA_SKIP_COMPAT_BUILD:-0}" != 1 ]; then
    "$ROOT/bin/mojo-real" build -j 4 -I src \
        src/compat_main.mojo \
        -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" \
        -o "$TEST_DIR/reta-mojo-compat-bin"
    python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
        "$TEST_DIR/reta-mojo-compat-bin" >/dev/null
fi

if command -v readelf >/dev/null 2>&1 && \
   readelf -d "$TEST_DIR/reta-mojo-compat-bin" 2>/dev/null | \
       grep NEEDED | grep -qi libpython; then
    printf '%s\n' 'Kompatibilitätslauncher bindet unerwartet libpython ein.' >&2
    exit 1
fi

run_group() {
    for test_node in "$@"; do
        RETA_COMPAT_BINARY="$TEST_DIR/reta-mojo-compat-bin" \
        PYTHONPATH=. "$ROOT/scripts/run_pytest.sh" -q "$test_node"
    done
}

GROUP=${RETA_COMPAT_TEST_GROUP:-all}
case "$GROUP" in
    1)
        run_group \
          tests/test_compat_launcher.py::test_compat_launcher_preserves_typed_argv_streams_and_exit_status \
          tests/test_compat_launcher.py::test_supported_historical_cli_runs_without_python_child \
          tests/test_compat_launcher.py::test_compat_launcher_matches_reference_table_bytes \
          tests/test_compat_launcher.py::test_shell_onetable_runs_without_python_child \
          tests/test_compat_launcher.py::test_markup_onetable_runs_without_python_child
        ;;
    2)
        run_group \
          tests/test_compat_launcher.py::test_no_blank_contents_runs_without_python_child \
          tests/test_compat_launcher.py::test_positive_column_widths_run_without_python_child \
          tests/test_compat_launcher.py::test_markup_nocolor_runs_without_python_child \
          tests/test_compat_launcher.py::test_flat_column_widths_run_without_python_child \
          tests/test_compat_launcher.py::test_zero_column_widths_run_without_python_child
        ;;
    3)
        run_group \
          tests/test_compat_launcher.py::test_force_reference_keeps_empty_cli_on_complete_reference_surface \
          tests/test_compat_launcher.py::test_force_reference_override_keeps_full_legacy_surface \
          tests/test_compat_launcher.py::test_safe_generator_ranges_run_without_python_child \
          tests/test_compat_launcher.py::test_non_owned_generator_expression_falls_back_atomically \
          tests/test_compat_launcher.py::test_native_debug_and_nothing_controls_need_no_python_child
        ;;
    4)
        run_group \
          tests/test_compat_launcher.py::test_native_debug_and_nothing_table_vectors_match_reference \
          tests/test_compat_launcher.py::test_compat_source_contains_no_embedded_python \
          tests/test_compat_launcher.py::test_compat_shell_launcher_preserves_project_interpreter \
          tests/test_compat_launcher.py::test_native_startup_help_and_language_only_need_no_python_child \
          tests/test_compat_launcher.py::test_optionless_main_sections_no_longer_render_default_table
        ;;
    all)
        for group in 1 2 3 4; do
            RETA_SKIP_COMPAT_BUILD=1 RETA_COMPAT_TEST_GROUP=$group "$0"
        done
        printf '%s\n' 'Nativer Kompatibilitätslauncher: 20/20 ohne eingebettetes CPython.'
        exit 0
        ;;
    *)
        printf 'Unbekannte RETA_COMPAT_TEST_GROUP: %s\n' "$GROUP" >&2
        exit 2
        ;;
esac
printf 'Nativer Kompatibilitätslauncher Gruppe %s: 5/5.\n' "$GROUP"
