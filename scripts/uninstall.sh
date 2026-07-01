#!/usr/bin/env sh
set -eu

PREFIX=${PREFIX:-/usr/local}
DESTDIR=${DESTDIR:-}
BINDIR=${BINDIR:-$PREFIX/bin}
LIBEXECDIR=${LIBEXECDIR:-$PREFIX/lib/reta}
DATADIR=${DATADIR:-$PREFIX/share/reta}

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")

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
rm -rf "$STAGE_LIBEXECDIR" "$STAGE_DATADIR"
printf 'Reta entfernt aus %s und %s.\n' "$LIBEXECDIR" "$DATADIR"
