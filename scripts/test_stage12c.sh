#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
./scripts/check_native_prompt_input.sh
./scripts/check_prompt_external_commands.sh
./scripts/check_prompt_mixed_reciprocal_parity.sh
./scripts/check_prompt_classic_fraction_parity.sh
./scripts/check_prompt_terminal_parity.sh
printf '%s\n' 'stage12c1/c2/c3/c4a/c4b/c4c/c4d terminal-width, native TTY editor, raw-command, fallback-child, reciprocal and classic-fraction tests complete'
