#!/usr/bin/env sh
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$ROOT/scripts/test_stage12c5cz.sh" "$@"
