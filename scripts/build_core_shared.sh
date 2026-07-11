#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/build_core_shared.sh [--dry-run] [--] [MOJO_BUILD_OPTION ...]

Baut die erste produktive Core-Shared-Library-Zielgruppe:
  - target/lib/reta/libreta_core_mojo.so
  - target/bin/reta als dünner C-Starter
  - target/bin/grundStrukHtml als dünner C-Starter

Die historischen nativen Executables reta-native und grundStrukHtml-native
bleiben unverändert und werden weiterhin von scripts/build.sh gebaut.  Diese
Stage ergänzt die neue ABI-Spur, ohne den bisherigen Buildpfad zu zerstören.
USAGE
        exit 0
        ;;
esac

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=1
    shift
fi
if [ "${1:-}" = "--" ]; then
    shift
fi

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
MOJO_LIBRARY_RUNTIME_RPATH='$ORIGIN:$ORIGIN/mojo:$ORIGIN/../mojo'
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
CC=${CC:-cc}
BUILD_SOURCE_ID=${RETA_BUILD_SOURCE_ID:-$("$ROOT/scripts/current_source_id.sh")}

if [ "$DRY_RUN" = 1 ]; then
    cat <<'PLAN'
Core-Shared-Library-Buildplan:
  src/reta_core_abi.mojo --emit shared-lib -> target/lib/reta/libreta_core_mojo.so
  tools/reta_core_loader.c                 -> target/bin/reta
  tools/reta_core_loader.c                 -> target/bin/grundStrukHtml
  beide Starter laden dieselbe libreta_core_mojo.so und prüfen Source-ID-Sidecars
PLAN
    exit 0
fi

mkdir -p "$TARGET_DIR" "$LIB_DIR" "$RUNTIME_LINK_DIR"
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

LIBRARY="$LIB_DIR/libreta_core_mojo.so"
RETA_LOADER="$TARGET_DIR/reta"
GRUND_LOADER="$TARGET_DIR/grundStrukHtml"
TMP_LIBRARY="$LIB_DIR/.libreta_core_mojo.so.tmp.$$"
TMP_RETA_LOADER="$TARGET_DIR/.reta.tmp.$$"
TMP_GRUND_LOADER="$TARGET_DIR/.grundStrukHtml.tmp.$$"
cleanup_tmp() {
    rm -f "$TMP_LIBRARY" "$TMP_LIBRARY.reta-source-id" \
        "$TMP_RETA_LOADER" "$TMP_RETA_LOADER.reta-source-id" \
        "$TMP_GRUND_LOADER" "$TMP_GRUND_LOADER.reta-source-id"
}
trap cleanup_tmp EXIT HUP INT TERM
cleanup_tmp

printf 'Kompiliere gemeinsame reta-Core-Bibliothek -> %s\n' "$LIBRARY"
"$MOJO" build -I src "$@" --emit shared-lib \
    src/reta_core_abi.mojo \
    -Xlinker -rpath -Xlinker "$MOJO_LIBRARY_RUNTIME_RPATH" \
    -o "$TMP_LIBRARY"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    --portable-component '$ORIGIN/../mojo' "$TMP_LIBRARY" >/dev/null
file -b "$TMP_LIBRARY" | grep -q '^ELF 64-bit.*shared object' || {
    printf 'Compiler erzeugte keine gültige Core-Shared-Library: %s\n' "$TMP_LIBRARY" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_LIBRARY"

printf 'Kompiliere dünnen reta-Starter           -> %s\n' "$RETA_LOADER"
"$CC" -std=c11 -O2 -Wall -Wextra -Werror \
    "$ROOT/tools/reta_core_loader.c" -ldl -o "$TMP_RETA_LOADER"
file -b "$TMP_RETA_LOADER" | grep -q '^ELF 64-bit' || {
    printf 'C-Compiler erzeugte keinen gültigen reta-Starter: %s\n' "$TMP_RETA_LOADER" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_RETA_LOADER"

printf 'Kompiliere dünnen grundStrukHtml-Starter -> %s\n' "$GRUND_LOADER"
cp "$TMP_RETA_LOADER" "$TMP_GRUND_LOADER"
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_GRUND_LOADER"

mv -f "$TMP_LIBRARY" "$LIBRARY"
mv -f "$TMP_LIBRARY.reta-source-id" "$LIBRARY.reta-source-id"
mv -f "$TMP_RETA_LOADER" "$RETA_LOADER"
mv -f "$TMP_RETA_LOADER.reta-source-id" "$RETA_LOADER.reta-source-id"
mv -f "$TMP_GRUND_LOADER" "$GRUND_LOADER"
mv -f "$TMP_GRUND_LOADER.reta-source-id" "$GRUND_LOADER.reta-source-id"

trap - EXIT HUP INT TERM
cleanup_tmp
printf '%s\n' 'Gemeinsame Core-ABI 1 erzeugt.'
