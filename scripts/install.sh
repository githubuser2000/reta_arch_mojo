#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/reta_install_defaults.sh"
. "$ROOT/scripts/reta_artifacts.sh"
. "$ROOT/scripts/reta_manpages.sh"
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
for manpage in $(reta_public_manpages); do
    require_file "$ROOT/man/$manpage"
done
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
STAGE_REFERENCEDIR=$(stage_path "$REFERENCEDIR")
STAGE_MANDIR=$(stage_path "$MANDIR")

install -d "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \
    "$STAGE_DATADIR/csv" "$STAGE_DATADIR/assets" \
    "$STAGE_MANDIR/man1"

strip_executable_bits_outside_bindir() {
    for dir in "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" "$STAGE_REFERENCEDIR" "$STAGE_MANDIR"; do
        [ -d "$dir" ] || continue
        find "$dir" -type f \( -perm -0100 -o -perm -0010 -o -perm -0001 \) -exec chmod a-x {} +
    done
}

assert_no_executable_files_outside_bindir() {
    bad_files=$(
        find "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" "$STAGE_REFERENCEDIR" "$STAGE_MANDIR" \
            -type f \( -perm -0100 -o -perm -0010 -o -perm -0001 \) -print 2>/dev/null || true
    )
    if [ -n "$bad_files" ]; then
        printf '%s\n' 'Fehler: ausführbare Dateien dürfen nur unter BINDIR installiert werden.' >&2
        printf '%s\n' "$bad_files" >&2
        exit 3
    fi
}

for manpage in $(reta_public_manpages); do
    install -m 0644 "$ROOT/man/$manpage" "$STAGE_MANDIR/man1/$manpage"
done

# Architecture-independent immutable data belongs below share/reta.
cp -aL "$ROOT/python_reference/csv/." "$STAGE_DATADIR/csv/"
cp -aL "$ROOT/assets/." "$STAGE_DATADIR/assets/"

# Keep the Python reference tree out of lib/reta. It is architecture-independent
# reference/compatibility material, so its installed home is share/reta.  Do not
# replace subtrees by symlinks: installed layout should not grow launcher/data
# symlink depots either.
rm -rf "$STAGE_LIBEXECDIR/python_reference" "$STAGE_REFERENCEDIR"
cp -aL "$ROOT/python_reference" "$STAGE_REFERENCEDIR"
find "$STAGE_REFERENCEDIR" -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
find "$STAGE_REFERENCEDIR" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true

# Assets are installed physically under share/reta/assets only.  lib/reta is for
# native shared libraries and the Mojo runtime, not data aliases.
rm -rf "$STAGE_LIBEXECDIR/assets"

# Public shell frontends belong directly below BINDIR, never below lib/reta.
# They delegate to compiled targets in BINDIR and to the public runtime helper
# in BINDIR.  No private bin/ or scripts/ directory is installed under lib/reta.
install_public_wrapper() {
    wrapper_name=$1
    wrapper_source=$ROOT/tools/wrappers/$wrapper_name
    [ -f "$wrapper_source" ] || return 0
    install -m 0755 "$wrapper_source" "$STAGE_BINDIR/$wrapper_name"
    sed -i \
        -e "s|\$ROOT/target/bin|$BINDIR|g" \
        -e "s|\$ROOT/tools/wrappers/mojo-runtime-exec|$BINDIR/mojo-runtime-exec|g" \
        "$STAGE_BINDIR/$wrapper_name"
}

install -m 0755 "$ROOT/tools/wrappers/mojo-runtime-exec" "$STAGE_BINDIR/mojo-runtime-exec"
for wrapper_name in $(reta_artifact_public_shell_wrappers); do
    install_public_wrapper "$wrapper_name"
done

rm -rf "$STAGE_LIBEXECDIR/bin" "$STAGE_LIBEXECDIR/scripts"

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
    install -m 0644 "$source_library" \
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
    install -d "$STAGE_LIBEXECDIR/mojo"
    RUNTIME_DIR=$($ROOT/scripts/find_mojo_runtime.sh)
    for library in \
        libKGENCompilerRTShared.so \
        libAsyncRTMojoBindings.so \
        libMSupportGlobals.so \
        libAsyncRTRuntimeGlobals.so \
        libNVPTX.so
    do
        require_file "$RUNTIME_DIR/$library"
        install -m 0644 "$RUNTIME_DIR/$library" \
            "$STAGE_LIBEXECDIR/mojo/$library"
    done
fi

# Public commands are now either compiled files or shell frontends directly
# below BINDIR.  lib/reta intentionally contains no bin/ launcher depot.
# Shared libraries, Mojo runtime files, data, reference files and manpages are
# not public executable commands; strip accidental execute bits from all Reta-
# owned install trees outside BINDIR and then enforce that invariant.
strip_executable_bits_outside_bindir
assert_no_executable_files_outside_bindir

# Make accidental source-id/python-reference leakage into bin/lib a hard installation error.
if find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" \( -name '*.reta-source-id' -o -name '*.reta-test-source-id' \) | grep -q .; then
    printf '%s\n' 'Fehler: Source-ID-Sidecars dürfen nicht installiert werden.' >&2
    exit 3
fi
if [ -e "$STAGE_LIBEXECDIR/python_reference" ]; then
    printf '%s\n' 'Fehler: python_reference darf nicht unter lib/reta installiert werden.' >&2
    exit 3
fi
if [ -e "$STAGE_LIBEXECDIR/bin" ] || [ -e "$STAGE_LIBEXECDIR/scripts" ]; then
    printf '%s\n' 'Fehler: bin/ und scripts/ dürfen nicht unter lib/reta installiert werden.' >&2
    exit 3
fi
if find "$STAGE_BINDIR" "$STAGE_LIBEXECDIR" "$STAGE_DATADIR" -type l | grep -q .; then
    printf '%s\n' 'Fehler: Installation darf keine Launcher-/Daten-Symlinks erzeugen.' >&2
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
referencedir=$REFERENCEDIR
mandir=$MANDIR
compiled_targets=$INSTALLED_TARGETS
compiled_shared_libraries=$INSTALLED_LIBRARIES
installed_source_id_sidecars=0
executable_files_outside_bindir=0
LAYOUT

printf 'Reta installiert:\n'
printf '  Programme/Binaries: %s\n' "$BINDIR"
printf '  Shared Libraries:   %s\n' "$LIBEXECDIR"
printf '  Compilerziele:      %s\n' "$INSTALLED_TARGETS"
printf '  Shared Libraries:   %s\n' "$INSTALLED_LIBRARIES"
printf '  CSV-Daten:          %s\n' "$DATADIR/csv"
printf '  Assets:             %s\n' "$DATADIR/assets"
printf '  Python-Referenz:    %s\n' "$REFERENCEDIR"
printf '  Manpages:           %s/man1/{generate_html,reta,rp,rpl,rpe,rpb}.1\n' "$MANDIR"
if [ -n "$DESTDIR" ]; then
    printf '  Paketwurzel:        %s\n' "$DESTDIR"
fi
