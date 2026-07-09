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

maybe_require_stamp() {
    require_file "$1"
    require_file "$1.reta-source-id"
}

require_file "$ROOT/python_reference/csv/religion.csv"
require_file "$ROOT/assets/parameter_aliases.tsv"
for required_target in reta-native reta-mojo-compat-bin generate-html-native; do
    maybe_require_stamp "$TARGETDIR/$required_target"
done
require_file "$ROOT/man/generate_html.1"
require_file "$(reta_artifact_install_target_file "$ROOT")"

CORE_LIBRARY="$TARGETLIBDIR/$(reta_artifact_core_shared_libraries | sed -n '1p')"
PROMPT_LIBRARY="$TARGETLIBDIR/$(reta_artifact_prompt_shared_libraries | sed -n '1p')"
PROMPT_INTERACTIVE_LIBRARY="$TARGETLIBDIR/$(reta_artifact_prompt_shared_libraries | sed -n '2p')"

CORE_STARTER_AVAILABLE=0
for starter in $(reta_artifact_core_starters); do
    if [ -f "$TARGETDIR/$starter" ]; then
        CORE_STARTER_AVAILABLE=1
        maybe_require_stamp "$TARGETDIR/$starter"
    fi
done
if [ "$CORE_STARTER_AVAILABLE" = 1 ]; then
    maybe_require_stamp "$CORE_LIBRARY"
fi

PROMPT_STARTER_AVAILABLE=0
INTERACTIVE_PROMPT_STARTER_AVAILABLE=0
for starter in $(reta_artifact_prompt_starters); do
    if [ -f "$TARGETDIR/$starter" ]; then
        PROMPT_STARTER_AVAILABLE=1
        maybe_require_stamp "$TARGETDIR/$starter"
        case "$starter" in
            rp|rpl|rpe|retaPrompt|retaPrompt.english) INTERACTIVE_PROMPT_STARTER_AVAILABLE=1 ;;
        esac
    fi
done
if [ "$PROMPT_STARTER_AVAILABLE" = 1 ]; then
    maybe_require_stamp "$PROMPT_LIBRARY"
fi
if [ "$INTERACTIVE_PROMPT_STARTER_AVAILABLE" = 1 ] || \
   [ -f "$TARGETDIR/rp" ] || [ -f "$TARGETDIR/rpl" ] || [ -f "$TARGETDIR/rpe" ]; then
    maybe_require_stamp "$PROMPT_INTERACTIVE_LIBRARY"
fi

INSTALL_DIAGNOSTICS=0
DIAGNOSTICS_LIBRARY="$TARGETLIBDIR/$(reta_artifact_diagnostics_shared_libraries | sed -n '1p')"
if [ -f "$TARGETDIR/reta-mojo-diagnostics" ]; then
    INSTALL_DIAGNOSTICS=1
    maybe_require_stamp "$TARGETDIR/reta-mojo-diagnostics"
    maybe_require_stamp "$DIAGNOSTICS_LIBRARY"
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
# Installed wrappers use public compiled binaries from BINDIR and the private
# runtime helpers from LIBEXECDIR. Source-tree wrappers are left unchanged.
find "$STAGE_LIBEXECDIR/bin" -maxdepth 1 -type f -exec sed -i \
    -e "s|\$ROOT/target/bin|$BINDIR|g" \
    -e 's|$ROOT/target/lib/mojo|$ROOT/mojo|g' \
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
    # Compiled executable binaries are installed only as public commands.
    # Their .reta-source-id build sidecars are intentionally not installed.
    install -m 0755 "$executable" "$STAGE_BINDIR/$name"
    INSTALLED_TARGETS=$((INSTALLED_TARGETS + 1))
done < "$ROOT/scripts/install_targets.txt"

INSTALLED_LIBRARIES=0
install_shared_library() {
    source_library=$1
    rebuild_command=$2
    [ -f "$source_library" ] || return 0
    installed_name=$(basename -- "$source_library")
    RETA_TARGET_DIR="$TARGETDIR" \
    RETA_TARGET_LIB_DIR="$TARGETLIBDIR" \
    RETA_REBUILD_COMMAND="$rebuild_command" \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$source_library"
    install -m 0755 "$source_library" \
        "$STAGE_LIBEXECDIR/$installed_name"
    # Shared-library .reta-source-id files stay in the build tree only.
    INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))
}

for library_name in $(reta_artifact_core_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_core_shared.sh
done
for library_name in $(reta_artifact_prompt_shared_libraries); do
    install_shared_library "$TARGETLIBDIR/$library_name" scripts/build_prompt_shared.sh
done

if [ "$INSTALL_DIAGNOSTICS" = 1 ]; then
    install_shared_library "$DIAGNOSTICS_LIBRARY" scripts/build.sh
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

# Public commands: compiled binaries already live directly in BINDIR.  Only
# source-compatible shell wrappers without a compiled public target remain
# relative links into the private runtime tree.
for launcher in "$ROOT"/bin/*; do
    [ -f "$launcher" ] || [ -L "$launcher" ] || continue
    name=$(basename -- "$launcher")
    case "$name" in
        mojo-real|mojo-runtime-exec) continue ;;
    esac
    if [ -x "$STAGE_BINDIR/$name" ] && [ ! -L "$STAGE_BINDIR/$name" ]; then
        continue
    fi
    target=$(relative_path "$BINDIR" "$LIBEXECDIR/bin/$name")
    rm -f "$STAGE_BINDIR/$name"
    ln -s "$target" "$STAGE_BINDIR/$name"
done

# Make accidental source-id leakage a hard installation error.
if find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \( -name '*.reta-source-id' -o -name '*.reta-test-source-id' \) | grep -q .; then
    printf '%s\n' 'Fehler: Source-ID-Sidecars dürfen nicht installiert werden.' >&2
    exit 3
fi

cat > "$STAGE_LIBEXECDIR/INSTALL_LAYOUT" <<LAYOUT
prefix=$PREFIX
bindir=$BINDIR
binarydir=$BINDIR
libexecdir=$LIBEXECDIR
sharedlibdir=$LIBEXECDIR
datadir=$DATADIR
csvdir=$DATADIR/csv
assetdir=$DATADIR/assets
mandir=$MANDIR
compiled_targets=$INSTALLED_TARGETS
compiled_shared_libraries=$INSTALLED_LIBRARIES
installed_source_id_sidecars=0
LAYOUT

printf 'Reta installiert:\n'
printf '  Programme/Binaries: %s\n' "$BINDIR"
printf '  Shared Libraries:   %s\n' "$LIBEXECDIR"
printf '  Private Skripte:    %s/bin\n' "$LIBEXECDIR"
printf '  Compilerziele:      %s\n' "$INSTALLED_TARGETS"
printf '  Shared Libraries:   %s\n' "$INSTALLED_LIBRARIES"
printf '  CSV-Daten:          %s\n' "$DATADIR/csv"
printf '  Assets:             %s\n' "$DATADIR/assets"
printf '  Manpage:            %s\n' "$MANDIR/man1/generate_html.1"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:        %s\n' "$DESTDIR"
fi
