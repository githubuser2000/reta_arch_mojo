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
PROFILE=${RETA_PROMPT_PROFILE:-$(basename -- "$0")}
# Preserve the historical PyPy3 reference for explicit Python/math commands
# and for the atomic compatibility child process.  The prompt execution itself
# is now reached through the thin shared-library starter below.
if [ -z "${RETA_PYTHON-}" ]; then
    if [ -x "$ROOT/scripts/select_reference_python.sh" ]; then
        RETA_PYTHON=$(RETA_PROJECT_ROOT="$ROOT" "$ROOT/scripts/select_reference_python.sh")
    elif command -v pypy3 >/dev/null 2>&1; then
        RETA_PYTHON=pypy3
    else
        RETA_PYTHON=python3
    fi
    export RETA_PYTHON
fi
PROMPT_STARTER="$ROOT/target/bin/$PROFILE"
if [ ! -x "$PROMPT_STARTER" ]; then
    printf 'Dünner Prompt-Starter fehlt: %s\n' "$PROMPT_STARTER" >&2
    printf 'Bitte neu kompilieren: scripts/build_prompt_shared.sh oder scripts/build-all.sh\n' >&2
    exit 127
fi
exec "$PROMPT_STARTER" "$@"
