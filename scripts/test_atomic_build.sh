#!/usr/bin/env sh
# Exercise publication and rollback paths without requiring the Modular compiler.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CC=${CC:-cc}
for tool in "$CC" readelf file sha256sum; do
    command -v "$tool" >/dev/null 2>&1 || {
        printf 'Benötigtes Testwerkzeug fehlt: %s\n' "$tool" >&2
        exit 77
    }
done

TMP=$(mktemp -d "${TMPDIR:-/tmp}/reta-atomic-build.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
RUNTIME="$TMP/runtime"
TARGET="$TMP/target/bin"
LIBDIR="$TMP/target/lib/reta"
mkdir -p "$RUNTIME" "$TARGET" "$LIBDIR"
for library in \
    libKGENCompilerRTShared.so \
    libAsyncRTMojoBindings.so \
    libMSupportGlobals.so \
    libAsyncRTRuntimeGlobals.so \
    libNVPTX.so
do
    : > "$RUNTIME/$library"
done

TEMPLATE_C="$TMP/template.c"
printf '%s\n' 'int main(void) { return 0; }' > "$TEMPLATE_C"
"$CC" "$TEMPLATE_C" \
    -Wl,-rpath,/tmp/fake-mojo-runtime:'$ORIGIN/../lib/mojo' \
    -o "$TMP/template-executable"
printf '%s\n' 'int fake_shared_symbol(void) { return 1; }' > "$TEMPLATE_C"
"$CC" -shared -fPIC "$TEMPLATE_C" \
    -Wl,-rpath,/tmp/fake-mojo-runtime:'$ORIGIN/../mojo' \
    -o "$TMP/template-library.so"
rm -f "$TEMPLATE_C"

FAKE_MOJO="$TMP/fake-mojo"
cat > "$FAKE_MOJO" <<'FAKE'
#!/usr/bin/env sh
set -eu
out=
source_file=
shared=0
expect=
for argument in "$@"; do
    case "$expect" in
        output) out=$argument; expect=; continue ;;
        emit) [ "$argument" = shared-lib ] && shared=1; expect=; continue ;;
    esac
    case "$argument" in
        -o) expect=output ;;
        --emit) expect=emit ;;
        *.mojo) source_file=$argument ;;
    esac
done
[ -n "$out" ] || { printf '%s\n' 'fake compiler: -o fehlt' >&2; exit 2; }
if [ "${FAKE_FAIL_SOURCE:-}" = "$source_file" ]; then
    : > "$out"
    exit 9
fi
if [ "$shared" -eq 1 ]; then
    cp "$FAKE_SO_TEMPLATE" "$out"
else
    cp "$FAKE_EXE_TEMPLATE" "$out"
fi
chmod 0755 "$out"
FAKE
chmod +x "$FAKE_MOJO"

# Seed the second regular and heavy targets with known-good old files.  The
# forced compiler failures must not replace or touch them.
printf '%s\n' 'old regular binary' > "$TARGET/reta-mojo-table"
printf '%s\n' 'old heavy binary' > "$TARGET/reta-mojo-schema"
chmod 0755 "$TARGET/reta-mojo-table" "$TARGET/reta-mojo-schema"
regular_before=$(sha256sum "$TARGET/reta-mojo-table" | awk '{print $1}')
heavy_before=$(sha256sum "$TARGET/reta-mojo-schema" | awk '{print $1}')

cd "$ROOT"
COMMON_ENV="RETA_TARGET_DIR=$TARGET RETA_TARGET_LIB_DIR=$LIBDIR RETA_MOJO_RUNTIME_LIBDIR=$RUNTIME MOJO_BIN=$FAKE_MOJO FAKE_EXE_TEMPLATE=$TMP/template-executable FAKE_SO_TEMPLATE=$TMP/template-library.so"

set +e
env $COMMON_ENV FAKE_FAIL_SOURCE=src/table_main.mojo \
    "$ROOT/scripts/build.sh" > "$TMP/regular-failed.log" 2>&1
regular_status=$?
env $COMMON_ENV FAKE_FAIL_SOURCE=src/schema_main.mojo \
    "$ROOT/scripts/build-heavy.sh" > "$TMP/heavy-failed.log" 2>&1
heavy_status=$?
set -e

[ "$regular_status" -eq 9 ] || {
    printf 'Regulärer Compilerfehlerstatus: erwartet 9, erhalten %s\n' \
        "$regular_status" >&2
    exit 1
}
[ "$heavy_status" -eq 9 ] || {
    printf 'Heavy-Compilerfehlerstatus: erwartet 9, erhalten %s\n' \
        "$heavy_status" >&2
    exit 1
}
[ "$regular_before" = "$(sha256sum "$TARGET/reta-mojo-table" | awk '{print $1}')" ]
[ "$heavy_before" = "$(sha256sum "$TARGET/reta-mojo-schema" | awk '{print $1}')" ]
[ -x "$TARGET/reta-mojo-native" ]
[ -x "$TARGET/reta-mojo-semantics" ]
[ -f "$TARGET/reta-mojo-native.reta-source-id" ]
[ -f "$TARGET/reta-mojo-semantics.reta-source-id" ]

# The coupled loader/library path is tested independently and must publish two
# artifacts with the same content ID only after both compilers succeeded.
env $COMMON_ENV "$ROOT/scripts/build_diagnostics_shared.sh" \
    > "$TMP/shared.log"
[ -x "$TARGET/reta-mojo-diagnostics" ]
[ -f "$LIBDIR/libreta-mojo-diagnostics.so" ]
cmp "$TARGET/reta-mojo-diagnostics.reta-source-id" \
    "$LIBDIR/libreta-mojo-diagnostics.so.reta-source-id"

if find "$TARGET" "$LIBDIR" -maxdepth 1 \
    -name '.*.tmp.*' -print -quit | grep -q .; then
    printf '%s\n' 'Temporäres Buildartefakt blieb nach dem Test zurück.' >&2
    exit 1
fi

printf '%s\n' \
    'Atomare Veröffentlichung regulärer und schwerer Ziele: bestanden' \
    'Fehlerstatus und vorherige Binaries bei Abbruch: bestanden' \
    'Atomare Shared-Diagnostics-Paarbildung: bestanden'
