#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/build_diagnostics_shared.sh [--] [MOJO_BUILD_OPTION ...]

Alle übergebenen Mojo-Optionen gelten für den Shared-Library-Build. Der kleine
C-Loader wird weiterhin mit seinen eigenen festen, sicherheitsrelevanten
C-Compileroptionen gebaut.
USAGE
        exit 0
        ;;
    --)
        shift
        ;;
esac

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
MOJO_LIBRARY_RUNTIME_RPATH='$ORIGIN/../mojo'
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
CC=${CC:-cc}
BUILD_SOURCE_ID=${RETA_BUILD_SOURCE_ID:-$("$ROOT/scripts/current_source_id.sh")}

mkdir -p "$TARGET_DIR" "$LIB_DIR" "$RUNTIME_LINK_DIR"
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

LIBRARY="$LIB_DIR/libreta-mojo-diagnostics.so"
LOADER="$TARGET_DIR/reta-mojo-diagnostics"
TMP_LIBRARY="$LIB_DIR/.libreta-mojo-diagnostics.so.tmp.$$"
TMP_LOADER="$TARGET_DIR/.reta-mojo-diagnostics.tmp.$$"
cleanup_tmp() {
    rm -f "$TMP_LIBRARY" "$TMP_LIBRARY.reta-source-id" \
        "$TMP_LOADER" "$TMP_LOADER.reta-source-id"
}
trap cleanup_tmp EXIT HUP INT TERM
cleanup_tmp

printf 'Kompiliere gemeinsame Mojo-Diagnosebibliothek -> %s\n' "$LIBRARY"
"$MOJO" build -I src "$@" --emit shared-lib \
    src/reta_diagnostics_abi.mojo \
    -Xlinker -rpath -Xlinker "$MOJO_LIBRARY_RUNTIME_RPATH" \
    -o "$TMP_LIBRARY"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    --portable-component '$ORIGIN/../mojo' "$TMP_LIBRARY" >/dev/null
file -b "$TMP_LIBRARY" | grep -q '^ELF 64-bit.*shared object' || {
    printf 'Compiler erzeugte keine gültige Shared Library: %s\n' "$TMP_LIBRARY" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_LIBRARY"

printf 'Kompiliere kleinen Diagnose-Loader          -> %s\n' "$LOADER"
"$CC" -std=c11 -O2 -Wall -Wextra -Werror \
    "$ROOT/tools/reta_mojo_diagnostics_loader.c" -ldl -o "$TMP_LOADER"
file -b "$TMP_LOADER" | grep -q '^ELF 64-bit' || {
    printf 'C-Compiler erzeugte keinen gültigen Loader: %s\n' "$TMP_LOADER" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_LOADER"

# Publish the pair only after both compilers, RUNPATH sanitation and stamps
# succeeded.  A failed rebuild leaves the previous compatible pair untouched.
mv -f "$TMP_LIBRARY" "$LIBRARY"
mv -f "$TMP_LIBRARY.reta-source-id" "$LIBRARY.reta-source-id"
mv -f "$TMP_LOADER" "$LOADER"
mv -f "$TMP_LOADER.reta-source-id" "$LOADER.reta-source-id"

# Remove default standalone copies only after the shared bundle was built
# successfully.  They can still be requested explicitly from scripts/build.sh.
for old_target in \
    reta-mojo-table-generation reta-mojo-output-syntax \
    reta-mojo-console-io reta-mojo-table-output
do
    rm -f "$TARGET_DIR/$old_target" "$TARGET_DIR/$old_target.reta-source-id"
done

trap - EXIT HUP INT TERM
cleanup_tmp
printf 'Gemeinsame Diagnose-ABI 1 erzeugt.\n'
