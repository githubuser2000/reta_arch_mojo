#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
./scripts/check_prompt_terminal_parity.sh
printf '%s\n' 'stage12c1 terminal-width and prompt-line parity tests complete'
