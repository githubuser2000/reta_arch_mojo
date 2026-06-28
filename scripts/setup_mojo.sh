#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if ! command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'uv wurde nicht gefunden.' >&2
    printf '%s\n' 'Installiere es gemäß der offiziellen Anleitung:' >&2
    printf '%s\n' '  curl -LsSf https://astral.sh/uv/install.sh | sh' >&2
    exit 127
fi

if [ -n "${RETA_MOJO_PYTHON-}" ]; then
    PYTHON_REQUEST=$RETA_MOJO_PYTHON
elif command -v python3.14 >/dev/null 2>&1; then
    PYTHON_REQUEST=$(command -v python3.14)
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_REQUEST=$(command -v python3)
else
    printf '%s\n' 'Kein Python 3 wurde gefunden.' >&2
    exit 127
fi

"$PYTHON_REQUEST" - <<'PY'
import sys
if not ((3, 10) <= sys.version_info[:2] <= (3, 14)):
    raise SystemExit(
        f"Mojo 1.0.0b2 benötigt hier Python 3.10 bis 3.14; gefunden: {sys.version.split()[0]}"
    )
print(f"Verwendetes Python: {sys.executable} ({sys.version.split()[0]})")
PY

rm -rf .venv
uv venv --python "$PYTHON_REQUEST" .venv
uv pip install --python .venv/bin/python 'mojo==1.0.0b2' --prerelease allow

printf '\n%s\n' 'Installierter Modular-Mojo-Compiler:'
.venv/bin/mojo --version
printf '\n%s\n' 'Jetzt ausführbar, ohne source/activate:'
printf '%s\n' '  ./bin/reta-mojo --mojo-prime 60'
printf '%s\n' "  ./bin/reta-mojo --mojo-range '1-9,-3' 100"
printf '%s\n' '  ./bin/reta-mojo --mojo-columns religionen sternpolygon'
