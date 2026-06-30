#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_BENCH_TARGET:-"$ROOT/target/bench-parallel-row-preparation"}
ROWS=${1:-20000}
WORKERS=${2:-8}
CHUNK_SIZE=${3:-128}
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src \
    benchmarks/parallel_row_preparation.mojo -o "$TARGET"
printf 'serial:  '
/usr/bin/time -f 'elapsed=%e user=%U sys=%S rss=%MKiB' \
    "$TARGET" off "$ROWS" "$WORKERS" "$CHUNK_SIZE"
printf 'threads: '
/usr/bin/time -f 'elapsed=%e user=%U sys=%S rss=%MKiB' \
    "$TARGET" threads "$ROWS" "$WORKERS" "$CHUNK_SIZE"
