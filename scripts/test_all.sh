#!/usr/bin/env sh
set -eu

report_test_build_status() {
    status=$?
    trap - 0
    if [ "$status" -eq 0 ]; then
        printf '%s: JA\n' 'Kompilierung und Ausführung aller ausgewählten Mojo-Tests erfolgreich'
    else
        printf '%s: NEIN (Exitstatus %s)\n' 'Kompilierung und Ausführung aller ausgewählten Mojo-Tests erfolgreich' "$status" >&2
    fi
    exit "$status"
}
trap report_test_build_status 0
# Vollständige native Mojo-Testprogrammsuite. Für den normalen Entwicklungs-
# zyklus genügt das aktuelle fokussierte Stage-Skript. Diese Suite ist vor
# Releases oder nach mehreren Stages sinnvoll; RETA_TEST_HEAVY=1 nimmt auch
# die zwei besonders speicher-/zeitintensiven Compilerziele hinzu.
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-all"}
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
mkdir -p "$TARGET"

for test_file in tests/test_*.mojo; do
    case "$test_file" in
        tests/test_category_theory.mojo|tests/test_schema_catalog_parity.mojo)
            if [ "${RETA_TEST_HEAVY:-0}" != "1" ]; then
                printf 'SKIP schweres Compilerziel: %s\n' "$test_file"
                continue
            fi
            ;;
    esac
    name=$(basename "$test_file" .mojo)
    set --
    case "$test_file" in
        tests/test_execution_network_persistence.mojo|tests/test_persistence.mojo)
            set -- -Xlinker -lsqlite3 -Xlinker -lcrypto
            ;;
        tests/test_package_integrity.mojo)
            set -- -Xlinker -lcrypto
            ;;
    esac
    printf '\n== build %s ==\n' "$test_file"
    "$MOJO" build -I src -I tests "$test_file" "$@" -o "$TARGET/$name"
    printf '== run %s ==\n' "$name"
    "$ROOT/bin/mojo-runtime-exec" "$TARGET/$name"
done
