#!/usr/bin/env sh
# Compatibility entry point: build the suite once, then execute it.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    cat <<'USAGE'
Verwendung: scripts/test_all.sh [--heavy] [--rebuild-all] [--run-jobs N] [--] [MOJO_BUILD_OPTION ...]

Kompiliert zuerst die ausgewählte Testsuite und führt anschließend das fertige
Manifest aus. Optionen hinter `--` werden unverändert an jeden einzelnen
`mojo build`-Aufruf von build-tests.sh weitergereicht.

Optionen:
  --heavy          auch die zwei besonders großen Compilerziele bauen
  --rebuild-all    alle Testprogramme ungeachtet des Fingerabdrucks neu bauen
  --run-jobs N     bis zu N isolierte Laufzeittests parallel ausführen
  --               Beginn der Mojo-Compileroptionen, z. B. -- -j 4

Umgebungsvariablen:
  RETA_TEST_HEAVY=1
  RETA_TEST_RUN_JOBS=N
  RETA_TEST_REBUILD_ALL=1
USAGE
}

HEAVY=${RETA_TEST_HEAVY:-0}
REBUILD_ALL=${RETA_TEST_REBUILD_ALL:-0}
RUN_JOBS=${RETA_TEST_RUN_JOBS:-1}
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
        --run-jobs)
            [ "$#" -ge 2 ] || { echo '--run-jobs benötigt eine Zahl.' >&2; exit 2; }
            RUN_JOBS=$2
            shift 2
            ;;
        --run-jobs=*)
            RUN_JOBS=${1#*=}
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            printf 'Unbekannte Option vor --: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done
case $HEAVY in 0|1) ;; *) echo 'RETA_TEST_HEAVY muss 0 oder 1 sein.' >&2; exit 2;; esac
case $REBUILD_ALL in 0|1) ;; *) echo 'RETA_TEST_REBUILD_ALL muss 0 oder 1 sein.' >&2; exit 2;; esac
case $RUN_JOBS in ''|*[!0-9]*|0) echo '--run-jobs muss eine positive Ganzzahl sein.' >&2; exit 2;; esac

report_status() {
    status=$?
    trap - 0
    if [ "$status" -eq 0 ]; then
        printf '%s: JA\n' 'Kompilierung und Ausführung aller ausgewählten Mojo-Tests erfolgreich'
    else
        printf '%s: NEIN (Exitstatus %s)\n' \
            'Kompilierung und Ausführung aller ausgewählten Mojo-Tests erfolgreich' \
            "$status" >&2
    fi
    exit "$status"
}
trap report_status 0

BUILD_ARGS=
if [ "$REBUILD_ALL" = 1 ]; then
    BUILD_ARGS=--rebuild-all
fi
if [ "$HEAVY" = 1 ]; then
    if [ -n "$BUILD_ARGS" ]; then
        "$ROOT/scripts/build-tests.sh" --heavy "$BUILD_ARGS" -- "$@"
    else
        "$ROOT/scripts/build-tests.sh" --heavy -- "$@"
    fi
else
    if [ -n "$BUILD_ARGS" ]; then
        "$ROOT/scripts/build-tests.sh" "$BUILD_ARGS" -- "$@"
    else
        "$ROOT/scripts/build-tests.sh" -- "$@"
    fi
fi
"$ROOT/scripts/run-tests.sh" --jobs "$RUN_JOBS"
