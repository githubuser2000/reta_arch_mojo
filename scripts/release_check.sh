#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    cat <<'USAGE'
Verwendung: scripts/release_check.sh [--dry-run] [--jobs N]
                                  [--check-timeout S] [--child-workers N]
                                  [--] [MOJO_BUILD_OPTION ...]

Führt den vollständigen Release-Sicherheitsgurt aus:
  1. vollständiger nativer Build inklusive Core-/Prompt-Shared-Libraries
  2. Buildlayout-Prüfung inklusive .reta-source-id-Frische
  3. FHS-/usr/local-Installationsprüfung mit installierten dünnen Startern
  4. Prompt-Shared-Runtime-Smoke im Build- und Installationsbaum
  5. Architektur-, Diagnose-, Katalog-, Paritäts- und Test-Suiten

Unabhängige Prüfungen laufen global begrenzt parallel. Compiler-, Installations-,
Prompt-, Completion- und intern threadende Prüfungen bleiben Barrieren.
Mojo-Buildoptionen nach -- werden nur an scripts/build-all.sh weitergereicht.

Umgebungsvariablen:
  RETA_RELEASE_CHECK_JOBS=N          parallele Prüfprozesse, Standard 4
  RETA_RELEASE_CHECK_TIMEOUT=S       Zeitlimit je Prüfung, 0 = unbegrenzt
  RETA_RELEASE_CHILD_WORKERS=N       native Worker je Prüfprozess, Standard 2
USAGE
}

DRY_RUN=0
CHECK_JOBS=${RETA_RELEASE_CHECK_JOBS:-4}
CHECK_TIMEOUT=${RETA_RELEASE_CHECK_TIMEOUT:-0}
CHILD_WORKERS=${RETA_RELEASE_CHILD_WORKERS:-2}
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --jobs)
            [ "$#" -ge 2 ] || { echo '--jobs benötigt eine Zahl.' >&2; exit 2; }
            CHECK_JOBS=$2
            shift 2
            ;;
        --jobs=*)
            CHECK_JOBS=${1#*=}
            shift
            ;;
        --check-timeout)
            [ "$#" -ge 2 ] || { echo '--check-timeout benötigt Sekunden.' >&2; exit 2; }
            CHECK_TIMEOUT=$2
            shift 2
            ;;
        --check-timeout=*)
            CHECK_TIMEOUT=${1#*=}
            shift
            ;;
        --child-workers)
            [ "$#" -ge 2 ] || { echo '--child-workers benötigt eine Zahl.' >&2; exit 2; }
            CHILD_WORKERS=$2
            shift 2
            ;;
        --child-workers=*)
            CHILD_WORKERS=${1#*=}
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
case $CHECK_JOBS in ''|*[!0-9]*|0) echo '--jobs muss eine positive Ganzzahl sein.' >&2; exit 2;; esac
case $CHILD_WORKERS in ''|*[!0-9]*|0) echo '--child-workers muss eine positive Ganzzahl sein.' >&2; exit 2;; esac
case $CHECK_TIMEOUT in ''|*[!0-9]*) echo '--check-timeout muss eine nichtnegative Ganzzahl sein.' >&2; exit 2;; esac

run_step() {
    title=$1
    shift
    printf '\n== %s ==\n' "$title"
    if [ "$DRY_RUN" = 1 ]; then
        printf '%s' '+ '
        printf '%s' "$1"
        shift
        for arg in "$@"; do
            printf ' %s' "$arg"
        done
        printf '\n'
        return 0
    fi
    "$@"
}

run_group() {
    title=$1
    manifest=$2
    printf '\n== %s ==\n' "$title"
    set -- python3 "$ROOT/tools/run_check_group.py" \
        --manifest "$manifest" \
        --root "$ROOT" \
        --jobs "$CHECK_JOBS" \
        --timeout "$CHECK_TIMEOUT" \
        --child-parallel-workers "$CHILD_WORKERS"
    if [ "$DRY_RUN" = 1 ]; then
        set -- "$@" --dry-run
    fi
    "$@"
}

# Reihenfolge und Einzelaufrufe dieser drei Vorbedingungen bleiben absichtlich
# sichtbar: sie validieren den Plan, bevor irgendein Build stattfindet.
run_step 'Artefaktmanifest gegen Installationsziele prüfen' \
    "$ROOT/scripts/check_artifact_manifest_consistency.sh"
run_step 'Installprofile für Shell, Pixi und CMake prüfen' \
    "$ROOT/scripts/check_install_profile_matrix.sh"
run_step 'Bridge-/Release-Policy für native Installation prüfen' \
    "$ROOT/scripts/check_release_bridge_policy.sh"
run_step 'vollständiger nativer Build mit Core-/Prompt-Shared-Libraries' \
    "$ROOT/scripts/build-all.sh" -- "$@"
run_step 'Buildlayout inklusive Shared-Libraries prüfen' \
    "$ROOT/scripts/check_build_layout.sh"
run_step 'FHS-/usr/local-Installation inklusive dünner Starter prüfen' \
    "$ROOT/scripts/check_install_layout.sh"

run_group 'Architektur- und Diagnoseprüfungen begrenzt parallel ausführen' \
    "$ROOT/scripts/architecture_diagnostic_checks.tsv"

# Dieser Check startet selbst den Mojo-Compiler und bleibt daher eine Barriere.
run_step 'Multis3-Parität prüfen' "$ROOT/scripts/check_multis3_parity.sh"

run_group 'Unabhängige Katalog- und Schema-Prüfungen begrenzt parallel ausführen' \
    "$ROOT/scripts/release_catalog_checks.tsv"

run_group 'Unabhängige Runtime- und Ausgabeparitäten begrenzt parallel ausführen' \
    "$ROOT/scripts/release_runtime_parity_checks.tsv"

# Prompt-/TTY-/Completion- und Stage-Gates bleiben seriell. test_stage12c
# parallelisiert intern ausschließlich seine zustandslosen Rendering-Paritäten.
run_step 'Prompt-Bin-Kompatibilität prüfen' "$ROOT/scripts/test_prompt_bins.sh"
run_step 'Stage 10 prüfen' "$ROOT/scripts/test_stage10.sh"
run_step 'Stage 12c prüfen' env \
    RETA_CHECK_JOBS="$CHECK_JOBS" \
    RETA_CHECK_TIMEOUT="$CHECK_TIMEOUT" \
    RETA_CHECK_CHILD_WORKERS="$CHILD_WORKERS" \
    "$ROOT/scripts/test_stage12c.sh"

run_step 'Vollständige Mojo-Test-Suite ausführen' \
    "$ROOT/scripts/test_all.sh" --run-jobs "$CHECK_JOBS"

if [ "$DRY_RUN" = 1 ]; then
    printf '\n%s\n' 'Release-Prüfplan ausgegeben; keine Kommandos ausgeführt.'
else
    printf '\n%s\n' 'Alle Release-Prüfungen bestanden, inklusive FHS-/usr/local-Installation und Prompt-Shared-Runtime-Smoke.'
fi
