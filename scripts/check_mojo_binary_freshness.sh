#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ "$#" -ne 1 ]; then
    printf 'Verwendung: %s BINARY\n' "$0" >&2
    exit 2
fi
BINARY=$1
MANIFEST=${RETA_SOURCE_MANIFEST:-"$ROOT/SOURCE_MANIFEST.sha256"}
# Installed trees need not carry the development manifest.
[ -f "$MANIFEST" ] || exit 0
case "$BINARY" in
    "$ROOT"/target/bin/*) ;;
    *) exit 0 ;;
esac
CURRENT=$("$ROOT/scripts/current_source_id.sh")
STAMP=$BINARY.reta-source-id
if [ ! -f "$STAMP" ] || [ "$(sed -n '1p' "$STAMP")" != "$CURRENT" ]; then
    printf '%s\n' \
        "Veraltetes oder unmarkiertes Mojo-Binary: $BINARY" \
        "Der Quellstand wurde nach diesem Build ausgetauscht." \
        "Bitte neu kompilieren: scripts/build.sh" >&2
    exit 78
fi
if find "$ROOT/src" -type f -newer "$BINARY" -print -quit 2>/dev/null | grep -q .; then
    printf '%s\n' \
        "Mojo-Quellen sind neuer als das Binary: $BINARY" \
        "Bitte neu kompilieren: scripts/build.sh" >&2
    exit 78
fi
