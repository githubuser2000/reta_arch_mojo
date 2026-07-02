#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ -n "${RETA_TEST_PYTHON-}" ]; then
    CANDIDATES=$RETA_TEST_PYTHON
else
    CANDIDATES=''
    if [ -x "$ROOT/.venv/bin/python3" ]; then
        CANDIDATES="$ROOT/.venv/bin/python3"
    fi
    SYSTEM_PYTHON=$(command -v python3 || true)
    if [ -n "$SYSTEM_PYTHON" ]; then
        CANDIDATES="$CANDIDATES $SYSTEM_PYTHON"
    fi
    SYSTEM_PYPY=$(command -v pypy3 || true)
    if [ -n "$SYSTEM_PYPY" ]; then
        CANDIDATES="$CANDIDATES $SYSTEM_PYPY"
    fi
fi

for python in $CANDIDATES; do
    [ -x "$python" ] || continue
    if "$python" -c 'import pytest' >/dev/null 2>&1; then
        printf '%s\n' "$python"
        exit 0
    fi
done

printf '%s\n' 'Kein Python mit installiertem pytest wurde gefunden.' >&2
printf '%s\n' 'Installiere die Testabhängigkeiten bevorzugt in der Mojo-.venv:' >&2
printf '%s\n' '  ./scripts/setup_test_dependencies.sh' >&2
printf '%s\n' 'oder direkt:' >&2
printf '%s\n' '  uv pip install --python .venv/bin/python3 pytest' >&2
printf '%s\n' 'Alternativ genügt auch ein System-python3/pypy3 mit installiertem pytest.' >&2
exit 127
