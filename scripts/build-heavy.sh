#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
mkdir -p "$TARGET_DIR"
MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'
"$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

sanitize_binaries() {
    python3 "$ROOT/tools/sanitize_mojo_runpath.py" "$TARGET_DIR" >/dev/null
}
trap sanitize_binaries EXIT

printf 'Kompiliere vollständige native Parametersemantik ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -I src src/semantics_builder_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-semantics"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-semantics"
printf 'Kompiliere schweres Parameterschema\n'
"$ROOT/bin/mojo-real" build -I src src/schema_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-schema"
printf 'Kompiliere schweren Architekturkatalog ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-architecture"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-architecture"
printf 'Kompiliere nativen Architektur-Grenzgraph ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_boundaries_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-boundaries"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-boundaries"
printf 'Kompiliere native Architekturverträge ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_contracts_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-contracts"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-contracts"
printf 'Kompiliere native Architektur-Witnesses ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_witnesses_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-witnesses"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-witnesses"
printf 'Kompiliere native Architektur-Kohärenzmatrix ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_coherence_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-coherence"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-coherence"
printf 'Kompiliere native Architektur-Traces ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_traces_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-traces"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-traces"
printf 'Kompiliere nativen Architektur-Impact-Kalkül ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_impact_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-impact"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-impact"
printf 'Kompiliere nativen Architektur-Migrationsplan ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_migration_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-migration"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-migration"
printf 'Kompiliere native Architektur-Rehearsal-Schicht ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -I src src/architecture_rehearsal_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-rehearsal"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-rehearsal"
printf 'Kompiliere native Architektur-Aktivierungsschicht ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -I src src/architecture_activation_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-activation"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-activation"
printf 'Kompiliere native Architektur-Gesamtvalidierung ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -I src src/architecture_validation_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-validation"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-validation"
printf 'Kompiliere natives Architektur-Fortschritts-Overlay ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -I src src/architecture_progress_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-progress"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-progress"
printf 'Kompiliere native SQLite-Persistenz ...\n'
"$ROOT/bin/mojo-real" build -I src src/architecture_persistence_main.mojo -Xlinker -lsqlite3 -Xlinker -lcrypto -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-persistence"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-persistence"
printf 'Kompiliere natives deterministisches Ausführungsnetz ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src src/architecture_execution_network_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-execution-network"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-execution-network"
printf 'Kompiliere native Thread-Tabellenparallelisierung ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src src/architecture_parallel_execution_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-parallel-execution"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-parallel-execution"
printf 'Kompiliere native typisierte Thread-Zeilenvorbereitung ...\n'
"$ROOT/bin/mojo-real" build --no-optimization -j 4 -I src src/architecture_parallel_row_preparation_main.mojo -Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH" -o "$TARGET_DIR/reta-mojo-row-preparation"
printf 'Erzeugt: %s\n' "$TARGET_DIR/reta-mojo-row-preparation"
for output_name in \
    reta-mojo-semantics reta-mojo-schema reta-mojo-architecture \
    reta-mojo-boundaries reta-mojo-contracts reta-mojo-witnesses \
    reta-mojo-coherence reta-mojo-traces reta-mojo-impact \
    reta-mojo-migration reta-mojo-rehearsal reta-mojo-activation \
    reta-mojo-validation reta-mojo-progress reta-mojo-persistence \
    reta-mojo-execution-network reta-mojo-parallel-execution \
    reta-mojo-row-preparation
do
    "$ROOT/scripts/stamp_mojo_binary.sh" "$TARGET_DIR/$output_name"
done

