#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
BIN=${RETA_PARALLEL_BIN:-"$ROOT/target/bin/reta-mojo-parallel-execution"}
TMP=${TMPDIR:-/tmp}/reta-parallel-backend-parity.$$
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"
"$BIN" --demo 2 2 > "$TMP/processes.out"
"$BIN" --demo-threads 2 2 > "$TMP/threads.out"
# Backend names are intentionally different; all semantic payload lines must match.
grep -v '_mode=' "$TMP/processes.out" > "$TMP/processes.semantic"
grep -v '_mode=' "$TMP/threads.out" > "$TMP/threads.semantic"
cmp "$TMP/processes.semantic" "$TMP/threads.semantic"
printf '%s\n' 'parallel process/thread semantic parity: 1 / 1'
