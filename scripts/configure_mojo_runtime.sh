#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
RUNTIME_DIR=$("$ROOT/scripts/find_mojo_runtime.sh")
LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$ROOT/target/lib/mojo"}
mkdir -p "$LINK_DIR"
RUNTIME_CANON=$(CDPATH= cd -- "$RUNTIME_DIR" && pwd)
LINK_CANON=$(CDPATH= cd -- "$LINK_DIR" && pwd)
if [ "$RUNTIME_CANON" = "$LINK_CANON" ]; then
    printf 'Mojo-Laufzeit bereits lokal verfügbar: %s\n' "$LINK_DIR"
    exit 0
fi

for library in \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
do
    source_path=$RUNTIME_DIR/$library
    destination=$LINK_DIR/$library
    rm -f "$destination"
    ln -s "$source_path" "$destination"
done

printf 'Mojo-Laufzeit verknüpft: %s -> %s\n' "$LINK_DIR" "$RUNTIME_DIR"
