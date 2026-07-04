#!/usr/bin/env sh
# Compute a content ID for every input that can change compiled Mojo artifacts.
# The historical filename is retained because launchers and installed layouts
# already refer to it.  Unlike the release manifest, this ID is calculated from
# the live files and therefore cannot silently remain stale after an edit.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# Tests and specialised tooling may deliberately provide a fixed manifest.
if [ -n "${RETA_SOURCE_MANIFEST:-}" ]; then
    [ -f "$RETA_SOURCE_MANIFEST" ] || exit 1
    sha256sum "$RETA_SOURCE_MANIFEST" | awk '{print $1}'
    exit 0
fi

[ -d "$ROOT/src" ] || exit 1
cd "$ROOT"
TMP=$(mktemp "${TMPDIR:-/tmp}/reta-build-inputs.XXXXXX")
trap 'rm -f "$TMP"' EXIT HUP INT TERM

{
    find src assets -type f -print0 2>/dev/null || true
    printf '%s\0' \
        scripts/build.sh \
        scripts/build-heavy.sh \
        scripts/build-all.sh \
        scripts/build_diagnostics_shared.sh \
        scripts/configure_mojo_runtime.sh \
        scripts/stamp_mojo_binary.sh \
        tools/sanitize_mojo_runpath.py \
        tools/reta_mojo_diagnostics_loader.c \
        bin/mojo-real
} | LC_ALL=C sort -zu | xargs -0 sha256sum > "$TMP"

# Include symlink destinations as build inputs as well.  None are required, but
# this prevents a future source symlink change from escaping the content ID.
find src assets -type l -printf '%p -> %l\n' 2>/dev/null \
    | LC_ALL=C sort >> "$TMP" || true

sha256sum "$TMP" | awk '{print $1}'
