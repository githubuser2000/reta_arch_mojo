#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/build_prompt_shared.sh [--dry-run] [--] [MOJO_BUILD_OPTION ...]

Baut die nächste Prompt-Shared-Library-Zielgruppe:
  - target/lib/reta/libreta_prompt_mojo.so
  - target/lib/reta/libreta_prompt_interactive_mojo.so
  - target/bin/rpb als dünner One-shot-Starter ohne interactive Library
  - target/bin/rp, rpl und rpe als dünne interaktive Starter

Diese Stage baut die offiziellen Prompt-Shared-Libraries und dünnen Prompt-Starter.
build-all.sh ruft sie nach dem Core-Shared-Build auf.
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
Prompt-Shared-Library-Buildplan:
  src/reta_prompt_abi.mojo             --emit shared-lib -> target/lib/reta/libreta_prompt_mojo.so
  src/reta_prompt_interactive_abi.mojo --emit shared-lib -> target/lib/reta/libreta_prompt_interactive_mojo.so
  tools/reta_prompt_loader.c                              -> target/bin/rpb
  tools/reta_prompt_loader.c                              -> target/bin/rp
  tools/reta_prompt_loader.c                              -> target/bin/rpl
  tools/reta_prompt_loader.c                              -> target/bin/rpe
  rpb lädt nur libreta_prompt_mojo.so, nicht libreta_prompt_interactive_mojo.so
PLAN
    exit 0
fi

mkdir -p "$TARGET_DIR" "$LIB_DIR" "$RUNTIME_LINK_DIR"
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

PROMPT_LIBRARY="$LIB_DIR/libreta_prompt_mojo.so"
INTERACTIVE_LIBRARY="$LIB_DIR/libreta_prompt_interactive_mojo.so"
TMP_PROMPT_LIBRARY="$LIB_DIR/.libreta_prompt_mojo.so.tmp.$$"
TMP_INTERACTIVE_LIBRARY="$LIB_DIR/.libreta_prompt_interactive_mojo.so.tmp.$$"
TMP_PROMPT_LOADER="$TARGET_DIR/.reta-prompt-loader.tmp.$$"

cleanup_tmp() {
    rm -f "$TMP_PROMPT_LIBRARY" "$TMP_PROMPT_LIBRARY.reta-source-id" \
        "$TMP_INTERACTIVE_LIBRARY" "$TMP_INTERACTIVE_LIBRARY.reta-source-id" \
        "$TMP_PROMPT_LOADER" "$TMP_PROMPT_LOADER.reta-source-id"
    for name in rp rpl rpe rpb; do
        rm -f "$TARGET_DIR/.${name}.tmp.$$" \
            "$TARGET_DIR/.${name}.tmp.$$.reta-source-id"
    done
}
trap cleanup_tmp EXIT HUP INT TERM
cleanup_tmp

printf 'Kompiliere gemeinsame Prompt-Bibliothek      -> %s\n' "$PROMPT_LIBRARY"
"$MOJO" build -I src "$@" --emit shared-lib \
    src/reta_prompt_abi.mojo \
    -Xlinker -rpath -Xlinker "$MOJO_LIBRARY_RUNTIME_RPATH" \
    -o "$TMP_PROMPT_LIBRARY"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    --portable-component '$ORIGIN/../mojo' "$TMP_PROMPT_LIBRARY" >/dev/null
file -b "$TMP_PROMPT_LIBRARY" | grep -q '^ELF 64-bit.*shared object' || {
    printf 'Compiler erzeugte keine gültige Prompt-Shared-Library: %s\n' "$TMP_PROMPT_LIBRARY" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_PROMPT_LIBRARY"

printf 'Kompiliere interaktive Prompt-Bibliothek     -> %s\n' "$INTERACTIVE_LIBRARY"
"$MOJO" build -I src "$@" --emit shared-lib \
    src/reta_prompt_interactive_abi.mojo \
    -Xlinker -rpath -Xlinker "$MOJO_LIBRARY_RUNTIME_RPATH" \
    -o "$TMP_INTERACTIVE_LIBRARY"
python3 "$ROOT/tools/sanitize_mojo_runpath.py" \
    --portable-component '$ORIGIN/../mojo' "$TMP_INTERACTIVE_LIBRARY" >/dev/null
file -b "$TMP_INTERACTIVE_LIBRARY" | grep -q '^ELF 64-bit.*shared object' || {
    printf 'Compiler erzeugte keine gültige interaktive Prompt-Bibliothek: %s\n' "$TMP_INTERACTIVE_LIBRARY" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_INTERACTIVE_LIBRARY"

printf 'Kompiliere dünne Prompt-Starter              -> %s\n' "$TARGET_DIR/{rp,rpl,rpe,rpb}"
"$CC" -std=c11 -O2 -Wall -Wextra -Werror \
    "$ROOT/tools/reta_prompt_loader.c" -ldl -o "$TMP_PROMPT_LOADER"
file -b "$TMP_PROMPT_LOADER" | grep -q '^ELF 64-bit' || {
    printf 'C-Compiler erzeugte keinen gültigen Prompt-Starter: %s\n' "$TMP_PROMPT_LOADER" >&2
    exit 1
}
RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TMP_PROMPT_LOADER"

for name in rp rpl rpe rpb; do
    tmp_loader="$TARGET_DIR/.${name}.tmp.$$"
    cp "$TMP_PROMPT_LOADER" "$tmp_loader"
    cp "$TMP_PROMPT_LOADER.reta-source-id" "$tmp_loader.reta-source-id"
    mv -f "$tmp_loader" "$TARGET_DIR/$name"
    mv -f "$tmp_loader.reta-source-id" "$TARGET_DIR/$name.reta-source-id"
done

mv -f "$TMP_PROMPT_LIBRARY" "$PROMPT_LIBRARY"
mv -f "$TMP_PROMPT_LIBRARY.reta-source-id" "$PROMPT_LIBRARY.reta-source-id"
mv -f "$TMP_INTERACTIVE_LIBRARY" "$INTERACTIVE_LIBRARY"
mv -f "$TMP_INTERACTIVE_LIBRARY.reta-source-id" "$INTERACTIVE_LIBRARY.reta-source-id"
rm -f "$TMP_PROMPT_LOADER" "$TMP_PROMPT_LOADER.reta-source-id"

trap - EXIT HUP INT TERM
cleanup_tmp
printf '%s\n' 'Gemeinsame Prompt-ABI 1 erzeugt.'
