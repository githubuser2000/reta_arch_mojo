#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/build-all.sh [--optimize-heavy] [--] [MOJO_BUILD_OPTION ...]

Baut zuerst alle schweren, danach alle regulären nativen Ziele. Die nach `--`
stehenden Mojo-Compileroptionen werden unverändert an beide untergeordneten
Build-Skripte und damit an jedes `mojo build` weitergereicht.

`--optimize-heavy` entfernt die absichtliche O0-Vorgabe der besonders großen
Metadatenziele. Ohne diesen Schalter bleiben diese Ziele auch dann O0, wenn für
die übrigen Ziele ein anderer Optimierungsgrad übergeben wurde.

Beispiele:
  scripts/build-all.sh -- --optimization-level 2
  scripts/build-all.sh -- --target-cpu <CPU-NAME> -j 8
  scripts/build-all.sh --optimize-heavy -- --optimization-level 2 -j 8
USAGE
}

HEAVY_DEFAULT_NO_OPT=${RETA_HEAVY_DEFAULT_NO_OPT:-1}
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --optimize-heavy)
            HEAVY_DEFAULT_NO_OPT=0
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

case $HEAVY_DEFAULT_NO_OPT in
    0|1) ;;
    *)
        printf 'RETA_HEAVY_DEFAULT_NO_OPT muss 0 oder 1 sein, erhalten: %s\n' \
            "$HEAVY_DEFAULT_NO_OPT" >&2
        exit 2
        ;;
esac

report_full_build_status() {
    status=$?
    trap - 0
    if [ "$status" -eq 0 ]; then
        printf '%s: JA\n' 'Kompilierung des vollständigen nativen Builds erfolgreich'
    else
        printf '%s: NEIN (Exitstatus %s)\n' 'Kompilierung des vollständigen nativen Builds erfolgreich' "$status" >&2
    fi
    exit "$status"
}
trap report_full_build_status 0
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
TARGET_LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}

# One durable entry point for every installable native artifact.  The heavy
# architecture owners are compiled first; the regular build then creates the
# user-facing programs and the shared diagnostic library.  Every individual
# output is published atomically by the subordinate scripts.  The exact same
# user-supplied Mojo options reach both build classes.
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
RETA_HEAVY_DEFAULT_NO_OPT="$HEAVY_DEFAULT_NO_OPT" \
    "$ROOT/scripts/build-heavy.sh" -- "$@"
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
    "$ROOT/scripts/build.sh" -- "$@"

# A build is successful only if every regular and heavy artifact exists, is a
# valid ELF and carries the live content ID of sources plus build recipes.
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
RETA_CHECK_HEAVY=1 \
    "$ROOT/scripts/check_build_layout.sh"

printf '\n%s\n' 'Vollständiger nativer Build abgeschlossen.'
printf '%s\n' 'Erzeugt und verifiziert wurden alle regulären und schweren Executables sowie die Shared Libraries.'
printf '%s\n' 'Aktuellen Stage-Test nach Änderungen ausführen; vollständige Mojo-Suite vor Releases oder nach mehreren Stages: scripts/test_all.sh'
printf '%s\n' 'Mit zwei zusätzlichen schweren Testzielen: RETA_TEST_HEAVY=1 scripts/test_all.sh'
