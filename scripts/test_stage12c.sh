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
./scripts/check_paginated_rendering_parity.sh
./scripts/check_column_widths_parity.sh
./scripts/check_column_zero_widths_parity.sh
./scripts/check_flat_column_widths_parity.sh
./scripts/check_markup_nocolor_parity.sh
./scripts/check_resource_paths.sh
./scripts/check_install_layout.sh
python3 -m pytest -q tests/test_mojo_runtime_path.py tests/test_install_layout.py
RETA_COMPAT_PARITY_GROUP=1 ./scripts/check_compat_native_first_parity.sh
RETA_COMPAT_PARITY_GROUP=2 ./scripts/check_compat_native_first_parity.sh
./scripts/check_prompt_mixed_reciprocal_parity.sh
./scripts/check_prompt_classic_fraction_parity.sh
./scripts/check_prompt_terminal_parity.sh
printf '%s\n' 'stage12c1/c2/c3/c4a/c4b/c4c/c4d/c4e/c4f/c4g/c4h/c4i/c4j/c4k/c4l/c4m/c4n/c4o terminal-width, native TTY editor, raw-command, fallback-child, bridge-free compatibility, portable Mojo runtime/FHS resource installation, native output-stream/markup-oneTable/no-blank-contents/paginated-rendering/column-widths/flat-column-widths/raw-nocolor-markup, reciprocal and classic-fraction tests complete'
