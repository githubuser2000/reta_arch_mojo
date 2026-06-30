"""Generated native Mojo representation of architecture_witnesses.
Repository path resolution happens only during explicit regeneration; runtime
witness navigation and coverage inspection are fully native.
Regenerate with tools/generate_architecture_witnesses.py.
"""

from std.collections import List

@fieldwise_init
struct WitnessMappingSpec(Copyable):
    var key: String
    var value: String

@fieldwise_init
struct AnchorWitnessSpec(Copyable):
    var anchor: String
    var owner: String
    var resolution_kind: String
    var matched_paths: List[String]
    var status: String
    var note: String

@fieldwise_init
struct CapsuleSliceSpec(Copyable):
    var capsule: String
    var layer: String
    var old_reta_parts: List[String]
    var new_owners: List[String]
    var contained_sections: List[String]
    var math_roles: List[String]
    var protected_by: List[String]
    var witness_anchors: List[String]
    var anchor_status: String
    var stage_span: String
    var description: String

@fieldwise_init
struct DiagramWitnessSpec(Copyable):
    var diagram: String
    var diagram_type: String
    var capsules: List[String]
    var natural_transformations: List[String]
    var implementation_anchors: List[String]
    var verification_evidence: List[String]
    var probe_commands: List[String]
    var proof_obligation: String
    var witness_status: String

@fieldwise_init
struct NaturalTransformationWitnessSpec(Copyable):
    var transformation: String
    var source_functor: String
    var target_functor: String
    var diagrams: List[String]
    var capsules: List[String]
    var component_anchors: List[WitnessMappingSpec]
    var code_owner: String
    var witness_status: String
    var naturality_condition: String

@fieldwise_init
struct RefactorObligationSpec(Copyable):
    var name: String
    var obligation_type: String
    var applies_to: List[String]
    var witness_diagrams: List[String]
    var evidence: List[String]
    var keep_true_when: String
    var status: String

@fieldwise_init
struct WitnessValidationSpec(Copyable):
    var status: String
    var file_like_anchor_count: Int
    var resolved_anchor_count: Int
    var symbolic_anchor_count: Int
    var missing_file_like_anchors: List[String]
    var uncovered_capsules: List[String]
    var uncovered_diagrams: List[String]
    var uncovered_laws: List[String]
    var uncovered_natural_transformations: List[String]

@fieldwise_init
struct Stage30ArchitecturePlan(Copyable):
    var planned_after_stage_29: List[String]
    var implemented_in_stage_30: List[String]
    var inherited_from_previous_stages: List[String]
    var behaviour_change: String

@fieldwise_init
struct ArchitectureWitnessBundle(Copyable):
    var anchor_witnesses: List[AnchorWitnessSpec]
    var capsule_slices: List[CapsuleSliceSpec]
    var diagram_witnesses: List[DiagramWitnessSpec]
    var naturality_witnesses: List[NaturalTransformationWitnessSpec]
    var obligations: List[RefactorObligationSpec]
    var validation: WitnessValidationSpec
    var text_diagram: String
    var mermaid_diagram: String
    var plan: Stage30ArchitecturePlan

def anchor_witness_index(bundle: ArchitectureWitnessBundle, owner: String, anchor: String) -> Int:
    for index in range(len(bundle.anchor_witnesses)):
        if bundle.anchor_witnesses[index].owner == owner and bundle.anchor_witnesses[index].anchor == anchor:
            return index
    return -1

def capsule_slice_index(bundle: ArchitectureWitnessBundle, capsule: String) -> Int:
    for index in range(len(bundle.capsule_slices)):
        if bundle.capsule_slices[index].capsule == capsule:
            return index
    return -1

def diagram_witness_index(bundle: ArchitectureWitnessBundle, diagram: String) -> Int:
    for index in range(len(bundle.diagram_witnesses)):
        if bundle.diagram_witnesses[index].diagram == diagram:
            return index
    return -1

def naturality_witness_index(bundle: ArchitectureWitnessBundle, transformation: String) -> Int:
    for index in range(len(bundle.naturality_witnesses)):
        if bundle.naturality_witnesses[index].transformation == transformation:
            return index
    return -1

def refactor_obligation_index(bundle: ArchitectureWitnessBundle, name: String) -> Int:
    for index in range(len(bundle.obligations)):
        if bundle.obligations[index].name == name:
            return index
    return -1

def witness_validation_passed(bundle: ArchitectureWitnessBundle) -> Bool:
    return (
        bundle.validation.status == "passed"
        and bundle.validation.file_like_anchor_count == bundle.validation.resolved_anchor_count
        and len(bundle.validation.missing_file_like_anchors) == 0
        and len(bundle.validation.uncovered_capsules) == 0
        and len(bundle.validation.uncovered_diagrams) == 0
        and len(bundle.validation.uncovered_laws) == 0
        and len(bundle.validation.uncovered_natural_transformations) == 0
    )

def architecture_witnesses_count_line(bundle: ArchitectureWitnessBundle) -> String:
    return (
        "anchor_witnesses=" + String(len(bundle.anchor_witnesses))
        + " capsule_slices=" + String(len(bundle.capsule_slices))
        + " diagram_witnesses=" + String(len(bundle.diagram_witnesses))
        + " naturality_witnesses=" + String(len(bundle.naturality_witnesses))
        + " obligations=" + String(len(bundle.obligations))
        + " resolved_anchors=" + String(bundle.validation.resolved_anchor_count)
    )

def bootstrap_architecture_witnesses() -> ArchitectureWitnessBundle:
    var anchor_witnesses = List[AnchorWitnessSpec]()
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/facade.py", "RetaArchitectureRoot", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/__init__.py", "RetaArchitectureRoot", "source_file",
        ["reta_architecture/__init__.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/schema.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/schema.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/topology.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/topology.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/split_i18n.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/split_i18n.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_context.py", "SchemaTopologyCapsule", "source_file",
        ["i18n/words_context.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_matrix.py", "SchemaTopologyCapsule", "source_file",
        ["i18n/words_matrix.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_runtime.py", "SchemaTopologyCapsule", "source_file",
        ["i18n/words_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/presheaves.py", "LocalSectionCapsule", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "csv/*.csv", "LocalSectionCapsule", "glob",
        ["csv/2024-07-06-symbols-alt-ak-circle-sphere-etc.csv", "csv/cn-dualism-trinities-etc.csv", "csv/cn-gebrochen-rational-emotionen.csv", "csv/cn-gebrochen-rational-galaxie.csv", "csv/cn-gebrochen-rational-strukturgroesse.csv", "csv/cn-gebrochen-rational-universum.csv", "csv/cn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/cn-kombi-meta-systeme.csv", "csv/cn-kombi-meta.csv", "csv/cn-kombi-universelle-wirklichkeit.csv", "csv/cn-kombi.csv", "csv/cn-kreisVomTyp18.csv", "csv/cn-meaningOfLife.csv", "csv/cn-primenumbers.csv", "csv/cn-religion.csv", "csv/cn-sunMoonEtc.csv", "csv/cn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/dualism-trinities-etc.csv", "csv/en-dualism-trinities-etc.csv", "csv/en-gebrochen-rational-emotionen.csv", "csv/en-gebrochen-rational-galaxie.csv", "csv/en-gebrochen-rational-strukturgroesse.csv", "csv/en-gebrochen-rational-universum.csv", "csv/en-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/en-kombi-meta-systeme.csv", "csv/en-kombi-meta.csv", "csv/en-kombi-universelle-wirklichkeit.csv", "csv/en-kombi.csv", "csv/en-kreisVomTyp18.csv", "csv/en-meaningOfLife.csv", "csv/en-primenumbers.csv", "csv/en-religion.csv", "csv/en-sunMoonEtc.csv", "csv/gebrochen-rational-emotionen.csv", "csv/gebrochen-rational-galaxie.csv", "csv/gebrochen-rational-strukturgroesse.csv", "csv/gebrochen-rational-universum.csv", "csv/kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kombi-meta-systeme.csv", "csv/kombi-meta.csv", "csv/kombi-universelle-wirklichkeit.csv", "csv/kombi.csv", "csv/kr-dualism-trinities-etc.csv", "csv/kr-gebrochen-rational-emotionen.csv", "csv/kr-gebrochen-rational-galaxie.csv", "csv/kr-gebrochen-rational-strukturgroesse.csv", "csv/kr-gebrochen-rational-universum.csv", "csv/kr-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kr-kombi-meta-systeme.csv", "csv/kr-kombi-meta.csv", "csv/kr-kombi-universelle-wirklichkeit.csv", "csv/kr-kombi.csv", "csv/kr-kreisVomTyp18.csv", "csv/kr-meaningOfLife.csv", "csv/kr-primenumbers.csv", "csv/kr-religion.csv", "csv/kr-sunMoonEtc.csv", "csv/kr-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/kreisVomTyp18.csv", "csv/meaningOfLife.csv", "csv/primenumbers.csv", "csv/religion.csv", "csv/sunMoonEtc.csv", "csv/vn-dualism-trinities-etc.csv", "csv/vn-gebrochen-rational-emotionen.csv", "csv/vn-gebrochen-rational-galaxie.csv", "csv/vn-gebrochen-rational-strukturgroesse.csv", "csv/vn-gebrochen-rational-universum.csv", "csv/vn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/vn-kombi-meta-systeme.csv", "csv/vn-kombi-meta.csv", "csv/vn-kombi-universelle-wirklichkeit.csv", "csv/vn-kombi.csv", "csv/vn-kreisVomTyp18.csv", "csv/vn-meaningOfLife.csv", "csv/vn-primenumbers.csv", "csv/vn-religion.csv", "csv/vn-sunMoonEtc.csv", "csv/vn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "doc/*.md", "LocalSectionCapsule", "glob",
        ["doc/readme-reta-en.md", "doc/readme-reta.md", "doc/readme-retaPrompt-en.md", "doc/readme-retaPrompt.md", "doc/readme-startFiles.md"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "readme*.md", "LocalSectionCapsule", "glob",
        ["readme-reta-en.md", "readme-reta.md", "readme-retaPrompt-en.md", "readme-retaPrompt.md", "readme-startFiles.md"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/sheaves.py", "SemanticSheafCapsule", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/semantics_builder.py", "SemanticSheafCapsule", "source_file",
        ["reta_architecture/semantics_builder.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/input_semantics.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/input_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_runtime.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_language.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_session.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_session.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_execution.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_execution.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_preparation.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_preparation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_interaction.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/prompt_interaction.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "retaPrompt.py", "InputPromptCapsule", "source_file",
        ["retaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/LibRetaPrompt.py", "InputPromptCapsule", "source_file",
        ["libs/LibRetaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/nestedAlx.py", "InputPromptCapsule", "source_file",
        ["libs/nestedAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/parameter_runtime.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/parameter_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/column_selection.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/column_selection.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/program_workflow.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/program_workflow.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_generation.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/universal.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "WorkflowGluingCapsule", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_runtime.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_state.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_preparation.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_preparation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_filtering.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/row_filtering.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_wrapping.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_wrapping.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/number_theory.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/number_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/tableHandling.py", "TableCoreCapsule", "source_file",
        ["libs/tableHandling.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_prepare.py", "TableCoreCapsule", "source_file",
        ["libs/lib4tables_prepare.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/generated_columns.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/meta_columns.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/meta_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/concat_csv.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/concat_csv.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/combi_join.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/combi_join.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_concat.py", "GeneratedRelationCapsule", "source_file",
        ["libs/lib4tables_concat.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/tableHandling.py", "GeneratedRelationCapsule", "source_file",
        ["libs/tableHandling.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/output_syntax.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_syntax.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/output_semantics.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_output.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables.py", "OutputRenderingCapsule", "source_file",
        ["libs/lib4tables.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "CompatibilityCapsule", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "retaPrompt.py", "CompatibilityCapsule", "source_file",
        ["retaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/tableHandling.py", "CompatibilityCapsule", "source_file",
        ["libs/tableHandling.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables.py", "CompatibilityCapsule", "source_file",
        ["libs/lib4tables.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_prepare.py", "CompatibilityCapsule", "source_file",
        ["libs/lib4tables_prepare.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_concat.py", "CompatibilityCapsule", "source_file",
        ["libs/lib4tables_concat.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/package_integrity.py", "CompatibilityCapsule", "source_file",
        ["reta_architecture/package_integrity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_command_parity.py", "CompatibilityCapsule", "source_file",
        ["tests/test_command_parity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/category_theory.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/category_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_map.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_map.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_contracts.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_witnesses.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_witnesses.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_coherence.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_coherence.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_traces.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_traces.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_boundaries.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_boundaries.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_impact.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_impact.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_migration.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_migration.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_rehearsal.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_rehearsal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_activation.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_activation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words.py", "i18n/words.py", "source_file",
        ["i18n/words.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_context.py", "i18n/words.py", "source_file",
        ["i18n/words_context.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_matrix.py", "i18n/words.py", "source_file",
        ["i18n/words_matrix.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "i18n/words_runtime.py", "i18n/words.py", "source_file",
        ["i18n/words_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/schema.py", "i18n/words.py", "source_file",
        ["reta_architecture/schema.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/semantics_builder.py", "i18n/words.py", "source_file",
        ["reta_architecture/semantics_builder.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "csv/*.csv", "csv/*.csv", "glob",
        ["csv/2024-07-06-symbols-alt-ak-circle-sphere-etc.csv", "csv/cn-dualism-trinities-etc.csv", "csv/cn-gebrochen-rational-emotionen.csv", "csv/cn-gebrochen-rational-galaxie.csv", "csv/cn-gebrochen-rational-strukturgroesse.csv", "csv/cn-gebrochen-rational-universum.csv", "csv/cn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/cn-kombi-meta-systeme.csv", "csv/cn-kombi-meta.csv", "csv/cn-kombi-universelle-wirklichkeit.csv", "csv/cn-kombi.csv", "csv/cn-kreisVomTyp18.csv", "csv/cn-meaningOfLife.csv", "csv/cn-primenumbers.csv", "csv/cn-religion.csv", "csv/cn-sunMoonEtc.csv", "csv/cn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/dualism-trinities-etc.csv", "csv/en-dualism-trinities-etc.csv", "csv/en-gebrochen-rational-emotionen.csv", "csv/en-gebrochen-rational-galaxie.csv", "csv/en-gebrochen-rational-strukturgroesse.csv", "csv/en-gebrochen-rational-universum.csv", "csv/en-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/en-kombi-meta-systeme.csv", "csv/en-kombi-meta.csv", "csv/en-kombi-universelle-wirklichkeit.csv", "csv/en-kombi.csv", "csv/en-kreisVomTyp18.csv", "csv/en-meaningOfLife.csv", "csv/en-primenumbers.csv", "csv/en-religion.csv", "csv/en-sunMoonEtc.csv", "csv/gebrochen-rational-emotionen.csv", "csv/gebrochen-rational-galaxie.csv", "csv/gebrochen-rational-strukturgroesse.csv", "csv/gebrochen-rational-universum.csv", "csv/kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kombi-meta-systeme.csv", "csv/kombi-meta.csv", "csv/kombi-universelle-wirklichkeit.csv", "csv/kombi.csv", "csv/kr-dualism-trinities-etc.csv", "csv/kr-gebrochen-rational-emotionen.csv", "csv/kr-gebrochen-rational-galaxie.csv", "csv/kr-gebrochen-rational-strukturgroesse.csv", "csv/kr-gebrochen-rational-universum.csv", "csv/kr-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kr-kombi-meta-systeme.csv", "csv/kr-kombi-meta.csv", "csv/kr-kombi-universelle-wirklichkeit.csv", "csv/kr-kombi.csv", "csv/kr-kreisVomTyp18.csv", "csv/kr-meaningOfLife.csv", "csv/kr-primenumbers.csv", "csv/kr-religion.csv", "csv/kr-sunMoonEtc.csv", "csv/kr-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/kreisVomTyp18.csv", "csv/meaningOfLife.csv", "csv/primenumbers.csv", "csv/religion.csv", "csv/sunMoonEtc.csv", "csv/vn-dualism-trinities-etc.csv", "csv/vn-gebrochen-rational-emotionen.csv", "csv/vn-gebrochen-rational-galaxie.csv", "csv/vn-gebrochen-rational-strukturgroesse.csv", "csv/vn-gebrochen-rational-universum.csv", "csv/vn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/vn-kombi-meta-systeme.csv", "csv/vn-kombi-meta.csv", "csv/vn-kombi-universelle-wirklichkeit.csv", "csv/vn-kombi.csv", "csv/vn-kreisVomTyp18.csv", "csv/vn-meaningOfLife.csv", "csv/vn-primenumbers.csv", "csv/vn-religion.csv", "csv/vn-sunMoonEtc.csv", "csv/vn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/presheaves.py", "csv/*.csv", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/concat_csv.py", "csv/*.csv", "source_file",
        ["reta_architecture/concat_csv.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_generation.py", "csv/*.csv", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "reta.py", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/parameter_runtime.py", "reta.py", "source_file",
        ["reta_architecture/parameter_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/column_selection.py", "reta.py", "source_file",
        ["reta_architecture/column_selection.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/program_workflow.py", "reta.py", "source_file",
        ["reta_architecture/program_workflow.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_generation.py", "reta.py", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/facade.py", "reta.py", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "retaPrompt.py", "retaPrompt.py", "source_file",
        ["retaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_runtime.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "retaPrompt.py", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_language.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_session.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_session.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_execution.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_execution.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_preparation.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_preparation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_interaction.py", "retaPrompt.py", "source_file",
        ["reta_architecture/prompt_interaction.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "libs/center.py", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/input_semantics.py", "libs/center.py", "source_file",
        ["reta_architecture/input_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_filtering.py", "libs/center.py", "source_file",
        ["reta_architecture/row_filtering.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/LibRetaPrompt.py", "libs/LibRetaPrompt.py", "source_file",
        ["libs/LibRetaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/input_semantics.py", "libs/LibRetaPrompt.py", "source_file",
        ["reta_architecture/input_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_runtime.py", "libs/LibRetaPrompt.py", "source_file",
        ["reta_architecture/prompt_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "libs/LibRetaPrompt.py", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_language.py", "libs/LibRetaPrompt.py", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/nestedAlx.py", "libs/nestedAlx.py", "source_file",
        ["libs/nestedAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "libs/nestedAlx.py", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_language.py", "libs/nestedAlx.py", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables.py", "libs/lib4tables.py", "source_file",
        ["libs/lib4tables.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/output_syntax.py", "libs/lib4tables.py", "source_file",
        ["reta_architecture/output_syntax.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/output_semantics.py", "libs/lib4tables.py", "source_file",
        ["reta_architecture/output_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/number_theory.py", "libs/lib4tables.py", "source_file",
        ["reta_architecture/number_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/tableHandling.py", "libs/tableHandling.py", "source_file",
        ["libs/tableHandling.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_runtime.py", "libs/tableHandling.py", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_state.py", "libs/tableHandling.py", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_output.py", "libs/tableHandling.py", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/combi_join.py", "libs/tableHandling.py", "source_file",
        ["reta_architecture/combi_join.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/generated_columns.py", "libs/tableHandling.py", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_prepare.py", "libs/lib4tables_prepare.py", "source_file",
        ["libs/lib4tables_prepare.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_preparation.py", "libs/lib4tables_prepare.py", "source_file",
        ["reta_architecture/table_preparation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_filtering.py", "libs/lib4tables_prepare.py", "source_file",
        ["reta_architecture/row_filtering.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_wrapping.py", "libs/lib4tables_prepare.py", "source_file",
        ["reta_architecture/table_wrapping.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_concat.py", "libs/lib4tables_concat.py", "source_file",
        ["libs/lib4tables_concat.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/generated_columns.py", "libs/lib4tables_concat.py", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/meta_columns.py", "libs/lib4tables_concat.py", "source_file",
        ["reta_architecture/meta_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/concat_csv.py", "libs/lib4tables_concat.py", "source_file",
        ["reta_architecture/concat_csv.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "source_file",
        ["reta_architecture/combi_join.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables_Enum.py", "libs/lib4tables_Enum.py", "source_file",
        ["libs/lib4tables_Enum.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/tag_schema.py", "libs/lib4tables_Enum.py", "source_file",
        ["reta_architecture/tag_schema.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/schema.py", "libs/lib4tables_Enum.py", "source_file",
        ["reta_architecture/schema.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/generated_columns.py", "libs/lib4tables_Enum.py", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_state.py", "libs/lib4tables_Enum.py", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_contracts.py", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/category_theory.py", "reta_architecture/architecture_contracts.py", "source_file",
        ["reta_architecture/category_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "source_file",
        ["reta_architecture/architecture_map.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_witnesses.py", "source_file",
        ["reta_architecture/architecture_witnesses.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "reta_architecture/architecture_witnesses.py", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_validation.py", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_validation.py", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture_probe_py.py", "reta_architecture/architecture_validation.py", "source_file",
        ["reta_architecture_probe_py.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_coherence.py", "source_file",
        ["reta_architecture/architecture_coherence.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_coherence.py", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture_probe_py.py", "reta_architecture/architecture_coherence.py", "source_file",
        ["reta_architecture_probe_py.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "readme*.md / doc/*.md", "readme*.md / doc/*.md", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "doc/*.md", "readme*.md / doc/*.md", "glob",
        ["doc/readme-reta-en.md", "doc/readme-reta.md", "doc/readme-retaPrompt-en.md", "doc/readme-retaPrompt.md", "doc/readme-startFiles.md"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ARCHITECTURE_REFACTOR*.md", "readme*.md / doc/*.md", "glob",
        ["ARCHITECTURE_REFACTOR.md", "ARCHITECTURE_REFACTOR_STAGE18.md", "ARCHITECTURE_REFACTOR_STAGE22.md", "ARCHITECTURE_REFACTOR_STAGE23.md", "ARCHITECTURE_REFACTOR_STAGE26.md", "ARCHITECTURE_REFACTOR_STAGE27.md", "ARCHITECTURE_REFACTOR_STAGE28.md", "ARCHITECTURE_REFACTOR_STAGE29.md", "ARCHITECTURE_REFACTOR_STAGE30.md", "ARCHITECTURE_REFACTOR_STAGE31.md", "ARCHITECTURE_REFACTOR_STAGE32.md", "ARCHITECTURE_REFACTOR_STAGE33.md", "ARCHITECTURE_REFACTOR_STAGE34.md", "ARCHITECTURE_REFACTOR_STAGE35.md", "ARCHITECTURE_REFACTOR_STAGE36.md", "ARCHITECTURE_REFACTOR_STAGE37.md", "ARCHITECTURE_REFACTOR_STAGE38.md", "ARCHITECTURE_REFACTOR_STAGE39.md", "ARCHITECTURE_REFACTOR_STAGE40.md", "ARCHITECTURE_REFACTOR_STAGE41.md"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "STAGE*_CHANGES.md", "readme*.md / doc/*.md", "glob",
        ["STAGE10_CHANGES.md", "STAGE11_CHANGES.md", "STAGE12_CHANGES.md", "STAGE13_CHANGES.md", "STAGE14_CHANGES.md", "STAGE15_CHANGES.md", "STAGE16_CHANGES.md", "STAGE17_CHANGES.md", "STAGE18_CHANGES.md", "STAGE19_CHANGES.md", "STAGE20_CHANGES.md", "STAGE21_CHANGES.md", "STAGE22_CHANGES.md", "STAGE23_CHANGES.md", "STAGE24_CHANGES.md", "STAGE25_CHANGES.md", "STAGE26_CHANGES.md", "STAGE27_CHANGES.md", "STAGE28_CHANGES.md", "STAGE29_CHANGES.md", "STAGE30_CHANGES.md", "STAGE31_CHANGES.md", "STAGE32_CHANGES.md", "STAGE33_CHANGES.md", "STAGE34_CHANGES.md", "STAGE35_CHANGES.md", "STAGE36_CHANGES.md", "STAGE37_CHANGES.md", "STAGE38_CHANGES.md", "STAGE39_CHANGES.md", "STAGE3_CHANGES.md", "STAGE40_CHANGES.md", "STAGE41_CHANGES.md", "STAGE42_CHANGES.md", "STAGE4_CHANGES.md", "STAGE5_CHANGES.md", "STAGE6_CHANGES.md", "STAGE7_CHANGES.md", "STAGE8_CHANGES.md", "STAGE9_CHANGES.md"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/architecture_traces.py", "source_file",
        ["reta_architecture/architecture_traces.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureTraceBundle", "reta_architecture/architecture_traces.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_boundaries.py", "source_file",
        ["reta_architecture/architecture_boundaries.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureBoundariesBundle", "reta_architecture/architecture_boundaries.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_impact.py", "source_file",
        ["reta_architecture/architecture_impact.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureImpactBundle", "reta_architecture/architecture_impact.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_migration.py", "reta_architecture/architecture_migration.py", "source_file",
        ["reta_architecture/architecture_migration.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureMigrationBundle", "reta_architecture/architecture_migration.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_rehearsal.py", "source_file",
        ["reta_architecture/architecture_rehearsal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "reta_architecture/architecture_rehearsal.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_activation.py", "reta_architecture/architecture_activation.py", "source_file",
        ["reta_architecture/architecture_activation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureActivationBundle", "reta_architecture/architecture_activation.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "libs/center.py", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "reta_architecture/row_ranges.py", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "RowRangeMorphismBundle", "reta_architecture/row_ranges.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "libs/center.py", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "reta_architecture/arithmetic.py", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArithmeticMorphismBundle", "reta_architecture/arithmetic.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "libs/center.py", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "reta_architecture/console_io.py", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ConsoleIOMorphismBundle", "reta_architecture/console_io.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/word_completerAlx.py", "libs/word_completerAlx.py", "source_file",
        ["libs/word_completerAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "libs/word_completerAlx.py", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "reta_architecture/completion_word.py", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "WordCompletionMorphismBundle", "reta_architecture/completion_word.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureWordCompleter", "reta_architecture/completion_word.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "libs/nestedAlx.py", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/completion_nested.py", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "NestedCompletionMorphismBundle", "reta_architecture/completion_nested.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureNestedCompleter", "reta_architecture/completion_nested.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ComplSitua", "reta_architecture/completion_nested.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_progress.py", "reta_architecture/architecture_progress.py", "source_file",
        ["reta_architecture/architecture_progress.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureProgressBundle", "reta_architecture/architecture_progress.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "MigrationExecutionSpec", "reta_architecture/architecture_progress.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "WaveExecutionSpec", "reta_architecture/architecture_progress.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "OutstandingWorkItemSpec", "reta_architecture/architecture_progress.py", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "RetaArchitecture.bootstrap", "flow:CompatibilityCapsule->SchemaTopologyCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "RetaContextSchema.from_words_parts", "flow:CompatibilityCapsule->SchemaTopologyCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "RetaContextTopology", "flow:SchemaTopologyCapsule->LocalSectionCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "PresheafBundle", "flow:SchemaTopologyCapsule->LocalSectionCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "PresheafBundle", "flow:LocalSectionCapsule->SemanticSheafCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "SheafBundle", "flow:LocalSectionCapsule->SemanticSheafCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "UniversalBundle", "flow:LocalSectionCapsule->SemanticSheafCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "morphisms.py", "flow:InputPromptCapsule->SemanticSheafCapsule", "source_file",
        ["reta_architecture/morphisms.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt_language.py", "flow:InputPromptCapsule->SemanticSheafCapsule", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves.py", "flow:InputPromptCapsule->SemanticSheafCapsule", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "column_selection.py", "flow:SemanticSheafCapsule->WorkflowGluingCapsule", "source_file",
        ["reta_architecture/column_selection.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "parameter_runtime.py", "flow:SemanticSheafCapsule->WorkflowGluingCapsule", "source_file",
        ["reta_architecture/parameter_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "universal.py", "flow:SemanticSheafCapsule->WorkflowGluingCapsule", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_generation.py", "flow:WorkflowGluingCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "program_workflow.py", "flow:WorkflowGluingCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/program_workflow.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_runtime.py", "flow:WorkflowGluingCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "generated_columns.py", "flow:TableCoreCapsule->GeneratedRelationCapsule", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "concat_csv.py", "flow:TableCoreCapsule->GeneratedRelationCapsule", "source_file",
        ["reta_architecture/concat_csv.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "combi_join.py", "flow:TableCoreCapsule->GeneratedRelationCapsule", "source_file",
        ["reta_architecture/combi_join.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "generated_columns.py", "flow:GeneratedRelationCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state.py", "flow:GeneratedRelationCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "universal.py", "flow:GeneratedRelationCapsule->TableCoreCapsule", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_output.py", "flow:TableCoreCapsule->OutputRenderingCapsule", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "output_semantics.py", "flow:TableCoreCapsule->OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "output_syntax.py", "flow:TableCoreCapsule->OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_syntax.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_command_parity.py", "flow:OutputRenderingCapsule->CompatibilityCapsule", "source_file",
        ["tests/test_command_parity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "flow:CompatibilityCapsule->RetaArchitectureRoot", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "retaPrompt.py", "flow:CompatibilityCapsule->RetaArchitectureRoot", "source_file",
        ["retaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs compatibility facades", "flow:CompatibilityCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_runtime.py", "flow:TableCoreCapsule->CategoricalMetaCapsule", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state.py", "flow:TableCoreCapsule->CategoricalMetaCapsule", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "category_theory.py", "flow:TableCoreCapsule->CategoricalMetaCapsule", "source_file",
        ["reta_architecture/category_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_contracts.py", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_witnesses.py", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "source_file",
        ["reta_architecture/architecture_witnesses.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_validation.py", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_coherence.py", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "source_file",
        ["reta_architecture/architecture_coherence.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureTraceBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureBoundariesBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureImpactBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureImpactBundle", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureMigrationBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureMigrationBundle", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "flow:CategoricalMetaCapsule->WorkflowGluingCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "flow:CategoricalMetaCapsule->SchemaTopologyCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureRehearsalBundle", "flow:CategoricalMetaCapsule->CategoricalMetaCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureActivationBundle", "flow:CategoricalMetaCapsule->RetaArchitectureRoot", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureActivationBundle", "flow:CategoricalMetaCapsule->CompatibilityCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureActivationBundle", "flow:CategoricalMetaCapsule->WorkflowGluingCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "ArchitectureActivationBundle", "flow:CategoricalMetaCapsule->CategoricalMetaCapsule", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "flow:CategoricalMetaCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "flow:CompatibilityCapsule->InputPromptCapsule", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "flow:InputPromptCapsule->LocalSectionCapsule", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "flow:InputPromptCapsule->CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "flow:CategoricalMetaCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "flow:InputPromptCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "flow:CategoricalMetaCapsule->OutputRenderingCapsule", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "flow:CompatibilityCapsule->OutputRenderingCapsule", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "flow:OutputRenderingCapsule->OutputRenderingCapsule", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "flow:OutputRenderingCapsule->CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "flow:CategoricalMetaCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/word_completerAlx.py", "flow:CompatibilityCapsule->InputPromptCapsule", "source_file",
        ["libs/word_completerAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "flow:InputPromptCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "flow:CategoricalMetaCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/nestedAlx.py", "flow:CompatibilityCapsule->InputPromptCapsule", "source_file",
        ["libs/nestedAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "flow:InputPromptCapsule->InputPromptCapsule", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "facade.py", "RetaArchitectureRoot", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "__init__.py", "RetaArchitectureRoot", "source_file",
        ["reta_architecture/__init__.py", "tests/__init__.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "schema.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/schema.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "topology.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/topology.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "split_i18n.py", "SchemaTopologyCapsule", "source_file",
        ["reta_architecture/split_i18n.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "presheaves.py", "LocalSectionCapsule", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves.py", "SemanticSheafCapsule", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "semantics_builder.py", "SemanticSheafCapsule", "source_file",
        ["reta_architecture/semantics_builder.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "input_semantics.py", "InputPromptCapsule", "source_file",
        ["reta_architecture/input_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt_*.py", "InputPromptCapsule", "glob",
        ["reta_architecture/prompt_execution.py", "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_runtime.py", "reta_architecture/prompt_session.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "parameter_runtime.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/parameter_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "column_selection.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/column_selection.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "program_workflow.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/program_workflow.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_generation.py", "WorkflowGluingCapsule", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_runtime.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_preparation.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_preparation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row_filtering.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/row_filtering.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_wrapping.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/table_wrapping.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "number_theory.py", "TableCoreCapsule", "source_file",
        ["reta_architecture/number_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "generated_columns.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "meta_columns.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/meta_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "concat_csv.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/concat_csv.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "combi_join.py", "GeneratedRelationCapsule", "source_file",
        ["reta_architecture/combi_join.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "output_syntax.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_syntax.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "output_semantics.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/output_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_output.py", "OutputRenderingCapsule", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/*", "CompatibilityCapsule", "glob",
        ["libs/2021-06-varibales.sh", "libs/256.sh", "libs/LibRetaPrompt.py", "libs/alxcommit", "libs/center.py", "libs/changeVersion.sh", "libs/farbuebersicht.sh", "libs/generate4readme.py", "libs/kombi-merke.sh", "libs/lib4tables.py", "libs/lib4tables_Enum.py", "libs/lib4tables_concat.py", "libs/lib4tables_prepare.py", "libs/nestedAlx.py", "libs/out1csv.sh", "libs/tableHandling.py", "libs/version.sh", "libs/word_completerAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "package_integrity.py", "CompatibilityCapsule", "source_file",
        ["reta_architecture/package_integrity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "category_theory.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/category_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_map.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_map.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_contracts.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_witnesses.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_witnesses.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_validation.py", "CategoricalMetaCapsule", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "topology.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/topology.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "presheaves.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt_language.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "input_semantics.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/input_semantics.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt_runtime.py", "RawCommandNaturalitySquare", "source_file",
        ["reta_architecture/prompt_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "known alias lookup", "verification:RawCommandNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt-language regression tests", "verification:RawCommandNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "presheaves.py", "PresheafSheafGluingSquare", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves.py", "PresheafSheafGluingSquare", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "universal.py", "PresheafSheafGluingSquare", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "semantics_builder.py", "PresheafSheafGluingSquare", "source_file",
        ["reta_architecture/semantics_builder.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "topology.py", "PresheafSheafGluingSquare", "source_file",
        ["reta_architecture/topology.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "presheaves-json", "verification:PresheafSheafGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves-json", "verification:PresheafSheafGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "semantic count regressions", "verification:PresheafSheafGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "parameter_runtime.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/parameter_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "column_selection.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/column_selection.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_generation.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/table_generation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "universal.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "facade.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "program_workflow.py", "UniversalWorkflowTableSquare", "source_file",
        ["reta_architecture/program_workflow.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "program workflow tests", "verification:UniversalWorkflowTableSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "command parity tests", "verification:UniversalWorkflowTableSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "generated_columns.py", "GeneratedColumnStateSyncSquare", "source_file",
        ["reta_architecture/generated_columns.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_runtime.py", "GeneratedColumnStateSyncSquare", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state.py", "GeneratedColumnStateSyncSquare", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "sheaves.py", "GeneratedColumnStateSyncSquare", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "universal.py", "GeneratedColumnStateSyncSquare", "source_file",
        ["reta_architecture/universal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state tests", "verification:GeneratedColumnStateSyncSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "generated_columns tests", "verification:GeneratedColumnStateSyncSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_runtime.py", "RuntimeStateProjectionSquare", "source_file",
        ["reta_architecture/table_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state.py", "RuntimeStateProjectionSquare", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state snapshot tests", "verification:RuntimeStateProjectionSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_output.py", "RenderedOutputParitySquare", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "output_syntax.py", "RenderedOutputParitySquare", "source_file",
        ["reta_architecture/output_syntax.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_command_parity.py", "RenderedOutputParitySquare", "source_file",
        ["tests/test_command_parity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/tableHandling.py", "RenderedOutputParitySquare", "source_file",
        ["libs/tableHandling.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/lib4tables.py", "RenderedOutputParitySquare", "source_file",
        ["libs/lib4tables.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "Shell/Markdown/HTML parity", "verification:RenderedOutputParitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "gebrochenuniversum parity", "verification:RenderedOutputParitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta.py", "LegacyArchitectureCompatibilitySquare", "source_file",
        ["reta.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "retaPrompt.py", "LegacyArchitectureCompatibilitySquare", "source_file",
        ["retaPrompt.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs", "LegacyArchitectureCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_command_parity.py", "LegacyArchitectureCompatibilitySquare", "source_file",
        ["tests/test_command_parity.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "facade.py", "LegacyArchitectureCompatibilitySquare", "source_file",
        ["reta_architecture/facade.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "package integrity", "verification:LegacyArchitectureCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "command parity", "verification:LegacyArchitectureCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "category_theory.py", "ArchitectureMapContractReflectionTriangle", "source_file",
        ["reta_architecture/category_theory.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_contracts.py", "ArchitectureMapContractReflectionTriangle", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_map.py", "ArchitectureMapContractReflectionTriangle", "source_file",
        ["reta_architecture/architecture_map.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-contracts-json validation", "verification:ArchitectureMapContractReflectionTriangle", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_witnesses.py", "ValidationWitnessCommutationSquare", "source_file",
        ["reta_architecture/architecture_witnesses.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_validation.py", "ValidationWitnessCommutationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_contracts.py", "ValidationWitnessCommutationSquare", "source_file",
        ["reta_architecture/architecture_contracts.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ValidationWitnessCommutationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-witnesses-json", "verification:ValidationWitnessCommutationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-contracts-json", "verification:ValidationWitnessCommutationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_traces.py", "CoherenceTraceNavigationSquare", "source_file",
        ["reta_architecture/architecture_traces.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_map.py", "CoherenceTraceNavigationSquare", "source_file",
        ["reta_architecture/architecture_map.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-traces-json", "verification:CoherenceTraceNavigationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-coherence-json", "verification:CoherenceTraceNavigationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_boundaries.py", "BoundaryImportGraphCommutationSquare", "source_file",
        ["reta_architecture/architecture_boundaries.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-boundaries-json", "verification:BoundaryImportGraphCommutationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_impact.py", "TraceBoundaryImpactSquare", "source_file",
        ["reta_architecture/architecture_impact.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_boundaries.py", "TraceBoundaryImpactSquare", "source_file",
        ["reta_architecture/architecture_boundaries.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-impact-json", "verification:TraceBoundaryImpactSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-traces-json", "verification:TraceBoundaryImpactSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-boundaries-json", "verification:TraceBoundaryImpactSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_impact.py", "ImpactGateValidationSquare", "source_file",
        ["reta_architecture/architecture_impact.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-impact-json", "verification:ImpactGateValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ImpactGateValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "verification:ImpactGateValidationSquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_migration.py", "ImpactMigrationPlanningSquare", "source_file",
        ["reta_architecture/architecture_migration.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_impact.py", "ImpactMigrationPlanningSquare", "source_file",
        ["reta_architecture/architecture_impact.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-migration-json", "verification:ImpactMigrationPlanningSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-impact-json", "verification:ImpactMigrationPlanningSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ImpactMigrationPlanningSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_migration.py", "MigrationGateCoherenceSquare", "source_file",
        ["reta_architecture/architecture_migration.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-migration-json", "verification:MigrationGateCoherenceSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-coherence-json", "verification:MigrationGateCoherenceSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:MigrationGateCoherenceSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_rehearsal.py", "MigrationRehearsalSquare", "source_file",
        ["reta_architecture/architecture_rehearsal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_migration.py", "MigrationRehearsalSquare", "source_file",
        ["reta_architecture/architecture_migration.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-rehearsal-json", "verification:MigrationRehearsalSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-migration-json", "verification:MigrationRehearsalSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:MigrationRehearsalSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_rehearsal.py", "RehearsalReadinessValidationSquare", "source_file",
        ["reta_architecture/architecture_rehearsal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_validation.py", "RehearsalReadinessValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-rehearsal-json", "verification:RehearsalReadinessValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:RehearsalReadinessValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-coherence-json", "verification:RehearsalReadinessValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_activation.py", "RehearsalActivationSquare", "source_file",
        ["reta_architecture/architecture_activation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_rehearsal.py", "RehearsalActivationSquare", "source_file",
        ["reta_architecture/architecture_rehearsal.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-activation-json", "verification:RehearsalActivationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-rehearsal-json", "verification:RehearsalActivationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:RehearsalActivationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_activation.py", "ActivationRollbackValidationSquare", "source_file",
        ["reta_architecture/architecture_activation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture_validation.py", "ActivationRollbackValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-activation-json", "verification:ActivationRollbackValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ActivationRollbackValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-coherence-json", "verification:ActivationRollbackValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "CenterRowRangeCompatibilitySquare", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "CenterRowRangeCompatibilitySquare", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row-ranges-json", "verification:CenterRowRangeCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:CenterRowRangeCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:CenterRowRangeCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "RowRangeValidationSquare", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "RowRangeValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "RowRangeValidationSquare", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "RowRangeValidationSquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row-ranges-json", "verification:RowRangeValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:RowRangeValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:RowRangeValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "CenterArithmeticCompatibilitySquare", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "CenterArithmeticCompatibilitySquare", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "arithmetic-json", "verification:CenterArithmeticCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:CenterArithmeticCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:CenterArithmeticCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_ranges.py", "ArithmeticRowRangeGluingSquare", "source_file",
        ["reta_architecture/row_ranges.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "ArithmeticRowRangeGluingSquare", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "ArithmeticRowRangeGluingSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row-ranges-json", "verification:ArithmeticRowRangeGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "arithmetic-json", "verification:ArithmeticRowRangeGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ArithmeticRowRangeGluingSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/center.py", "CenterConsoleIOCompatibilitySquare", "source_file",
        ["libs/center.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "CenterConsoleIOCompatibilitySquare", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "console-io-json", "verification:CenterConsoleIOCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:CenterConsoleIOCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:CenterConsoleIOCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/console_io.py", "ConsoleIOOutputValidationSquare", "source_file",
        ["reta_architecture/console_io.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "ConsoleIOOutputValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_output.py", "ConsoleIOOutputValidationSquare", "source_file",
        ["reta_architecture/table_output.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "ConsoleIOOutputValidationSquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "console-io-json", "verification:ConsoleIOOutputValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:ConsoleIOOutputValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:ConsoleIOOutputValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/word_completerAlx.py", "WordCompleterCompatibilitySquare", "source_file",
        ["libs/word_completerAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "WordCompleterCompatibilitySquare", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "word-completion-json", "verification:WordCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:WordCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:WordCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_word.py", "WordCompletionValidationSquare", "source_file",
        ["reta_architecture/completion_word.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "WordCompletionValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "WordCompletionValidationSquare", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "WordCompletionValidationSquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "word-completion-json", "verification:WordCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:WordCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:WordCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "libs/nestedAlx.py", "NestedCompleterCompatibilitySquare", "source_file",
        ["libs/nestedAlx.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "NestedCompleterCompatibilitySquare", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "nested-completion-json", "verification:NestedCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:NestedCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:NestedCompleterCompatibilitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_nested.py", "NestedCompletionValidationSquare", "source_file",
        ["reta_architecture/completion_nested.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "NestedCompletionValidationSquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/completion_runtime.py", "NestedCompletionValidationSquare", "source_file",
        ["reta_architecture/completion_runtime.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "NestedCompletionValidationSquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "nested-completion-json", "verification:NestedCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:NestedCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:NestedCompletionValidationSquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/parallel_execution.py", "ExecutionProcessParallelNaturalitySquare", "source_file",
        ["reta_architecture/parallel_execution.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/execution_network.py", "ExecutionProcessParallelNaturalitySquare", "source_file",
        ["reta_architecture/execution_network.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/row_filtering.py", "ExecutionProcessParallelNaturalitySquare", "source_file",
        ["reta_architecture/row_filtering.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/arithmetic.py", "ExecutionProcessParallelNaturalitySquare", "source_file",
        ["reta_architecture/arithmetic.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "parallel-execution-json", "verification:ExecutionProcessParallelNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "execution-network-json", "verification:ExecutionProcessParallelNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:ExecutionProcessParallelNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "verification:ExecutionProcessParallelNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/execution_network.py", "ChannelPromptExecutionNaturalitySquare", "source_file",
        ["reta_architecture/execution_network.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_interaction.py", "ChannelPromptExecutionNaturalitySquare", "source_file",
        ["reta_architecture/prompt_interaction.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/presheaves.py", "ChannelPromptExecutionNaturalitySquare", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_language.py", "ChannelPromptExecutionNaturalitySquare", "source_file",
        ["reta_architecture/prompt_language.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/prompt_execution.py", "ChannelPromptExecutionNaturalitySquare", "source_file",
        ["reta_architecture/prompt_execution.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "execution-network-json", "verification:ChannelPromptExecutionNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt-runtime-json", "verification:ChannelPromptExecutionNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:ChannelPromptExecutionNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/persistence.py", "PersistenceRoundTripNaturalitySquare", "source_file",
        ["reta_architecture/persistence.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/presheaves.py", "PersistenceRoundTripNaturalitySquare", "source_file",
        ["reta_architecture/presheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/sheaves.py", "PersistenceRoundTripNaturalitySquare", "source_file",
        ["reta_architecture/sheaves.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/table_state.py", "PersistenceRoundTripNaturalitySquare", "source_file",
        ["reta_architecture/table_state.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "persistence-json", "verification:PersistenceRoundTripNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "package-integrity-json", "verification:PersistenceRoundTripNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:PersistenceRoundTripNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:PersistenceRoundTripNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/persistence.py", "CacheAuditPersistenceNaturalitySquare", "source_file",
        ["reta_architecture/persistence.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/execution_network.py", "CacheAuditPersistenceNaturalitySquare", "source_file",
        ["reta_architecture/execution_network.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "reta_architecture/architecture_validation.py", "CacheAuditPersistenceNaturalitySquare", "source_file",
        ["reta_architecture/architecture_validation.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests/test_architecture_refactor.py", "CacheAuditPersistenceNaturalitySquare", "source_file",
        ["tests/test_architecture_refactor.py"], "resolved", "Repository anchor resolved.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "persistence-json", "verification:CacheAuditPersistenceNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "execution-network-json", "verification:CacheAuditPersistenceNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "verification:CacheAuditPersistenceNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "verification:CacheAuditPersistenceNaturalitySquare", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "topology-json", "law:ContextRefinementCompositionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "presheaves-json", "law:PresheafRestrictionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "known pair lookup", "law:SheafGluingUniquenessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "semantic regression counts", "law:SheafGluingUniquenessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "prompt language tests", "law:RawCanonicalNaturalityLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "program-workflow-json", "law:WorkflowUniversalConstructionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table_state tests", "law:GeneratedColumnStateSyncLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "table-state-json", "law:RuntimeStateProjectionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "command parity tests", "law:OutputNormalizationNaturalityLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "package integrity", "law:LegacyCompatibilityNaturalityLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "command parity tests", "law:LegacyCompatibilityNaturalityLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ArchitectureValidationCompletenessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-witnesses-json", "law:ArchitectureValidationCompletenessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "package-integrity-json", "law:ArchitectureValidationCompletenessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-traces-json", "law:ArchitectureTraceNavigationLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-boundaries-json", "law:ArchitectureBoundaryImportLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-impact-json", "law:ArchitectureImpactGateLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-traces-json", "law:ArchitectureImpactGateLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-boundaries-json", "law:ArchitectureImpactGateLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ArchitectureImpactGateLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-migration-json", "law:ArchitectureMigrationOrderingLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-impact-json", "law:ArchitectureMigrationOrderingLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ArchitectureMigrationOrderingLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-rehearsal-json", "law:ArchitectureRehearsalReadinessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-migration-json", "law:ArchitectureRehearsalReadinessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ArchitectureRehearsalReadinessLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-activation-json", "law:ArchitectureActivationCommitLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-rehearsal-json", "law:ArchitectureActivationCommitLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ArchitectureActivationCommitLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row-ranges-json", "law:ActivatedRowRangeLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ActivatedRowRangeLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ActivatedRowRangeLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "arithmetic-json", "law:ActivatedArithmeticLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "row-ranges-json", "law:ActivatedArithmeticLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ActivatedArithmeticLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ActivatedArithmeticLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "console-io-json", "law:ActivatedConsoleIOLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ActivatedConsoleIOLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ActivatedConsoleIOLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ActivatedConsoleIOLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "word-completion-json", "law:ActivatedWordCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ActivatedWordCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ActivatedWordCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ActivatedWordCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "nested-completion-json", "law:ActivatedNestedCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "architecture-validation-json", "law:ActivatedNestedCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ActivatedNestedCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ActivatedNestedCompletionLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "parallel-execution-json", "law:ExecutionNetworkPersistenceLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "execution-network-json", "law:ExecutionNetworkPersistenceLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "persistence-json", "law:ExecutionNetworkPersistenceLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_architecture_refactor", "law:ExecutionNetworkPersistenceLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    anchor_witnesses.append(AnchorWitnessSpec(
        "tests.test_command_parity", "law:ExecutionNetworkPersistenceLaw", "symbolic",
        [], "symbolic", "Symbolic owner, function name or architecture term; not expected to resolve to a file.",
    ))
    var capsule_slices = List[CapsuleSliceSpec]()
    capsule_slices.append(CapsuleSliceSpec(
        "RetaArchitectureRoot", "0 root / facade",
        [], ["reta_architecture/facade.py", "reta_architecture/__init__.py"],
        ["SchemaTopologyCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "InputPromptCapsule", "WorkflowGluingCapsule", "TableCoreCapsule", "GeneratedRelationCapsule", "OutputRenderingCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"], ["Gesamtfunktor-Fassade", "Kapsel-Root"],
        ["snapshot-json"], ["reta_architecture/facade.py", "reta_architecture/__init__.py", "facade.py", "__init__.py"],
        "resolved", "Stages 1-31", "Die oberste Fassade hält die neue Architektur zusammen und ersetzt den alten impliziten Monolithverbund als Orientierungspunkt.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "SchemaTopologyCapsule", "1 schema + topology",
        ["i18n/words.py", "libs/lib4tables_Enum.py"], ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py"],
        ["RetaContextSchema", "ContextSelection", "RetaContextTopology", "split i18n modules", "tag/domain skeleton"], ["Topologie", "math Kategorie: OpenRetaContextCategory"],
        ["topology-json"], ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py", "schema.py", "topology.py", "split_i18n.py"],
        "resolved", "Stages 1-4", "Hier werden die früher verstreuten Parameter-, Sprach-, Zeilen-, Ausgabe- und Scope-Domänen zu offenen Kontexten über reta.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "LocalSectionCapsule", "2 presheaves / local data",
        ["csv/*.csv", "readme*.md / doc/*.md"], ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md"],
        ["FilesystemPresheaf", "PromptStatePresheaf", "LocalSection", "CSV sections", "translation/readme/assets sections"], ["Prägarbe", "Restriktionsmorphismus", "LocalSectionCategory"],
        ["presheaves-json"], ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md", "presheaves.py"],
        "resolved", "Stage 1 onward", "Rohdaten bleiben lokal: CSVs, Übersetzungen, Assets und Prompt-Zustand werden als kontextabhängige Sektionen verstanden.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "SemanticSheafCapsule", "3 sheaves / canonical semantics",
        ["i18n/words.py"], ["reta_architecture/sheaves.py", "reta_architecture/semantics_builder.py"],
        ["ParameterSemanticsSheaf", "GeneratedColumnsSheaf", "TableOutputSheaf", "HtmlReferenceSheaf", "ParameterSemanticsBuilder"], ["Garbe", "Sheafification", "CanonicalSemanticSheafCategory"],
        ["sheaves-json", "known pair lookup"], ["reta_architecture/sheaves.py", "reta_architecture/semantics_builder.py", "sheaves.py", "semantics_builder.py"],
        "resolved", "Stages 1-3 and 27", "Lokale Matrix-/CSV-/Aliasdaten werden zu kanonischer, global nutzbarer Parametersemantik verklebt.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "InputPromptCapsule", "4 input + prompt stack",
        ["libs/LibRetaPrompt.py", "libs/center.py", "libs/nestedAlx.py", "libs/word_completerAlx.py", "retaPrompt.py", "reta_architecture/arithmetic.py", "reta_architecture/completion_nested.py", "reta_architecture/completion_word.py", "reta_architecture/row_ranges.py"], ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_interaction.py", "retaPrompt.py", "libs/LibRetaPrompt.py", "libs/nestedAlx.py", "reta_architecture/row_ranges.py", "reta_architecture/arithmetic.py", "reta_architecture/console_io.py", "reta_architecture/completion_word.py", "reta_architecture/completion_nested.py"],
        ["InputBundle", "RowRangeSyntax", "PromptVocabulary", "PromptRuntimeBundle", "CompletionRuntimeBundle", "PromptLanguageBundle", "PromptSessionBundle", "PromptExecutionBundle", "PromptPreparationBundle", "PromptInteractionBundle", "RowRangeMorphismBundle", "RowRangeExpression", "RowIndexSet", "ArithmeticMorphismBundle", "ArithmeticExpression", "FactorPairSet", "PrimeFactorSection", "DivisorSection", "ConsoleIOMorphismBundle", "HelpMarkdownSection", "FiniteUtilitySection", "WordCompletionMorphismBundle", "CompletionCandidateSection", "CursorPrefixOpenSet", "NestedCompletionMorphismBundle", "NestedCompletionOpenSet", "NestedOptionSection", "NestedCompletionCandidateSection"], ["Morphismen", "RawCommandPresheafFunctor", "RawToCanonicalParameterTransformation", "aktivierter Zeilenbereichs-Morphismus", "aktivierter Arithmetik-Morphismus", "Teiler-Gluing über Row-Range-Topologie", "aktivierte Hilfe-/Debug-/Utility-Morphismen", "aktivierte Word-Completion-Morphismen", "aktivierte hierarchische Prompt-Completion-Morphismen"],
        ["prompt-* tests"], ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_interaction.py", "retaPrompt.py", "libs/LibRetaPrompt.py", "libs/nestedAlx.py", "reta_architecture/row_ranges.py", "reta_architecture/arithmetic.py", "reta_architecture/console_io.py", "reta_architecture/completion_word.py", "reta_architecture/completion_nested.py", "input_semantics.py", "prompt_*.py"],
        "resolved", "Stages 4, 6-12, 37-41", "Der alte Prompt-Monolith ist in Runtime, Completion, Sprache, Session, Execution, Vorbereitung und Interaktion gekapselt. Stage 37 aktiviert die Zeilenbereichslogik: center.py delegiert an RowRangeMorphismBundle. Stage 38 aktiviert die center-Arithmetik: multiples/teiler/primfaktoren/primRepeat werden Wrapper über ArithmeticMorphismBundle. Stage 39 aktiviert center-Hilfe-/Debug-/Utility-Funktionen als ConsoleIOMorphismBundle. Stage 40 aktiviert word_completerAlx.WordCompleter als WordCompletionMorphismBundle. Stage 41 aktiviert nestedAlx.NestedCompleter als NestedCompletionMorphismBundle.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "WorkflowGluingCapsule", "5 universal workflow / gluing",
        ["reta.py"], ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py", "reta.py"],
        ["ParameterRuntimeBundle", "ColumnSelectionBundle", "ProgramWorkflowBundle", "TableGenerationBundle", "UniversalBundle", "merge_parameter_dicts", "normalize_column_buckets"], ["universelle Eigenschaft", "Gluing", "TableGenerationGluingFunctor", "TableGenerationGluingTransformation"],
        ["program-workflow-json"], ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py", "reta.py", "parameter_runtime.py", "column_selection.py", "program_workflow.py", "table_generation.py"],
        "resolved", "Stages 2, 13-15, 19, 21", "Diese Kapsel ersetzt die früher in reta.py versteckte Orchestrierung durch kanonische Merge-/Normalisierungs-/Tabellenbau-Knoten.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "TableCoreCapsule", "6 global table section + state",
        ["libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/tableHandling.py"], ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py", "reta_architecture/number_theory.py", "libs/tableHandling.py", "libs/lib4tables_prepare.py"],
        ["Tables", "TableRuntimeBundle", "TableStateBundle", "TableStateSections", "GeneratedColumnSection", "TableDisplayState", "TablePreparationBundle", "RowFilteringBundle", "TableWrappingBundle", "NumberTheoryBundle"], ["globale Garbensektion", "Tabellen-Morphismen", "ExplicitTableStateFunctor", "TableRuntimeToStateSectionsTransformation"],
        ["table-state-json", "table-runtime-json"], ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py", "reta_architecture/number_theory.py", "libs/tableHandling.py", "libs/lib4tables_prepare.py", "table_runtime.py", "table_state.py", "table_preparation.py", "row_filtering.py", "table_wrapping.py", "number_theory.py"],
        "resolved", "Stages 16, 20, 22-23, 25-26", "Die Tabelle ist jetzt eine globale Sektion mit explizitem Zustand; alte mutable Attribute bleiben nur noch Kompatibilitätsoberfläche.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "GeneratedRelationCapsule", "7 generated/meta/concat/combi morphisms",
        ["libs/lib4tables_Enum.py", "libs/lib4tables_concat.py", "libs/tableHandling.py"], ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "libs/tableHandling.py"],
        ["GeneratedColumnsBundle", "GeneratedColumnRegistry", "MetaColumnsBundle", "ConcatCsvBundle", "KombiJoinBundle", "fraction/csv gluing morphisms", "generated table endomorphisms"], ["Morphismen", "Endofunktoren", "GeneratedColumnEndomorphismCategory", "GeneratedColumnsSheafSyncTransformation"],
        ["generated-columns-json", "concat-csv-json", "combi-join-json"], ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "libs/tableHandling.py", "generated_columns.py", "meta_columns.py", "concat_csv.py", "combi_join.py"],
        "resolved", "Stages 17-19, 21", "Alle ehemals im Concat-/Combi-Monolithen liegenden Erzeuger werden als Tabellen-Endomorphismen oder CSV-Gluing-Morphismen geführt.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "OutputRenderingCapsule", "8 syntax + output rendering",
        ["libs/center.py", "libs/lib4tables.py", "libs/tableHandling.py", "reta_architecture/console_io.py"], ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py", "reta_architecture/console_io.py"],
        ["OutputSyntaxBundle", "RetaOutputSemantics", "TableOutputBundle", "TableOutput", "shell/markdown/html/csv/emacs/bbcode/nichts modes", "ConsoleIOMorphismBundle", "ConsoleOutputSection"], ["Renderer-Morphismus", "OutputRenderingFunctorFamily", "RenderedOutputNormalizationTransformation", "aktivierter Console-Output-Morphismus"],
        ["output-syntax-json", "table-output-json"], ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py", "reta_architecture/console_io.py", "output_syntax.py", "output_semantics.py", "table_output.py"],
        "resolved", "Stages 5, 20, 24, 27, 39", "Ausgabeformate sind nicht mehr Tabellenbesitz, sondern Darstellungsmorphismen über der globalen Tabellensektion. Stage 39 macht CLI-Ausgabe, Hilfe-Rendering und Terminal-Wrapping zu einem aktivierten Output-Service.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "CompatibilityCapsule", "9 legacy compatibility + parity",
        ["reta.py"], ["reta.py", "retaPrompt.py", "libs/tableHandling.py", "libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/lib4tables_concat.py", "reta_architecture/package_integrity.py", "tests/test_command_parity.py"],
        ["reta.py", "retaPrompt.py", "libs facades", "tests/test_command_parity.py", "RepoManifest"], ["LegacyRuntimeFunctor", "ArchitectureRuntimeFunctor", "LegacyToArchitectureTransformation"],
        ["package-integrity-json", "tests/test_command_parity.py"], ["reta.py", "retaPrompt.py", "libs/tableHandling.py", "libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/lib4tables_concat.py", "reta_architecture/package_integrity.py", "tests/test_command_parity.py", "reta.py", "retaPrompt.py", "libs/*", "package_integrity.py"],
        "resolved", "Stages 3-28", "Die alte Oberfläche bleibt bedienbar; die Eigentümerschaft liegt schrittweise in den neuen Kapseln.",
    ))
    capsule_slices.append(CapsuleSliceSpec(
        "CategoricalMetaCapsule", "10 category theory + map",
        ["readme*.md / doc/*.md", "reta_architecture/architecture_activation.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_progress.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_witnesses.py"], ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_activation.py"],
        ["CategoryTheoryBundle", "CategorySpec", "FunctorSpec", "NaturalTransformationSpec", "ArchitectureMapBundle", "ArchitectureContractsBundle", "ArchitectureWitnessBundle", "ArchitectureValidationBundle", "ArchitectureCoherenceBundle", "CommutativeDiagramSpec", "CapsuleContractSpec", "RefactorLawSpec", "AnchorWitnessSpec", "CapsuleSliceSpec", "DiagramWitnessSpec", "ArchitectureValidationCheckSpec", "ArchitectureValidationSummarySpec", "CapsuleCoherenceSpec", "FunctorialRouteSpec", "NaturalityCoherenceSpec", "LawCoherenceSpec", "Stage31ArchitecturePlan", "capsule diagram", "ArchitectureTraceBundle", "ArchitectureBoundariesBundle", "RetaComponentTraceSpec", "CapsuleTraceSpec", "StageHistoryTraceSpec", "TraceHopSpec", "CapsuleBoundarySpec", "ModuleOwnershipSpec", "ImportEdgeSpec", "CapsuleImportEdgeSpec", "Stage32ArchitecturePlan", "Stage32BoundaryPlan", "ArchitectureImpactBundle", "ImpactSourceSpec", "ImpactContractSpec", "RegressionGateSpec", "MigrationCandidateSpec", "ImpactValidationSpec", "Stage33ArchitecturePlan", "ArchitectureMigrationBundle", "MigrationWaveSpec", "MigrationStepSpec", "MigrationGateBindingSpec", "MigrationInvariantSpec", "MigrationValidationSpec", "Stage34ArchitecturePlan", "ArchitectureRehearsalBundle", "RehearsalOpenSetSpec", "RehearsalMoveSpec", "GateRehearsalSpec", "RehearsalCoverSpec", "RehearsalValidationSpec", "Stage35ArchitecturePlan", "ArchitectureActivationBundle", "ActivationWindowSpec", "ActivationUnitSpec", "ActivationGateSpec", "ActivationRollbackSpec", "ActivationTransactionSpec", "ActivationValidationSpec", "Stage36ArchitecturePlan"], ["math Kategorie", "Funktor", "natürliche Transformation", "kommutierendes Diagramm", "Architekturkarte", "Witness", "Validierung", "Proof obligation", "Kohärenzmatrix", "Trace-Index", "Boundary-Importgraph", "Impact- und Migration-Gate-Schicht", "Migration-Plan-Schicht", "Rehearsal-/Readiness-Schicht", "Activation-/Commit-/Rollback-Schicht"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_activation.py", "category_theory.py", "architecture_map.py", "architecture_contracts.py", "architecture_witnesses.py", "architecture_validation.py"],
        "resolved", "Stages 27-36", "Diese Ebene benennt mathematische Objekte, zeigt die Kapselung, hält seit Stage 29 kommutierende Pfade als Gesetze fest, verbindet sie seit Stage 30 mit Witnesses und prüft seit Stage 31 die Gesamtarchitektur als ausführbaren Validierungsbericht plus Kohärenzmatrix. Stage 32 ergänzt navigierbare Traces und reale Import-Boundaries. Stage 33 ergänzt Impact-Routen und Regression-Gates über Trace- und Boundary-Morphismen. Stage 34 ergänzt einen Migration-Plan über Impact-Kandidaten, Wellen, Schritte und Gate-Bindings. Stage 35 ergänzt Trockenlauf-Readiness über geplante Migrationsschritte und Gate-Suites. Stage 36 ergänzt commit-geschützte Aktivierungsfenster, Rollback-Sektionen und Transaktionen über Stage-35-Rehearsals.",
    ))
    var diagram_witnesses = List[DiagramWitnessSpec]()
    diagram_witnesses.append(DiagramWitnessSpec(
        "RawCommandNaturalitySquare", "naturality square",
        ["InputPromptCapsule", "SemanticSheafCapsule"], ["RawToCanonicalParameterTransformation"],
        ["input_semantics.py", "presheaves.py", "prompt_language.py", "prompt_runtime.py", "sheaves.py", "topology.py"],
        ["known alias lookup", "prompt-language regression tests"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py prompt-language-json"],
        "canonicalize(restrict(raw,U→V)) = restrict(canonicalize(raw),U→V)", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "PresheafSheafGluingSquare", "sheafification square",
        ["LocalSectionCapsule", "SemanticSheafCapsule"], ["PresheafToSheafGluingTransformation"],
        ["presheaves.py", "semantics_builder.py", "sheaves.py", "topology.py", "universal.py"],
        ["presheaves-json", "sheaves-json", "semantic count regressions"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py presheaves-json", "python -B -S reta_architecture_probe_py.py sheaves-json"],
        "glue(restrict(local_sections,V)) = restrict(glue(local_sections),V)", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "UniversalWorkflowTableSquare", "universal construction square",
        ["WorkflowGluingCapsule", "TableCoreCapsule", "CompatibilityCapsule"], ["TableGenerationGluingTransformation", "LegacyToArchitectureTransformation"],
        ["column_selection.py", "facade.py", "parameter_runtime.py", "program_workflow.py", "reta.py", "table_generation.py", "universal.py"],
        ["program workflow tests", "command parity tests"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py program-workflow-json", "python -m unittest tests.test_command_parity -v"],
        "architecture_table(canonical_semantics) = sync(legacy_program(canonical_semantics))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "GeneratedColumnStateSyncSquare", "endomorphism/state square",
        ["GeneratedRelationCapsule", "TableCoreCapsule"], ["GeneratedColumnsSheafSyncTransformation", "TableRuntimeToStateSectionsTransformation"],
        ["generated_columns.py", "sheaves.py", "table_runtime.py", "table_state.py", "universal.py"],
        ["table_state tests", "generated_columns tests"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py generated-columns-json", "python -B -S reta_architecture_probe_py.py table-state-json"],
        "project_state(Gᵢ(table)) = sync_generated(project_state(table))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "RuntimeStateProjectionSquare", "projection square",
        ["TableCoreCapsule"], ["TableRuntimeToStateSectionsTransformation"],
        ["table_runtime.py", "table_state.py"],
        ["table_state snapshot tests"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py table-runtime-json", "python -B -S reta_architecture_probe_py.py table-state-json"],
        "snapshot(mutate_legacy(Tables)) = snapshot(update_state_sections(Tables))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "RenderedOutputParitySquare", "output parity square",
        ["OutputRenderingCapsule", "CompatibilityCapsule"], ["RenderedOutputNormalizationTransformation", "LegacyToArchitectureTransformation"],
        ["libs/lib4tables.py", "libs/tableHandling.py", "output_syntax.py", "table_output.py", "tests/test_command_parity.py"],
        ["Shell/Markdown/HTML parity", "gebrochenuniversum parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py table-output-json", "python -m unittest tests.test_command_parity -v"],
        "normalize(render_arch(table)) = normalize(render_legacy(table))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "LegacyArchitectureCompatibilitySquare", "compatibility square",
        ["CompatibilityCapsule", "RetaArchitectureRoot"], ["LegacyToArchitectureTransformation"],
        ["facade.py", "libs", "reta.py", "retaPrompt.py", "tests/test_command_parity.py"],
        ["package integrity", "command parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py package-integrity-json", "python -m unittest tests.test_command_parity -v"],
        "observe(legacy(command)) = observe(architecture(command))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ArchitectureMapContractReflectionTriangle", "reflection triangle",
        ["CategoricalMetaCapsule"], ["ContractedNaturalityTransformation"],
        ["architecture_contracts.py", "architecture_map.py", "category_theory.py"],
        ["architecture-contracts-json validation"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "validate(contracts(category_theory)) = validate(contracts(architecture_map))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ValidationWitnessCommutationSquare", "validation square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule"], ["ContractWitnessValidationTransformation"],
        ["architecture_contracts.py", "architecture_validation.py", "architecture_witnesses.py"],
        ["architecture-validation-json", "architecture-witnesses-json", "architecture-contracts-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "validate_via_witnesses(contracts) = compose_validation(validate_contracts(contracts))", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "CoherenceTraceNavigationSquare", "trace naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule"], ["CoherenceToTraceTransformation"],
        ["architecture_map.py", "architecture_traces.py"],
        ["architecture-traces-json", "architecture-coherence-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Tracing through coherence equals tracing from the old owner mapping.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "BoundaryImportGraphCommutationSquare", "boundary naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule"], ["CoherenceBoundaryValidationTransformation"],
        ["architecture_boundaries.py"],
        ["architecture-boundaries-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Boundary classification from coherence equals classification from real Python imports.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "TraceBoundaryImpactSquare", "impact naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["TraceBoundaryImpactTransformation"],
        ["architecture_boundaries.py", "architecture_impact.py"],
        ["architecture-impact-json", "architecture-traces-json", "architecture-boundaries-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Impact calculated from trace routes equals impact calculated from boundary-import evidence.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ImpactGateValidationSquare", "migration gate validation square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["ImpactGateValidationTransformation"],
        ["architecture_impact.py"],
        ["architecture-impact-json", "architecture-validation-json", "tests/test_architecture_refactor.py"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "A guarded migration candidate and its impact-derived regression gates describe the same allowed future move.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ImpactMigrationPlanningSquare", "migration planning naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["ImpactGateMigrationTransformation"],
        ["architecture_impact.py", "architecture_migration.py"],
        ["architecture-migration-json", "architecture-impact-json", "architecture-validation-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Planning directly from impact and planning through the candidate/gate-binding path yield the same guarded migration step.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "MigrationGateCoherenceSquare", "migration gate coherence square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["MigrationPlanCoherenceTransformation"],
        ["architecture_migration.py"],
        ["architecture-migration-json", "architecture-coherence-json", "architecture-validation-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "A migration step's wave ordering and its gate binding produce the same wave invariant.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "MigrationRehearsalSquare", "migration rehearsal naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["MigrationRehearsalNaturalityTransformation"],
        ["architecture_migration.py", "architecture_rehearsal.py"],
        ["architecture-rehearsal-json", "architecture-migration-json", "architecture-validation-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Rehearsing a migration step directly and rehearsing it through its gate binding produce the same gate-protected dry-run move.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "RehearsalReadinessValidationSquare", "rehearsal readiness validation square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["RehearsalReadinessValidationTransformation"],
        ["architecture_rehearsal.py", "architecture_validation.py"],
        ["architecture-rehearsal-json", "architecture-validation-json", "architecture-coherence-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "Wave cover validation and gate-suite validation produce the same Stage-35 readiness status.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "RehearsalActivationSquare", "rehearsal activation naturality square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["RehearsalActivationNaturalityTransformation"],
        ["architecture_activation.py", "architecture_rehearsal.py"],
        ["architecture-activation-json", "architecture-rehearsal-json", "architecture-validation-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Activating a rehearsed move directly and activating it through its gate rehearsal produce the same commit-gated activation unit.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ActivationRollbackValidationSquare", "activation rollback validation square",
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"], ["ActivationRollbackValidationTransformation"],
        ["architecture_activation.py", "architecture_validation.py"],
        ["architecture-activation-json", "architecture-validation-json", "architecture-coherence-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "Transaction validation and rollback-gate validation produce the same Stage-36 activation safety status.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "CenterRowRangeCompatibilitySquare", "activated row-range compatibility square",
        ["InputPromptCapsule", "CompatibilityCapsule"], ["CenterRowRangeToArchitectureTransformation"],
        ["libs/center.py", "reta_architecture/row_ranges.py"],
        ["row-ranges-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Calling BereichToNumbers2/isZeilenAngabe through center.py and calling RowRangeMorphismBundle directly produce the same row-range section.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "RowRangeValidationSquare", "activated row-range validation square",
        ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"], ["RowRangeValidationTransformation", "CenterRowRangeToArchitectureTransformation"],
        ["libs/center.py", "reta_architecture/architecture_validation.py", "reta_architecture/row_ranges.py", "tests/test_architecture_refactor.py"],
        ["row-ranges-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "Row-range activation and row-range validation commute with the compatibility facade and the architecture validation report.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "CenterArithmeticCompatibilitySquare", "activated arithmetic compatibility square",
        ["InputPromptCapsule", "CompatibilityCapsule"], ["CenterArithmeticToArchitectureTransformation"],
        ["libs/center.py", "reta_architecture/arithmetic.py"],
        ["arithmetic-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Calling multiples/teiler/primfaktoren/primRepeat through center.py and calling ArithmeticMorphismBundle directly produce the same arithmetic section.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ArithmeticRowRangeGluingSquare", "activated arithmetic row-range gluing square",
        ["InputPromptCapsule", "CategoricalMetaCapsule"], ["ArithmeticRowRangeGluingTransformation"],
        ["reta_architecture/architecture_validation.py", "reta_architecture/arithmetic.py", "reta_architecture/row_ranges.py"],
        ["row-ranges-json", "arithmetic-json", "architecture-validation-json"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Row-range expansion and arithmetic divisor gluing commute with direct architecture validation.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "CenterConsoleIOCompatibilitySquare", "activated console/io compatibility square",
        ["OutputRenderingCapsule", "InputPromptCapsule", "CompatibilityCapsule"], ["CenterConsoleIOToArchitectureTransformation"],
        ["libs/center.py", "reta_architecture/console_io.py"],
        ["console-io-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Calling cliout/getTextWrapThings/retaHilfe/unique_everseen through center.py and calling ConsoleIOMorphismBundle directly produce the same visible output or finite helper section.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ConsoleIOOutputValidationSquare", "activated console/io output validation square",
        ["OutputRenderingCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"], ["ConsoleIOOutputValidationTransformation", "CenterConsoleIOToArchitectureTransformation"],
        ["reta_architecture/architecture_validation.py", "reta_architecture/console_io.py", "reta_architecture/table_output.py", "tests/test_architecture_refactor.py"],
        ["console-io-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py table-output-json", "python -m unittest tests.test_command_parity -v"],
        "Console-IO activation and output validation commute with the existing output-rendering capsule.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "WordCompleterCompatibilitySquare", "activated word-completion compatibility square",
        ["InputPromptCapsule", "CompatibilityCapsule"], ["WordCompleterToArchitectureTransformation"],
        ["libs/word_completerAlx.py", "reta_architecture/completion_word.py"],
        ["word-completion-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Calling WordCompleter from word_completerAlx and calling WordCompletionMorphismBundle directly produce the same completion candidate section.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "WordCompletionValidationSquare", "activated word-completion validation square",
        ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"], ["WordCompletionValidationTransformation", "WordCompleterToArchitectureTransformation"],
        ["reta_architecture/architecture_validation.py", "reta_architecture/completion_runtime.py", "reta_architecture/completion_word.py", "tests/test_architecture_refactor.py"],
        ["word-completion-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "Word-completion activation and validation commute with the existing prompt completion runtime.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "NestedCompleterCompatibilitySquare", "activated nested-completion compatibility square",
        ["InputPromptCapsule", "CompatibilityCapsule"], ["NestedCompleterToArchitectureTransformation"],
        ["libs/nestedAlx.py", "reta_architecture/completion_nested.py"],
        ["nested-completion-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "Calling NestedCompleter from nestedAlx and calling NestedCompletionMorphismBundle directly produce the same nested completion candidate section.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "NestedCompletionValidationSquare", "activated nested-completion validation square",
        ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"], ["NestedCompletionValidationTransformation", "NestedCompleterToArchitectureTransformation"],
        ["reta_architecture/architecture_validation.py", "reta_architecture/completion_nested.py", "reta_architecture/completion_runtime.py", "tests/test_architecture_refactor.py"],
        ["nested-completion-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"],
        "Nested-completion activation and validation commute with the existing prompt completion runtime.", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ExecutionProcessParallelNaturalitySquare", "execution network process-parallel naturality square",
        ["TableCoreCapsule", "InputPromptCapsule", "CompatibilityCapsule"], ["ParallelExecutionNaturalityTransformation", "SchedulerExecutionNaturalityTransformation", "RowFilterProcessNaturalityTransformation", "ArithmeticBatchProcessNaturalityTransformation"],
        ["reta_architecture/arithmetic.py", "reta_architecture/execution_network.py", "reta_architecture/parallel_execution.py", "reta_architecture/row_filtering.py"],
        ["parallel-execution-json", "execution-network-json", "tests.test_architecture_refactor", "tests.test_command_parity"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "process_chunk_execution(input) reduced by original index equals the serial row/table/arithmetic result", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "ChannelPromptExecutionNaturalitySquare", "channel/prompt execution naturality square",
        ["InputPromptCapsule", "CompatibilityCapsule"], ["ChannelPromptNaturalityTransformation"],
        ["reta_architecture/execution_network.py", "reta_architecture/presheaves.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_language.py"],
        ["execution-network-json", "prompt-runtime-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "channelized prompt requests preserve the same raw-command section and executable prompt result", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "PersistenceRoundTripNaturalitySquare", "persistence roundtrip naturality square",
        ["LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule", "CategoricalMetaCapsule"], ["PresheafPersistenceRoundTripTransformation", "SheafPersistenceRoundTripTransformation", "TableStatePersistenceTransformation", "PersistenceBatchPreparationNaturalityTransformation", "PackageIntegrityProcessNaturalityTransformation"],
        ["reta_architecture/persistence.py", "reta_architecture/presheaves.py", "reta_architecture/sheaves.py", "reta_architecture/table_state.py"],
        ["persistence-json", "package-integrity-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "load(persist(section)) preserves stable digest and semantic context for local, sheaf and table sections", "witnessed",
    ))
    diagram_witnesses.append(DiagramWitnessSpec(
        "CacheAuditPersistenceNaturalitySquare", "cache/audit persistence naturality square",
        ["WorkflowGluingCapsule", "TableCoreCapsule", "CategoricalMetaCapsule"], ["CacheCoherenceTransformation", "AuditPersistenceValidationTransformation", "ProcessExecutionAuditNaturalityTransformation"],
        ["reta_architecture/architecture_validation.py", "reta_architecture/execution_network.py", "reta_architecture/persistence.py", "tests/test_architecture_refactor.py"],
        ["persistence-json", "execution-network-json", "architecture-validation-json", "tests.test_architecture_refactor"], ["python -B -S reta_architecture_probe_py.py architecture-witnesses-json", "python -B -S reta_architecture_probe_py.py architecture-contracts-json", "python -B -S reta_architecture_probe_py.py architecture-map-json"],
        "valid cache and audit materializations preserve the same validation/coherence statement as direct execution", "witnessed",
    ))
    var naturality_witnesses = List[NaturalTransformationWitnessSpec]()
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RawToCanonicalParameterTransformation", "RawCommandPresheafFunctor", "CanonicalParameterSheafFunctor",
        ["RawCommandNaturalitySquare"], ["InputPromptCapsule", "SemanticSheafCapsule"],
        [WitnessMappingSpec("PromptText", "PromptMorphisms.split_command_words"), WitnessMappingSpec("RawAlias", "AliasMorphisms.canonical_main / canonical_sub"), WitnessMappingSpec("ParameterPair", "ParameterSemanticsSheaf.canonicalize_pair")], "reta_architecture.morphisms + reta_architecture.sheaves",
        "witnessed", "Kontext zuerst einschränken und dann kanonisieren liefert dieselbe kanonische Semantik wie zuerst kanonisieren und anschließend auf den kleineren Kontext einschränken.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "PresheafToSheafGluingTransformation", "LocalDataPresheafFunctor", "GluedSemanticSheafFunctor",
        ["PresheafSheafGluingSquare"], ["LocalSectionCapsule", "SemanticSheafCapsule"],
        [WitnessMappingSpec("CsvSections", "Presheaf.restrict -> merge_parameter_dicts"), WitnessMappingSpec("TranslationSections", "SheafBundle.from_repo"), WitnessMappingSpec("PromptSections", "PromptStatePresheaf.update -> sync_program_semantics")], "reta_architecture.presheaves + reta_architecture.sheaves + reta_architecture.universal",
        "witnessed", "Lokale Sektionen über einer Überdeckung kleben zu derselben globalen Semantik, unabhängig davon, in welcher kompatiblen Reihenfolge die lokalen Restriktionen gelesen werden.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "TableGenerationGluingTransformation", "CanonicalParameterSheafFunctor", "TableGenerationGluingFunctor",
        ["UniversalWorkflowTableSquare"], ["CompatibilityCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        [WitnessMappingSpec("ParameterSemanticsSheaf", "ColumnSelectionBundle"), WitnessMappingSpec("ColumnBuckets", "normalize_column_buckets"), WitnessMappingSpec("ProgramWorkflow", "ProgramWorkflowBundle.run")], "reta_architecture.column_selection + reta_architecture.table_generation + reta_architecture.program_workflow",
        "witnessed", "Kanonische Parametersemantik, Spaltenauswahl und Tabellenbau bilden ein kommutatives Workflow-Diagramm: äquivalente Alias-/Kontextpfade erzeugen dieselbe globale Tabellensektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "GeneratedColumnsSheafSyncTransformation", "GeneratedColumnEndofunctorFamily", "ExplicitTableStateFunctor",
        ["GeneratedColumnStateSyncSquare"], ["GeneratedRelationCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("GeneratedColumnRegistry", "GeneratedColumnSection.parameters"), WitnessMappingSpec("GeneratedColumnTags", "GeneratedColumnSection.tags"), WitnessMappingSpec("GeneratedColumnsSheaf", "sync_generated_columns_from_tables")], "reta_architecture.generated_columns + reta_architecture.table_state + reta_architecture.universal",
        "witnessed", "Ein generierter Spalten-Endofunktor und die anschließende State-/Sheaf-Synchronisierung kommutieren mit dem direkten Zugriff auf die explizite GeneratedColumnSection.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "TableRuntimeToStateSectionsTransformation", "MutableTableRuntimeFunctor", "ExplicitTableStateFunctor",
        ["GeneratedColumnStateSyncSquare", "RuntimeStateProjectionSquare"], ["GeneratedRelationCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("Tables.generatedSpaltenParameter", "TableStateSections.generated_columns.parameters"), WitnessMappingSpec("Tables.generatedSpaltenParameter_Tags", "TableStateSections.generated_columns.tags"), WitnessMappingSpec("Tables.rowNumDisplay2rowNumOrig", "TableStateSections.row_display_to_original"), WitnessMappingSpec("Tables.religionNumbers", "TableDisplayState.religion_numbers")], "reta_architecture.table_runtime + reta_architecture.table_state",
        "witnessed", "Alte mutable Tabellenattribute und neue explizite Zustandssektionen referenzieren dieselben Objekte; Mutation über einen Pfad ist über den anderen Pfad sichtbar.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RenderedOutputNormalizationTransformation", "OutputRenderingFunctorFamily", "NormalizedOutputFunctor",
        ["RenderedOutputParitySquare"], ["CompatibilityCapsule", "OutputRenderingCapsule"],
        [WitnessMappingSpec("html", "HTML normalisieren"), WitnessMappingSpec("markdown", "Markdown-Text vergleichen"), WitnessMappingSpec("shell", "Shell-Text vergleichen"), WitnessMappingSpec("csv", "CSV-Text vergleichen")], "reta_architecture.output_syntax + reta_architecture.output_semantics + tests.test_command_parity",
        "witnessed", "Renderer-Ausgaben dürfen syntaktische Formatdetails haben, müssen nach zulässiger Normalisierung aber dieselbe semantische Paritätsaussage ergeben.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "LegacyToArchitectureTransformation", "LegacyRuntimeFunctor", "ArchitectureRuntimeFunctor",
        ["UniversalWorkflowTableSquare", "RenderedOutputParitySquare", "LegacyArchitectureCompatibilitySquare"], ["CompatibilityCapsule", "OutputRenderingCapsule", "RetaArchitectureRoot", "TableCoreCapsule", "WorkflowGluingCapsule"],
        [WitnessMappingSpec("reta.py", "RetaArchitecture.bootstrap"), WitnessMappingSpec("libs.tableHandling", "reta_architecture.table_runtime"), WitnessMappingSpec("libs.lib4tables_prepare", "reta_architecture.table_preparation / row_filtering / table_wrapping"), WitnessMappingSpec("libs.lib4tables_concat", "reta_architecture.generated_columns / concat_csv / combi_join")], "compatibility facades + tests.test_command_parity",
        "witnessed", "Jeder repräsentative alte Aufrufpfad und der entsprechende neue Architekturpfad müssen beobachtbar gleiche Ausgabe liefern.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ContractedNaturalityTransformation", "CategoryTheoryToContractFunctor", "ArchitectureMapToContractFunctor",
        ["ArchitectureMapContractReflectionTriangle"], ["CategoricalMetaCapsule"],
        [WitnessMappingSpec("NaturalTransformationSpec", "CommutativeDiagramSpec"), WitnessMappingSpec("ArchitectureCapsuleSpec", "CapsuleContractSpec"), WitnessMappingSpec("RefactorInvariant", "RefactorLawSpec"), WitnessMappingSpec("ReferenceValidation", "ContractValidationSpec")], "reta_architecture.architecture_contracts",
        "witnessed", "Die aus Kategorie-Theorie und Kapselkarte abgeleiteten Vertragsdiagramme referenzieren dieselben bekannten Kapseln, Kategorien, Funktoren und natürlichen Transformationen.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ContractWitnessValidationTransformation", "ContractToValidationFunctor", "WitnessToValidationFunctor",
        ["ValidationWitnessCommutationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        [WitnessMappingSpec("CommutativeDiagramSpec", "DiagramWitnessCoverageCheck"), WitnessMappingSpec("CapsuleContractSpec", "CapsuleContractCoverageCheck"), WitnessMappingSpec("RefactorLawSpec", "RefactorLawObligationCoverageCheck"), WitnessMappingSpec("NaturalTransformationSpec", "NaturalTransformationWitnessCoverageCheck"), WitnessMappingSpec("RepositoryManifest", "PackageIntegrityValidationCheck")], "reta_architecture.architecture_validation",
        "witnessed", "Direkte Vertragsvalidierung und Validierung über konkrete Witnesses müssen denselben Stage-31-Gesamtstatus liefern: alle referenzierten Kategorien, Kapseln, Diagramme, Gesetze und natürlichen Transformationen sind gedeckt.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CoherenceToTraceTransformation", "CoherenceMatrixFunctor", "CoherenceToTraceFunctor",
        ["CoherenceTraceNavigationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        [WitnessMappingSpec("Capsule", "CapsuleTraceSpec"), WitnessMappingSpec("LegacyOwner", "RetaComponentTraceSpec")], "reta_architecture/architecture_traces.py",
        "witnessed", "Kohärenz und Trace-Navigation führen für jede Kapsel zum selben Diagramm-/Witness-Vertrag.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CoherenceBoundaryValidationTransformation", "CoherenceToBoundaryFunctor", "LegacyImportBoundaryFunctor",
        ["BoundaryImportGraphCommutationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        [WitnessMappingSpec("Module", "ModuleOwnershipSpec"), WitnessMappingSpec("Import", "ImportEdgeSpec")], "reta_architecture/architecture_boundaries.py",
        "witnessed", "Kapselgrenzen aus Kohärenz und reale Python-Importe werden zu demselben Boundary-Graphen klassifiziert.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "TraceBoundaryImpactTransformation", "TraceBoundaryImpactFunctor", "BoundaryImpactFunctor",
        ["TraceBoundaryImpactSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Owner", "ImpactSourceSpec"), WitnessMappingSpec("Import", "ImpactSourceSpec")], "reta_architecture/architecture_impact.py",
        "witnessed", "Impact aus Trace-Route und Impact aus Boundary-Importgraph führen zu derselben betroffenen Kapsel-/Diagramm-/Gate-Lesart.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ImpactGateValidationTransformation", "MigrationCandidateFunctor", "ImpactGateValidationFunctor",
        ["ImpactGateValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Candidate", "RegressionGateSpec"), WitnessMappingSpec("Gate", "ImpactValidationSpec")], "reta_architecture/architecture_impact.py",
        "witnessed", "Migrationskandidaten und Gate-Validierung kommutieren: ein späterer Move ist nur zulässig, wenn seine Impact-Gates bestehen.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ImpactGateMigrationTransformation", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor",
        ["ImpactMigrationPlanningSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Candidate", "MigrationStepSpec"), WitnessMappingSpec("Gate", "MigrationGateBindingSpec")], "reta_architecture/architecture_migration.py",
        "witnessed", "Der direkte Pfad Impact-Kandidat→Migrationsschritt und der Pfad Impact-Gate→Gate-Binding beschreiben denselben erlaubten späteren Move.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "MigrationPlanCoherenceTransformation", "MigrationOrderingCoherenceFunctor", "MigrationGateCoherenceFunctor",
        ["MigrationGateCoherenceSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Wave", "MigrationInvariantSpec"), WitnessMappingSpec("GateBinding", "MigrationGateBindingSpec")], "reta_architecture/architecture_migration.py",
        "witnessed", "Wellenordnung und Gate-Kohärenz kommutieren: eine geplante Extraktion ist nur kohärent, wenn ihre Gates und Invarianten dieselbe Welle schützen.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "MigrationRehearsalNaturalityTransformation", "MigrationStepRehearsalFunctor", "MigrationGateRehearsalFunctor",
        ["MigrationRehearsalSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Step", "RehearsalMoveSpec"), WitnessMappingSpec("Gate", "GateRehearsalSpec")], "reta_architecture/architecture_rehearsal.py",
        "witnessed", "Migrationsschritt und Gate-Binding führen zum selben trockenlaufgeschützten Move.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RehearsalReadinessValidationTransformation", "RehearsalCoverFunctor", "RehearsalGateValidationFunctor",
        ["RehearsalReadinessValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Cover", "RehearsalCoverSpec"), WitnessMappingSpec("GateSuite", "ArchitectureValidationCheckSpec")], "reta_architecture/architecture_rehearsal.py",
        "witnessed", "Readiness-Cover und Gate-Validierung kommutieren: lokale Gate-Suiten kleben zur gleichen globalen Readiness-Aussage.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RehearsalActivationNaturalityTransformation", "RehearsalActivationFunctor", "GateActivationFunctor",
        ["RehearsalActivationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Move", "ActivationUnitSpec"), WitnessMappingSpec("Gate", "ActivationGateSpec")], "reta_architecture/architecture_activation.py",
        "witnessed", "Aktivierung über den Rehearsal-Move und Aktivierung über die Gate-Suite beschreiben denselben commit-geschützten Umschlag.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ActivationRollbackValidationTransformation", "ActivationTransactionFunctor", "ActivationValidationFunctor",
        ["ActivationRollbackValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        [WitnessMappingSpec("Transaction", "ActivationTransactionSpec"), WitnessMappingSpec("Rollback", "ActivationRollbackSpec")], "reta_architecture/architecture_activation.py",
        "witnessed", "Transaktionsgluing und Validierung kommutieren nur, wenn Rollback-Sektionen für alle lokalen Aktivierungen existieren.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CenterRowRangeToArchitectureTransformation", "CenterRowRangeCompatibilityFunctor", "RowRangeActivationFunctor",
        ["CenterRowRangeCompatibilitySquare", "RowRangeValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("BereichToNumbers2", "range_to_numbers"), WitnessMappingSpec("isZeilenAngabe", "is_row_range"), WitnessMappingSpec("strAsGeneratorToListOfNumStrs", "str_as_generator_to_set")], "reta_architecture/row_ranges.py + libs/center.py",
        "witnessed", "Erst über center.py aufrufen und dann expandieren ergibt dieselbe Zeilenmenge wie direkt über RowRangeMorphismBundle expandieren.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RowRangeValidationTransformation", "RowRangeInputFunctor", "RowRangeValidationFunctor",
        ["RowRangeValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("RowRangeMorphismBundle", "row-ranges-json"), WitnessMappingSpec("RowIndexSet", "architecture-validation-json")], "reta_architecture/row_ranges.py",
        "witnessed", "Row-Range-Ausdruck einschränken, expandieren und validieren kommutiert mit direkter Architekturvalidierung.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CenterArithmeticToArchitectureTransformation", "CenterArithmeticCompatibilityFunctor", "ArithmeticActivationFunctor",
        ["CenterArithmeticCompatibilitySquare"], ["CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("multiples", "factor_pairs"), WitnessMappingSpec("teiler", "divisor_range"), WitnessMappingSpec("primfaktoren", "prime_factors"), WitnessMappingSpec("primRepeat", "prime_repeat_legacy"), WitnessMappingSpec("textHatZiffer", "has_digit")], "reta_architecture/arithmetic.py + libs/center.py",
        "witnessed", "Erst über center.py aufrufen und dann arithmetisch expandieren ergibt dasselbe Ergebnis wie der direkte ArithmeticMorphismBundle-Pfad.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ArithmeticRowRangeGluingTransformation", "ArithmeticRowRangeGluingFunctor", "ArithmeticValidationFunctor",
        ["ArithmeticRowRangeGluingSquare"], ["CategoricalMetaCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("RowIndexSet", "DivisorSection"), WitnessMappingSpec("ArithmeticMorphismBundle", "arithmetic-json")], "reta_architecture/arithmetic.py",
        "witnessed", "Row-Range-Expansion und arithmetisches Teiler-Gluing kommutieren mit der Architekturvalidierung.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CenterConsoleIOToArchitectureTransformation", "CenterConsoleIOCompatibilityFunctor", "ConsoleIOActivationFunctor",
        ["CenterConsoleIOCompatibilitySquare", "ConsoleIOOutputValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule", "OutputRenderingCapsule"],
        [WitnessMappingSpec("cliout", "cli_output"), WitnessMappingSpec("getTextWrapThings", "get_text_wrap_things"), WitnessMappingSpec("retaHilfe", "reta_help_text"), WitnessMappingSpec("unique_everseen", "unique_everseen")], "reta_architecture/console_io.py + libs/center.py",
        "witnessed", "Erst über center.py aufrufen und dann rendern/zerlegen ergibt dieselbe sichtbare Ausgabe bzw. endliche Hilfssektion wie der direkte ConsoleIOMorphismBundle-Pfad.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ConsoleIOOutputValidationTransformation", "ConsoleIOOutputRenderingFunctor", "ConsoleIOValidationFunctor",
        ["ConsoleIOOutputValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "OutputRenderingCapsule"],
        [WitnessMappingSpec("ConsoleIOMorphismBundle", "console-io-json"), WitnessMappingSpec("ConsoleOutputSection", "architecture-validation-json")], "reta_architecture/console_io.py",
        "witnessed", "Console-Output rendern und Console-Output validieren kommutieren mit der bestehenden Output-Rendering-Kategorie.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "WordCompleterToArchitectureTransformation", "LegacyWordCompleterCompatibilityFunctor", "WordCompletionActivationFunctor",
        ["WordCompleterCompatibilitySquare", "WordCompletionValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("WordCompleter", "ArchitectureWordCompleter"), WitnessMappingSpec("get_completions", "iter_word_completions")], "reta_architecture/completion_word.py + libs/word_completerAlx.py",
        "witnessed", "Erst über libs.word_completerAlx.WordCompleter instanziieren und dann Completion-Kandidaten erzeugen ergibt dieselbe Kandidatensektion wie der direkte WordCompletionMorphismBundle-Pfad.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "WordCompletionValidationTransformation", "WordCompletionPromptFunctor", "WordCompletionValidationFunctor",
        ["WordCompletionValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("CompletionCandidateSection", "word-completion-json"), WitnessMappingSpec("WordCompletionMorphismBundle", "architecture-validation-json")], "reta_architecture/completion_word.py",
        "witnessed", "Prompt-Completion und Word-Completion-Validierung kommutieren über derselben Completion-Kandidatensektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "NestedCompleterToArchitectureTransformation", "LegacyNestedCompleterCompatibilityFunctor", "NestedCompletionActivationFunctor",
        ["NestedCompleterCompatibilitySquare", "NestedCompletionValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("NestedCompleter", "ArchitectureNestedCompleter"), WitnessMappingSpec("ComplSitua", "ComplSitua"), WitnessMappingSpec("get_completions", "yield_nested_candidates")], "reta_architecture/completion_nested.py + libs/nestedAlx.py",
        "witnessed", "Erst über libs.nestedAlx.NestedCompleter instanziieren und dann hierarchisch completieren ergibt dieselbe Kandidatensektion wie der direkte NestedCompletionMorphismBundle-Pfad.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "NestedCompletionValidationTransformation", "NestedCompletionPromptFunctor", "NestedCompletionValidationFunctor",
        ["NestedCompletionValidationSquare"], ["CategoricalMetaCapsule", "CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("NestedCompletionCandidateSection", "nested-completion-json"), WitnessMappingSpec("NestedCompletionMorphismBundle", "architecture-validation-json")], "reta_architecture/completion_nested.py",
        "witnessed", "Nested Prompt Completion und Nested-Completion-Validierung kommutieren über derselben Completion-Kandidatensektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ParallelExecutionNaturalityTransformation", "TableChunkExecutionFunctor", "ExecutionResultGluingFunctor",
        ["ExecutionProcessParallelNaturalitySquare"], ["CompatibilityCapsule", "InputPromptCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("ChunkTask", "ExecutionTask"), WitnessMappingSpec("ChunkResult", "OrderedResultSection"), WitnessMappingSpec("TableStateSections", "Tables")], "reta_architecture/execution_network.py",
        "witnessed", "Parallel oder seriell ausgeführte Chunks kleben nach deterministischer Reduktion zur selben Tabellensektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "SchedulerExecutionNaturalityTransformation", "SchedulerResourceFunctor", "TableChunkExecutionFunctor",
        ["ExecutionProcessParallelNaturalitySquare"], ["CompatibilityCapsule", "InputPromptCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("FifoQueue", "ExecutionQueue"), WitnessMappingSpec("ResourceSemaphore", "ExecutionNetworkBundle")], "reta_architecture/execution_network.py",
        "witnessed", "Scheduler-Disziplin und Ressourcenbegrenzung verändern nur die Ausführungsreihenfolge, nicht das deterministisch geklebte Resultat.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ChannelPromptNaturalityTransformation", "ChannelPromptFunctor", "RawCommandPresheafFunctor",
        ["ChannelPromptExecutionNaturalitySquare"], ["CompatibilityCapsule", "InputPromptCapsule"],
        [WitnessMappingSpec("ChannelMessage", "PromptText"), WitnessMappingSpec("PromptStatePresheaf", "LocalSection")], "reta_architecture/execution_network.py",
        "witnessed", "Kanaltransport eines Prompt-Befehls und direkte Rohkommando-Prägarbe führen zu derselben lokalen Prompt-Sektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "PresheafPersistenceRoundTripTransformation", "PresheafPersistenceFunctor", "LocalDataPresheafFunctor",
        ["PersistenceRoundTripNaturalitySquare"], ["CategoricalMetaCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("LocalSection", "PersistentLocalSection"), WitnessMappingSpec("FilesystemPresheaf", "PersistentLocalSection")], "reta_architecture/persistence.py",
        "witnessed", "Persistieren und Laden einer lokalen Sektion liefert bei gleicher Prüfsumme dieselbe lokale Prägarbensektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "SheafPersistenceRoundTripTransformation", "SheafPersistenceFunctor", "GluedSemanticSheafFunctor",
        ["PersistenceRoundTripNaturalitySquare"], ["CategoricalMetaCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("SheafBundle", "PersistentSheafSnapshot"), WitnessMappingSpec("ParameterSemanticsSheaf", "PersistentSheafSnapshot")], "reta_architecture/persistence.py",
        "witnessed", "Persistieren und Laden eines Garben-Snapshots liefert bei gleicher Prüfsumme dieselbe geklebte Semantik.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "TableStatePersistenceTransformation", "TableStatePersistenceFunctor", "ExplicitTableStateFunctor",
        ["PersistenceRoundTripNaturalitySquare"], ["CategoricalMetaCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("TableStateSections", "PersistentSheafSnapshot"), WitnessMappingSpec("Tables", "PersistentExecutionRun")], "reta_architecture/persistence.py",
        "witnessed", "Expliziter Tabellenzustand und persistierter Tabellen-Snapshot kommutieren, solange Kontext- und Payload-Hashes gleich bleiben.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "CacheCoherenceTransformation", "CacheMaterializationFunctor", "TableGenerationGluingFunctor",
        ["CacheAuditPersistenceNaturalitySquare"], ["CategoricalMetaCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        [WitnessMappingSpec("CacheEntry", "Tables"), WitnessMappingSpec("ParameterDictionaryDiagram", "PersistentSheafSnapshot")], "reta_architecture/persistence.py",
        "witnessed", "Ein Cache-Hit darf nur denselben Tabellen-Zielpunkt liefern wie erneutes universelles Gluing mit identischen Kontext-/Sektionshashes.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "AuditPersistenceValidationTransformation", "AuditValidationPersistenceFunctor", "PersistenceAuditFunctor",
        ["CacheAuditPersistenceNaturalitySquare"], ["CategoricalMetaCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        [WitnessMappingSpec("ArchitectureValidationBundle", "AuditEvent"), WitnessMappingSpec("ArchitectureValidationCheckSpec", "AuditEvent")], "reta_architecture/persistence.py",
        "witnessed", "Audit-Ereignisse aus Validierung und Persistenzabfragen beschreiben denselben prüfbaren Lauf.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "RowFilterProcessNaturalityTransformation", "RowFilterProcessFunctor", "TableChunkExecutionFunctor",
        ["ExecutionProcessParallelNaturalitySquare"], ["CompatibilityCapsule", "InputPromptCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("RowSet", "ExecutionTask"), WitnessMappingSpec("ChunkResult", "OrderedResultSection")], "reta_architecture/row_filtering.py + reta_architecture/parallel_execution.py",
        "witnessed", "Zeilenfilter seriell oder in PyPy3-Prozesschunks liefern dieselbe RowSet-Sektion, bevor die Tabelle vorbereitet wird.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ArithmeticBatchProcessNaturalityTransformation", "ArithmeticBatchExecutionFunctor", "ArithmeticRowRangeGluingFunctor",
        ["ExecutionProcessParallelNaturalitySquare"], ["CompatibilityCapsule", "InputPromptCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("ArithmeticExpression", "ExecutionTask"), WitnessMappingSpec("DivisorSection", "OrderedResultSection")], "reta_architecture/arithmetic.py + reta_architecture/parallel_execution.py",
        "witnessed", "Arithmetikbatches über Prozesse und direkte RowRange-Arithmetik-Gluing-Pfade führen zu derselben Faktor-/Teilersektion.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "PackageIntegrityProcessNaturalityTransformation", "PackageIntegrityExecutionFunctor", "WitnessToValidationFunctor",
        ["PersistenceRoundTripNaturalitySquare"], ["CategoricalMetaCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("RepositoryManifest", "ArchitectureValidationCheckSpec"), WitnessMappingSpec("FileDigest", "AuditEvent")], "reta_architecture/package_integrity.py",
        "witnessed", "Serielle Manifestberechnung und prozessbasierte Datei-Chunk-Berechnung ergeben denselben RepositoryManifest-Digest.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "PersistenceBatchPreparationNaturalityTransformation", "PersistenceBatchPreparationFunctor", "PresheafPersistenceFunctor",
        ["PersistenceRoundTripNaturalitySquare"], ["CategoricalMetaCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule"],
        [WitnessMappingSpec("PersistentLocalSection", "LocalSection"), WitnessMappingSpec("CacheEntry", "PersistentLocalSection")], "reta_architecture/persistence.py",
        "witnessed", "Batchweise Digest-/JSON-Vorbereitung in Prozessen und direkte Persistenz einzelner Sektionen liefern bei gleicher Prüfsumme dieselben persistierten Datensätze.",
    ))
    naturality_witnesses.append(NaturalTransformationWitnessSpec(
        "ProcessExecutionAuditNaturalityTransformation", "ProcessExecutionAuditFunctor", "TableStatePersistenceFunctor",
        ["CacheAuditPersistenceNaturalitySquare"], ["CategoricalMetaCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        [WitnessMappingSpec("ExecutionRunResult", "PersistentExecutionRun"), WitnessMappingSpec("OrderedResultSection", "PersistentSheafSnapshot")], "reta_architecture/persistence.py",
        "witnessed", "Persistierte Prozessläufe und persistierte Tabellenzustände beschreiben denselben deterministisch reduzierten Lauf, solange Kontext- und Payload-Hashes gleich sind.",
    ))
    var obligations = List[RefactorObligationSpec]()
    obligations.append(RefactorObligationSpec(
        "RawCommandNaturalitySquare", "commutative_diagram", ["InputPromptCapsule", "SemanticSheafCapsule"],
        ["RawCommandNaturalitySquare"], ["known alias lookup", "prompt-language regression tests"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "PresheafSheafGluingSquare", "commutative_diagram", ["LocalSectionCapsule", "SemanticSheafCapsule"],
        ["PresheafSheafGluingSquare"], ["presheaves-json", "sheaves-json", "semantic count regressions"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "UniversalWorkflowTableSquare", "commutative_diagram", ["WorkflowGluingCapsule", "TableCoreCapsule", "CompatibilityCapsule"],
        ["UniversalWorkflowTableSquare"], ["program workflow tests", "command parity tests"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "GeneratedColumnStateSyncSquare", "commutative_diagram", ["GeneratedRelationCapsule", "TableCoreCapsule"],
        ["GeneratedColumnStateSyncSquare"], ["table_state tests", "generated_columns tests"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RuntimeStateProjectionSquare", "commutative_diagram", ["TableCoreCapsule"],
        ["RuntimeStateProjectionSquare"], ["table_state snapshot tests"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RenderedOutputParitySquare", "commutative_diagram", ["OutputRenderingCapsule", "CompatibilityCapsule"],
        ["RenderedOutputParitySquare"], ["Shell/Markdown/HTML parity", "gebrochenuniversum parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "LegacyArchitectureCompatibilitySquare", "commutative_diagram", ["CompatibilityCapsule", "RetaArchitectureRoot"],
        ["LegacyArchitectureCompatibilitySquare"], ["package integrity", "command parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureMapContractReflectionTriangle", "commutative_diagram", ["CategoricalMetaCapsule"],
        ["ArchitectureMapContractReflectionTriangle"], ["architecture-contracts-json validation"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ValidationWitnessCommutationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["ValidationWitnessCommutationSquare"], ["architecture-validation-json", "architecture-witnesses-json", "architecture-contracts-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "CoherenceTraceNavigationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["CoherenceTraceNavigationSquare"], ["architecture-traces-json", "architecture-coherence-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "BoundaryImportGraphCommutationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["BoundaryImportGraphCommutationSquare"], ["architecture-boundaries-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "TraceBoundaryImpactSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["TraceBoundaryImpactSquare"], ["architecture-impact-json", "architecture-traces-json", "architecture-boundaries-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ImpactGateValidationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["ImpactGateValidationSquare"], ["architecture-impact-json", "architecture-validation-json", "tests/test_architecture_refactor.py"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ImpactMigrationPlanningSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["ImpactMigrationPlanningSquare"], ["architecture-migration-json", "architecture-impact-json", "architecture-validation-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "MigrationGateCoherenceSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["MigrationGateCoherenceSquare"], ["architecture-migration-json", "architecture-coherence-json", "architecture-validation-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "MigrationRehearsalSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["MigrationRehearsalSquare"], ["architecture-rehearsal-json", "architecture-migration-json", "architecture-validation-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RehearsalReadinessValidationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["RehearsalReadinessValidationSquare"], ["architecture-rehearsal-json", "architecture-validation-json", "architecture-coherence-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RehearsalActivationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["RehearsalActivationSquare"], ["architecture-activation-json", "architecture-rehearsal-json", "architecture-validation-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivationRollbackValidationSquare", "commutative_diagram", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["ActivationRollbackValidationSquare"], ["architecture-activation-json", "architecture-validation-json", "architecture-coherence-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "CenterRowRangeCompatibilitySquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterRowRangeCompatibilitySquare"], ["row-ranges-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RowRangeValidationSquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"],
        ["RowRangeValidationSquare"], ["row-ranges-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "CenterArithmeticCompatibilitySquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterArithmeticCompatibilitySquare"], ["arithmetic-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArithmeticRowRangeGluingSquare", "commutative_diagram", ["InputPromptCapsule", "CategoricalMetaCapsule"],
        ["ArithmeticRowRangeGluingSquare"], ["row-ranges-json", "arithmetic-json", "architecture-validation-json"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "CenterConsoleIOCompatibilitySquare", "commutative_diagram", ["OutputRenderingCapsule", "InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterConsoleIOCompatibilitySquare"], ["console-io-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ConsoleIOOutputValidationSquare", "commutative_diagram", ["OutputRenderingCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"],
        ["ConsoleIOOutputValidationSquare"], ["console-io-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "WordCompleterCompatibilitySquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["WordCompleterCompatibilitySquare"], ["word-completion-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "WordCompletionValidationSquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"],
        ["WordCompletionValidationSquare"], ["word-completion-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "NestedCompleterCompatibilitySquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["NestedCompleterCompatibilitySquare"], ["nested-completion-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "NestedCompletionValidationSquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"],
        ["NestedCompletionValidationSquare"], ["nested-completion-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ExecutionProcessParallelNaturalitySquare", "commutative_diagram", ["TableCoreCapsule", "InputPromptCapsule", "CompatibilityCapsule"],
        ["ExecutionProcessParallelNaturalitySquare"], ["parallel-execution-json", "execution-network-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ChannelPromptExecutionNaturalitySquare", "commutative_diagram", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["ChannelPromptExecutionNaturalitySquare"], ["execution-network-json", "prompt-runtime-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "PersistenceRoundTripNaturalitySquare", "commutative_diagram", ["LocalSectionCapsule", "SemanticSheafCapsule", "TableCoreCapsule", "CategoricalMetaCapsule"],
        ["PersistenceRoundTripNaturalitySquare"], ["persistence-json", "package-integrity-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "CacheAuditPersistenceNaturalitySquare", "commutative_diagram", ["WorkflowGluingCapsule", "TableCoreCapsule", "CategoricalMetaCapsule"],
        ["CacheAuditPersistenceNaturalitySquare"], ["persistence-json", "execution-network-json", "architecture-validation-json", "tests.test_architecture_refactor"],
        "moving implementation across legacy facades, architecture bundles or capsule boundaries", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ContextRefinementCompositionLaw", "topology/category", ["SchemaTopologyCapsule", "OpenRetaContextCategory"],
        [], ["topology-json"],
        "Sprache/Parameter/Zeilen/Ausgabe-Kontexte dürfen bei kompatibler Verfeinerung nicht ordnungsabhängig werden.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "PresheafRestrictionLaw", "presheaf", ["LocalSectionCapsule", "LocalSectionCategory"],
        ["PresheafSheafGluingSquare"], ["presheaves-json"],
        "Lokale CSV-/Prompt-Sektionen behalten bei mehrfacher Einschränkung dieselbe Bedeutung wie bei direkter Einschränkung.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "SheafGluingUniquenessLaw", "sheaf/universal", ["SemanticSheafCapsule", "UniversalConstructionCategory"],
        [], ["known pair lookup", "semantic regression counts"],
        "Parametersemantik soll nur über den kanonischen Builder/Gluing-Knoten global werden.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RawCanonicalNaturalityLaw", "natural transformation", ["InputPromptCapsule", "SemanticSheafCapsule"],
        [], ["prompt language tests"],
        "Aliasauflösung und Kontextverfeinerung dürfen sich nicht widersprechen.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "WorkflowUniversalConstructionLaw", "universal property", ["WorkflowGluingCapsule", "TableCoreCapsule"],
        [], ["program-workflow-json"],
        "Tabellenbau gehört in den Workflow-Gluing-Knoten, nicht zurück in reta.py als Monolith.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "GeneratedColumnStateSyncLaw", "functor/natural transformation", ["GeneratedRelationCapsule", "TableCoreCapsule"],
        ["GeneratedColumnStateSyncSquare"], ["table_state tests"],
        "Generierte Spalten müssen TableStateSections und Sheaf-Metadaten synchron halten.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "RuntimeStateProjectionLaw", "projection", ["TableCoreCapsule"],
        [], ["table-state-json"],
        "Legacy-Attribute an Tables bleiben kompatibel, aber der Zustand ist explizit gekapselt.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "OutputNormalizationNaturalityLaw", "natural transformation", ["OutputRenderingCapsule", "CompatibilityCapsule"],
        ["UniversalWorkflowTableSquare"], ["command parity tests"],
        "HTML/Markdown/Shell dürfen intern anders laufen, müssen aber normalisiert paritätsfähig bleiben.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "LegacyCompatibilityNaturalityLaw", "compatibility natural transformation", ["CompatibilityCapsule", "RetaArchitectureRoot"],
        ["UniversalWorkflowTableSquare", "LegacyArchitectureCompatibilitySquare"], ["package integrity", "command parity tests"],
        "Alte Startdateien und libs sind Fassaden; neue Semantik gehört den Architektur-Kapseln.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureValidationCompletenessLaw", "validation natural transformation", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["ValidationWitnessCommutationSquare", "ImpactGateValidationSquare", "ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare", "MigrationRehearsalSquare", "RehearsalReadinessValidationSquare", "RehearsalActivationSquare", "ActivationRollbackValidationSquare", "RowRangeValidationSquare", "ArithmeticRowRangeGluingSquare", "ConsoleIOOutputValidationSquare", "WordCompletionValidationSquare", "NestedCompletionValidationSquare", "PersistenceRoundTripNaturalitySquare", "CacheAuditPersistenceNaturalitySquare"], ["architecture-validation-json", "architecture-witnesses-json", "package-integrity-json"],
        "Ein weiterer Umbau ist nur sauber, wenn Kategorie-, Kapsel-, Vertrags-, Witness-, Paket- und Markdown-Checks zusammen bestehen.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureTraceNavigationLaw", "trace naturality", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["CoherenceTraceNavigationSquare", "TraceBoundaryImpactSquare"], ["architecture-traces-json"],
        "Jede alte reta-Komponente muss über Kapsel, Kategorie, Funktor/Transformation, Diagramm und Witness verfolgbar bleiben.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureBoundaryImportLaw", "boundary morphism", ["CategoricalMetaCapsule", "CompatibilityCapsule"],
        ["BoundaryImportGraphCommutationSquare", "TraceBoundaryImpactSquare"], ["architecture-boundaries-json"],
        "Spätere Umbauten dürfen Kapselgrenzen nicht verstecken; Importkanten müssen klassifizierbar bleiben.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureImpactGateLaw", "impact naturality", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["TraceBoundaryImpactSquare", "ImpactGateValidationSquare"], ["architecture-impact-json", "architecture-traces-json", "architecture-boundaries-json", "architecture-validation-json"],
        "Spätere Umbauten dürfen eine alte reta-Komponente nur bewegen, wenn ihre betroffenen Kapseln, Diagramme, Gesetze, Witnesses und Regression-Gates sichtbar bleiben.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureMigrationOrderingLaw", "migration naturality", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["architecture-migration-json", "architecture-impact-json", "architecture-validation-json"],
        "Spätere Umbauten dürfen eine alte reta-Komponente erst bewegen, wenn ihr Stage-34-Migrationsschritt, seine Welle, seine Diagramme, natürlichen Transformationen und Gates sichtbar validiert sind.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureRehearsalReadinessLaw", "rehearsal naturality", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["MigrationRehearsalSquare", "RehearsalReadinessValidationSquare"], ["architecture-rehearsal-json", "architecture-migration-json", "architecture-validation-json"],
        "Spätere Runtime-Umbauten dürfen eine alte reta-Komponente erst bewegen, wenn ihr Stage-35-Rehearsal-Open-Set, Refactor-Morphismus, Gate-Suite, Rollback-Anker und Readiness-Cover validiert sind.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ArchitectureActivationCommitLaw", "activation naturality", ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot"],
        ["RehearsalActivationSquare", "ActivationRollbackValidationSquare"], ["architecture-activation-json", "architecture-rehearsal-json", "architecture-validation-json"],
        "Spätere Runtime-Umbauten dürfen einen Stage-35-Rehearsal-Move erst aktivieren, wenn Stage-36-Aktivierungsfenster, Commit-Gate, Rollback-Sektion, Transaktion und Validierung kommutieren.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivatedRowRangeLaw", "activated runtime naturality", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterRowRangeCompatibilitySquare", "RowRangeValidationSquare"], ["row-ranges-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "center.py darf die Zeilenbereichslogik nicht wieder selbst besitzen; alte Funktionen bleiben Wrapper über RowRangeMorphismBundle und müssen dieselben Mengen liefern.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivatedArithmeticLaw", "activated runtime naturality", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterArithmeticCompatibilitySquare", "ArithmeticRowRangeGluingSquare"], ["arithmetic-json", "row-ranges-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "center.py darf die Faktor-/Teiler-/Primfaktorlogik nicht wieder selbst besitzen; alte Funktionen bleiben Wrapper über ArithmeticMorphismBundle und müssen dieselben Ergebnisse liefern.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivatedConsoleIOLaw", "activated runtime naturality", ["OutputRenderingCapsule", "InputPromptCapsule", "CompatibilityCapsule"],
        ["CenterConsoleIOCompatibilitySquare", "ConsoleIOOutputValidationSquare"], ["console-io-json", "architecture-validation-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "center.py darf Hilfe-/Output-/Wrapping-/Utilitylogik nicht wieder selbst besitzen; alte Funktionen bleiben Wrapper über ConsoleIOMorphismBundle und müssen dieselben sichtbaren Ausgaben bzw. Hilfssektionen liefern.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivatedWordCompletionLaw", "activated runtime naturality", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["WordCompleterCompatibilitySquare", "WordCompletionValidationSquare"], ["word-completion-json", "architecture-validation-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "word_completerAlx.py darf Matching- und Candidate-Erzeugung nicht wieder selbst besitzen; der alte WordCompleter bleibt Fassade über ArchitectureWordCompleter und muss dieselben Completion-Objekte liefern.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ActivatedNestedCompletionLaw", "activated runtime naturality", ["InputPromptCapsule", "CompatibilityCapsule"],
        ["NestedCompleterCompatibilitySquare", "NestedCompletionValidationSquare"], ["nested-completion-json", "architecture-validation-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "nestedAlx.py darf Situation-/Subcompleter-/Gleichheits-/Kommawertlogik nicht wieder selbst besitzen; NestedCompleter und ComplSitua bleiben Fassaden über ArchitectureNestedCompleter und müssen dieselben Completion-Pfade liefern.", "witnessed",
    ))
    obligations.append(RefactorObligationSpec(
        "ExecutionNetworkPersistenceLaw", "execution/persistence naturality", ["TableCoreCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "CategoricalMetaCapsule"],
        ["ExecutionProcessParallelNaturalitySquare", "ChannelPromptExecutionNaturalitySquare", "PersistenceRoundTripNaturalitySquare", "CacheAuditPersistenceNaturalitySquare"], ["parallel-execution-json", "execution-network-json", "persistence-json", "tests.test_architecture_refactor", "tests.test_command_parity"],
        "Queues, Stacks, Semaphoren, Kanäle und SQLite-Persistenz bleiben eigene Runtime-/Audit-Kapseln; mathematische Kernschichten bleiben rein und alle Materialisierungen müssen roundtrip-, cache- und parallelitätskohärent sein.", "witnessed",
    ))
    var validation = WitnessValidationSpec(
        "passed", 351,
        351, 185,
        [],
        [], [],
        [], [],
    )
    var plan = Stage30ArchitecturePlan(
        ["Tie Stage-29 diagrams and laws back to concrete repository witnesses.", "Show stufenweise/kapselweise where old reta owners now sit.", "Make natural transformations inspectable through proof obligations and probe commands."],
        ["reta_architecture/architecture_witnesses.py", "architecture-witnesses-json and architecture-witnesses-md probe commands", "ArchitectureMap stage step and CategoricalMetaCapsule containment for ArchitectureWitnessBundle", "tests and package-integrity coverage for the witness layer"],
        ["Stage 27 CategoryTheoryBundle", "Stage 28 ArchitectureMapBundle", "Stage 29 ArchitectureContractsBundle", "Existing command parity and architecture-regression tests"],
        "keine beabsichtigte Laufzeit-/CLI-Verhaltensänderung; Stage 30 ist eine Nachweis-, Traceability- und Planungs-Schicht",
    )
    return ArchitectureWitnessBundle(
        anchor_witnesses^, capsule_slices^, diagram_witnesses^,
        naturality_witnesses^, obligations^, validation^,
        "ArchitectureWitnessBundle\n├─ AnchorWitnesses: repository files / globs / symbolic owners\n├─ CapsuleSlices: old reta owner → new capsule → math role → protected contract\n├─ DiagramWitnesses: Stage-29 commutative diagrams with concrete evidence\n├─ NaturalityWitnesses: natural transformations tied to diagrams and capsules\n├─ RefactorObligations: laws future stages must preserve\n└─ Validation handoff: Stage-31 validation consumes this witness matrix\n\nStage-30 reading:\nLegacy reta surfaces are no longer the architecture source.  They are witnesses\nor compatibility entrances.  The new owner is the capsule; the capsule is\nprotected by a contract; the contract is witnessed by concrete files, probes and\nregression tests.\n", "```mermaid\nflowchart TD\n    Map[ArchitectureMapBundle<br/>capsules + flows] --> Witness[ArchitectureWitnessBundle]\n    Contracts[ArchitectureContractsBundle<br/>diagrams + laws] --> Witness\n    Category[CategoryTheoryBundle<br/>functors + natural transformations] --> Witness\n    Repo[Repository tree<br/>reta.py / libs / reta_architecture / tests / csv] --> Witness\n    Witness --> Anchors[Anchor witnesses]\n    Witness --> Slices[Capsule slices]\n    Witness --> Diagrams[Diagram witnesses]\n    Witness --> Naturality[Naturality witnesses]\n    Witness --> Obligations[Refactor obligations]\n    Diagrams --> Compatibility[CompatibilityCapsule parity]\n    Naturality --> Meta[CategoricalMetaCapsule]\n```\n", plan^,
    )
