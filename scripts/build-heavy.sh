#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TARGET_DIR"

printf 'Kompiliere schweres Parameterschema\n'
"$ROOT/bin/mojo-real" build -I src src/schema_main.mojo -o "$TARGET_DIR/reta-mojo-schema"
printf 'Kompiliere schweren Architekturkatalog ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_main.mojo -o "$TARGET_DIR/reta-mojo-architecture"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-architecture"
