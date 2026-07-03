#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}

if [ "$#" -lt 2 ]; then
    printf 'Verwendung: %s BUILD-BEFEHL ZIEL [ZIEL ...]\n' "$0" >&2
    exit 2
fi
BUILD_COMMAND=$1
shift

missing=0
for name in "$@"; do
    target="$TARGET_DIR/$name"
    if [ ! -x "$target" ]; then
        printf 'Fehlendes gebautes Ziel: %s\n' "$target" >&2
        missing=1
        continue
    fi
    RETA_REBUILD_COMMAND="$BUILD_COMMAND" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$target"
done

if [ "$missing" -ne 0 ]; then
    printf 'Bitte zuerst ausführen: %s\n' "$BUILD_COMMAND" >&2
    exit 78
fi
