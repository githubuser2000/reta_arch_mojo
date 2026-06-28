#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
RETA_MARKUP_EXTENDED=1 exec "$ROOT/scripts/check_markup_parity.sh"
