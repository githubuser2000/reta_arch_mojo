#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
TARGET_LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}

# One durable entry point for every installable native artifact.  The heavy
# architecture owners are compiled first; the regular build then creates the
# user-facing programs and the shared diagnostic library.  Every individual
# output is published atomically by the subordinate scripts.
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
    "$ROOT/scripts/build-heavy.sh"
RETA_TARGET_DIR="$TARGET_DIR" \
RETA_TARGET_LIB_DIR="$TARGET_LIB_DIR" \
    "$ROOT/scripts/build.sh"

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
