#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
rm -rf "$ROOT/target" "$ROOT/build"
rm -f "$ROOT/middle.alx"
find "$ROOT" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$ROOT" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
printf '%s\n' 'Build-, Laufzeit- und Cache-Artefakte entfernt.'
