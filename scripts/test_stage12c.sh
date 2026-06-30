#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
./scripts/check_native_prompt_input.sh
./scripts/check_prompt_terminal_parity.sh
printf '%s\n' 'stage12c1/c2 terminal-width and native prompt-input tests complete'
