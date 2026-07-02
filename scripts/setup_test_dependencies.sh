#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

PYTHON=${RETA_TEST_PYTHON:-"$ROOT/.venv/bin/python3"}
if [ ! -x "$PYTHON" ]; then
    printf '%s\n' "Test-Python nicht gefunden: $PYTHON" >&2
    printf '%s\n' 'Erzeuge zuerst die Mojo-Umgebung mit ./scripts/setup_mojo.sh' >&2
    exit 127
fi

if command -v uv >/dev/null 2>&1; then
    uv pip install --python "$PYTHON" -r requirements-test.txt
else
    if ! "$PYTHON" -m pip --version >/dev/null 2>&1; then
        "$PYTHON" -m ensurepip --upgrade
    fi
    "$PYTHON" -m pip install -r requirements-test.txt
fi

"$PYTHON" - <<'PY'
import pytest, sys
print(f"pytest {pytest.__version__} installiert für {sys.executable}")
PY
