#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
reta_install_set_defaults
INSTALL_MOJO_RUNTIME=${RETA_INSTALL_MOJO_RUNTIME:-1}
TARGETDIR=${RETA_TARGET_DIR:-$ROOT/target/bin}
TARGETROOT=$(dirname -- "$TARGETDIR")
TARGETLIBDIR=${RETA_TARGET_LIB_DIR:-$TARGETROOT/lib/reta}

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
for required_target in reta-native reta-mojo-compat-bin generate-html-native; do
    require_file "$TARGETDIR/$required_target"
done
require_file "$ROOT/man/generate_html.1"
require_file "$(reta_artifact_install_target_file "$ROOT")"

for starter in $(reta_artifact_core_starters) $(reta_artifact_prompt_starters); do
    require_file "$TARGETDIR/$starter"
    require_file "$TARGETDIR/$starter.reta-source-id"
done
for library_name in $(reta_artifact_core_shared_libraries) $(reta_artifact_prompt_shared_libraries); do
    require_file "$TARGETLIBDIR/$library_name"
    require_file "$TARGETLIBDIR/$library_name.reta-source-id"
done


INSTALL_DIAGNOSTICS=0
DIAGNOSTICS_LIBRARY="$TARGETLIBDIR/$(reta_artifact_diagnostics_shared_libraries | sed -n '1p')"
if [ -f "$TARGETDIR/reta-mojo-diagnostics" ]; then
    INSTALL_DIAGNOSTICS=1
    LOADER_STAMP="$TARGETDIR/reta-mojo-diagnostics.reta-source-id"
    require_file "$DIAGNOSTICS_LIBRARY"
    require_file "$DIAGNOSTICS_LIBRARY.reta-source-id"
    require_file "$LOADER_STAMP"
fi

STAGE_BINDIR=$(stage_path "$BINDIR")
STAGE_LIBEXECDIR=$(stage_path "$LIBEXECDIR")
STAGE_DATADIR=$(stage_path "$DATADIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

install -d "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \
    "$STAGE_LIBEXECDIR/bin" "$STAGE_LIBEXECDIR/scripts" \
    "$STAGE_LIBEXECDIR/mojo" \
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
# Installed wrappers use the flat LIBEXECDIR runtime instead of the source
# tree's target/bin directory.  Source-tree wrappers are left unchanged.
find "$STAGE_LIBEXECDIR/bin" -maxdepth 1 -type f -exec sed -i \
    -e 's|\$ROOT/target/bin|\$ROOT|g' \
    -e 's|\$ROOT/target/lib/mojo|\$ROOT/mojo|g' \
    {} +
install -m 0755 "$ROOT/scripts/find_mojo_runtime.sh" \
    "$STAGE_LIBEXECDIR/scripts/find_mojo_runtime.sh"
install -m 0755 "$ROOT/scripts/check_mojo_binary_freshness.sh" \
    "$STAGE_LIBEXECDIR/scripts/check_mojo_binary_freshness.sh"
install -m 0755 "$ROOT/scripts/current_source_id.sh" \
    "$STAGE_LIBEXECDIR/scripts/current_source_id.sh"
install -m 0755 "$ROOT/scripts/select_reference_python.sh" \
    "$STAGE_LIBEXECDIR/scripts/select_reference_python.sh"

rm -rf "$STAGE_LIBEXECDIR/target"
CURRENT_SOURCE_ID=$("$ROOT/scripts/current_source_id.sh")
INSTALLED_TARGETS=0
while IFS= read -r name || [ -n "$name" ]; do
    case "$name" in
        ''|'#'*) continue ;;
    esac
    executable="$TARGETDIR/$name"
    [ -f "$executable" ] || continue
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND=scripts/build-all.sh \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$executable"
    install -m 0755 "$executable" "$STAGE_LIBEXECDIR/$name"
    install -m 0644 "$executable.reta-source-id" "$STAGE_LIBEXECDIR/$name.reta-source-id"
    INSTALLED_TARGETS=$((INSTALLED_TARGETS + 1))
done < "$ROOT/scripts/install_targets.txt"

INSTALLED_LIBRARIES=0
install_shared_library() {
    source_library=$1
    rebuild_command=$2
    installed_name=$(basename -- "$source_library")
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND="$rebuild_command" \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$source_library"
    install -m 0755 "$source_library" \
        "$STAGE_LIBEXECDIR/$installed_name"
    install -m 0644 "$source_library.reta-source-id" \
        "$STAGE_LIBEXECDIR/$installed_name.reta-source-id"
    INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))
}

for library_name in $(reta_artifact_core_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_core_shared.sh
done
for library_name in $(reta_artifact_prompt_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_prompt_shared.sh
done

if [ "$INSTALL_DIAGNOSTICS" = 1 ]; then
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND=scripts/build.sh \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$DIAGNOSTICS_LIBRARY"
    install -m 0755 "$DIAGNOSTICS_LIBRARY" \
        "$STAGE_LIBEXECDIR/libreta-mojo-diagnostics.so"
    install -m 0644 "$DIAGNOSTICS_LIBRARY.reta-source-id" \
        "$STAGE_LIBEXECDIR/libreta-mojo-diagnostics.so.reta-source-id"
    install -m 0644 "$LOADER_STAMP" \
        "$STAGE_LIBEXECDIR/reta-mojo-diagnostics.reta-source-id"
    INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))
fi

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
            "$STAGE_LIBEXECDIR/mojo/$library"
    done
fi

# Public commands are relative links into the private runtime tree.  Prefer
# flat installed native targets; keep shell dispatchers only where no compiled
# command with the public name exists.
for launcher in "$ROOT"/bin/*; do
    [ -f "$launcher" ] || [ -L "$launcher" ] || continue
    name=$(basename -- "$launcher")
    case "$name" in
        mojo-real|mojo-runtime-exec) continue ;;
    esac
    case "$name" in
        reta|grundStrukHtml|rp|rpl|rpe|rpb)
            if [ -x "$STAGE_LIBEXECDIR/$name" ]; then
                target=$(relative_path "$BINDIR" "$LIBEXECDIR/$name")
            else
                target=$(relative_path "$BINDIR" "$LIBEXECDIR/bin/$name")
            fi
            ;;
        *)
            target=$(relative_path "$BINDIR" "$LIBEXECDIR/bin/$name")
            ;;
    esac
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
compiled_targets=$INSTALLED_TARGETS
compiled_shared_libraries=$INSTALLED_LIBRARIES
LAYOUT

printf 'Reta installiert:\n'
printf '  Programme:      %s\n' "$BINDIR"
printf '  Private Laufzeit: %s\n' "$LIBEXECDIR"
printf '  Compilerziele:  %s\n' "$INSTALLED_TARGETS"
printf '  Shared Libraries: %s\n' "$INSTALLED_LIBRARIES"
printf '  CSV-Daten:      %s\n' "$DATADIR/csv"
printf '  Assets:         %s\n' "$DATADIR/assets"
printf '  Manpage:        %s\n' "$MANDIR/man1/generate_html.1"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:    %s\n' "$DESTDIR"
fi
