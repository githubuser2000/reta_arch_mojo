#!/usr/bin/env sh
set -eu
SELF=$0
if command -v readlink >/dev/null 2>&1; then
    SELF=$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")
fi
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$SELF")" && pwd)
if [ -d "$SCRIPT_DIR/../src" ] && [ -d "$SCRIPT_DIR/../scripts" ]; then
    ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
elif [ -d "$SCRIPT_DIR/../../src" ] && [ -d "$SCRIPT_DIR/../../scripts" ]; then
    ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
else
    ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
fi
CORE_STARTER="$ROOT/target/bin/reta"
if [ ! -x "$CORE_STARTER" ]; then
    printf 'Dünner reta-Core-Starter fehlt: %s\n' "$CORE_STARTER" >&2
    printf 'Bitte neu kompilieren: scripts/build_core_shared.sh oder scripts/build-all.sh\n' >&2
    exit 127
fi
exec "$CORE_STARTER" "$@"
