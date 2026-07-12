#!/usr/bin/env bash
set -euo pipefail

# RETA_STAGE10_CURRENT_TERMINAL_REFERENCE
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
IMPL="$ROOT/scripts/test_stage10.current-terminal-impl.sh"
FIXTURE="$ROOT/tests/fixtures/prompt_execution/moon-table.expected"
DYNAMIC="$ROOT/target/tests/prompt-exec-moon-table.current-terminal.expected"

if [[ ! -x "$IMPL" ]]; then
    printf 'Stage-10-Implementierung fehlt oder ist nicht ausführbar: %s\n' "$IMPL" >&2
    exit 1
fi

mkdir -p "$ROOT/target/tests"

terminal_size() {
    local size=""
    if [[ -r /dev/tty ]]; then
        size="$(stty size </dev/tty 2>/dev/null || true)"
    fi
    if [[ ! "$size" =~ ^[0-9]+[[:space:]][0-9]+$ ]]; then
        size="$(stty size 2>/dev/null || true)"
    fi
    if [[ ! "$size" =~ ^[0-9]+[[:space:]][0-9]+$ ]]; then
        local rows="${LINES:-24}"
        local cols="${COLUMNS:-80}"
        size="$rows $cols"
    fi
    printf '%s\n' "$size"
}

read -r RETA_TERMINAL_ROWS RETA_TERMINAL_COLUMNS < <(terminal_size)
export LINES="$RETA_TERMINAL_ROWS"
export COLUMNS="$RETA_TERMINAL_COLUMNS"

REFERENCE=""
for candidate in \
    "$ROOT/python_reference/reta.py" \
    "$ROOT/reta.py" \
    "$ROOT/original/reta.py"
do
    if [[ -f "$candidate" ]]; then
        REFERENCE="$candidate"
        break
    fi
done

if [[ -z "$REFERENCE" ]]; then
    REFERENCE="$(
        find "$ROOT" -maxdepth 4 -type f -name reta.py \
            -not -path '*/.git/*' \
            -not -path '*/target/*' \
            -not -path '*/build/*' \
            -print -quit
    )"
fi

if [[ -z "$REFERENCE" || ! -f "$REFERENCE" ]]; then
    printf 'Python-Referenz reta.py wurde nicht gefunden.\n' >&2
    exit 1
fi

REFERENCE_PYTHON="${RETA_REFERENCE_PYTHON:-}"
if [[ -z "$REFERENCE_PYTHON" ]]; then
    if command -v python3 >/dev/null 2>&1; then
        REFERENCE_PYTHON="$(command -v python3)"
    elif command -v pypy3 >/dev/null 2>&1; then
        REFERENCE_PYTHON="$(command -v pypy3)"
    else
        printf 'Weder python3 noch pypy3 gefunden.\n' >&2
        exit 1
    fi
fi

printf 'Stage-10-Paritätsbreite: %s Spalten, %s Zeilen\n' \
    "$RETA_TERMINAL_COLUMNS" "$RETA_TERMINAL_ROWS"
printf 'Python-Referenz: %s (%s)\n' "$REFERENCE" "$REFERENCE_PYTHON"

python3 - \
    "$FIXTURE" \
    "$DYNAMIC" \
    "$REFERENCE_PYTHON" \
    "$REFERENCE" \
    "$RETA_TERMINAL_COLUMNS" \
    "$RETA_TERMINAL_ROWS" <<'PY'
from __future__ import annotations

import os
from pathlib import Path
import shlex
import subprocess
import sys

fixture = Path(sys.argv[1])
output = Path(sys.argv[2])
interpreter = sys.argv[3]
reference = Path(sys.argv[4]).resolve()
columns = sys.argv[5]
lines = sys.argv[6]

raw = fixture.read_bytes().replace(b"\r\n", b"\n")
first_line = raw.split(b"\n", 1)[0].decode("utf-8")
argv = shlex.split(first_line)

if not argv or Path(argv[0]).name != "reta":
    raise SystemExit(
        f"Unerwartete erste Zeile in {fixture}: {first_line!r}"
    )

env = os.environ.copy()
env.update(
    {
        "COLUMNS": columns,
        "LINES": lines,
        "PYTHONIOENCODING": "utf-8",
        "PYTHONUTF8": "1",
        "PYTHONWARNINGS": "ignore",
    }
)

reference_dir = reference.parent
old_pythonpath = env.get("PYTHONPATH", "")
env["PYTHONPATH"] = (
    str(reference_dir)
    if not old_pythonpath
    else str(reference_dir) + os.pathsep + old_pythonpath
)

completed = subprocess.run(
    [interpreter, str(reference), *argv[1:]],
    cwd=reference_dir,
    env=env,
    stdin=subprocess.DEVNULL,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    check=False,
)

if completed.returncode != 0:
    sys.stderr.buffer.write(completed.stderr)
    raise SystemExit(
        f"Python-Referenz endete mit Status {completed.returncode}"
    )

body = completed.stdout.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
prefix = first_line.encode("utf-8") + b"\n"

# Manche Referenzeinstiege geben die rekonstruierte Befehlszeile selbst aus.
if body.startswith(prefix):
    combined = body
else:
    combined = prefix + body

output.parent.mkdir(parents=True, exist_ok=True)
output.write_bytes(combined)
PY

fixture_backup="$(mktemp "$ROOT/tests/fixtures/prompt_execution/.moon-table.expected.XXXXXX")"
cp -a -- "$FIXTURE" "$fixture_backup"

restore_fixture() {
    if [[ -e "$fixture_backup" ]]; then
        mv -f -- "$fixture_backup" "$FIXTURE"
    fi
}
trap restore_fixture EXIT HUP INT TERM

cp -- "$DYNAMIC" "$FIXTURE"

set +e
"$IMPL" "$@"
status=$?
set -e

restore_fixture
trap - EXIT HUP INT TERM
exit "$status"
