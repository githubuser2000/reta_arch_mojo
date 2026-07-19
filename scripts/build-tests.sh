#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/build-tests.sh [--heavy] [--rebuild-all] [--] [MOJO_BUILD_OPTION ...]

Kompiliert die vollständige Mojo-Testsuite, führt aber keinen Test aus.
Die fertigen Testprogramme und ein Frischemanifest liegen standardmäßig unter
`target/tests-all`. Mehrere Mojo-Compilerprozesse werden absichtlich nicht
parallel gestartet; Parallelität innerhalb eines einzelnen Compileraufrufs
kann kontrolliert über eine weitergereichte Option wie `-j 4` aktiviert werden.

Optionen:
  --heavy       die zwei besonders großen Compilerziele ebenfalls bauen
  --rebuild-all alle Testprogramme unabhängig vom Fingerabdruck neu bauen
  --            alle folgenden Optionen unverändert an `mojo build` weiterreichen

Umgebungsvariablen:
  RETA_TEST_HEAVY=1       entspricht --heavy
  RETA_TEST_TARGET_DIR=…  alternatives Zielverzeichnis
  MOJO_BIN=…              alternativer Mojo-Compiler
  RETA_TEST_REBUILD_ALL=1  entspricht --rebuild-all
USAGE
}

HEAVY=${RETA_TEST_HEAVY:-0}
REBUILD_ALL=${RETA_TEST_REBUILD_ALL:-0}
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --heavy)
            HEAVY=1
            shift
            ;;
        --rebuild-all)
            REBUILD_ALL=1
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
case $HEAVY in 0|1) ;; *) echo 'RETA_TEST_HEAVY muss 0 oder 1 sein.' >&2; exit 2;; esac
case $REBUILD_ALL in 0|1) ;; *) echo 'RETA_TEST_REBUILD_ALL muss 0 oder 1 sein.' >&2; exit 2;; esac

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"
MOJO=${MOJO_BIN:-"$ROOT/bin/mojo-real"}
TEST_PYTHON=$($ROOT/scripts/find_test_python.sh)
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-all"}
MANIFEST="$TARGET/manifest.tsv"
MANIFEST_TMP="$TARGET/.manifest.tsv.tmp.$$"
SOURCE_ID=$("$ROOT/scripts/current_test_source_id.sh")
CONTEXT_TMP=$(mktemp "${TMPDIR:-/tmp}/reta-test-build-context.XXXXXX")
{
    printf 'compiler=%s\0' "$MOJO"
    "$MOJO" --version 2>&1 || true
    printf '\0platform='
    uname -srm 2>/dev/null || true
    printf '\0build-option-count=%s\0' "$#"
    for option in "$@"; do
        printf '%s\0' "$option"
    done
    env | LC_ALL=C sort | grep -E '^(CC|CXX|LD|AR|PATH|LIBRARY_PATH|CPATH|C_INCLUDE_PATH|CPLUS_INCLUDE_PATH|LDFLAGS|MOJO_|MODULAR_|SDKROOT|MACOSX_DEPLOYMENT_TARGET)=' || true
    sha256sum \
        scripts/build-tests.sh \
        scripts/mojo_build_options.sh \
        scripts/configure_mojo_runtime.sh \
        tools/mojo_test_build_fingerprint.py \
        bin/mojo-real
} > "$CONTEXT_TMP"
BUILD_CONTEXT_ID=$(sha256sum "$CONTEXT_TMP" | awk '{print $1}')
rm -f "$CONTEXT_TMP"
FINGERPRINTS_TMP=$(mktemp "${TMPDIR:-/tmp}/reta-test-build-fingerprints.XXXXXX")
"$TEST_PYTHON" "$ROOT/tools/mojo_test_build_fingerprint.py" \
    --root "$ROOT" --context-id "$BUILD_CONTEXT_ID" tests/test_*.mojo \
    > "$FINGERPRINTS_TMP"
mkdir -p "$TARGET"
# The manifest is the suite-level ready marker. Remove it before touching any
# binary so an interrupted rebuild can never execute a mixed old/new suite.
rm -f "$MANIFEST"
RETA_MOJO_RUNTIME_LINK_DIR="$(dirname -- "$TARGET")/lib/mojo" \
    "$ROOT/scripts/configure_mojo_runtime.sh" >/dev/null

ACTIVE_TMP=
ACTIVE_STAMP=
ACTIVE_BUILD_STAMP=
cleanup() {
    [ -z "$ACTIVE_TMP" ] || rm -f "$ACTIVE_TMP"
    [ -z "$ACTIVE_STAMP" ] || rm -f "$ACTIVE_STAMP"
    [ -z "$ACTIVE_BUILD_STAMP" ] || rm -f "$ACTIVE_BUILD_STAMP"
    rm -f "$MANIFEST_TMP" "$FINGERPRINTS_TMP"
}
trap cleanup EXIT HUP INT TERM

is_heavy_test() {
    case $1 in
        tests/test_category_theory.mojo|tests/test_schema_catalog_parity.mojo) return 0 ;;
        *) return 1 ;;
    esac
}

execution_class() {
    case $1 in
        # Very long or resource-heavy runtime tests remain exclusive. Running
        # several together is slower on typical developer machines and can
        # exhaust memory despite being logically independent.
        tests/test_csv_reference.mojo|\
        tests/test_csv_table.mojo|\
        tests/test_fraction_concat_columns.mojo|\
        tests/test_generated_columns.mojo|\
        tests/test_generated_table_columns.mojo|\
        tests/test_kombi_join_columns.mojo|\
        tests/test_meta_columns.mojo|\
        tests/test_meta_columns_complete.mojo|\
        tests/test_native_reta_cli.mojo|\
        tests/test_native_reta_utf8_html.mojo|\
        tests/test_execution_network.mojo|\
        tests/test_execution_network_persistence.mojo|\
        tests/test_parallel_execution_config.mojo|\
        tests/test_parallel_number_processes.mojo|\
        tests/test_parallel_number_threads.mojo|\
        tests/test_parallel_row_preparation.mojo|\
        tests/test_parallel_row_processes.mojo|\
        tests/test_parallel_row_threads.mojo|\
        tests/test_parallel_table_execution.mojo|\
        tests/test_parallel_thread_backend.mojo|\
        tests/test_prime_effect_columns.mojo|\
        tests/test_prime_universe_columns.mojo|\
        tests/test_py_reta_truth_native.mojo|\
        tests/test_table_rendering.mojo) printf '%s' exclusive ;;
        *) printf '%s' parallel ;;
    esac
}


{
    printf '# reta-test-manifest-v1\n'
    printf 'source_id\t%s\n' "$SOURCE_ID"
    printf 'heavy\t%s\n' "$HEAVY"
    printf 'name\tsource\tbinary\tclass\n'
} > "$MANIFEST_TMP"

count=0
rebuilt=0
reused=0
for test_file in tests/test_*.mojo; do
    if is_heavy_test "$test_file" && [ "$HEAVY" != 1 ]; then
        printf 'SKIP schweres Compilerziel: %s\n' "$test_file"
        continue
    fi
    name=$(basename "$test_file" .mojo)
    final="$TARGET/$name"
    ACTIVE_TMP="$TARGET/.${name}.tmp.$$"
    ACTIVE_STAMP="$ACTIVE_TMP.reta-test-source-id"
    ACTIVE_BUILD_STAMP="$ACTIVE_TMP.reta-test-build-id"
    rm -f "$ACTIVE_TMP" "$ACTIVE_STAMP" "$ACTIVE_BUILD_STAMP"
    BUILD_ID=$(awk -F '\t' -v path="$test_file" '$1 == path { print $2; exit }' "$FINGERPRINTS_TMP")
    [ -n "$BUILD_ID" ] || {
        printf 'Kein Buildfingerabdruck für %s erzeugt.\n' "$test_file" >&2
        exit 1
    }
    BUILD_STAMP="$final.reta-test-build-id"
    if [ "$REBUILD_ALL" != 1 ] \
        && [ -x "$final" ] \
        && [ -f "$BUILD_STAMP" ] \
        && [ "$(sed -n '1p' "$BUILD_STAMP")" = "$BUILD_ID" ] \
        && file -b "$final" | grep -q '^ELF 64-bit'; then
        printf '\n== reuse %s ==\n' "$test_file"
        printf '%s\n' "$SOURCE_ID" > "$final.reta-test-source-id"
        reused=$((reused + 1))
    else
        # POSIX sh has no arrays. Build the three known linker forms explicitly.
        printf '\n== build %s ==\n' "$test_file"
        case "$test_file" in
        tests/test_execution_network_persistence.mojo|tests/test_persistence.mojo)
            "$MOJO" build -I src -I tests "$test_file" \
                -Xlinker -lsqlite3 -Xlinker -lcrypto "$@" -o "$ACTIVE_TMP"
            ;;
        tests/test_package_integrity.mojo)
            "$MOJO" build -I src -I tests "$test_file" \
                -Xlinker -lcrypto "$@" -o "$ACTIVE_TMP"
            ;;
        *)
            "$MOJO" build -I src -I tests "$test_file" "$@" -o "$ACTIVE_TMP"
            ;;
        esac
        file -b "$ACTIVE_TMP" | grep -q '^ELF 64-bit' || {
            printf 'Compiler erzeugte kein gültiges 64-Bit-ELF: %s\n' "$ACTIVE_TMP" >&2
            exit 1
        }
        printf '%s\n' "$SOURCE_ID" > "$ACTIVE_STAMP"
        printf '%s\n' "$BUILD_ID" > "$ACTIVE_BUILD_STAMP"
        mv -f "$ACTIVE_TMP" "$final"
        mv -f "$ACTIVE_STAMP" "$final.reta-test-source-id"
        mv -f "$ACTIVE_BUILD_STAMP" "$final.reta-test-build-id"
        ACTIVE_TMP=
        ACTIVE_STAMP=
        ACTIVE_BUILD_STAMP=
        rebuilt=$((rebuilt + 1))
    fi
    class=$(execution_class "$test_file")
    printf '%s\t%s\t%s\t%s\n' "$name" "$test_file" "$final" "$class" >> "$MANIFEST_TMP"
    count=$((count + 1))
done

mv -f "$MANIFEST_TMP" "$MANIFEST"
trap - EXIT HUP INT TERM
cleanup
printf '\nTestkompilierung abgeschlossen: %s Programme (%s neu, %s wiederverwendet).\n' \
    "$count" "$rebuilt" "$reused"
printf 'Manifest: %s\n' "$MANIFEST"
printf 'Ausführen: scripts/run-tests.sh\n'
