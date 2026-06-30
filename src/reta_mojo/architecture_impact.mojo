"""Generated native Mojo representation of architecture_impact.
The Python reference is evaluated only during explicit regeneration; runtime
navigation and validation are fully native.
Regenerate with tools/generate_architecture_impact.py.
"""

from std.collections import List

@fieldwise_init
struct ImpactSourceSpec(Copyable):
    var source: String
    var source_kind: String
    var capsules: List[String]
    var categories: List[String]
    var functors: List[String]
    var natural_transformations: List[String]
    var diagrams: List[String]
    var laws: List[String]
    var boundary_edges: List[String]
    var route_hops: List[String]
    var reading: String

@fieldwise_init
struct ImpactContractSpec(Copyable):
    var source: String
    var affected_capsules: List[String]
    var affected_diagrams: List[String]
    var affected_laws: List[String]
    var affected_natural_transformations: List[String]
    var required_gates: List[String]
    var required_probes: List[String]
    var impact_reading: String

@fieldwise_init
struct RegressionGateSpec(Copyable):
    var name: String
    var gate_type: String
    var protects: List[String]
    var command: String
    var required_for: List[String]
    var stage_origin: String
    var status: String
    var reading: String

@fieldwise_init
struct MigrationCandidateSpec(Copyable):
    var candidate: String
    var legacy_owner: String
    var current_capsule: String
    var target_capsule: String
    var move_kind: String
    var mathematical_reading: String
    var affected_diagrams: List[String]
    var gates: List[String]
    var next_action: String
    var status: String

@fieldwise_init
struct ImpactCheckSpec(Copyable):
    var name: String
    var status: String
    var failed_items: List[String]
    var checked_count: Int
    var reading: String

@fieldwise_init
struct ImpactValidationSpec(Copyable):
    var status: String
    var missing_sources: List[String]
    var sources_without_contracts: List[String]
    var candidates_without_gates: List[String]
    var unknown_capsules: List[String]
    var uncovered_natural_transformations: List[String]
    var checks: List[ImpactCheckSpec]

@fieldwise_init
struct Stage33ArchitecturePlan(Copyable):
    var planned_after_stage_32: List[String]
    var implemented_in_stage_33: List[String]
    var inherited_from_previous_stages: List[String]
    var behaviour_change: String

@fieldwise_init
struct ArchitectureImpactBundle(Copyable):
    var impact_sources: List[ImpactSourceSpec]
    var impact_contracts: List[ImpactContractSpec]
    var regression_gates: List[RegressionGateSpec]
    var migration_candidates: List[MigrationCandidateSpec]
    var validation: ImpactValidationSpec
    var text_diagram: String
    var mermaid_diagram: String
    var plan: Stage33ArchitecturePlan

def impact_source_index(bundle: ArchitectureImpactBundle, source: String) -> Int:
    for index in range(len(bundle.impact_sources)):
        if bundle.impact_sources[index].source == source:
            return index
    return -1

def impact_contract_index(bundle: ArchitectureImpactBundle, source: String) -> Int:
    for index in range(len(bundle.impact_contracts)):
        if bundle.impact_contracts[index].source == source:
            return index
    return -1

def regression_gate_index(bundle: ArchitectureImpactBundle, name: String) -> Int:
    for index in range(len(bundle.regression_gates)):
        if bundle.regression_gates[index].name == name:
            return index
    return -1

def migration_candidate_index(bundle: ArchitectureImpactBundle, name: String) -> Int:
    for index in range(len(bundle.migration_candidates)):
        if bundle.migration_candidates[index].candidate == name:
            return index
    return -1

def impact_snapshot_validation_passed(bundle: ArchitectureImpactBundle) -> Bool:
    return (
        bundle.validation.status == "passed"
        and len(bundle.validation.missing_sources) == 0
        and len(bundle.validation.sources_without_contracts) == 0
        and len(bundle.validation.candidates_without_gates) == 0
        and len(bundle.validation.unknown_capsules) == 0
        and len(bundle.validation.uncovered_natural_transformations) == 0
    )

def architecture_impact_count_line(bundle: ArchitectureImpactBundle) -> String:
    return (
        "sources=" + String(len(bundle.impact_sources))
        + " contracts=" + String(len(bundle.impact_contracts))
        + " gates=" + String(len(bundle.regression_gates))
        + " candidates=" + String(len(bundle.migration_candidates))
    )

def bootstrap_architecture_impact() -> ArchitectureImpactBundle:
    var sources = List[ImpactSourceSpec]()
    sources.append(ImpactSourceSpec(
        "i18n/words.py", "repository owner", ["SchemaTopologyCapsule"],
        ["OpenRetaContextCategory"], ["SchemaToTopologyFunctor"],
        [], ["topology-json"],
        ["ContextRefinementCompositionLaw"], [],
        ["i18n/words.py->SchemaTopologyCapsule", "SchemaTopologyCapsule->OpenRetaContextCategory", "OpenRetaContextCategory->SchemaToTopologyFunctor", "SchemaTopologyCapsule->topology-json", "topology-json->reta_architecture/schema.py", "reta_architecture/schema.py->ContextRefinementCompositionLaw"], "i18n/words.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "csv/*.csv", "local section data", ["LocalSectionCapsule"],
        ["LocalSectionCategory"], ["LocalDataPresheafFunctor"],
        [], ["presheaves-json"],
        ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"], [],
        ["csv/*.csv->LocalSectionCapsule", "LocalSectionCapsule->LocalSectionCategory", "LocalSectionCategory->LocalDataPresheafFunctor", "LocalSectionCapsule->presheaves-json", "presheaves-json->reta_architecture/presheaves.py", "reta_architecture/presheaves.py->PresheafRestrictionLaw"], "csv/*.csv wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta.py", "legacy compatibility surface", ["WorkflowGluingCapsule"],
        ["UniversalConstructionCategory"], [],
        ["TableGenerationGluingTransformation"], ["program-workflow-json"],
        ["WorkflowUniversalConstructionLaw"], ["reta.py->reta_architecture/__init__.py:CompatibilityCapsule->RetaArchitectureRoot", "reta.py->reta_architecture/parallel_execution.py:CompatibilityCapsule->RetaArchitectureRoot", "reta.py->reta_architecture/parameter_runtime.py:CompatibilityCapsule->WorkflowGluingCapsule", "reta.py->reta_architecture/output_syntax.py:CompatibilityCapsule->OutputRenderingCapsule", "reta.py->reta_architecture/number_theory.py:CompatibilityCapsule->TableCoreCapsule", "reta_architecture/prompt_execution.py->reta.py:InputPromptCapsule->CompatibilityCapsule", "reta_architecture/prompt_execution.py->reta.py:InputPromptCapsule->CompatibilityCapsule", "reta_architecture/prompt_execution.py->reta.py:InputPromptCapsule->CompatibilityCapsule"],
        ["reta.py->WorkflowGluingCapsule", "WorkflowGluingCapsule->UniversalConstructionCategory", "WorkflowGluingCapsule->TableGenerationGluingTransformation", "TableGenerationGluingTransformation->program-workflow-json", "program-workflow-json->reta_architecture/parameter_runtime.py", "reta_architecture/parameter_runtime.py->WorkflowUniversalConstructionLaw"], "reta.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "retaPrompt.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["retaPrompt.py->libs/LibRetaPrompt.py:CompatibilityCapsule->InputPromptCapsule", "retaPrompt.py->libs/nestedAlx.py:CompatibilityCapsule->InputPromptCapsule", "retaPrompt.py->reta_architecture/__init__.py:CompatibilityCapsule->RetaArchitectureRoot", "retaPrompt.py->reta_architecture/parallel_execution.py:CompatibilityCapsule->RetaArchitectureRoot", "retaPrompt.py->reta_architecture/prompt_execution.py:CompatibilityCapsule->InputPromptCapsule", "retaPrompt.py->reta_architecture/prompt_interaction.py:CompatibilityCapsule->InputPromptCapsule"],
        ["retaPrompt.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "retaPrompt.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/center.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], [],
        ["libs/center.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/center.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/LibRetaPrompt.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["libs/LibRetaPrompt.py->reta_architecture/__init__.py:InputPromptCapsule->RetaArchitectureRoot", "retaPrompt.py->libs/LibRetaPrompt.py:CompatibilityCapsule->InputPromptCapsule", "reta_architecture/parameter_runtime.py->libs/LibRetaPrompt.py:WorkflowGluingCapsule->InputPromptCapsule"],
        ["libs/LibRetaPrompt.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/LibRetaPrompt.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/nestedAlx.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["libs/nestedAlx.py->reta_architecture/completion_nested.py:InputPromptCapsule->InputPromptCapsule", "retaPrompt.py->libs/nestedAlx.py:CompatibilityCapsule->InputPromptCapsule"],
        ["libs/nestedAlx.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/nestedAlx.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/lib4tables.py", "legacy compatibility surface", ["OutputRenderingCapsule"],
        ["OutputFormatCategory"], ["OutputRenderingFunctorFamily"],
        [], ["output-syntax-json", "table-output-json"],
        ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], ["libs/lib4tables.py->reta_architecture/output_syntax.py:CompatibilityCapsule->OutputRenderingCapsule", "libs/lib4tables.py->reta_architecture/number_theory.py:CompatibilityCapsule->TableCoreCapsule", "libs/lib4tables_concat.py->libs/lib4tables.py:CompatibilityCapsule->CompatibilityCapsule", "libs/lib4tables_prepare.py->libs/lib4tables.py:CompatibilityCapsule->CompatibilityCapsule"],
        ["libs/lib4tables.py->OutputRenderingCapsule", "OutputRenderingCapsule->OutputFormatCategory", "OutputFormatCategory->OutputRenderingFunctorFamily", "OutputRenderingCapsule->output-syntax-json", "output-syntax-json->reta_architecture/output_syntax.py", "reta_architecture/output_syntax.py->OutputNormalizationNaturalityLaw"], "libs/lib4tables.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/tableHandling.py", "legacy compatibility surface", ["TableCoreCapsule"],
        ["TableSectionCategory"], [],
        ["TableRuntimeToStateSectionsTransformation"], ["table-state-json", "table-runtime-json"],
        ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"], ["libs/tableHandling.py->libs/lib4tables_prepare.py:CompatibilityCapsule->CompatibilityCapsule", "libs/tableHandling.py->reta_architecture/number_theory.py:CompatibilityCapsule->TableCoreCapsule", "libs/tableHandling.py->reta_architecture/output_syntax.py:CompatibilityCapsule->OutputRenderingCapsule", "libs/tableHandling.py->reta_architecture/table_runtime.py:CompatibilityCapsule->TableCoreCapsule"],
        ["libs/tableHandling.py->TableCoreCapsule", "TableCoreCapsule->TableSectionCategory", "TableCoreCapsule->TableRuntimeToStateSectionsTransformation", "TableRuntimeToStateSectionsTransformation->table-state-json", "table-state-json->reta_architecture/table_runtime.py", "reta_architecture/table_runtime.py->WorkflowUniversalConstructionLaw"], "libs/tableHandling.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/lib4tables_prepare.py", "legacy compatibility surface", ["TableCoreCapsule"],
        ["TableSectionCategory"], [],
        ["TableRuntimeToStateSectionsTransformation"], ["table-state-json", "table-runtime-json"],
        ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"], ["libs/lib4tables_prepare.py->libs/lib4tables.py:CompatibilityCapsule->CompatibilityCapsule", "libs/lib4tables_prepare.py->reta_architecture/table_preparation.py:CompatibilityCapsule->TableCoreCapsule", "libs/lib4tables_prepare.py->reta_architecture/row_filtering.py:CompatibilityCapsule->TableCoreCapsule", "libs/lib4tables_prepare.py->reta_architecture/table_wrapping.py:CompatibilityCapsule->TableCoreCapsule", "libs/tableHandling.py->libs/lib4tables_prepare.py:CompatibilityCapsule->CompatibilityCapsule"],
        ["libs/lib4tables_prepare.py->TableCoreCapsule", "TableCoreCapsule->TableSectionCategory", "TableCoreCapsule->TableRuntimeToStateSectionsTransformation", "TableRuntimeToStateSectionsTransformation->table-state-json", "table-state-json->reta_architecture/table_runtime.py", "reta_architecture/table_runtime.py->WorkflowUniversalConstructionLaw"], "libs/lib4tables_prepare.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/lib4tables_concat.py", "legacy compatibility surface", ["GeneratedRelationCapsule"],
        ["GeneratedColumnEndomorphismCategory"], ["GeneratedColumnEndofunctorFamily"],
        [], ["generated-columns-json", "concat-csv-json", "combi-join-json"],
        ["GeneratedColumnStateSyncLaw"], ["libs/lib4tables_concat.py->libs/lib4tables.py:CompatibilityCapsule->CompatibilityCapsule", "libs/lib4tables_concat.py->reta_architecture/__init__.py:CompatibilityCapsule->RetaArchitectureRoot", "libs/lib4tables_concat.py->reta_architecture/__init__.py:CompatibilityCapsule->RetaArchitectureRoot", "libs/lib4tables_concat.py->reta_architecture/__init__.py:CompatibilityCapsule->RetaArchitectureRoot"],
        ["libs/lib4tables_concat.py->GeneratedRelationCapsule", "GeneratedRelationCapsule->GeneratedColumnEndomorphismCategory", "GeneratedColumnEndomorphismCategory->GeneratedColumnEndofunctorFamily", "GeneratedRelationCapsule->generated-columns-json", "generated-columns-json->reta_architecture/generated_columns.py", "reta_architecture/generated_columns.py->GeneratedColumnStateSyncLaw"], "libs/lib4tables_concat.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/lib4tables_Enum.py", "legacy compatibility surface", ["SchemaTopologyCapsule"],
        ["OpenRetaContextCategory"], ["SchemaToTopologyFunctor"],
        [], ["topology-json"],
        ["ContextRefinementCompositionLaw"], [],
        ["libs/lib4tables_Enum.py->SchemaTopologyCapsule", "SchemaTopologyCapsule->OpenRetaContextCategory", "OpenRetaContextCategory->SchemaToTopologyFunctor", "SchemaTopologyCapsule->topology-json", "topology-json->reta_architecture/schema.py", "reta_architecture/schema.py->ContextRefinementCompositionLaw"], "libs/lib4tables_Enum.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_contracts.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_activation.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_coherence.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_contracts.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_contracts.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_contracts.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_contracts.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_witnesses.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_coherence.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_witnesses.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_witnesses.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_witnesses.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_witnesses.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_witnesses.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_witnesses.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_validation.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_validation.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_traces.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_boundaries.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_impact.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_rehearsal.py:CategoricalMetaCapsule->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_validation.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_validation.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_coherence.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_boundaries.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_coherence.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_coherence.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_coherence.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_coherence.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_coherence.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_coherence.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_coherence.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "readme*.md / doc/*.md", "repository owner", ["LocalSectionCapsule"],
        ["LocalSectionCategory"], ["LocalDataPresheafFunctor"],
        [], ["presheaves-json"],
        ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"], [],
        ["readme*.md / doc/*.md->LocalSectionCapsule", "LocalSectionCapsule->LocalSectionCategory", "LocalSectionCategory->LocalDataPresheafFunctor", "LocalSectionCapsule->presheaves-json", "presheaves-json->reta_architecture/presheaves.py", "reta_architecture/presheaves.py->PresheafRestrictionLaw"], "readme*.md / doc/*.md wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_traces.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_impact.py->reta_architecture/architecture_traces.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_traces.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_traces.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_traces.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_traces.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_traces.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_boundaries.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_boundaries.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_boundaries.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_boundaries.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_boundaries.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_boundaries.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_boundaries.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_boundaries.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_impact.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_impact.py->reta_architecture/architecture_boundaries.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_coherence.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_traces.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/architecture_witnesses.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_impact.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/architecture_impact.py:CategoricalMetaCapsule->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_impact.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_impact.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_migration.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_activation.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/architecture_impact.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/architecture_map.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_migration.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_progress.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_migration.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_migration.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_rehearsal.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_activation.py->reta_architecture/architecture_rehearsal.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/architecture_impact.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_rehearsal.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_rehearsal.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_rehearsal.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_rehearsal.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_rehearsal.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_activation.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_activation.py->reta_architecture/architecture_contracts.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_activation.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_activation.py->reta_architecture/architecture_rehearsal.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_activation.py->reta_architecture/category_theory.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_progress.py->reta_architecture/architecture_activation.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_validation.py->reta_architecture/architecture_activation.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_activation.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_activation.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_activation.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/center.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], [],
        ["libs/center.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/center.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/row_ranges.py", "architecture module", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["reta_architecture/architecture_validation.py->reta_architecture/row_ranges.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/arithmetic.py->reta_architecture/row_ranges.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/row_ranges.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/facade.py->reta_architecture/row_ranges.py:RetaArchitectureRoot->InputPromptCapsule", "reta_architecture/row_ranges.py->reta_architecture/input_semantics.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/runtime_compat.py->reta_architecture/row_ranges.py:RetaArchitectureRoot->InputPromptCapsule"],
        ["reta_architecture/row_ranges.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "reta_architecture/row_ranges.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/center.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], [],
        ["libs/center.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/center.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/arithmetic.py", "architecture module", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["reta_architecture/architecture_validation.py->reta_architecture/arithmetic.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/arithmetic.py->reta_architecture/row_ranges.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/arithmetic.py->reta_architecture/parallel_execution.py:InputPromptCapsule->RetaArchitectureRoot", "reta_architecture/facade.py->reta_architecture/arithmetic.py:RetaArchitectureRoot->InputPromptCapsule", "reta_architecture/parallel_execution.py->reta_architecture/arithmetic.py:RetaArchitectureRoot->InputPromptCapsule", "reta_architecture/runtime_compat.py->reta_architecture/arithmetic.py:RetaArchitectureRoot->InputPromptCapsule"],
        ["reta_architecture/arithmetic.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "reta_architecture/arithmetic.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/center.py", "legacy compatibility surface", ["OutputRenderingCapsule"],
        ["OutputFormatCategory"], ["OutputRenderingFunctorFamily"],
        [], ["output-syntax-json", "table-output-json"],
        ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], [],
        ["libs/center.py->OutputRenderingCapsule", "OutputRenderingCapsule->OutputFormatCategory", "OutputFormatCategory->OutputRenderingFunctorFamily", "OutputRenderingCapsule->output-syntax-json", "output-syntax-json->reta_architecture/output_syntax.py", "reta_architecture/output_syntax.py->OutputNormalizationNaturalityLaw"], "libs/center.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/console_io.py", "architecture module", ["OutputRenderingCapsule"],
        ["OutputFormatCategory"], ["OutputRenderingFunctorFamily"],
        [], ["output-syntax-json", "table-output-json"],
        ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], ["reta_architecture/architecture_validation.py->reta_architecture/console_io.py:CategoricalMetaCapsule->OutputRenderingCapsule", "reta_architecture/facade.py->reta_architecture/console_io.py:RetaArchitectureRoot->OutputRenderingCapsule", "reta_architecture/runtime_compat.py->reta_architecture/console_io.py:RetaArchitectureRoot->OutputRenderingCapsule", "reta_architecture/table_adapters.py->reta_architecture/console_io.py:RetaArchitectureRoot->OutputRenderingCapsule"],
        ["reta_architecture/console_io.py->OutputRenderingCapsule", "OutputRenderingCapsule->OutputFormatCategory", "OutputFormatCategory->OutputRenderingFunctorFamily", "OutputRenderingCapsule->output-syntax-json", "output-syntax-json->reta_architecture/output_syntax.py", "reta_architecture/output_syntax.py->OutputNormalizationNaturalityLaw"], "reta_architecture/console_io.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/word_completerAlx.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], [],
        ["libs/word_completerAlx.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/word_completerAlx.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/completion_word.py", "architecture module", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["reta_architecture/architecture_validation.py->reta_architecture/completion_word.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/architecture_validation.py->reta_architecture/completion_word.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/completion_word.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/facade.py->reta_architecture/completion_word.py:RetaArchitectureRoot->InputPromptCapsule"],
        ["reta_architecture/completion_word.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "reta_architecture/completion_word.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "libs/nestedAlx.py", "legacy compatibility surface", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["libs/nestedAlx.py->reta_architecture/completion_nested.py:InputPromptCapsule->InputPromptCapsule", "retaPrompt.py->libs/nestedAlx.py:CompatibilityCapsule->InputPromptCapsule"],
        ["libs/nestedAlx.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "libs/nestedAlx.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/completion_nested.py", "architecture module", ["InputPromptCapsule"],
        ["LocalSectionCategory"], ["RawCommandPresheafFunctor"],
        [], ["prompt-* tests"],
        ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], ["libs/nestedAlx.py->reta_architecture/completion_nested.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/architecture_validation.py->reta_architecture/completion_nested.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/architecture_validation.py->reta_architecture/completion_nested.py:CategoricalMetaCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/completion_word.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/input_semantics.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/row_ranges.py:InputPromptCapsule->InputPromptCapsule", "reta_architecture/completion_nested.py->reta_architecture/split_i18n.py:InputPromptCapsule->SchemaTopologyCapsule", "reta_architecture/completion_nested.py->reta_architecture/prompt_language.py:InputPromptCapsule->InputPromptCapsule"],
        ["reta_architecture/completion_nested.py->InputPromptCapsule", "InputPromptCapsule->LocalSectionCategory", "LocalSectionCategory->RawCommandPresheafFunctor", "InputPromptCapsule->prompt-* tests", "prompt-* tests->reta_architecture/input_semantics.py", "reta_architecture/input_semantics.py->RawCanonicalNaturalityLaw"], "reta_architecture/completion_nested.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    sources.append(ImpactSourceSpec(
        "reta_architecture/architecture_progress.py", "architecture module", ["CategoricalMetaCapsule"],
        ["ArchitectureCoherenceCategory"], [],
        ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], ["reta_architecture/architecture_progress.py->reta_architecture/architecture_activation.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/architecture_progress.py->reta_architecture/architecture_migration.py:CategoricalMetaCapsule->CategoricalMetaCapsule", "reta_architecture/facade.py->reta_architecture/architecture_progress.py:RetaArchitectureRoot->CategoricalMetaCapsule"],
        ["reta_architecture/architecture_progress.py->CategoricalMetaCapsule", "CategoricalMetaCapsule->ArchitectureCoherenceCategory", "CategoricalMetaCapsule->ContractWitnessValidationTransformation", "ContractWitnessValidationTransformation->architecture-contracts-json validation", "architecture-contracts-json validation->reta_architecture/category_theory.py", "reta_architecture/category_theory.py->ArchitectureValidationCompletenessLaw"], "reta_architecture/architecture_progress.py wird als Impact-Quelle über Trace-Route und Boundary-Graph auf seine Refactor-Gates abgebildet.",
    ))
    var contracts = List[ImpactContractSpec]()
    contracts.append(ImpactContractSpec(
        "i18n/words.py", ["SchemaTopologyCapsule"],
        ["topology-json"], ["ContextRefinementCompositionLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an i18n/words.py müssen die betroffenen Diagramme topology-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "csv/*.csv", ["LocalSectionCapsule"],
        ["presheaves-json"], ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an csv/*.csv müssen die betroffenen Diagramme presheaves-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta.py", ["WorkflowGluingCapsule"],
        ["program-workflow-json"], ["WorkflowUniversalConstructionLaw"],
        ["TableGenerationGluingTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta.py müssen die betroffenen Diagramme program-workflow-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "retaPrompt.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an retaPrompt.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/center.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/center.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/LibRetaPrompt.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/LibRetaPrompt.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/nestedAlx.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/nestedAlx.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/lib4tables.py", ["OutputRenderingCapsule"],
        ["output-syntax-json", "table-output-json"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/lib4tables.py müssen die betroffenen Diagramme output-syntax-json, table-output-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/tableHandling.py", ["TableCoreCapsule"],
        ["table-state-json", "table-runtime-json"], ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"],
        ["TableRuntimeToStateSectionsTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/tableHandling.py müssen die betroffenen Diagramme table-state-json, table-runtime-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/lib4tables_prepare.py", ["TableCoreCapsule"],
        ["table-state-json", "table-runtime-json"], ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"],
        ["TableRuntimeToStateSectionsTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/lib4tables_prepare.py müssen die betroffenen Diagramme table-state-json, table-runtime-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/lib4tables_concat.py", ["GeneratedRelationCapsule"],
        ["generated-columns-json", "concat-csv-json", "combi-join-json"], ["GeneratedColumnStateSyncLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/lib4tables_concat.py müssen die betroffenen Diagramme generated-columns-json, concat-csv-json, combi-join-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/lib4tables_Enum.py", ["SchemaTopologyCapsule"],
        ["topology-json"], ["ContextRefinementCompositionLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/lib4tables_Enum.py müssen die betroffenen Diagramme topology-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_contracts.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_contracts.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_witnesses.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_witnesses.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_validation.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_validation.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_coherence.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_coherence.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "readme*.md / doc/*.md", ["LocalSectionCapsule"],
        ["presheaves-json"], ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an readme*.md / doc/*.md müssen die betroffenen Diagramme presheaves-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_traces.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_traces.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_boundaries.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_boundaries.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_impact.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_impact.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_migration.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_migration.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_rehearsal.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_rehearsal.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_activation.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_activation.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/center.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/center.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/row_ranges.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/row_ranges.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/center.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/center.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/arithmetic.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/arithmetic.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/center.py", ["OutputRenderingCapsule"],
        ["output-syntax-json", "table-output-json"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/center.py müssen die betroffenen Diagramme output-syntax-json, table-output-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/console_io.py", ["OutputRenderingCapsule"],
        ["output-syntax-json", "table-output-json"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/console_io.py müssen die betroffenen Diagramme output-syntax-json, table-output-json und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/word_completerAlx.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/word_completerAlx.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/completion_word.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/completion_word.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "libs/nestedAlx.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an libs/nestedAlx.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/completion_nested.py", ["InputPromptCapsule"],
        ["prompt-* tests"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"],
        [],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/completion_nested.py müssen die betroffenen Diagramme prompt-* tests und Gates passieren.",
    ))
    contracts.append(ImpactContractSpec(
        "reta_architecture/architecture_progress.py", ["CategoricalMetaCapsule"],
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"],
        ["ContractWitnessValidationTransformation"],
        ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"], ["python -B -S reta_architecture_probe_py.py architecture-impact-json", "python -B -S reta_architecture_probe_py.py architecture-validation-json"],
        "Änderungen an reta_architecture/architecture_progress.py müssen die betroffenen Diagramme architecture-contracts-json validation, architecture-validation-json summary und Gates passieren.",
    ))
    var gates = List[RegressionGateSpec]()
    gates.append(RegressionGateSpec(
        "CategoryTheoryProbeGate", "probe", ["categories", "functors", "natural transformations"],
        "python -B -S reta_architecture_probe_py.py category-theory-json", ["categorical references"],
        "Stage 27", "required", "Kategorien, Funktoren und natürliche Transformationen müssen referenziell geschlossen bleiben.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureMapProbeGate", "probe", ["capsules", "flows", "stage map"],
        "python -B -S reta_architecture_probe_py.py architecture-map-json", ["capsule ownership"],
        "Stage 28", "required", "Kapselkarte und Datenflüsse müssen den geänderten Owner weiterhin enthalten.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureContractsProbeGate", "probe", ["commutative diagrams", "laws"],
        "python -B -S reta_architecture_probe_py.py architecture-contracts-json", ["diagram contracts"],
        "Stage 29", "required", "Kommutierende Diagramme und Refactor-Gesetze müssen gültig bleiben.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureWitnessProbeGate", "probe", ["witnesses", "obligations"],
        "python -B -S reta_architecture_probe_py.py architecture-witnesses-json", ["repository anchors"],
        "Stage 30", "required", "Jeder Vertrag braucht einen Datei-/Probe-/Test-Witness.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureCoherenceProbeGate", "probe", ["coherence matrix"],
        "python -B -S reta_architecture_probe_py.py architecture-coherence-json", ["cross-layer coherence"],
        "Stage 31", "required", "Kapsel, Kategorie, Funktor, Transformation, Diagramm und Witness müssen zusammenpassen.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureTraceProbeGate", "probe", ["trace routes"],
        "python -B -S reta_architecture_probe_py.py architecture-traces-json", ["component traces"],
        "Stage 32", "required", "Die alte Komponente muss weiter navigierbar bleiben.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureBoundaryProbeGate", "probe", ["module ownership", "import boundaries"],
        "python -B -S reta_architecture_probe_py.py architecture-boundaries-json", ["capsule boundaries"],
        "Stage 32", "required", "Importkanten müssen als Kapselgrenzen sichtbar bleiben.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureImpactSelfGate", "probe", ["impact contracts", "migration candidates"],
        "python -B -S reta_architecture_probe_py.py architecture-impact-json", ["Stage 33 impact calculus"],
        "Stage 33", "required", "Die Impact-Schicht muss sich selbst vollständig aus Trace und Boundary rekonstruieren.",
    ))
    gates.append(RegressionGateSpec(
        "ArchitectureRegressionGate", "unittest", ["architecture regression tests"],
        "python -m unittest tests.test_architecture_refactor -v", ["all staged architecture metadata"],
        "Stages 1-33", "required", "Die Architektur-Regressionssuite muss grün bleiben.",
    ))
    gates.append(RegressionGateSpec(
        "CommandParityGate", "unittest", ["legacy CLI parity"],
        "python -m unittest tests.test_command_parity -v", ["CompatibilityCapsule", "OutputRenderingCapsule"],
        "Stages 1-33", "required", "Beobachtbare Legacy-Ausgabe muss gegen die alte reta-Referenz paritätisch bleiben.",
    ))
    var candidates = List[MigrationCandidateSpec]()
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::i18n/words.py", "i18n/words.py",
        "SchemaTopologyCapsule + SemanticSheafCapsule", "SchemaTopologyCapsule + SemanticSheafCapsule",
        "guarded maintenance", "i18n/words.py wird als Morphismus/Objekt über SchemaTopologyCapsule + SemanticSheafCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["topology-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "guarded_data_or_document_owner",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::csv/*.csv", "csv/*.csv",
        "LocalSectionCapsule", "LocalSectionCapsule",
        "guarded maintenance", "csv/*.csv wird als Morphismus/Objekt über LocalSectionCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["presheaves-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "guarded_data_or_document_owner",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta.py", "reta.py",
        "CompatibilityCapsule", "WorkflowGluingCapsule + CompatibilityCapsule",
        "guarded extraction", "reta.py wird als Morphismus/Objekt über WorkflowGluingCapsule + CompatibilityCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["program-workflow-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::retaPrompt.py", "retaPrompt.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "retaPrompt.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/center.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/LibRetaPrompt.py", "libs/LibRetaPrompt.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/LibRetaPrompt.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/nestedAlx.py", "libs/nestedAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/nestedAlx.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/lib4tables.py", "libs/lib4tables.py",
        "CompatibilityCapsule", "OutputRenderingCapsule + TableCoreCapsule",
        "guarded extraction", "libs/lib4tables.py wird als Morphismus/Objekt über OutputRenderingCapsule + TableCoreCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/tableHandling.py", "libs/tableHandling.py",
        "CompatibilityCapsule", "TableCoreCapsule + GeneratedRelationCapsule + OutputRenderingCapsule",
        "guarded extraction", "libs/tableHandling.py wird als Morphismus/Objekt über TableCoreCapsule + GeneratedRelationCapsule + OutputRenderingCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["table-state-json", "table-runtime-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/lib4tables_prepare.py", "libs/lib4tables_prepare.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "guarded extraction", "libs/lib4tables_prepare.py wird als Morphismus/Objekt über TableCoreCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["table-state-json", "table-runtime-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/lib4tables_concat.py", "libs/lib4tables_concat.py",
        "CompatibilityCapsule", "GeneratedRelationCapsule",
        "guarded extraction", "libs/lib4tables_concat.py wird als Morphismus/Objekt über GeneratedRelationCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["generated-columns-json", "concat-csv-json", "combi-join-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/lib4tables_Enum.py", "libs/lib4tables_Enum.py",
        "CompatibilityCapsule", "SchemaTopologyCapsule + GeneratedRelationCapsule",
        "guarded extraction", "libs/lib4tables_Enum.py wird als Morphismus/Objekt über SchemaTopologyCapsule + GeneratedRelationCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["topology-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_contracts.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_contracts.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_witnesses.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_validation.py", "reta_architecture/architecture_validation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_validation.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_coherence.py", "reta_architecture/architecture_coherence.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_coherence.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::readme*.md / doc/*.md", "readme*.md / doc/*.md",
        "LocalSectionCapsule + CategoricalMetaCapsule", "LocalSectionCapsule + CategoricalMetaCapsule",
        "guarded maintenance", "readme*.md / doc/*.md wird als Morphismus/Objekt über LocalSectionCapsule + CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["presheaves-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "guarded_data_or_document_owner",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_traces.py", "reta_architecture/architecture_traces.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_traces.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_boundaries.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_boundaries.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_impact.py", "reta_architecture/architecture_impact.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_impact.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_migration.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_migration.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_rehearsal.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_rehearsal.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_activation.py", "reta_architecture/architecture_activation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_activation.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/center.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/row_ranges.py", "reta_architecture/row_ranges.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "guarded maintenance", "reta_architecture/row_ranges.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/center.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/arithmetic.py", "reta_architecture/arithmetic.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "guarded maintenance", "reta_architecture/arithmetic.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "OutputRenderingCapsule",
        "guarded extraction", "libs/center.py wird als Morphismus/Objekt über OutputRenderingCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/console_io.py", "reta_architecture/console_io.py",
        "OutputRenderingCapsule", "OutputRenderingCapsule",
        "guarded maintenance", "reta_architecture/console_io.py wird als Morphismus/Objekt über OutputRenderingCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["output-syntax-json", "table-output-json"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/word_completerAlx.py", "libs/word_completerAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/word_completerAlx.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/completion_word.py", "reta_architecture/completion_word.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "guarded maintenance", "reta_architecture/completion_word.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::libs/nestedAlx.py", "libs/nestedAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "guarded extraction", "libs/nestedAlx.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate"],
        "nur mit CommandParityGate und Output-/Legacy-Diagrammen weiter extrahieren", "guarded_legacy_surface",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/completion_nested.py", "reta_architecture/completion_nested.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "guarded maintenance", "reta_architecture/completion_nested.py wird als Morphismus/Objekt über InputPromptCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["prompt-* tests"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    candidates.append(MigrationCandidateSpec(
        "Stage33Guard::reta_architecture/architecture_progress.py", "reta_architecture/architecture_progress.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "guarded maintenance", "reta_architecture/architecture_progress.py wird als Morphismus/Objekt über CategoricalMetaCapsule und die zugehörigen natürlichen Transformationen kontrolliert.",
        ["architecture-contracts-json validation", "architecture-validation-json summary"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate"],
        "als Architektur-Owner behalten und bei Änderungen Impact-Gates prüfen", "already_architecture_owned",
    ))
    var checks = List[ImpactCheckSpec]()
    checks.append(ImpactCheckSpec(
        "ImpactSourceCoverageCheck", "passed", [],
        30, "Jede Legacy-/Architektur-Mapping-Zeile braucht eine Impact-Quelle.",
    ))
    checks.append(ImpactCheckSpec(
        "ImpactContractCoverageCheck", "passed", [],
        30, "Jede Impact-Quelle braucht einen betroffenen Vertrags-/Gate-Satz.",
    ))
    checks.append(ImpactCheckSpec(
        "RegressionGateCoverageCheck", "passed", [],
        34, "Jeder Migrationskandidat braucht konkrete Gates.",
    ))
    checks.append(ImpactCheckSpec(
        "ImpactCapsuleReferenceCheck", "passed", [],
        34, "Impact-Kapseln müssen in der Architekturkarte existieren.",
    ))
    checks.append(ImpactCheckSpec(
        "ImpactNaturalityReferenceCheck", "passed", [],
        3, "Impact-Transformationen müssen in CategoryTheoryBundle existieren.",
    ))
    var validation = ImpactValidationSpec(
        "passed", [],
        [], [],
        [], [],
        checks^,
    )
    var plan = Stage33ArchitecturePlan(
        ["Trace- und Boundary-Schichten nicht nur anzeigen, sondern als Impact-Route für spätere Umbauten nutzbar machen.", "Für jede alte reta-Komponente zeigen, welche Kapseln, Diagramme, Gesetze, natürlichen Transformationen, Probes und Tests berührt werden.", "Migrationen als guarded candidates modellieren, nicht als stillschweigende Verhaltensänderung."], ["reta_architecture/architecture_impact.py", "architecture-impact-json and architecture-impact-md probe commands", "ArchitectureMap stage step and CategoricalMetaCapsule containment for ArchitectureImpactBundle", "CategoryTheory impact category/functors/natural transformations", "ArchitectureContracts impact diagrams and impact-gate law"],
        ["Stage 27 CategoryTheoryBundle", "Stage 28 ArchitectureMapBundle", "Stage 29 ArchitectureContractsBundle", "Stage 30 ArchitectureWitnessBundle", "Stage 31 ArchitectureValidation/Coherence bundles", "Stage 32 ArchitectureTrace/Boundary bundles"], "keine beabsichtigte Laufzeit-/CLI-/Prompt-/Tabellen-/Output-Verhaltensänderung; Stage 33 ist eine Impact- und Migration-Gate-Metaschicht",
    )
    return ArchitectureImpactBundle(
        sources^, contracts^, gates^, candidates^, validation^,
        "ArchitectureImpactBundle\n├─ ImpactSourceSpec\n│  └─ old/new reta owner → capsule → category/functor/natural transformation\n├─ ImpactContractSpec\n│  └─ source → affected diagrams/laws/transformations → required probes\n├─ RegressionGateSpec\n│  └─ category/map/contract/witness/coherence/trace/boundary/impact/parity gates\n├─ MigrationCandidateSpec\n│  └─ future extraction candidates are guarded, not silently moved\n└─ ImpactValidationSpec\n   └─ Stage-33 coverage over sources, contracts, gates, capsules and naturality\n", "```mermaid\nflowchart TD\n    Trace[ArchitectureTraceBundle<br/>old owner routes] --> Impact[ArchitectureImpactBundle]\n    Boundary[ArchitectureBoundariesBundle<br/>module/import edges] --> Impact\n    Contracts[ArchitectureContractsBundle<br/>diagrams + laws] --> Impact\n    Witness[ArchitectureWitnessBundle<br/>probes + obligations] --> Impact\n    Impact --> Sources[Impact sources]\n    Impact --> Affected[Affected contracts]\n    Impact --> Gates[Regression gates]\n    Impact --> Candidates[Migration candidates]\n    Gates --> Future[Future stage<br/>move only when gates pass]\n```\n", plan^,
    )
