#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p build
"$ROOT/bin/mojo-real" build -I src src/main.mojo -o build/reta-mojo-native
"$ROOT/bin/mojo-real" build -I src src/schema_main.mojo -o build/reta-mojo-schema
"$ROOT/bin/mojo-real" build src/compat_main.mojo -o build/reta-mojo-compat-bin
printf '%s\n' 'Build abgeschlossen: native CLI, Schema-CLI und Kompatibilitäts-Launcher'
printf '%s\n' 'Der große Architekturkatalog wird bei Bedarf über bin/reta-mojo --mojo-architecture ausgeführt.'
