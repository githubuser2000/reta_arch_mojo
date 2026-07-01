#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
RUNTIME_DIR=$("$ROOT/scripts/find_mojo_runtime.sh")
LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$ROOT/target/lib/mojo"}
mkdir -p "$LINK_DIR"

for library in libKGENCompilerRTShared.so libAsyncRTMojoBindings.so; do
    source_path=$RUNTIME_DIR/$library
    destination=$LINK_DIR/$library
    rm -f "$destination"
    ln -s "$source_path" "$destination"
done

printf 'Mojo-Laufzeit verknüpft: %s -> %s\n' "$LINK_DIR" "$RUNTIME_DIR"
