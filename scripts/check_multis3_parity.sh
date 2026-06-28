#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
cp tests/multis3_parity_constants.mojo "$tmp"
python3 tools/generate_multis3_parity.py >/dev/null
cmp -s "$tmp" tests/multis3_parity_constants.mojo || {
    printf '%s\n' 'multis3-Paritätskonstanten waren nicht reproduzierbar.' >&2
    exit 1
}
"$ROOT/bin/mojo-real" run -I src -I tests tests/test_multis3_parity.mojo
