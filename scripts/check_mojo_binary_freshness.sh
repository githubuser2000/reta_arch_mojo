#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ "$#" -ne 1 ]; then
    printf 'Verwendung: %s BINARY\n' "$0" >&2
    exit 2
fi
BINARY=$1
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
TARGET_LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
case "$BINARY" in
    "$TARGET_DIR"/*|"$TARGET_LIB_DIR"/*) ;;
    *) exit 0 ;;
esac

# Installed trees intentionally do not contain src/.  Their artifacts were
# checked before installation and therefore need no development-tree guard.
CURRENT=${RETA_CURRENT_SOURCE_ID:-$("$ROOT/scripts/current_source_id.sh" 2>/dev/null || true)}
[ -n "$CURRENT" ] || exit 0
REBUILD_COMMAND=${RETA_REBUILD_COMMAND:-scripts/build.sh}
STAMP=$BINARY.reta-source-id
if [ ! -f "$STAMP" ] || [ "$(sed -n '1p' "$STAMP")" != "$CURRENT" ]; then
    printf '%s\n' \
        "Veraltetes oder unmarkiertes Mojo-Binary: $BINARY" \
        "Quellen oder Buildrezept stimmen nicht mit diesem Binary überein." \
        "Bitte neu kompilieren: $REBUILD_COMMAND" >&2
    exit 78
fi
if [ -d "$ROOT/src" ] && \
   find "$ROOT/src" -type f -newer "$BINARY" -print -quit 2>/dev/null | grep -q .; then
    printf '%s\n' \
        "Mojo-Quellen sind neuer als das Binary: $BINARY" \
        "Bitte neu kompilieren: $REBUILD_COMMAND" >&2
    exit 78
fi
