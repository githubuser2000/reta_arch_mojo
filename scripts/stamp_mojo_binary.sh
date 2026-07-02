#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ "$#" -ne 1 ]; then
    printf 'Verwendung: %s BINARY\n' "$0" >&2
    exit 2
fi
BINARY=$1
[ -f "$BINARY" ] || { printf 'Binary fehlt: %s\n' "$BINARY" >&2; exit 1; }
SOURCE_ID=$("$ROOT/scripts/current_source_id.sh" 2>/dev/null || true)
[ -n "$SOURCE_ID" ] || exit 0
printf '%s\n' "$SOURCE_ID" > "$BINARY.reta-source-id"
