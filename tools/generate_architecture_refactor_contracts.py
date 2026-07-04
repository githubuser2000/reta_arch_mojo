#!/usr/bin/env python3
"""Generate the exact native coverage contract for the legacy refactor suite.

``python_reference/tests/test_architecture_refactor.py`` is a monolithic
regression aggregator.  Its production owners have already moved to focused
Mojo modules and tests.  This generator keeps a strict one-to-one inventory of
all historical test methods, their assertion fingerprints, and the native test
that owns each contract.  It deliberately parses but never imports or executes
the Python reference.
"""
from __future__ import annotations

import argparse
import ast
import csv
import hashlib
import io
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/tests/test_architecture_refactor.py"
MANIFEST = ROOT / "assets/architecture_refactor_contracts.tsv"

# test_name: (category, native owner, native test, evidence token)
COVERAGE: dict[str, tuple[str, str, str, str]] = {
    "test_schema_is_explicit": ("schema", "schema.mojo", "tests/test_schema_snapshot.mojo", "test_native_schema_snapshot_matches_python_reference"),
    "test_words_split_modules_are_visible": ("i18n", "i18n_words.mojo", "tests/test_i18n_words.mojo", "test_container_and_reference_contract"),
    "test_input_layer_is_explicit": ("input", "input_semantics.mojo", "tests/test_input_semantics.mojo", "test_row_range_syntax_and_input_bundle_snapshot"),
    "test_prompt_runtime_layer_is_explicit": ("prompt", "prompt_runtime.mojo", "tests/test_prompt_runtime_contract.mojo", "test_runtime_contract_snapshot"),
    "test_prompt_session_layer_is_explicit": ("prompt", "prompt_session.mojo", "tests/test_prompt_session.mojo", "test_contract_snapshot"),
    "test_prompt_execution_layer_is_explicit": ("prompt", "prompt_execution.mojo", "tests/test_prompt_execution.mojo", "test_bundle_maps_large_python_owner_to_native_components"),
    "test_prompt_preparation_layer_is_explicit": ("prompt", "prompt_preparation.mojo", "tests/test_prompt_preparation.mojo", "test_legacy_facade_surface_and_snapshot"),
    "test_prompt_interaction_layer_is_explicit": ("prompt", "prompt_interaction.mojo", "tests/test_prompt_interaction.mojo", "test_contract_snapshot"),
    "test_completion_runtime_layer_is_explicit": ("completion", "completion_runtime.mojo", "tests/test_completion_runtime.mojo", "test_deutsch_runtime_sections_and_shortcuts"),
    "test_nested_completion_morphism_layer_is_activated": ("completion", "completion_nested.mojo", "tests/test_completion_nested.mojo", "test_bundle_snapshot_and_situations"),
    "test_prompt_language_layer_is_explicit": ("prompt", "prompt_language.mojo", "tests/test_prompt_language.mojo", "test_multilingual_dispatch_aliases"),
    "test_center_uses_split_i18n_proxy": ("i18n", "split_i18n.mojo", "tests/test_split_i18n.mojo", "build_split_i18n_proxy"),
    "test_row_range_morphism_layer_is_activated": ("domain", "row_ranges.mojo", "tests/test_row_ranges.mojo", "test_multiple_prefix"),
    "test_arithmetic_morphism_layer_is_activated": ("domain", "arithmetic.mojo", "tests/test_arithmetic.mojo", "test_prime_factors_modulo"),
    "test_console_io_morphism_layer_is_activated": ("runtime", "console_io.mojo", "tests/test_console_io_complete.mojo", "test_complete_console_bundle_snapshot"),
    "test_word_completion_morphism_layer_is_activated": ("completion", "completion_word.mojo", "tests/test_completion_word.mojo", "test_bundle_and_sample_match_stage_40_contract"),
    "test_prompt_vocabulary_matches_exported_globals": ("prompt", "legacy_libreta_prompt.mojo", "tests/test_legacy_libreta_prompt.mojo", "test_import_time_bundle_counts_match_reference"),
    "test_libretaprompt_is_thin_compatibility_facade": ("facade", "legacy_libreta_prompt.mojo", "tests/test_legacy_libreta_prompt.mojo", "test_prompt_modes_and_helpers_are_explicit"),
    "test_completion_stack_sources_use_explicit_completion_runtime": ("completion", "completion_runtime.mojo", "tests/test_completion_runtime.mojo", "test_language_normalization_and_fallback_values"),
    "test_column_selection_layer_is_explicit": ("table", "column_selection.mojo", "tests/test_column_selection.mojo", "test_legacy_bucket_coordinates_are_exact"),
    "test_generated_columns_layer_is_explicit": ("table", "generated_columns.mojo", "tests/test_generated_columns_registry.mojo", "test_surface_maps_every_python_owner_entry"),
    "test_table_output_layer_is_explicit": ("output", "table_output.mojo", "tests/test_table_output_complete.mojo", "test_bundle_snapshot_matches_python_contract"),
    "test_row_filtering_layer_is_explicit": ("table", "row_filtering.mojo", "tests/test_row_filtering.mojo", "test_absolute_and_divisors"),
    "test_table_wrapping_layer_is_explicit": ("table", "table_wrapping.mojo", "tests/test_table_wrapping.mojo", "test_complete_runtime_surface_and_snapshot"),
    "test_number_theory_layer_is_explicit": ("domain", "number_theory.mojo", "tests/test_number_theory.mojo", "test_prime_creativity"),
    "test_prepare_stack_delegates_to_row_filtering_layer": ("facade", "legacy_lib4tables_prepare.mojo", "tests/test_legacy_lib4tables_prepare.mojo", "test_prepare_filter_wrapping_and_row_preparation"),
    "test_table_preparation_layer_is_explicit": ("table", "table_preparation.mojo", "tests/test_table_preparation_complete.mojo", "test_bundle_snapshot_matches_reference_surface"),
    "test_parallel_execution_layer_is_explicit_and_argv_driven": ("parallel", "parallel_execution.mojo", "tests/test_parallel_execution_config.mojo", "extract_parallel_config_from_argv"),
    "test_parallel_row_preparation_matches_serial_result": ("parallel", "parallel_row_preparation.mojo", "tests/test_parallel_row_preparation.mojo", "parallel row preparation tests"),
    "test_more_parallel_table_helpers_match_serial_results": ("parallel", "parallel_execution.mojo", "tests/test_parallel_table_execution.mojo", "parallel table execution tests"),
    "test_table_generation_layer_is_explicit": ("table", "table_generation.mojo", "tests/test_table_generation_complete.mojo", "test_table_generation_bundle_snapshot_covers_python_contract"),
    "test_parameter_runtime_layer_is_explicit": ("parameter", "parameter_runtime.mojo", "tests/test_parameter_runtime_complete.mojo", "test_complete_legacy_surface_is_explicit"),
    "test_program_workflow_layer_is_explicit": ("workflow", "program_workflow.mojo", "tests/test_program_workflow.mojo", "test_program_workflow_catalog_and_snapshot"),
    "test_prepare_stack_delegates_to_table_preparation_layer": ("facade", "table_adapters.mojo", "tests/test_table_adapters.mojo", "test_prepare_row_helpers_delegate_to_native_owners"),
    "test_reta_program_delegates_to_program_workflow_layer": ("workflow", "legacy_reta_program.mojo", "tests/test_legacy_reta_program.mojo", "test_workflow_and_legacy_helpers_delegate_to_native_owners"),
    "test_output_syntax_layer_is_explicit": ("output", "output_syntax.mojo", "tests/test_output_semantics_complete.mojo", "test_output_syntax_bundle_owns_class_map_and_cells"),
    "test_lib4tables_is_thin_number_and_output_facade": ("facade", "legacy_lib4tables.mojo", "tests/test_legacy_lib4tables.mojo", "test_export_snapshot_matches_python_all"),
    "test_output_semantics_is_explicit": ("output", "output_semantics.mojo", "tests/test_output_semantics_complete.mojo", "test_output_semantics_snapshot_matches_python_order"),
    "test_output_mode_registry_matches_table_runtime": ("output", "output_modes.mojo", "tests/test_output_modes.mojo", "test_mode_inventory"),
    "test_semantic_builder_does_not_mutate_schema_sets": ("parameter", "semantics_builder.mojo", "tests/test_semantics_builder.mojo", "test_collect_all_values_normal_and_inverted"),
    "test_empty_modal_concat_short_circuits": ("table", "generated_table_columns.mojo", "tests/test_generated_table_columns.mojo", "test_modal_logic_stops_after_first_product_beyond_table"),
    "test_universal_merge_avoids_repeated_deepcopy": ("category", "universal.mojo", "tests/test_universal.mojo", "test_input_is_not_mutated"),
    "test_output_stack_sources_use_explicit_output_architecture": ("output", "table_output.mojo", "tests/test_table_output_complete.mojo", "test_cli_out_owns_renderer_result_and_buffer"),
    "test_remaining_executable_scripts_use_split_i18n_proxy": ("i18n", "split_i18n.mojo", "tests/test_split_i18n.mojo", "split_i18n_node_count"),
    "test_execution_network_layer_is_explicit_and_deterministic": ("execution", "execution_network.mojo", "tests/test_execution_network.mojo", "execute_tasks_deterministically"),
    "test_persistence_layer_is_explicit_and_roundtrips_sections": ("persistence", "persistence.mojo", "tests/test_persistence.mojo", "persist_section"),
    "test_package_integrity_manifest_is_explicit": ("package", "package_integrity.mojo", "tests/test_package_integrity.mojo", "repo_manifest_from_tree"),
    "test_parameter_semantics_regression_counts": ("parameter", "parameter_semantics.mojo", "tests/test_parameter_semantics.mojo", "test_parameter_groups_and_pair_storage_match_python_order"),
    "test_builder_standalone_matches_program_semantics": ("parameter", "semantics_builder.mojo", "tests/test_semantics_builder.mojo", "test_merge_overwrite_and_group_append_contract"),
    "test_meta_columns_layer_is_explicit": ("table", "meta_columns.mojo", "tests/test_meta_columns_complete.mojo", "test_meta_bundle_and_surface_cover_python_owner"),
    "test_concat_csv_layer_is_explicit": ("table", "concat_csv.mojo", "tests/test_concat_csv.mojo", "test_bundle_and_source_contract"),
    "test_concat_stack_delegates_to_concat_csv_layer": ("facade", "legacy_lib4tables_concat.mojo", "tests/test_legacy_lib4tables_concat.mojo", "test_pair_aliases_forward_to_concat_owner"),
    "test_combi_join_layer_is_explicit": ("table", "combi_join.mojo", "tests/test_combi_join.mojo", "test_bundle_covers_all_historical_morphisms"),
    "test_table_state_layer_is_explicit": ("table", "table_state.mojo", "tests/test_table_state.mojo", "test_state_section_names_match_python_bundle"),
    "test_table_runtime_layer_owns_tables": ("table", "table_runtime.mojo", "tests/test_table_runtime_complete.mojo", "test_bundle_snapshot_matches_python_contract"),
    "test_category_theory_layer_is_explicit": ("category", "category_theory.mojo", "tests/test_category_theory.mojo", "test_snapshot_counts"),
    "test_architecture_map_layer_is_explicit": ("architecture", "architecture_map.mojo", "tests/test_architecture_map.mojo", "test_snapshot_counts"),
    "test_architecture_contract_layer_is_explicit": ("architecture", "architecture_contracts.mojo", "tests/probe_architecture_contracts.mojo", "bootstrap_architecture_contracts"),
    "test_architecture_witness_layer_is_explicit": ("architecture", "architecture_witnesses.mojo", "tests/probe_architecture_witnesses.mojo", "bootstrap_architecture_witnesses"),
    "test_architecture_validation_layer_is_explicit": ("architecture", "architecture_validation.mojo", "tests/test_architecture_validation.mojo", "bootstrap_architecture_validation"),
    "test_architecture_coherence_layer_is_explicit": ("architecture", "architecture_coherence.mojo", "tests/test_architecture_coherence.mojo", "bootstrap_architecture_coherence"),
    "test_architecture_trace_layer_is_explicit": ("architecture", "architecture_traces.mojo", "tests/test_architecture_traces.mojo", "bootstrap_architecture_traces"),
    "test_architecture_boundary_layer_is_explicit": ("architecture", "architecture_boundaries.mojo", "tests/test_architecture_boundaries.mojo", "test_validation_and_known_ownership"),
    "test_architecture_impact_layer_is_explicit": ("architecture", "architecture_impact.mojo", "tests/test_architecture_impact.mojo", "bootstrap_architecture_impact"),
    "test_architecture_migration_layer_is_explicit": ("architecture", "architecture_migration.mojo", "tests/test_architecture_migration.mojo", "bootstrap_architecture_migration"),
    "test_architecture_rehearsal_layer_is_explicit": ("architecture", "architecture_rehearsal.mojo", "tests/test_architecture_rehearsal.mojo", "bootstrap_architecture_rehearsal"),
    "test_architecture_activation_layer_is_explicit": ("architecture", "architecture_activation.mojo", "tests/test_architecture_activation.mojo", "bootstrap_architecture_activation"),
    "test_tag_schema_owner_is_explicit": ("schema", "tag_schema.mojo", "tests/test_tag_schema.mojo", "test_complete_group_fingerprints_match_python"),
    "test_architecture_progress_layer_is_explicit": ("architecture", "architecture_progress.mojo", "tests/test_architecture_progress.mojo", "bootstrap_architecture_progress"),
    "test_known_pair_lookup_still_resolves": ("parameter", "parameter_semantics.mojo", "tests/test_schema_catalog_parity.mojo", "test_known_reta_aliases_resolve_natively"),
}


def reference_methods() -> list[ast.FunctionDef]:
    tree = ast.parse(REFERENCE.read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name == "ArchitectureRefactorRegressionTest":
            return [
                item
                for item in node.body
                if isinstance(item, ast.FunctionDef) and item.name.startswith("test_")
            ]
    raise RuntimeError("ArchitectureRefactorRegressionTest missing")


def assertion_count(method: ast.FunctionDef) -> int:
    total = 0
    for node in ast.walk(method):
        if not isinstance(node, ast.Call) or not isinstance(node.func, ast.Attribute):
            continue
        if isinstance(node.func.value, ast.Name) and node.func.value.id == "self" and node.func.attr.startswith("assert"):
            total += 1
    return total


def method_fingerprint(method: ast.FunctionDef) -> str:
    payload = ast.dump(method, annotate_fields=True, include_attributes=False).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def expected_manifest() -> bytes:
    methods = reference_methods()
    names = [method.name for method in methods]
    missing = sorted(set(names) - set(COVERAGE))
    stale = sorted(set(COVERAGE) - set(names))
    if missing or stale:
        raise RuntimeError(f"coverage mismatch: missing={missing}, stale={stale}")

    output = io.StringIO(newline="")
    writer = csv.writer(output, delimiter="\t", lineterminator="\n")
    writer.writerow(
        [
            "ordinal",
            "python_test",
            "line",
            "assertions",
            "category",
            "native_owner",
            "native_test",
            "evidence",
            "ast_sha256",
        ]
    )
    for ordinal, method in enumerate(methods, 1):
        category, owner, native_test, evidence = COVERAGE[method.name]
        target = ROOT / native_test
        if not target.is_file():
            raise RuntimeError(f"native test missing for {method.name}: {native_test}")
        target_source = target.read_text(encoding="utf-8")
        if evidence not in target_source:
            raise RuntimeError(
                f"evidence {evidence!r} missing in {native_test} for {method.name}"
            )
        writer.writerow(
            [
                ordinal,
                method.name,
                method.lineno,
                assertion_count(method),
                category,
                owner,
                native_test,
                evidence,
                method_fingerprint(method),
            ]
        )
    return output.getvalue().encode("utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    payload = expected_manifest()
    if args.check:
        if not MANIFEST.is_file() or MANIFEST.read_bytes() != payload:
            print("architecture refactor contract manifest differs")
            return 1
        action = "verified"
    else:
        MANIFEST.parent.mkdir(parents=True, exist_ok=True)
        MANIFEST.write_bytes(payload)
        action = "generated"
    print(f"architecture refactor contracts {action}: {len(reference_methods())} tests")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
