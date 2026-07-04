#!/usr/bin/env sh
# Build and verify from the current project root; commit only a fully green state.
set -eu

COMMIT_MESSAGE=${1:-12c5ap}

if [ ! -x scripts/build-all.sh ] \
    || [ ! -x scripts/test_current_stage.sh ] \
    || [ ! -x scripts/build-and-test-shared-diagnostics.sh ] \
    || [ ! -x scripts/test_all.sh ]; then
    cat >&2 <<'MSG'
Fehler: do.sh muss aus dem Wurzelverzeichnis von reta_arch_mojo gestartet werden.
Es wird absichtlich kein automatischer Verzeichniswechsel vorgenommen.
MSG
    exit 2
fi

if scripts/build-all.sh; then
    :
else
    status=$?
    printf '%s\n' \
        'Abbruch: Aktueller Stage-Test, Shared-Diagnostics, Mojo-Gesamttests und Git-Commit werden nach einem fehlgeschlagenen Vollbuild nicht ausgeführt.' >&2
    exit "$status"
fi

if scripts/test_current_stage.sh; then
    :
else
    status=$?
    printf '%s\n' \
        'Abbruch: Shared-Diagnostics, Mojo-Gesamttests und Git-Commit werden nach einem fehlgeschlagenen aktuellen Stage-Test nicht ausgeführt.' >&2
    exit "$status"
fi

if scripts/build-and-test-shared-diagnostics.sh; then
    :
else
    status=$?
    printf '%s\n' \
        'Abbruch: Mojo-Gesamttests und Git-Commit werden nach einer fehlgeschlagenen Shared-Diagnostics-Prüfung nicht ausgeführt.' >&2
    exit "$status"
fi

if scripts/test_all.sh; then
    :
else
    status=$?
    printf '%s\n' \
        'Abbruch: Der Git-Commit wird nach fehlgeschlagenen Mojo-Gesamttests nicht ausgeführt.' >&2
    exit "$status"
fi

git add -A
git commit -m "$COMMIT_MESSAGE"
