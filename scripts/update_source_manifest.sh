#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

find . \
  \( -path './.venv' -o -path './target' -o -path './build' -o -path './.git' -o -path '*/__pycache__' \) -prune -o \
  -type l -printf '%p -> %l\n' \
  | LC_ALL=C sort > SOURCE_SYMLINKS.txt

find . \
  \( -path './.venv' -o -path './target' -o -path './build' -o -path './.git' -o -path '*/__pycache__' \) -prune -o \
  -type f ! -name 'SOURCE_MANIFEST.sha256' ! -name 'middle.alx' -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum > SOURCE_MANIFEST.sha256

printf 'Manifest: %s Dateien, %s Symlinks\n' \
  "$(wc -l < SOURCE_MANIFEST.sha256)" \
  "$(wc -l < SOURCE_SYMLINKS.txt)"
