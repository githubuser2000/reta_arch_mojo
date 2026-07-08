#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
reta_install_set_defaults

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

if [ -d "$STAGE_LIBEXECDIR/bin" ]; then
    for launcher in "$STAGE_LIBEXECDIR"/bin/*; do
        [ -f "$launcher" ] || [ -L "$launcher" ] || continue
        name=$(basename -- "$launcher")
        case "$name" in
            mojo-real|mojo-runtime-exec) continue ;;
        esac
        [ -L "$STAGE_BINDIR/$name" ] && rm -f "$STAGE_BINDIR/$name"
    done
fi
rm -f "$STAGE_MANDIR/man1/generate_html.1"
rm -rf "$STAGE_LIBEXECDIR" "$STAGE_DATADIR"
printf 'Reta entfernt aus %s und %s.\n' "$LIBEXECDIR" "$DATADIR"
