#!/usr/bin/env sh
# Select the interpreter for the frozen Python/PyPy3 reference implementation.
#
# Precedence:
#   1. RETA_REFERENCE_PYTHON
#   2. RETA_PYTHON (historical compatibility name)
#   3. pypy3
#   4. python3
#   5. the local .venv interpreter as a last-resort fallback
#
# The Mojo compiler environment is deliberately not preferred: it exists for
# building Mojo, while the behavioural reference historically runs on PyPy3.
set -eu

ROOT=${RETA_PROJECT_ROOT-}
if [ -z "$ROOT" ]; then
    ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fi

resolve_python() {
    candidate=$1
    [ -n "$candidate" ] || return 1
    case "$candidate" in
        */*)
            [ -x "$candidate" ] || return 1
            printf '%s\n' "$candidate"
            ;;
        *)
            command -v "$candidate" 2>/dev/null || return 1
            ;;
    esac
}

for configured in "${RETA_REFERENCE_PYTHON-}" "${RETA_PYTHON-}"; do
    if resolved=$(resolve_python "$configured"); then
        printf '%s\n' "$resolved"
        exit 0
    fi
    if [ -n "$configured" ]; then
        printf 'Konfigurierter Referenzinterpreter ist nicht ausführbar: %s\n' "$configured" >&2
        exit 127
    fi
done

for candidate in pypy3 python3; do
    if resolved=$(resolve_python "$candidate"); then
        printf '%s\n' "$resolved"
        exit 0
    fi
done

if [ -x "$ROOT/.venv/bin/python" ]; then
    printf '%s\n' "$ROOT/.venv/bin/python"
    exit 0
fi

printf '%s\n' 'Kein PyPy3-/Python3-Referenzinterpreter gefunden.' >&2
exit 127
