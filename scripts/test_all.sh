#!/usr/bin/env sh
# Compatibility entry point: build the suite once, then execute it.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

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

if [ "${RETA_TEST_HEAVY:-0}" = 1 ]; then
    "$ROOT/scripts/build-tests.sh" --heavy
else
    "$ROOT/scripts/build-tests.sh"
fi
"$ROOT/scripts/run-tests.sh" --jobs "${RETA_TEST_RUN_JOBS:-1}"
