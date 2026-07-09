#!/usr/bin/env sh
set -eu

usage() {
    cat <<'USAGE'
Verwendung: scripts/run-tests.sh [--jobs N]

Führt ausschließlich bereits kompilierte, frische Mojo-Testprogramme aus.
Standardmäßig laufen sie sequenziell. Mit --jobs N werden nur als parallel
klassifizierte Tests gleichzeitig ausgeführt; feste /tmp-Namen und besonders
ressourcenintensive Tests bleiben serielle Barrieren.

Umgebungsvariablen:
  RETA_TEST_RUN_JOBS=N     Standardwert für --jobs
  RETA_TEST_RUN_TIMEOUT=S  optionales Zeitlimit je Test, 0 bedeutet unbegrenzt
  RETA_TEST_TARGET_DIR=…   Verzeichnis aus scripts/build-tests.sh
USAGE
}

JOBS=${RETA_TEST_RUN_JOBS:-1}
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --jobs)
            [ "$#" -ge 2 ] || { echo '--jobs benötigt eine Zahl.' >&2; exit 2; }
            JOBS=$2
            shift 2
            ;;
        *)
            printf 'Unbekannte Option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done
case $JOBS in ''|*[!0-9]*) echo '--jobs muss eine positive Ganzzahl sein.' >&2; exit 2;; esac
[ "$JOBS" -ge 1 ] || { echo '--jobs muss mindestens 1 sein.' >&2; exit 2; }

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET=${RETA_TEST_TARGET_DIR:-"$ROOT/target/tests-all"}
MANIFEST="$TARGET/manifest.tsv"
[ -f "$MANIFEST" ] || {
    printf 'Testmanifest fehlt: %s\nBitte zuerst kompilieren: scripts/build-tests.sh\n' "$MANIFEST" >&2
    exit 78
}
EXPECTED=$(sed -n 's/^source_id\t//p' "$MANIFEST" | sed -n '1p')
CURRENT=$("$ROOT/scripts/current_test_source_id.sh")
if [ -z "$EXPECTED" ] || [ "$EXPECTED" != "$CURRENT" ]; then
    printf '%s\n' \
        'Die kompilierten Tests sind gegenüber Quellen, Assets oder Testrezepten veraltet.' \
        'Bitte neu kompilieren: scripts/build-tests.sh' >&2
    exit 78
fi

while IFS="$(printf '\t')" read -r name source binary class; do
    [ "$name" != name ] || continue
    [ -n "$name" ] || continue
    case $name in \#*|source_id|heavy) continue;; esac
    [ -x "$binary" ] || {
        printf 'Testbinary fehlt oder ist nicht ausführbar: %s\n' "$binary" >&2
        exit 78
    }
    stamp="$binary.reta-test-source-id"
    [ -f "$stamp" ] && [ "$(sed -n '1p' "$stamp")" = "$CURRENT" ] || {
        printf 'Testbinary ist nicht frisch markiert: %s\n' "$binary" >&2
        exit 78
    }
done < "$MANIFEST"

TEST_PYTHON=${RETA_TEST_PYTHON:-$(command -v python3 || true)}
[ -n "$TEST_PYTHON" ] && [ -x "$TEST_PYTHON" ] || {
    echo 'Python 3 für den parallelen Testläufer fehlt.' >&2
    exit 127
}
TIMEOUT=${RETA_TEST_RUN_TIMEOUT:-0}
"$TEST_PYTHON" "$ROOT/tools/run_mojo_test_binaries.py" \
    --manifest "$MANIFEST" \
    --runtime-exec "$ROOT/tools/wrappers/mojo-runtime-exec" \
    --root "$ROOT" \
    --jobs "$JOBS" \
    --timeout "$TIMEOUT"
printf '\nAusführung aller ausgewählten Mojo-Tests erfolgreich: JA\n'
