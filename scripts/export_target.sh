#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE=${1:-"$ROOT/target"}
OUTPUT=${2:-"$ROOT/target-portable.tar.xz"}

[ -d "$SOURCE/bin" ] || {
    printf 'Target-Binärbaum fehlt: %s/bin\n' "$SOURCE" >&2
    exit 2
}

case "$OUTPUT" in
    /*) ;;
    *) OUTPUT=$PWD/$OUTPUT ;;
esac

TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/reta-target-export.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM
mkdir -p "$TMP_ROOT/target"
cp -a "$SOURCE/." "$TMP_ROOT/target/"

# Absolute development symlinks are useful for local incremental builds but
# not transferable.  Replace the complete Mojo runtime set with real files.
RETA_MOJO_RUNTIME_MODE=copy \
RETA_MOJO_RUNTIME_LINK_DIR="$TMP_ROOT/target/lib/mojo" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

if find "$TMP_ROOT/target/lib/mojo" -type l -print -quit | grep -q .; then
    printf '%s\n' 'Portabilitätsfehler: Laufzeitexport enthält noch Symlinks.' >&2
    exit 2
fi

mkdir -p "$(dirname -- "$OUTPUT")"
tar -cJf "$OUTPUT" -C "$TMP_ROOT" target
printf 'Portables Target erzeugt: %s\n' "$OUTPUT"
