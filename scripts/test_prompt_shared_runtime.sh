#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/test_prompt_shared_runtime.sh [--dry-run]

Prüft die aktiven Prompt-Shared-Runtime-Artefakte:
  - target/bin/rpb nutzt libreta-prompt.so ohne libreta-prompt-interactive.so
  - target/bin/rp/rpl/rpe haben zusätzlich die interaktive Prompt-Bibliothek
  - Starter und Bibliotheken tragen denselben .reta-source-id-Quellstand
  - einfache rpb- und rp-Smoke-Kommandos laufen über die dünnen Starter
USAGE
        exit 0
        ;;
esac

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=1
    shift
fi

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TARGET_ROOT=$(dirname -- "$TARGET_DIR")
LIB_DIR=${RETA_TARGET_LIB_DIR:-"$TARGET_ROOT/lib/reta"}
PROMPT_LIBRARY="$LIB_DIR/libreta-prompt.so"
INTERACTIVE_LIBRARY="$LIB_DIR/libreta-prompt-interactive.so"
TMP=${TMPDIR:-/tmp}/reta-prompt-shared-runtime.$$

if [ "$DRY_RUN" = 1 ]; then
    cat <<'PLAN'
Prompt-Shared-Runtime-Smokeplan:
  1. erwarte target/bin/rpb, rp, rpl, rpe
  2. erwarte libreta-prompt.so und libreta-prompt-interactive.so
  3. rpb muss mit absichtlich kaputter RETA_PROMPT_INTERACTIVE_LIBRARY laufen
  4. rpb muss mit kaputter RETA_PROMPT_LIBRARY scheitern
  5. rp/rpl/rpe müssen die interaktive Bibliothek als Zusatzgrenze besitzen
PLAN
    exit 0
fi

mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

require_file() {
    if [ ! -f "$1" ]; then
        printf 'Fehlendes Prompt-Runtime-Artefakt: %s\n' "$1" >&2
        printf 'Bitte neu bauen: scripts/build_prompt_shared.sh oder scripts/build-all.sh\n' >&2
        exit 127
    fi
}

require_executable() {
    require_file "$1"
    if [ ! -x "$1" ]; then
        printf 'Prompt-Runtime-Artefakt ist nicht ausführbar: %s\n' "$1" >&2
        exit 126
    fi
}

source_id() {
    stamp="$1.reta-source-id"
    require_file "$stamp"
    sed -n '1p' "$stamp"
}

require_executable "$TARGET_DIR/rpb"
for name in rp rpl rpe; do
    require_executable "$TARGET_DIR/$name"
done
require_file "$PROMPT_LIBRARY"
require_file "$INTERACTIVE_LIBRARY"

prompt_id=$(source_id "$PROMPT_LIBRARY")
interactive_id=$(source_id "$INTERACTIVE_LIBRARY")
if [ "$prompt_id" != "$interactive_id" ]; then
    printf '%s\n' 'libreta-prompt.so und libreta-prompt-interactive.so stammen nicht aus demselben Quellstand.' >&2
    exit 78
fi

if [ "$(source_id "$TARGET_DIR/rpb")" != "$prompt_id" ]; then
    printf '%s\n' 'rpb und libreta-prompt.so stammen nicht aus demselben Quellstand.' >&2
    exit 78
fi
for name in rp rpl rpe; do
    if [ "$(source_id "$TARGET_DIR/$name")" != "$interactive_id" ]; then
        printf '%s und libreta-prompt-interactive.so stammen nicht aus demselben Quellstand.\n' "$name" >&2
        exit 78
    fi
done

# rpb ist one-shot und darf die interaktive Bibliothek auch dann nicht berühren,
# wenn deren Override absichtlich auf einen kaputten Pfad gesetzt ist.
RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing/libreta-prompt-interactive.so \
    "$TARGET_DIR/rpb" prim 60 > "$TMP/rpb-prim"
[ "$(cat "$TMP/rpb-prim")" = "60: 2^2 3 5" ]

set +e
RETA_PROMPT_LIBRARY=/definitely/missing/libreta-prompt.so \
    "$TARGET_DIR/rpb" prim 60 > "$TMP/rpb-missing.out" 2> "$TMP/rpb-missing.err"
missing_status=$?
set -e
if [ "$missing_status" -eq 0 ]; then
    printf '%s\n' 'rpb lief trotz fehlender libreta-prompt.so erfolgreich.' >&2
    exit 1
fi

grep -F 'Prompt-Bibliothek konnte nicht geladen werden' "$TMP/rpb-missing.err" >/dev/null

# rp/rpl/rpe sind interaktive Starter.  Für den schnellen Smoke genügt ein
# kurzes Kommando über stdin; sie müssen außerdem die gemeinsame Prompt-Bibliothek
# zusätzlich zur interaktiven Bibliothek laden können.
printf 'prim 29\nq\n' | "$TARGET_DIR/rp" > "$TMP/rp"
grep -F '29: 29' "$TMP/rp" >/dev/null

for name in rpl rpe; do
    printf 'q\n' | "$TARGET_DIR/$name" > "$TMP/$name" || {
        printf 'Interaktiver Prompt-Starter scheiterte: %s\n' "$name" >&2
        exit 1
    }
done

printf '%s\n' 'Prompt-Shared-Runtime-Smoke bestanden.'
