#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
RUNTIME_LINK_DIR=${RETA_MOJO_RUNTIME_LINK_DIR:-"$TARGET_ROOT/lib/mojo"}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p "$TARGET_DIR" "$RUNTIME_LINK_DIR"
MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'
BUILD_SOURCE_ID=${RETA_BUILD_SOURCE_ID:-$("$ROOT/scripts/current_source_id.sh")}
RETA_MOJO_RUNTIME_LINK_DIR="$RUNTIME_LINK_DIR" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

ACTIVE_TMP=
cleanup_tmp() {
    [ -n "$ACTIVE_TMP" ] || return 0
    rm -f "$ACTIVE_TMP" "$ACTIVE_TMP.reta-source-id"
}
trap cleanup_tmp EXIT HUP INT TERM

build_heavy() {
    description=$1
    source_file=$2
    output_name=$3
    shift 3
    final_output="$TARGET_DIR/$output_name"
    ACTIVE_TMP="$TARGET_DIR/.${output_name}.tmp.$$"
    rm -f "$ACTIVE_TMP" "$ACTIVE_TMP.reta-source-id"
    printf '%s\n' "$description"
    if "$MOJO" build "$@" -I src "$source_file" \
        -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" \
        -o "$ACTIVE_TMP"; then
        :
    else
        compiler_status=$?
        cleanup_tmp
        ACTIVE_TMP=
        return "$compiler_status"
    fi
    python3 "$ROOT/tools/sanitize_mojo_runpath.py" "$ACTIVE_TMP" >/dev/null
    file -b "$ACTIVE_TMP" | grep -q '^ELF 64-bit' || {
        printf 'Compiler erzeugte kein gültiges 64-Bit-ELF: %s\n' "$ACTIVE_TMP" >&2
        cleanup_tmp
        ACTIVE_TMP=
        return 1
    }
    RETA_BUILD_SOURCE_ID="$BUILD_SOURCE_ID" \
        "$ROOT/scripts/stamp_mojo_binary.sh" "$ACTIVE_TMP"
    mv -f "$ACTIVE_TMP" "$final_output"
    mv -f "$ACTIVE_TMP.reta-source-id" "$final_output.reta-source-id"
    ACTIVE_TMP=
    printf 'Erzeugt: %s\n' "$final_output"
}

build_heavy 'Kompiliere vollständige native Parametersemantik ...' \
    src/semantics_builder_main.mojo reta-mojo-semantics --no-optimization
build_heavy 'Kompiliere schweres Parameterschema ...' \
    src/schema_main.mojo reta-mojo-schema
build_heavy 'Kompiliere schweren Architekturkatalog ...' \
    src/architecture_main.mojo reta-mojo-architecture
build_heavy 'Kompiliere nativen Architektur-Grenzgraph ...' \
    src/architecture_boundaries_main.mojo reta-mojo-boundaries
build_heavy 'Kompiliere native Architekturverträge ...' \
    src/architecture_contracts_main.mojo reta-mojo-contracts
build_heavy 'Kompiliere native Architektur-Witnesses ...' \
    src/architecture_witnesses_main.mojo reta-mojo-witnesses
build_heavy 'Kompiliere native Architektur-Kohärenzmatrix ...' \
    src/architecture_coherence_main.mojo reta-mojo-coherence
build_heavy 'Kompiliere native Architektur-Traces ...' \
    src/architecture_traces_main.mojo reta-mojo-traces
build_heavy 'Kompiliere nativen Architektur-Impact-Kalkül ...' \
    src/architecture_impact_main.mojo reta-mojo-impact
build_heavy 'Kompiliere nativen Architektur-Migrationsplan ...' \
    src/architecture_migration_main.mojo reta-mojo-migration
build_heavy 'Kompiliere native Architektur-Rehearsal-Schicht ...' \
    src/architecture_rehearsal_main.mojo reta-mojo-rehearsal --no-optimization
build_heavy 'Kompiliere native Architektur-Aktivierungsschicht ...' \
    src/architecture_activation_main.mojo reta-mojo-activation --no-optimization
build_heavy 'Kompiliere native Architektur-Gesamtvalidierung ...' \
    src/architecture_validation_main.mojo reta-mojo-validation --no-optimization
build_heavy 'Kompiliere natives Architektur-Fortschritts-Overlay ...' \
    src/architecture_progress_main.mojo reta-mojo-progress --no-optimization
build_heavy 'Kompiliere native SQLite-Persistenz ...' \
    src/architecture_persistence_main.mojo reta-mojo-persistence \
    -Xlinker -lsqlite3 -Xlinker -lcrypto
build_heavy 'Kompiliere natives deterministisches Ausführungsnetz ...' \
    src/architecture_execution_network_main.mojo reta-mojo-execution-network \
    --no-optimization -j 4
build_heavy 'Kompiliere native Thread-Tabellenparallelisierung ...' \
    src/architecture_parallel_execution_main.mojo reta-mojo-parallel-execution \
    --no-optimization -j 4
build_heavy 'Kompiliere native typisierte Thread-Zeilenvorbereitung ...' \
    src/architecture_parallel_row_preparation_main.mojo reta-mojo-row-preparation \
    --no-optimization -j 4

trap - EXIT HUP INT TERM
cleanup_tmp
