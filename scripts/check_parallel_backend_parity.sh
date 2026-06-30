#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
BIN=${RETA_PARALLEL_BIN:-"$ROOT/target/bin/reta-mojo-parallel-execution"}
TMP=${TMPDIR:-/tmp}/reta-parallel-backend-parity.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
"$BIN" --demo 2 2 > "$TMP/threads.out"
"$BIN" --demo-threads 2 2 > "$TMP/legacy-thread-alias.out"
# Backend names are intentionally different; all semantic payload lines must match.
cmp "$TMP/threads.out" "$TMP/legacy-thread-alias.out"
printf '%s\n' 'parallel thread/legacy-alias parity: 1 / 1'
