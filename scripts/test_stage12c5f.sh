#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
PYTHON=${RETA_REFERENCE_PYTHON:-"$(scripts/select_reference_python.sh)"}

(
    cd python_reference
    PYTHONPATH=.:libs PYTHONDONTWRITEBYTECODE=1 PYTHONHASHSEED=0 "$PYTHON" -m unittest \
      tests.test_architecture_refactor.ArchitectureRefactorRegressionTest.test_prompt_runtime_layer_is_explicit \
      tests.test_architecture_refactor.ArchitectureRefactorRegressionTest.test_semantic_builder_does_not_mutate_schema_sets \
      tests.test_architecture_refactor.ArchitectureRefactorRegressionTest.test_parameter_semantics_regression_counts \
      tests.test_architecture_refactor.ArchitectureRefactorRegressionTest.test_builder_standalone_matches_program_semantics
)

# Keep source/ownership gates before the full generated-catalog compile. The
# three compression roundtrips remain in the separate release/archive gate.
python3 -m pytest -q \
    tests/test_semantics_builder_source.py \
    tests/test_porting_matrix_ownership.py \
    tests/test_known_defects.py \
    tests/test_documented_python_defects.py \
    tests/test_native_boundary_audit.py \
    tests/test_porting_metrics.py
python3 tools/check_known_defects.py
python3 tools/porting_metrics.py

# Keep the allocator-heavy generated-catalog compile as the final operation.
scripts/check_semantics_builder.sh
printf '%s\n' 'stage12c5f native parameter semantics, column binding, and universal sync complete'
