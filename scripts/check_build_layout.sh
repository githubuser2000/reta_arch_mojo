#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
TARGET_LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}

expected='reta grundStrukHtml reta-mojo-native reta-mojo-table reta-mojo-tags reta-mojo-i18n reta-mojo-package-integrity reta-mojo-exports reta-mojo-facade reta-mojo-workflow reta-mojo-sheaves reta-mojo-diagnostics reta-mojo-domain-probe reta-mojo-architecture-probe reta-mojo-combi-join reta-native reta-mojo-compat-bin reta-prompt-native reta-prompt-complete grundStrukHtml-native generate-html-native generate-readme-native reta-extract-html-classes-native'
CURRENT_SOURCE_ID=$("$ROOT/scripts/current_source_id.sh")

heavy='reta-mojo-semantics reta-mojo-schema reta-mojo-architecture reta-mojo-boundaries reta-mojo-contracts reta-mojo-witnesses reta-mojo-coherence reta-mojo-traces reta-mojo-impact reta-mojo-migration reta-mojo-rehearsal reta-mojo-activation reta-mojo-validation reta-mojo-progress reta-mojo-persistence reta-mojo-execution-network reta-mojo-parallel-execution reta-mojo-row-preparation'

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
        *)
            check_target "$name" scripts/build.sh
            ;;
    esac
done

CORE_LIBRARY="$TARGET_LIB_DIR/libreta-core.so"
if [ ! -f "$CORE_LIBRARY" ]; then
    printf 'Fehler: erwartete Core-Shared-Library fehlt: %s\n' "$CORE_LIBRARY" >&2
    exit 1
fi
if ! file -b "$CORE_LIBRARY" | grep -q '^ELF 64-bit.*shared object'; then
    printf 'Fehler: keine native ELF-Core-Shared-Library: %s\n' "$CORE_LIBRARY" >&2
    exit 1
fi
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
RETA_REBUILD_COMMAND=scripts/build_core_shared.sh \
RETA_CURRENT_SOURCE_ID="$CURRENT_SOURCE_ID" \
    "$ROOT/scripts/check_mojo_binary_freshness.sh" "$CORE_LIBRARY"

for stamped in "$TARGET_DIR/reta" "$TARGET_DIR/grundStrukHtml" "$CORE_LIBRARY"; do
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
