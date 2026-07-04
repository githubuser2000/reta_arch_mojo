#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/build.sh [--] [MOJO_BUILD_OPTION ...]

Kompiliert alle regulären nativen Ziele. Alle Argumente nach dem optionalen
Trenner `--` werden unverändert an jeden Aufruf von `mojo build` weitergereicht.
Das Skript besitzt weiterhin selbst Quellpfad, Ausgabeformat, Linker-RUNPATH
und Ausgabedatei.

Beispiele:
  scripts/build.sh -- --optimization-level 2
  scripts/build.sh -- --target-cpu <CPU-NAME> -j 8
  scripts/build.sh -- --no-optimization
USAGE
}

case ${1:-} in
    -h|--help)
        usage
        exit 0
        ;;
    --)
        shift
        ;;
esac

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p "$TARGET_DIR" "$RUNTIME_LINK_DIR"
MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'
BUILD_SOURCE_ID=${RETA_BUILD_SOURCE_ID:-$("$ROOT/scripts/current_source_id.sh")}
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

print_forwarded_options() {
    [ "$#" -gt 0 ] || return 0
    printf 'Zusätzliche Mojo-Buildoptionen:'
    for option do
        printf ' <%s>' "$option"
    done
    printf '\n'
}

ACTIVE_TMP=
cleanup_tmp() {
    [ -n "$ACTIVE_TMP" ] || return 0
    rm -f "$ACTIVE_TMP" "$ACTIVE_TMP.reta-source-id"
}
trap cleanup_tmp EXIT HUP INT TERM

build() {
    source_file=$1
    output_name=$2
    shift 2
    final_output="$TARGET_DIR/$output_name"
    ACTIVE_TMP="$TARGET_DIR/.${output_name}.tmp.$$"
    rm -f "$ACTIVE_TMP" "$ACTIVE_TMP.reta-source-id"
    printf 'Kompiliere %-35s -> %s\n' "$source_file" "$output_name"
    if "$MOJO" build "$@" --emit exe "$source_file" \
        -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" \
        -o "$ACTIVE_TMP"; then
        :
    else
        compiler_status=$?
        cleanup_tmp
        ACTIVE_TMP=
        return "$compiler_status"
    fi
    python3 "$ROOT/tools/sanitize_mojo_runpath.py" "$ACTIVE_TMP" >/dev/null
    file -b "$ACTIVE_TMP" | grep -q '^ELF 64-bit' || {
        printf 'Compiler erzeugte kein gültiges 64-Bit-ELF: %s\n' "$ACTIVE_TMP" >&2
        cleanup_tmp
        ACTIVE_TMP=
        return 1
    }
    RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
        "$ROOT/scripts/stamp_mojo_binary.sh" "$ACTIVE_TMP"

    # Publish only a completely compiled, sanitised and stamped artifact.  A
    # failed compiler invocation leaves the previous known-good binary intact.
    mv -f "$ACTIVE_TMP" "$final_output"
    mv -f "$ACTIVE_TMP.reta-source-id" "$final_output.reta-source-id"
    ACTIVE_TMP=
}

build_regular_targets() {
    build src/main.mojo reta-mojo-native -I src "$@"
    build src/table_main.mojo reta-mojo-table -I src "$@"
    build src/tags_main.mojo reta-mojo-tags -I src "$@"
    build src/i18n_words_main.mojo reta-mojo-i18n -I src "$@"
    build src/package_integrity_main.mojo reta-mojo-package-integrity \
        -I src -Xlinker -lcrypto "$@"
    build src/architecture_exports_main.mojo reta-mojo-exports -I src "$@"
    build src/architecture_facade_main.mojo reta-mojo-facade -I src "$@"
    build src/program_workflow_main.mojo reta-mojo-workflow -I src "$@"
    build src/sheaves_main.mojo reta-mojo-sheaves -I src "$@"
    RETA_TARGET_DIR="$TARGET_DIR" \
    RETA_TARGET_LIB_DIR="$TARGET_ROOT/lib/reta" \
    RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    MOJO_BIN="$MOJO" \
    RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
        "$ROOT/scripts/build_diagnostics_shared.sh" -- "$@"
    if [ "${RETA_BUILD_STANDALONE_DIAGNOSTICS:-0}" = 1 ]; then
        build src/table_generation_main.mojo reta-mojo-table-generation -I src "$@"
        build src/output_syntax_main.mojo reta-mojo-output-syntax -I src "$@"
        build src/console_io_main.mojo reta-mojo-console-io -I src "$@"
        build src/table_output_main.mojo reta-mojo-table-output -I src "$@"
    fi
    build src/domain_probe_main.mojo reta-mojo-domain-probe -I src "$@"
    build src/architecture_probe_main.mojo reta-mojo-architecture-probe \
        -I src -Xlinker -lcrypto "$@"
    build src/combi_join_main.mojo reta-mojo-combi-join -I src "$@"
    build src/reta_native_main.mojo reta-native -I src "$@"
    build src/compat_main.mojo reta-mojo-compat-bin -I src "$@"
    build src/prompt_main.mojo reta-prompt-native -I src "$@"
    build src/prompt_completion_main.mojo reta-prompt-complete -I src "$@"
    build src/grundstruk_html_main.mojo grundStrukHtml-native -I src "$@"
    build src/generate_html_main.mojo generate-html-native -I src "$@"
    build src/generate_readme_main.mojo generate-readme-native -I src "$@"
    build src/extract_html_classes_main.mojo reta-extract-html-classes-native -I src "$@"
}

print_forwarded_options "$@"
build_regular_targets "$@"

trap - EXIT HUP INT TERM
cleanup_tmp

printf '\nKompilierte Mojo-Executables:\n'
for executable in "$TARGET_DIR"/*; do
    [ -x "$executable" ] || continue
    printf '  %s\n' "$executable"
done

printf '\nKompilierte Mojo-Shared-Libraries:\n'
for library in "$TARGET_ROOT"/lib/reta/*.so; do
    [ -f "$library" ] || continue
    printf '  %s\n' "$library"
done

printf '\nBuild abgeschlossen. Tests werden nicht automatisch ausgeführt.\n'
printf 'Vollständiger Build inklusive schwerer Ziele: scripts/build-all.sh\n'
printf 'Optionale Shared-Diagnostics-Parität: scripts/build-and-test-shared-diagnostics.sh\n'
