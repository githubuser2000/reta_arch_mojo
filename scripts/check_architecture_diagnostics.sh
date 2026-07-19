#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    cat <<'USAGE'
Verwendung: scripts/check_architecture_diagnostics.sh [--jobs N] [--timeout S] [--dry-run]

Führt unabhängige Architektur-, Kohärenz-, Migrations-, Aktivierungs-,
Validierungs-, Persistenz- und Diagnoseprüfungen begrenzt parallel aus.
Thread-spezifische Execution-Network-Prüfungen bleiben eine exklusive Barriere.
USAGE
}

JOBS=${RETA_CHECK_JOBS:-4}
TIMEOUT=${RETA_CHECK_TIMEOUT:-0}
CHILD_WORKERS=${RETA_CHECK_CHILD_WORKERS:-2}
DRY_RUN=0
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        --jobs) JOBS=$2; shift 2 ;;
        --jobs=*) JOBS=${1#*=}; shift ;;
        --timeout) TIMEOUT=$2; shift 2 ;;
        --timeout=*) TIMEOUT=${1#*=}; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        *) printf 'Unbekannte Option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done
for value in "$JOBS" "$CHILD_WORKERS"; do
    case $value in ''|*[!0-9]*|0) echo 'jobs/child workers müssen positive Ganzzahlen sein.' >&2; exit 2;; esac
done
case $TIMEOUT in ''|*[!0-9]*) echo 'timeout muss eine nichtnegative Ganzzahl sein.' >&2; exit 2;; esac

set -- python3 "$ROOT/tools/run_check_group.py" \
    --manifest "$ROOT/scripts/architecture_diagnostic_checks.tsv" \
    --root "$ROOT" --jobs "$JOBS" --timeout "$TIMEOUT" \
    --child-parallel-workers "$CHILD_WORKERS"
if [ "$DRY_RUN" = 1 ]; then
    set -- "$@" --dry-run
fi
"$@"
printf '%s\n' 'Architektur- und Diagnoseprüfungen erfolgreich: JA'
