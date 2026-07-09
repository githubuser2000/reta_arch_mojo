#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
reta_install_set_defaults

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_REFERENCEDIR=$(stage_path "$REFERENCEDIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

remove_public_command() {
    name=$1
    rm -f "$STAGE_BINDIR/$name"
}

while IFS= read -r name || [ -n "$name" ]; do
    case "$name" in
        ''|'#'*) continue ;;
    esac
    remove_public_command "$name"
done < "$ROOT/scripts/install_targets.txt"

for wrapper_name in $(reta_artifact_public_shell_wrappers); do
    remove_public_command "$wrapper_name"
done
remove_public_command mojo-runtime-exec

for manpage in $(reta_public_manpages); do
    rm -f "$STAGE_MANDIR/man1/$manpage"
done
if [ "$STAGE_REFERENCEDIR" != "$STAGE_DATADIR/python_reference" ]; then
    rm -rf "$STAGE_REFERENCEDIR"
fi
rm -rf "$STAGE_LIBEXECDIR" "$STAGE_DATADIR"
printf 'Reta entfernt aus %s, %s und %s. Öffentliche Befehle wurden aus %s entfernt.\n' \
    "$LIBEXECDIR" "$DATADIR" "$REFERENCEDIR" "$BINDIR"
