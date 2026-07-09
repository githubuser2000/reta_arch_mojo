#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if [ -e run ]; then
    printf '%s\n' 'Fehler: run/ darf im Projektbaum nicht mehr existieren.' >&2
    exit 1
fi

for root_launcher in \
    reta rp rpl rpe rpb reta.sh rp.sh rpl.sh retaPrompt retaPrompt.english \
    grundStrukHtml grundStrukHtml.py generate_html generate4readme math modulo \
    multis multis3 prim prim24 reta-native reta.english
 do
    if [ -e "$root_launcher" ] || [ -L "$root_launcher" ]; then
        printf 'Fehler: Launcher/Symlink in der Projektwurzel verboten: %s\n' "$root_launcher" >&2
        exit 1
    fi
done

for path in bin/*; do
    [ -e "$path" ] || continue
    name=${path##*/}
    if [ "$name" != mojo-real ]; then
        printf 'Fehler: Projekt-bin darf nur mojo-real enthalten: %s\n' "$path" >&2
        exit 1
    fi
    if [ -L "$path" ]; then
        printf 'Fehler: Projekt-bin darf keine Symlinks enthalten: %s\n' "$path" >&2
        exit 1
    fi
    if file -b "$path" | grep -q '^ELF '; then
        printf 'Fehler: Projekt-bin darf keine kompilierten Executables enthalten: %s\n' "$path" >&2
        exit 1
    fi
done

if [ ! -x bin/mojo-real ]; then
    printf '%s\n' 'Fehler: bin/mojo-real fehlt oder ist nicht ausführbar.' >&2
    exit 1
fi

if [ ! -d tools/wrappers ]; then
    printf '%s\n' 'Fehler: tools/wrappers fehlt.' >&2
    exit 1
fi
if find tools/wrappers -maxdepth 1 -type l | grep -q .; then
    printf '%s\n' 'Fehler: tools/wrappers darf keine Symlinks enthalten.' >&2
    exit 1
fi
for wrapper in generate_html generate4readme reta-extract-html-classes reta-mojo reta-mojo-compat mojo-runtime-exec reta rp rpl rpe rpb; do
    if [ ! -x "tools/wrappers/$wrapper" ]; then
        printf 'Fehler: erwarteter Wrapper fehlt: tools/wrappers/%s\n' "$wrapper" >&2
        exit 1
    fi
done

printf '%s\n' 'Projekt-Launcher-Layout sauber: target/bin für Build-Binaries, bin/mojo-real als Resolver, tools/wrappers für Quell-Wrapper.'
