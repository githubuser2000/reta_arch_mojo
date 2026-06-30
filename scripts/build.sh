#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TARGET_DIR"

build() {
    source_file=$1
    output_name=$2
    shift 2
    printf 'Kompiliere %-35s -> %s\n' "$source_file" "$output_name"
    "$ROOT/bin/mojo-real" build "$@" "$source_file" -o "$TARGET_DIR/$output_name"
}

build src/main.mojo reta-mojo-native -I src
build src/table_main.mojo reta-mojo-table -I src
build src/tags_main.mojo reta-mojo-tags -I src
build src/reta_native_main.mojo reta-native -I src
build src/compat_main.mojo reta-mojo-compat-bin
build src/prompt_main.mojo reta-prompt-native -I src
build src/prompt_completion_main.mojo reta-prompt-complete -I src
build src/grundstruk_html_main.mojo grundStrukHtml-native -I src
build src/generate_html_main.mojo generate-html-native -I src

printf '\nKompilierte Mojo-Executables:\n'
for executable in "$TARGET_DIR"/*; do
    [ -x "$executable" ] || continue
    printf '  %s\n' "$executable"
done

printf '\nBuild abgeschlossen. Tests werden nicht automatisch ausgeführt.\n'
printf 'Optionale Gesamtprüfung: scripts/test_stage12c.sh\n'
