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

uv venv --python 3.14 .venv
uv pip install --python .venv/bin/python 'mojo==1.0.0b2' --prerelease allow

printf '\n%s\n' 'Installierter Modular-Mojo-Compiler:'
.venv/bin/mojo --version
printf '\n%s\n' 'Jetzt ausführbar, ohne source/activate:'
printf '%s\n' '  ./bin/reta-mojo --mojo-prime 60'
printf '%s\n' "  ./bin/reta-mojo --mojo-range '1-9,-3' 100"
