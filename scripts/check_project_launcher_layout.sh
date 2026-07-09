#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

fail() {
    printf 'Fehler: %s\n' "$*" >&2
    exit 1
}

# Es darf keinen separaten Projekt-Run-Baum geben.
# Build-Ausgaben gehören nach target/bin, Installation nach PREFIX/bin.
if [ -e run ] || [ -L run ]; then
    fail 'run/ darf im Projektbaum nicht mehr existieren.'
fi

# Keine Komfort-Launcher oder Symlinks direkt in der Projektwurzel.
for root_launcher in \
    reta rp rpl rpe rpb reta.sh rp.sh rpl.sh retaPrompt retaPrompt.english \
    grundStrukHtml grundStrukHtml.py generate_html generate4readme math modulo \
    multis multis3 prim prim24 reta-native reta.english mojo-real
 do
    if [ -e "$root_launcher" ] || [ -L "$root_launcher" ]; then
        fail "Launcher/Symlink in der Projektwurzel verboten: $root_launcher"
    fi
done

# bin/ darf als bewusst leerer Platzhalter existieren, z.B. für ein späteres
# lokales Mojo-Setup. Dieses Prüfskript selbst legt dort nichts an.
if [ ! -d bin ]; then
    fail 'bin/ fehlt. Der Ordner darf existieren, muss aber leer bleiben.'
fi

# bin/ muss leer sein: kein mojo-real, keine reta/rp/rpl/rpe/rpb, keine Symlinks,
# keine versteckten Dateien. find erfasst auch Dotfiles.
if find bin -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    first_entry=$(find bin -mindepth 1 -maxdepth 1 -print -quit)
    fail "bin/ muss leer sein; gefunden: $first_entry"
fi

# Quellbaum-Wrapper sind erlaubt, aber nicht als Symlinks und nicht in bin/.
if [ ! -d tools/wrappers ]; then
    fail 'tools/wrappers fehlt.'
fi
if find tools/wrappers -maxdepth 1 -type l -print -quit | grep -q .; then
    first_link=$(find tools/wrappers -maxdepth 1 -type l -print -quit)
    fail "tools/wrappers darf keine Symlinks enthalten; gefunden: $first_link"
fi
for wrapper in generate_html generate4readme reta-extract-html-classes reta-mojo reta-mojo-compat mojo-runtime-exec reta rp rpl rpe rpb; do
    if [ ! -x "tools/wrappers/$wrapper" ]; then
        fail "erwarteter Wrapper fehlt oder ist nicht ausführbar: tools/wrappers/$wrapper"
    fi
done

printf '%s\n' 'Projekt-Launcher-Layout sauber: target/bin für Build-Binaries, /usr/local/bin für Installation, bin/ leer, tools/wrappers für Quell-Wrapper.'
