#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if ! command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'uv wurde nicht gefunden.' >&2
    printf '%s\n' 'Installiere uv zuerst, z.B. gemäß der offiziellen Anleitung:' >&2
    printf '%s\n' '  curl -LsSf https://astral.sh/uv/install.sh | sh' >&2
    exit 127
fi

if [ -n "${RETA_MOJO_PYTHON-}" ]; then
    PYTHON_REQUEST=$RETA_MOJO_PYTHON
elif command -v python3.14 >/dev/null 2>&1; then
    PYTHON_REQUEST=$(command -v python3.14)
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_REQUEST=$(command -v python3)
else
    printf '%s\n' 'Kein Python 3 wurde gefunden.' >&2
    exit 127
fi

"$PYTHON_REQUEST" - <<'PY'
import sys
if not ((3, 10) <= sys.version_info[:2] <= (3, 14)):
    raise SystemExit(
        f"Mojo 1.0.0b2 benötigt hier Python 3.10 bis 3.14; gefunden: {sys.version.split()[0]}"
    )
print(f"Verwendetes Python: {sys.executable} ({sys.version.split()[0]})")
PY

rm -rf .venv
uv venv --python "$PYTHON_REQUEST" .venv
uv pip install --python .venv/bin/python 'mojo==1.0.0b2' --prerelease allow

# bin/ ist im Projekt kein Ort für reta/rp/rpl/rpe/rpb-Binaries.
# Er darf aber den Mojo-Resolver enthalten. Der eigentliche Modular-Mojo-
# Compiler liegt nach diesem Skript in .venv/bin/mojo; bin/mojo-real ist nur
# ein stabiler Resolver/Wrapper für alle Build- und Testskripte.
mkdir -p bin
cat > bin/mojo-real <<'MOJO_REAL'
#!/usr/bin/env sh
set -eu

SELF=$0
if command -v readlink >/dev/null 2>&1; then
    SELF=$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")
fi
ROOT=$(CDPATH= cd -- "$(dirname -- "$SELF")/.." && pwd)

fail() {
    cat >&2 <<'MSG'
Kein Compiler der Mojo-Programmiersprache von Modular wurde gefunden.

Der gefundene Snap /snap/mojo ist ein anderes Programm (Canonical/Juju) und
kann keine .mojo-Dateien ausführen.

Richte den offiziellen Compiler lokal für dieses Projekt ein:

    ./scripts/setup_mojo.sh

Alternativ kann der Compiler explizit angegeben werden:

    MOJO_BIN=/pfad/zum/offiziellen/mojo scripts/build.sh
MSG
    exit 127
}

is_candidate() {
    candidate=$1
    [ -n "$candidate" ] || return 1
    [ -x "$candidate" ] || return 1

    resolved=$candidate
    if command -v readlink >/dev/null 2>&1; then
        resolved=$(readlink -f "$candidate" 2>/dev/null || printf '%s' "$candidate")
    fi

    case "$resolved" in
        /snap/mojo/*)
            return 1
            ;;
    esac

    version=$($candidate --version 2>&1) || return 1
    case "$version" in
        *Mojo*|*mojo*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

try_exec() {
    candidate=$1
    shift
    if is_candidate "$candidate"; then
        exec "$candidate" "$@"
    fi
}

if [ -n "${MOJO_BIN-}" ]; then
    configured=$MOJO_BIN
    configured_resolved=$configured
    if command -v readlink >/dev/null 2>&1; then
        configured_resolved=$(readlink -f "$configured" 2>/dev/null || printf '%s' "$configured")
    fi
    if [ "$configured_resolved" = "$SELF" ]; then
        unset MOJO_BIN
    else
        try_exec "$configured" "$@"
        printf 'MOJO_BIN zeigt nicht auf den Modular-Mojo-Compiler: %s\n' "$configured" >&2
        fail
    fi
fi

try_exec "$ROOT/.venv/bin/mojo" "$@"
try_exec "$ROOT/.pixi/envs/default/bin/mojo" "$@"

if [ -n "${VIRTUAL_ENV-}" ]; then
    try_exec "$VIRTUAL_ENV/bin/mojo" "$@"
fi

path_mojo=$(command -v mojo 2>/dev/null || true)
if [ -n "$path_mojo" ]; then
    try_exec "$path_mojo" "$@"
fi

fail
MOJO_REAL
chmod +x bin/mojo-real

printf '\n%s\n' 'Installierter Modular-Mojo-Compiler:'
bin/mojo-real --version
printf '\n%s\n' 'setup_mojo.sh installiert nur Mojo: .venv/bin/mojo plus bin/mojo-real als Resolver.'
printf '%s\n' 'Es baut und installiert keine reta/rp/rpl/rpe/rpb-Binaries.'
printf '%s\n' 'Mojo direkt prüfen:'
printf '%s\n' '  .venv/bin/mojo --version'
printf '%s\n' '  ./bin/mojo-real --version'
