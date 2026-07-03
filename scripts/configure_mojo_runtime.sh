#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
RUNTIME_DIR=$("$ROOT/scripts/find_mojo_runtime.sh")
LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$ROOT/target/lib/mojo"}
MODE=${RETA_MOJO_RUNTIME_MODE:-link}

case "$MODE" in
    link|copy) ;;
    *)
        printf 'Ungültiger RETA_MOJO_RUNTIME_MODE: %s (erlaubt: link, copy)\n' "$MODE" >&2
        exit 2
        ;;
esac

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
    [ -f "$source_path" ] || {
        printf 'Fehlende Mojo-Laufzeitbibliothek: %s\n' "$source_path" >&2
        exit 2
    }
    rm -f "$destination"
    if [ "$MODE" = copy ]; then
        cp -L "$source_path" "$destination"
        chmod 0755 "$destination"
    else
        ln -s "$source_path" "$destination"
    fi
done

if [ "$MODE" = copy ]; then
    printf 'Mojo-Laufzeit portabel kopiert: %s <- %s\n' "$LINK_DIR" "$RUNTIME_DIR"
else
    printf 'Mojo-Laufzeit verknüpft: %s -> %s\n' "$LINK_DIR" "$RUNTIME_DIR"
fi
