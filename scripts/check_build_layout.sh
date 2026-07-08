#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
TARGET_LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
. "$ROOT/scripts/reta_artifacts.sh"

expected=$(reta_artifact_build_executables)
CURRENT_SOURCE_ID=$("$ROOT/scripts/current_source_id.sh")

heavy=$(reta_artifact_heavy_executables)

if ! grep -Eq '^target/$' .gitignore; then
    printf '%s\n' 'Fehler: target/ fehlt in .gitignore.' >&2
    exit 1
fi

for path in bin/*; do
    [ -f "$path" ] || continue
    if file -b "$path" | grep -q '^ELF '; then
        printf 'Fehler: kompiliertes ELF liegt im versionierbaren Launcher-Verzeichnis: %s\n' "$path" >&2
        exit 1
    fi
done

check_target() {
    name=$1
    rebuild=$2
    path="$TARGET_DIR/$name"
    if [ ! -x "$path" ]; then
        printf 'Fehler: erwartetes Executable fehlt: %s\n' "$path" >&2
        exit 1
    fi
    if ! file -b "$path" | grep -q '^ELF 64-bit'; then
        printf 'Fehler: kein natives ELF-Executable: %s\n' "$path" >&2
        exit 1
    fi
    RETA_TARGET_DIR="$TARGET_DIR" \
    RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
    RETA_REBUILD_COMMAND="$rebuild" \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$path"
}

for name in $expected; do
    case "$name" in
        reta|grundStrukHtml)
            check_target "$name" scripts/build_core_shared.sh
            ;;
        rp|rpl|rpe|rpb)
            check_target "$name" scripts/build_prompt_shared.sh
            ;;
        *)
            check_target "$name" scripts/build.sh
            ;;
    esac
done

check_shared_library() {
    library=$1
    rebuild=$2
    description=$3
    if [ ! -f "$library" ]; then
        printf 'Fehler: erwartete %s fehlt: %s\n' "$description" "$library" >&2
        exit 1
    fi
    if ! file -b "$library" | grep -q '^ELF 64-bit.*shared object'; then
        printf 'Fehler: keine native ELF-%s: %s\n' "$description" "$library" >&2
        exit 1
    fi
    RETA_TARGET_DIR="$TARGET_DIR" \
    RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
    RETA_REBUILD_COMMAND="$rebuild" \
    RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
        "$ROOT/scripts/check_mojo_binary_freshness.sh" "$library"
    [ -f "$library.reta-source-id" ] || {
        printf 'Fehler: Source-ID-Sidecar fehlt: %s.reta-source-id\n' "$library" >&2
        exit 1
    }
}

CORE_LIBRARY="$TARGET_LIB_DIR/libreta-core.so"
PROMPT_LIBRARY="$TARGET_LIB_DIR/libreta-prompt.so"
PROMPT_INTERACTIVE_LIBRARY="$TARGET_LIB_DIR/libreta-prompt-interactive.so"
check_shared_library "$CORE_LIBRARY" scripts/build_core_shared.sh 'Core-Shared-Library'
check_shared_library "$PROMPT_LIBRARY" scripts/build_prompt_shared.sh 'Prompt-Shared-Library'
check_shared_library "$PROMPT_INTERACTIVE_LIBRARY" scripts/build_prompt_shared.sh 'interaktive Prompt-Shared-Library'

for stamped in "$TARGET_DIR/reta" "$TARGET_DIR/grundStrukHtml" "$CORE_LIBRARY" \
    "$TARGET_DIR/rp" "$TARGET_DIR/rpl" "$TARGET_DIR/rpe" "$TARGET_DIR/rpb" \
    "$PROMPT_LIBRARY" "$PROMPT_INTERACTIVE_LIBRARY"; do
    [ -f "$stamped.reta-source-id" ] || {
        printf 'Fehler: Source-ID-Sidecar fehlt: %s.reta-source-id\n' "$stamped" >&2
        exit 1
    }
done
if [ "$(sed -n '1p' "$TARGET_DIR/reta.reta-source-id")" != \
     "$(sed -n '1p' "$CORE_LIBRARY.reta-source-id")" ] || \
   [ "$(sed -n '1p' "$TARGET_DIR/grundStrukHtml.reta-source-id")" != \
     "$(sed -n '1p' "$CORE_LIBRARY.reta-source-id")" ]; then
    printf '%s\n' 'Fehler: Core-Dünnstarter und libreta-core haben verschiedene Source-IDs.' >&2
    exit 1
fi
if [ "$(sed -n '1p' "$TARGET_DIR/rpb.reta-source-id")" != \
     "$(sed -n '1p' "$PROMPT_LIBRARY.reta-source-id")" ]; then
    printf '%s\n' 'Fehler: rpb und libreta-prompt haben verschiedene Source-IDs.' >&2
    exit 1
fi
for prompt_starter in rp rpl rpe; do
    if [ "$(sed -n '1p' "$TARGET_DIR/$prompt_starter.reta-source-id")" != \
         "$(sed -n '1p' "$PROMPT_INTERACTIVE_LIBRARY.reta-source-id")" ]; then
        printf 'Fehler: %s und libreta-prompt-interactive haben verschiedene Source-IDs.\n' "$prompt_starter" >&2
        exit 1
    fi
done

DIAGNOSTICS_LIBRARY="$TARGET_LIB_DIR/libreta-mojo-diagnostics.so"
if [ ! -f "$DIAGNOSTICS_LIBRARY" ]; then
    printf 'Fehler: erwartete Shared Library fehlt: %s\n' "$DIAGNOSTICS_LIBRARY" >&2
    exit 1
fi
if ! file -b "$DIAGNOSTICS_LIBRARY" | grep -q '^ELF 64-bit.*shared object'; then
    printf 'Fehler: keine native ELF-Shared-Library: %s\n' "$DIAGNOSTICS_LIBRARY" >&2
    exit 1
fi
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
RETA_REBUILD_COMMAND=scripts/build.sh \
RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
    "$ROOT/scripts/check_mojo_binary_freshness.sh" "$DIAGNOSTICS_LIBRARY"

for stamped in "$TARGET_DIR/reta-mojo-diagnostics" "$DIAGNOSTICS_LIBRARY"; do
    [ -f "$stamped.reta-source-id" ] || {
        printf 'Fehler: Source-ID-Sidecar fehlt: %s.reta-source-id\n' "$stamped" >&2
        exit 1
    }
done
if [ "$(sed -n '1p' "$TARGET_DIR/reta-mojo-diagnostics.reta-source-id")" != \
     "$(sed -n '1p' "$DIAGNOSTICS_LIBRARY.reta-source-id")" ]; then
    printf '%s\n' 'Fehler: Loader und Shared Library haben verschiedene Source-IDs.' >&2
    exit 1
fi

if [ "${RETA_CHECK_HEAVY:-0}" = "1" ]; then
    for name in $heavy; do
        check_target "$name" scripts/build-heavy.sh
    done
fi

printf '%s\n' 'Buildlayout und Build-Frische korrekt:'
printf '  Launcher:     %s/bin\n' "$ROOT"
printf '  Executables: %s\n' "$TARGET_DIR"
printf '  Libraries:   %s\n' "$TARGET_LIB_DIR"
