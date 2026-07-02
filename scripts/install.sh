#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PREFIX=${PREFIX:-/usr/local}
DESTDIR=${DESTDIR:-}
BINDIR=${BINDIR:-$PREFIX/bin}
LIBEXECDIR=${LIBEXECDIR:-$PREFIX/lib/reta}
DATADIR=${DATADIR:-$PREFIX/share/reta}
MANDIR=${MANDIR:-$PREFIX/share/man}
INSTALL_MOJO_RUNTIME=${RETA_INSTALL_MOJO_RUNTIME:-1}

stage_path() {
    printf '%s%s\n' "$DESTDIR" "$1"
}

relative_path() {
    from_dir=$1
    to_path=$2
    if command -v realpath >/dev/null 2>&1; then
        realpath -m --relative-to="$from_dir" "$to_path"
        return
    fi
    python3 - "$from_dir" "$to_path" <<'PY'
import os
import sys
print(os.path.relpath(sys.argv[2], sys.argv[1]))
PY
}

require_file() {
    [ -f "$1" ] || {
        printf 'Fehlende Installationsquelle: %s\n' "$1" >&2
        exit 2
    }
}

require_file "$ROOT/python_reference/csv/religion.csv"
require_file "$ROOT/assets/parameter_aliases.tsv"
require_file "$ROOT/target/bin/reta-native"
require_file "$ROOT/target/bin/reta-mojo-compat-bin"
require_file "$ROOT/target/bin/generate-html-native"
require_file "$ROOT/man/generate_html.1"

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

install -d "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \
    "$STAGE_LIBEXECDIR/bin" "$STAGE_LIBEXECDIR/scripts" \
    "$STAGE_LIBEXECDIR/target/bin" "$STAGE_LIBEXECDIR/target/lib/mojo" \
    "$STAGE_DATADIR/csv" "$STAGE_DATADIR/assets" \
    "$STAGE_MANDIR/man1"

install -m 0644 "$ROOT/man/generate_html.1" "$STAGE_MANDIR/man1/generate_html.1"

# Architecture-independent immutable data belongs below share/reta.
cp -a "$ROOT/python_reference/csv/." "$STAGE_DATADIR/csv/"
cp -a "$ROOT/assets/." "$STAGE_DATADIR/assets/"

# Keep the compatibility tree private. Its historical csv/ path is redirected
# to the canonical shared-data directory instead of duplicating the tables.
rm -rf "$STAGE_LIBEXECDIR/python_reference"
cp -a "$ROOT/python_reference" "$STAGE_LIBEXECDIR/python_reference"
rm -rf "$STAGE_LIBEXECDIR/python_reference/csv"
CSV_LINK=$(relative_path "$LIBEXECDIR/python_reference" "$DATADIR/csv")
ln -s "$CSV_LINK" "$STAGE_LIBEXECDIR/python_reference/csv"
find "$STAGE_LIBEXECDIR/python_reference" -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
find "$STAGE_LIBEXECDIR/python_reference" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true

# Native catalogs remain at the source-compatible private path through one
# relative link; the physical files still live exclusively below share/reta.
rm -rf "$STAGE_LIBEXECDIR/assets"
ASSET_LINK=$(relative_path "$LIBEXECDIR" "$DATADIR/assets")
ln -s "$ASSET_LINK" "$STAGE_LIBEXECDIR/assets"

rm -rf "$STAGE_LIBEXECDIR/bin"
cp -a "$ROOT/bin" "$STAGE_LIBEXECDIR/bin"
install -m 0755 "$ROOT/scripts/find_mojo_runtime.sh" \
    "$STAGE_LIBEXECDIR/scripts/find_mojo_runtime.sh"

rm -rf "$STAGE_LIBEXECDIR/target/bin"
install -d "$STAGE_LIBEXECDIR/target/bin"
for executable in "$ROOT"/target/bin/*; do
    [ -f "$executable" ] || continue
    install -m 0755 "$executable" "$STAGE_LIBEXECDIR/target/bin/$(basename -- "$executable")"
done

if [ "$INSTALL_MOJO_RUNTIME" != 0 ]; then
    RUNTIME_DIR=$($ROOT/scripts/find_mojo_runtime.sh)
    for library in \
        libKGENCompilerRTShared.so \
        libAsyncRTMojoBindings.so \
        libMSupportGlobals.so \
        libAsyncRTRuntimeGlobals.so \
        libNVPTX.so
    do
        require_file "$RUNTIME_DIR/$library"
        install -m 0755 "$RUNTIME_DIR/$library" \
            "$STAGE_LIBEXECDIR/target/lib/mojo/$library"
    done
fi

# Public commands are relative links into the private runtime tree. readlink -f
# in the launchers therefore reconstructs LIBEXECDIR as their runtime root.
for launcher in "$ROOT"/bin/*; do
    [ -f "$launcher" ] || [ -L "$launcher" ] || continue
    name=$(basename -- "$launcher")
    case "$name" in
        mojo-real|mojo-runtime-exec) continue ;;
    esac
    target=$(relative_path "$BINDIR" "$LIBEXECDIR/bin/$name")
    rm -f "$STAGE_BINDIR/$name"
    ln -s "$target" "$STAGE_BINDIR/$name"
done

cat > "$STAGE_LIBEXECDIR/INSTALL_LAYOUT" <<LAYOUT
prefix=$PREFIX
bindir=$BINDIR
libexecdir=$LIBEXECDIR
datadir=$DATADIR
csvdir=$DATADIR/csv
assetdir=$DATADIR/assets
mandir=$MANDIR
LAYOUT

printf 'Reta installiert:\n'
printf '  Programme:      %s\n' "$BINDIR"
printf '  Private Laufzeit: %s\n' "$LIBEXECDIR"
printf '  CSV-Daten:      %s\n' "$DATADIR/csv"
printf '  Assets:         %s\n' "$DATADIR/assets"
printf '  Manpage:        %s\n' "$MANDIR/man1/generate_html.1"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:    %s\n' "$DESTDIR"
fi
