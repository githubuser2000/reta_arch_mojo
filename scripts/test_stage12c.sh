#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
CHECK_JOBS=${RETA_CHECK_JOBS:-4}
CHECK_TIMEOUT=${RETA_CHECK_TIMEOUT:-0}
CHILD_WORKERS=${RETA_CHECK_CHILD_WORKERS:-2}

# Prompt-, Launcher- und interaktive Zustandsprüfungen bleiben seriell. Die
# Anwendungspfade selbst werden nicht parallelisiert.
./scripts/check_native_prompt_input.sh
./scripts/check_prompt_external_commands.sh
./scripts/check_compat_launcher.sh

# Reine Rendering-/Paritätsprüfungen sind unabhängig. Jede erhält einen eigenen
# TMPDIR; Ausgabe wird trotz paralleler Ausführung in Manifestreihenfolge gezeigt.
python3 "$ROOT/tools/run_check_group.py" \
    --manifest "$ROOT/scripts/stage12c_rendering_parity_checks.tsv" \
    --root "$ROOT" \
    --jobs "$CHECK_JOBS" \
    --timeout "$CHECK_TIMEOUT" \
    --child-parallel-workers "$CHILD_WORKERS"

# Diese Prüfungen kompilieren, installieren oder untersuchen globale Layouts und
# bleiben deshalb exklusive Barrieren.
./scripts/check_no_blank_contents.sh
./scripts/check_resource_paths.sh
./scripts/check_install_layout.sh
"$ROOT/scripts/run_pytest.sh" -q tests/test_mojo_runtime_path.py tests/test_install_layout.py

# Prompt-/Completion-Parität bleibt seriell. Parallelisiert wird nur die
# Testorchestrierung der unabhängigen, zustandslosen Gruppen oben.
RETA_COMPAT_PARITY_GROUP=1 ./scripts/check_compat_native_first_parity.sh
RETA_COMPAT_PARITY_GROUP=2 ./scripts/check_compat_native_first_parity.sh
./scripts/check_prompt_mixed_reciprocal_parity.sh
./scripts/check_prompt_true_fraction_multiples.sh
python3 tools/check_known_defects.py
"$ROOT/scripts/run_pytest.sh" -q tests/test_known_defects.py
./scripts/check_prompt_classic_fraction_parity.sh
./scripts/check_prompt_terminal_parity.sh
./scripts/check_completion_word.sh
printf '%s\n' 'stage12c1/c2/c3/c4a/c4b/c4c/c4d/c4e/c4f/c4g/c4h/c4i/c4j/c4k/c4l/c4m/c4n/c4o/c4p/c4q/c4r/c4s/c4t terminal-width, native TTY editor, raw-command, fallback-child, bridge-free compatibility, portable Mojo runtime/FHS resource installation, native output-stream/markup-oneTable/no-blank-contents/paginated-rendering/column-widths/flat-column-widths/safe-generator-ranges/raw-nocolor-markup, startup/help, defect-ledger, native word-completion, reciprocal, true-fraction and classic-fraction tests complete'
