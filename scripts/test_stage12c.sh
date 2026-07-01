#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
./scripts/check_native_prompt_input.sh
./scripts/check_prompt_external_commands.sh
./scripts/check_compat_launcher.sh
./scripts/check_native_output_stream_parity.sh
./scripts/check_native_markup_onetable_parity.sh
./scripts/check_no_blank_contents.sh
RETA_COMPAT_PARITY_GROUP=1 ./scripts/check_compat_native_first_parity.sh
RETA_COMPAT_PARITY_GROUP=2 ./scripts/check_compat_native_first_parity.sh
./scripts/check_prompt_mixed_reciprocal_parity.sh
./scripts/check_prompt_classic_fraction_parity.sh
./scripts/check_prompt_terminal_parity.sh
printf '%s\n' 'stage12c1/c2/c3/c4a/c4b/c4c/c4d/c4e/c4f/c4g/c4h terminal-width, native TTY editor, raw-command, fallback-child, bridge-free compatibility, native output-stream/markup-oneTable/no-blank-contents, reciprocal and classic-fraction tests complete'
