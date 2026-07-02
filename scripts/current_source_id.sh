#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST=${RETA_SOURCE_MANIFEST:-"$ROOT/SOURCE_MANIFEST.sha256"}
if [ ! -f "$MANIFEST" ]; then
    exit 1
fi
sha256sum "$MANIFEST" | awk '{print $1}'
