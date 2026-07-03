#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
mkdir -p "$TARGET_DIR" "$RUNTIME_LINK_DIR"
MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

build() {
    source_file=$1
    output_name=$2
    shift 2
    printf 'Kompiliere %-35s -> %s\n' "$source_file" "$output_name"
    "$ROOT/bin/mojo-real" build "$@" "$source_file" \
        -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" \
        -o "$TARGET_DIR/$output_name"
    python3 "$ROOT/tools/sanitize_mojo_runpath.py" "$TARGET_DIR/$output_name" >/dev/null
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TARGET_DIR/$output_name"
}

build src/main.mojo reta-mojo-native -I src
build src/table_main.mojo reta-mojo-table -I src
build src/tags_main.mojo reta-mojo-tags -I src
build src/i18n_words_main.mojo reta-mojo-i18n -I src
build src/package_integrity_main.mojo reta-mojo-package-integrity -I src -Xlinker -lcrypto
build src/architecture_exports_main.mojo reta-mojo-exports -I src
build src/architecture_facade_main.mojo reta-mojo-facade -I src
build src/program_workflow_main.mojo reta-mojo-workflow -I src
build src/sheaves_main.mojo reta-mojo-sheaves -I src
"$ROOT/scripts/build_diagnostics_shared.sh"
if [ "${RETA_BUILD_STANDALONE_DIAGNOSTICS:-0}" = 1 ]; then
    build src/table_generation_main.mojo reta-mojo-table-generation -I src
    build src/output_syntax_main.mojo reta-mojo-output-syntax -I src
    build src/console_io_main.mojo reta-mojo-console-io -I src
    build src/table_output_main.mojo reta-mojo-table-output -I src
fi
build src/domain_probe_main.mojo reta-mojo-domain-probe -I src
build src/combi_join_main.mojo reta-mojo-combi-join -I src
build src/reta_native_main.mojo reta-native -I src
build src/compat_main.mojo reta-mojo-compat-bin -I src
build src/prompt_main.mojo reta-prompt-native -I src
build src/prompt_completion_main.mojo reta-prompt-complete -I src
build src/grundstruk_html_main.mojo grundStrukHtml-native -I src
build src/generate_html_main.mojo generate-html-native -I src
build src/generate_readme_main.mojo generate-readme-native -I src
build src/extract_html_classes_main.mojo reta-extract-html-classes-native -I src

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
