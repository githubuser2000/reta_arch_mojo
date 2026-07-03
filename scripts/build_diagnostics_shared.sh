#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
MOJO_LIBRARY_RUNTIME_RPATH='$ORIGIN/../mojo'
CC=${CC:-cc}

mkdir -p "$TARGET_DIR" "$LIB_DIR" "$RUNTIME_LINK_DIR"
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

LIBRARY="$LIB_DIR/libreta-mojo-diagnostics.so"
LOADER="$TARGET_DIR/reta-mojo-diagnostics"

printf 'Kompiliere gemeinsame Mojo-Diagnosebibliothek -> %s\n' "$LIBRARY"
"$ROOT/bin/mojo-real" build --emit shared-lib -I src \
    src/reta_diagnostics_abi.mojo \
    -Xlinker -rpath -Xlinker "$MOJO_LIBRARY_RUNTIME_RPATH" \
    -o "$LIBRARY"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    --portable-component '$ORIGIN/../mojo' "$LIBRARY" >/dev/null
"$ROOT/scripts/stamp_mojo_binary.sh" "$LIBRARY"

printf 'Kompiliere kleinen Diagnose-Loader          -> %s\n' "$LOADER"
"$CC" -std=c11 -O2 -Wall -Wextra -Werror \
    "$ROOT/tools/reta_mojo_diagnostics_loader.c" -ldl -o "$LOADER"
"$ROOT/scripts/stamp_mojo_binary.sh" "$LOADER"

# Remove default standalone copies only after the shared bundle was built
# successfully.  They can still be requested explicitly from scripts/build.sh.
for old_target in \
    reta-mojo-table-generation reta-mojo-output-syntax \
    reta-mojo-console-io reta-mojo-table-output
do
    rm -f "$TARGET_DIR/$old_target" "$TARGET_DIR/$old_target.reta-source-id"
done

printf 'Gemeinsame Diagnose-ABI 1 erzeugt.\n'
