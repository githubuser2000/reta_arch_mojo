#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
status=0

have_cmd() {
    name=$1
    if command -v "$name" >/dev/null 2>&1; then
        printf 'OK   %-16s %s\n' "$name" "$(command -v "$name")"
    else
        printf 'MISS %-16s nicht im PATH\n' "$name" >&2
        status=1
    fi
}

show_version() {
    name=$1
    shift
    if command -v "$name" >/dev/null 2>&1; then
        printf '     %s\n' "$($@ 2>&1 | head -n 1)"
    fi
}

have_cmd python
show_version python python --version
have_cmd uv
show_version uv uv --version
have_cmd cmake
show_version cmake cmake --version
have_cmd ninja
show_version ninja ninja --version
have_cmd pkg-config
show_version pkg-config pkg-config --version

if [ -n "${CC-}" ]; then
    printf 'OK   %-16s %s\n' CC "$CC"
elif command -v cc >/dev/null 2>&1; then
    printf 'OK   %-16s %s\n' cc "$(command -v cc)"
else
    printf 'MISS %-16s weder CC noch cc gefunden\n' c-compiler >&2
    status=1
fi

if [ -x "$ROOT/bin/mojo-real" ]; then
    if version=$("$ROOT/bin/mojo-real" --version 2>&1); then
        printf 'OK   %-16s %s\n' mojo-real "$ROOT/bin/mojo-real"
        printf '     %s\n' "$(printf '%s\n' "$version" | head -n 1)"
    else
        printf 'MISS %-16s bin/mojo-real konnte keinen Modular-Mojo-Compiler starten\n' mojo-real >&2
        printf '%s\n' "$version" >&2
        status=1
    fi
else
    printf 'MISS %-16s %s nicht ausführbar\n' mojo-real "$ROOT/bin/mojo-real" >&2
    status=1
fi

if [ "$status" -ne 0 ]; then
    cat >&2 <<'MSG'

Toolchain unvollständig.

Mojo wird absichtlich nicht als Pixi-PyPI-Abhängigkeit installiert.
Nutze eine vorhandene .venv/uv-Installation oder richte sie ein mit:

    pixi run setup-mojo-venv

Direkt ohne Pixi bleibt weiterhin gültig:

    scripts/build_core_shared.sh -- -j 8
MSG
    exit "$status"
fi

printf '\nToolchain-Prüfung erfolgreich. Es wurde nichts kompiliert.\n'
