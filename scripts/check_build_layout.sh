#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

expected='reta-mojo-native reta-mojo-table reta-mojo-tags reta-native reta-mojo-compat-bin reta-prompt-native reta-prompt-complete grundStrukHtml-native generate-html-native'

if ! grep -Eq '^target/$' .gitignore; then
    printf '%s\n' 'Fehler: target/ fehlt in .gitignore.' >&2
    exit 1
fi

for path in bin/*; do
    [ -f "$path" ] || continue
    if file -b "$path" | grep -q '^ELF '; then
        printf 'Fehler: kompiliertes ELF liegt im versionierbaren Launcher-Verzeichnis: %s\n' "$path" >&2
        exit 1
    fi
done

for name in $expected; do
    path="target/bin/$name"
    if [ ! -x "$path" ]; then
        printf 'Fehler: erwartetes Executable fehlt: %s\n' "$path" >&2
        exit 1
    fi
    if ! file -b "$path" | grep -q '^ELF 64-bit'; then
        printf 'Fehler: kein natives ELF-Executable: %s\n' "$path" >&2
        exit 1
    fi
done

if [ "${RETA_CHECK_HEAVY:-0}" = "1" ]; then
    for name in reta-mojo-schema reta-mojo-architecture reta-mojo-boundaries reta-mojo-contracts reta-mojo-witnesses reta-mojo-coherence reta-mojo-traces reta-mojo-impact reta-mojo-migration; do
        path="target/bin/$name"
        [ -x "$path" ] || { printf 'Fehler: schweres Executable fehlt: %s\n' "$path" >&2; exit 1; }
    done
fi

printf '%s\n' 'Buildlayout korrekt:'
printf '%s\n' '  bin/        versionierte Shell-Launcher'
printf '%s\n' '  target/bin/ kompilierte, durch .gitignore ausgeschlossene ELF-Dateien'
