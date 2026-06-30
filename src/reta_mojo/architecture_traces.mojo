"""Generated native Mojo representation of architecture_traces.
The Python reference is evaluated only during explicit regeneration; runtime
trace navigation and snapshot validation are fully native.
Regenerate with tools/generate_architecture_traces.py.
"""

from std.collections import List

@fieldwise_init
struct TraceHopSpec(Copyable):
    var source: String
    var target: String
    var relation: String
    var categorical_kind: String
    var evidence: List[String]

@fieldwise_init
struct RetaComponentTraceSpec(Copyable):
    var legacy_owner: String
    var primary_capsules: List[String]
    var categories: List[String]
    var functors: List[String]
    var natural_transformations: List[String]
    var diagrams: List[String]
    var witnesses: List[String]
    var laws: List[String]
    var route: List[TraceHopSpec]
    var reading: String

@fieldwise_init
struct CapsuleTraceSpec(Copyable):
    var capsule: String
    var category: String
    var functors: List[String]
    var natural_transformations: List[String]
    var diagrams: List[String]
    var laws: List[String]
    var witnesses: List[String]
    var code_owners: List[String]
    var reading: String

@fieldwise_init
struct StageHistoryTraceSpec(Copyable):
    var stage: String
    var capsule: String
    var moved_to: List[String]
    var paradigms: List[String]
    var trace_target: String

@fieldwise_init
struct TraceValidationSpec(Copyable):
    var status: String
    var missing_component_traces: List[String]
    var missing_capsule_traces: List[String]
    var missing_stage_traces: List[String]
    var missing_stage32_documents: List[String]
    var unresolved_hops: List[String]
    var routes_needing_attention: List[String]
    var transformations_needing_attention: List[String]
    var route_hop_count: Int
    var component_trace_count: Int

@fieldwise_init
struct Stage32ArchitecturePlan(Copyable):
    var planned_after_stage_31: List[String]
    var implemented_in_stage_32: List[String]
    var inherited_from_previous_stages: List[String]
    var behaviour_change: String

@fieldwise_init
struct ArchitectureTraceBundle(Copyable):
    var component_traces: List[RetaComponentTraceSpec]
    var capsule_traces: List[CapsuleTraceSpec]
    var stage_traces: List[StageHistoryTraceSpec]
    var validation: TraceValidationSpec
    var text_diagram: String
    var mermaid_diagram: String
    var plan: Stage32ArchitecturePlan

def component_trace_index(bundle: ArchitectureTraceBundle, owner: String) -> Int:
    for index in range(len(bundle.component_traces)):
        if bundle.component_traces[index].legacy_owner == owner:
            return index
    return -1

def capsule_trace_index(bundle: ArchitectureTraceBundle, capsule: String) -> Int:
    for index in range(len(bundle.capsule_traces)):
        if bundle.capsule_traces[index].capsule == capsule:
            return index
    return -1

def stage_trace_index(bundle: ArchitectureTraceBundle, stage: String) -> Int:
    for index in range(len(bundle.stage_traces)):
        if bundle.stage_traces[index].stage == stage:
            return index
    return -1

def trace_route_hop_count(bundle: ArchitectureTraceBundle) -> Int:
    var count = 0
    for index in range(len(bundle.component_traces)):
        count += len(bundle.component_traces[index].route)
    return count

def trace_snapshot_validation_passed(bundle: ArchitectureTraceBundle) -> Bool:
    return (
        bundle.validation.status == "passed"
        and len(bundle.validation.missing_component_traces) == 0
        and len(bundle.validation.missing_capsule_traces) == 0
        and len(bundle.validation.missing_stage_traces) == 0
        and len(bundle.validation.missing_stage32_documents) == 0
        and len(bundle.validation.unresolved_hops) == 0
        and len(bundle.validation.routes_needing_attention) == 0
        and len(bundle.validation.transformations_needing_attention) == 0
        and bundle.validation.route_hop_count == trace_route_hop_count(bundle)
        and bundle.validation.component_trace_count == len(bundle.component_traces)
    )

def architecture_trace_count_line(bundle: ArchitectureTraceBundle) -> String:
    return (
        "components=" + String(len(bundle.component_traces))
        + " capsules=" + String(len(bundle.capsule_traces))
        + " stages=" + String(len(bundle.stage_traces))
        + " route_hops=" + String(trace_route_hop_count(bundle))
    )

def bootstrap_architecture_traces() -> ArchitectureTraceBundle:
    var components = List[RetaComponentTraceSpec]()
    var route_0 = List[TraceHopSpec]()
    route_0.append(TraceHopSpec("i18n/words.py", "SchemaTopologyCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_0.append(TraceHopSpec("SchemaTopologyCapsule", "OpenRetaContextCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_0.append(TraceHopSpec("OpenRetaContextCategory", "SchemaToTopologyFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_0.append(TraceHopSpec("SchemaTopologyCapsule", "topology-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_0.append(TraceHopSpec("topology-json", "reta_architecture/schema.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_0.append(TraceHopSpec("reta_architecture/schema.py", "ContextRefinementCompositionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "i18n/words.py", ["SchemaTopologyCapsule"], ["OpenRetaContextCategory"],
        ["SchemaToTopologyFunctor"], [], ["topology-json"],
        ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py"], ["ContextRefinementCompositionLaw"], route_0^, "i18n/words.py wird über SchemaTopologyCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_1 = List[TraceHopSpec]()
    route_1.append(TraceHopSpec("csv/*.csv", "LocalSectionCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_1.append(TraceHopSpec("LocalSectionCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_1.append(TraceHopSpec("LocalSectionCategory", "LocalDataPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_1.append(TraceHopSpec("LocalSectionCapsule", "presheaves-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_1.append(TraceHopSpec("presheaves-json", "reta_architecture/presheaves.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_1.append(TraceHopSpec("reta_architecture/presheaves.py", "PresheafRestrictionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "csv/*.csv", ["LocalSectionCapsule"], ["LocalSectionCategory"],
        ["LocalDataPresheafFunctor"], [], ["presheaves-json"],
        ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md"], ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"], route_1^, "csv/*.csv wird über LocalSectionCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_2 = List[TraceHopSpec]()
    route_2.append(TraceHopSpec("reta.py", "WorkflowGluingCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_2.append(TraceHopSpec("WorkflowGluingCapsule", "UniversalConstructionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_2.append(TraceHopSpec("WorkflowGluingCapsule", "TableGenerationGluingTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_2.append(TraceHopSpec("TableGenerationGluingTransformation", "program-workflow-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_2.append(TraceHopSpec("program-workflow-json", "reta_architecture/parameter_runtime.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_2.append(TraceHopSpec("reta_architecture/parameter_runtime.py", "WorkflowUniversalConstructionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta.py", ["WorkflowGluingCapsule"], ["UniversalConstructionCategory"],
        [], ["TableGenerationGluingTransformation"], ["program-workflow-json"],
        ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py"], ["WorkflowUniversalConstructionLaw"], route_2^, "reta.py wird über WorkflowGluingCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_3 = List[TraceHopSpec]()
    route_3.append(TraceHopSpec("retaPrompt.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_3.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_3.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_3.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_3.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_3.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "retaPrompt.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_3^, "retaPrompt.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_4 = List[TraceHopSpec]()
    route_4.append(TraceHopSpec("libs/center.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_4.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_4.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_4.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_4.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_4.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/center.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_4^, "libs/center.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_5 = List[TraceHopSpec]()
    route_5.append(TraceHopSpec("libs/LibRetaPrompt.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_5.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_5.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_5.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_5.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_5.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/LibRetaPrompt.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_5^, "libs/LibRetaPrompt.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_6 = List[TraceHopSpec]()
    route_6.append(TraceHopSpec("libs/nestedAlx.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_6.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_6.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_6.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_6.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_6.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/nestedAlx.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_6^, "libs/nestedAlx.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_7 = List[TraceHopSpec]()
    route_7.append(TraceHopSpec("libs/lib4tables.py", "OutputRenderingCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_7.append(TraceHopSpec("OutputRenderingCapsule", "OutputFormatCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_7.append(TraceHopSpec("OutputFormatCategory", "OutputRenderingFunctorFamily", "category_to_functor", "functor", ["category-theory-json"]))
    route_7.append(TraceHopSpec("OutputRenderingCapsule", "output-syntax-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_7.append(TraceHopSpec("output-syntax-json", "reta_architecture/output_syntax.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_7.append(TraceHopSpec("reta_architecture/output_syntax.py", "OutputNormalizationNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/lib4tables.py", ["OutputRenderingCapsule"], ["OutputFormatCategory"],
        ["OutputRenderingFunctorFamily"], [], ["output-syntax-json", "table-output-json"],
        ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], route_7^, "libs/lib4tables.py wird über OutputRenderingCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_8 = List[TraceHopSpec]()
    route_8.append(TraceHopSpec("libs/tableHandling.py", "TableCoreCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_8.append(TraceHopSpec("TableCoreCapsule", "TableSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_8.append(TraceHopSpec("TableCoreCapsule", "TableRuntimeToStateSectionsTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_8.append(TraceHopSpec("TableRuntimeToStateSectionsTransformation", "table-state-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_8.append(TraceHopSpec("table-state-json", "reta_architecture/table_runtime.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_8.append(TraceHopSpec("reta_architecture/table_runtime.py", "WorkflowUniversalConstructionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/tableHandling.py", ["TableCoreCapsule"], ["TableSectionCategory"],
        [], ["TableRuntimeToStateSectionsTransformation"], ["table-state-json", "table-runtime-json"],
        ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py"], ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"], route_8^, "libs/tableHandling.py wird über TableCoreCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_9 = List[TraceHopSpec]()
    route_9.append(TraceHopSpec("libs/lib4tables_prepare.py", "TableCoreCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_9.append(TraceHopSpec("TableCoreCapsule", "TableSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_9.append(TraceHopSpec("TableCoreCapsule", "TableRuntimeToStateSectionsTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_9.append(TraceHopSpec("TableRuntimeToStateSectionsTransformation", "table-state-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_9.append(TraceHopSpec("table-state-json", "reta_architecture/table_runtime.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_9.append(TraceHopSpec("reta_architecture/table_runtime.py", "WorkflowUniversalConstructionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/lib4tables_prepare.py", ["TableCoreCapsule"], ["TableSectionCategory"],
        [], ["TableRuntimeToStateSectionsTransformation"], ["table-state-json", "table-runtime-json"],
        ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py"], ["WorkflowUniversalConstructionLaw", "GeneratedColumnStateSyncLaw", "RuntimeStateProjectionLaw", "ExecutionNetworkPersistenceLaw"], route_9^, "libs/lib4tables_prepare.py wird über TableCoreCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_10 = List[TraceHopSpec]()
    route_10.append(TraceHopSpec("libs/lib4tables_concat.py", "GeneratedRelationCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_10.append(TraceHopSpec("GeneratedRelationCapsule", "GeneratedColumnEndomorphismCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_10.append(TraceHopSpec("GeneratedColumnEndomorphismCategory", "GeneratedColumnEndofunctorFamily", "category_to_functor", "functor", ["category-theory-json"]))
    route_10.append(TraceHopSpec("GeneratedRelationCapsule", "generated-columns-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_10.append(TraceHopSpec("generated-columns-json", "reta_architecture/generated_columns.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_10.append(TraceHopSpec("reta_architecture/generated_columns.py", "GeneratedColumnStateSyncLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/lib4tables_concat.py", ["GeneratedRelationCapsule"], ["GeneratedColumnEndomorphismCategory"],
        ["GeneratedColumnEndofunctorFamily"], [], ["generated-columns-json", "concat-csv-json", "combi-join-json"],
        ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py"], ["GeneratedColumnStateSyncLaw"], route_10^, "libs/lib4tables_concat.py wird über GeneratedRelationCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_11 = List[TraceHopSpec]()
    route_11.append(TraceHopSpec("libs/lib4tables_Enum.py", "SchemaTopologyCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_11.append(TraceHopSpec("SchemaTopologyCapsule", "OpenRetaContextCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_11.append(TraceHopSpec("OpenRetaContextCategory", "SchemaToTopologyFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_11.append(TraceHopSpec("SchemaTopologyCapsule", "topology-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_11.append(TraceHopSpec("topology-json", "reta_architecture/schema.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_11.append(TraceHopSpec("reta_architecture/schema.py", "ContextRefinementCompositionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/lib4tables_Enum.py", ["SchemaTopologyCapsule"], ["OpenRetaContextCategory"],
        ["SchemaToTopologyFunctor"], [], ["topology-json"],
        ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py"], ["ContextRefinementCompositionLaw"], route_11^, "libs/lib4tables_Enum.py wird über SchemaTopologyCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_12 = List[TraceHopSpec]()
    route_12.append(TraceHopSpec("reta_architecture/architecture_contracts.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_12.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_12.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_12.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_12.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_12.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_contracts.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_12^, "reta_architecture/architecture_contracts.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_13 = List[TraceHopSpec]()
    route_13.append(TraceHopSpec("reta_architecture/architecture_witnesses.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_13.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_13.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_13.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_13.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_13.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_witnesses.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_13^, "reta_architecture/architecture_witnesses.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_14 = List[TraceHopSpec]()
    route_14.append(TraceHopSpec("reta_architecture/architecture_validation.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_14.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_14.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_14.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_14.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_14.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_validation.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_14^, "reta_architecture/architecture_validation.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_15 = List[TraceHopSpec]()
    route_15.append(TraceHopSpec("reta_architecture/architecture_coherence.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_15.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_15.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_15.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_15.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_15.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_coherence.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_15^, "reta_architecture/architecture_coherence.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_16 = List[TraceHopSpec]()
    route_16.append(TraceHopSpec("readme*.md / doc/*.md", "LocalSectionCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_16.append(TraceHopSpec("LocalSectionCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_16.append(TraceHopSpec("LocalSectionCategory", "LocalDataPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_16.append(TraceHopSpec("LocalSectionCapsule", "presheaves-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_16.append(TraceHopSpec("presheaves-json", "reta_architecture/presheaves.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_16.append(TraceHopSpec("reta_architecture/presheaves.py", "PresheafRestrictionLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "readme*.md / doc/*.md", ["LocalSectionCapsule"], ["LocalSectionCategory"],
        ["LocalDataPresheafFunctor"], [], ["presheaves-json"],
        ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md"], ["PresheafRestrictionLaw", "ExecutionNetworkPersistenceLaw"], route_16^, "readme*.md / doc/*.md wird über LocalSectionCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_17 = List[TraceHopSpec]()
    route_17.append(TraceHopSpec("reta_architecture/architecture_traces.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_17.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_17.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_17.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_17.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_17.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_traces.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_17^, "reta_architecture/architecture_traces.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_18 = List[TraceHopSpec]()
    route_18.append(TraceHopSpec("reta_architecture/architecture_boundaries.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_18.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_18.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_18.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_18.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_18.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_boundaries.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_18^, "reta_architecture/architecture_boundaries.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_19 = List[TraceHopSpec]()
    route_19.append(TraceHopSpec("reta_architecture/architecture_impact.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_19.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_19.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_19.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_19.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_19.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_impact.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_19^, "reta_architecture/architecture_impact.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_20 = List[TraceHopSpec]()
    route_20.append(TraceHopSpec("reta_architecture/architecture_migration.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_20.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_20.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_20.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_20.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_20.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_migration.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_20^, "reta_architecture/architecture_migration.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_21 = List[TraceHopSpec]()
    route_21.append(TraceHopSpec("reta_architecture/architecture_rehearsal.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_21.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_21.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_21.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_21.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_21.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_rehearsal.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_21^, "reta_architecture/architecture_rehearsal.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_22 = List[TraceHopSpec]()
    route_22.append(TraceHopSpec("reta_architecture/architecture_activation.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_22.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_22.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_22.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_22.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_22.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_activation.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_22^, "reta_architecture/architecture_activation.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_23 = List[TraceHopSpec]()
    route_23.append(TraceHopSpec("libs/center.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_23.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_23.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_23.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_23.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_23.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/center.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_23^, "libs/center.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_24 = List[TraceHopSpec]()
    route_24.append(TraceHopSpec("reta_architecture/row_ranges.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_24.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_24.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_24.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_24.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_24.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/row_ranges.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_24^, "reta_architecture/row_ranges.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_25 = List[TraceHopSpec]()
    route_25.append(TraceHopSpec("libs/center.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_25.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_25.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_25.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_25.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_25.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/center.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_25^, "libs/center.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_26 = List[TraceHopSpec]()
    route_26.append(TraceHopSpec("reta_architecture/arithmetic.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_26.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_26.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_26.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_26.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_26.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/arithmetic.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_26^, "reta_architecture/arithmetic.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_27 = List[TraceHopSpec]()
    route_27.append(TraceHopSpec("libs/center.py", "OutputRenderingCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_27.append(TraceHopSpec("OutputRenderingCapsule", "OutputFormatCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_27.append(TraceHopSpec("OutputFormatCategory", "OutputRenderingFunctorFamily", "category_to_functor", "functor", ["category-theory-json"]))
    route_27.append(TraceHopSpec("OutputRenderingCapsule", "output-syntax-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_27.append(TraceHopSpec("output-syntax-json", "reta_architecture/output_syntax.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_27.append(TraceHopSpec("reta_architecture/output_syntax.py", "OutputNormalizationNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/center.py", ["OutputRenderingCapsule"], ["OutputFormatCategory"],
        ["OutputRenderingFunctorFamily"], [], ["output-syntax-json", "table-output-json"],
        ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], route_27^, "libs/center.py wird über OutputRenderingCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_28 = List[TraceHopSpec]()
    route_28.append(TraceHopSpec("reta_architecture/console_io.py", "OutputRenderingCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_28.append(TraceHopSpec("OutputRenderingCapsule", "OutputFormatCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_28.append(TraceHopSpec("OutputFormatCategory", "OutputRenderingFunctorFamily", "category_to_functor", "functor", ["category-theory-json"]))
    route_28.append(TraceHopSpec("OutputRenderingCapsule", "output-syntax-json", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_28.append(TraceHopSpec("output-syntax-json", "reta_architecture/output_syntax.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_28.append(TraceHopSpec("reta_architecture/output_syntax.py", "OutputNormalizationNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/console_io.py", ["OutputRenderingCapsule"], ["OutputFormatCategory"],
        ["OutputRenderingFunctorFamily"], [], ["output-syntax-json", "table-output-json"],
        ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw"], route_28^, "reta_architecture/console_io.py wird über OutputRenderingCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_29 = List[TraceHopSpec]()
    route_29.append(TraceHopSpec("libs/word_completerAlx.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_29.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_29.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_29.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_29.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_29.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/word_completerAlx.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_29^, "libs/word_completerAlx.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_30 = List[TraceHopSpec]()
    route_30.append(TraceHopSpec("reta_architecture/completion_word.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_30.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_30.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_30.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_30.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_30.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/completion_word.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_30^, "reta_architecture/completion_word.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_31 = List[TraceHopSpec]()
    route_31.append(TraceHopSpec("libs/nestedAlx.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_31.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_31.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_31.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_31.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_31.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "libs/nestedAlx.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_31^, "libs/nestedAlx.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_32 = List[TraceHopSpec]()
    route_32.append(TraceHopSpec("reta_architecture/completion_nested.py", "InputPromptCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_32.append(TraceHopSpec("InputPromptCapsule", "LocalSectionCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_32.append(TraceHopSpec("LocalSectionCategory", "RawCommandPresheafFunctor", "category_to_functor", "functor", ["category-theory-json"]))
    route_32.append(TraceHopSpec("InputPromptCapsule", "prompt-* tests", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_32.append(TraceHopSpec("prompt-* tests", "reta_architecture/input_semantics.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_32.append(TraceHopSpec("reta_architecture/input_semantics.py", "RawCanonicalNaturalityLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/completion_nested.py", ["InputPromptCapsule"], ["LocalSectionCategory"],
        ["RawCommandPresheafFunctor"], [], ["prompt-* tests"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw"], route_32^, "reta_architecture/completion_nested.py wird über InputPromptCapsule in die neue Architekturspur eingeordnet.",
    ))
    var route_33 = List[TraceHopSpec]()
    route_33.append(TraceHopSpec("reta_architecture/architecture_progress.py", "CategoricalMetaCapsule", "legacy_owner_to_capsule", "morphism", ["architecture-map-json"]))
    route_33.append(TraceHopSpec("CategoricalMetaCapsule", "ArchitectureCoherenceCategory", "capsule_to_category", "category", ["category-theory-json", "architecture-coherence-json"]))
    route_33.append(TraceHopSpec("CategoricalMetaCapsule", "ContractWitnessValidationTransformation", "functor_to_natural_transformation", "natural_transformation", ["category-theory-json"]))
    route_33.append(TraceHopSpec("ContractWitnessValidationTransformation", "architecture-contracts-json validation", "naturality_to_diagram", "commutative_diagram", ["architecture-contracts-json"]))
    route_33.append(TraceHopSpec("architecture-contracts-json validation", "reta_architecture/category_theory.py", "diagram_to_witness", "witness", ["architecture-witnesses-json"]))
    route_33.append(TraceHopSpec("reta_architecture/category_theory.py", "ArchitectureValidationCompletenessLaw", "witness_to_law", "refactor_law", ["architecture-contracts-json"]))
    components.append(RetaComponentTraceSpec(
        "reta_architecture/architecture_progress.py", ["CategoricalMetaCapsule"], ["ArchitectureCoherenceCategory"],
        [], ["ContractWitnessValidationTransformation"], ["architecture-contracts-json validation", "architecture-validation-json summary"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py"], ["ArchitectureValidationCompletenessLaw", "ArchitectureTraceNavigationLaw", "ArchitectureBoundaryImportLaw", "ArchitectureImpactGateLaw"], route_33^, "reta_architecture/architecture_progress.py wird über CategoricalMetaCapsule in die neue Architekturspur eingeordnet.",
    ))
    var capsules = List[CapsuleTraceSpec]()
    capsules.append(CapsuleTraceSpec(
        "RetaArchitectureRoot", "CommutativeArchitectureContractCategory", ["ArchitectureRuntimeFunctor", "ArchitectureMapToContractFunctor"],
        ["ContractedNaturalityTransformation", "LegacyToArchitectureTransformation"], ["ArchitectureMapContractReflectionTriangle", "LegacyArchitectureCompatibilitySquare"], ["LegacyCompatibilityNaturalityLaw"],
        ["reta_architecture/facade.py", "reta_architecture/__init__.py", "facade.py", "__init__.py"], ["reta_architecture/facade.py", "reta_architecture/__init__.py"], "RetaArchitectureRoot ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "SchemaTopologyCapsule", "OpenRetaContextCategory", ["SchemaToTopologyFunctor", "ArchitectureMapToContractFunctor"],
        ["ContractedNaturalityTransformation"], ["ArchitectureMapContractReflectionTriangle"], ["ContextRefinementCompositionLaw"],
        ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py"], ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py"], "SchemaTopologyCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "LocalSectionCapsule", "LocalSectionCategory", ["LocalDataPresheafFunctor", "RawCommandPresheafFunctor"],
        ["PresheafToSheafGluingTransformation"], ["PresheafSheafGluingSquare"], ["PresheafRestrictionLaw"],
        ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md", "presheaves.py"], ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md"], "LocalSectionCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "SemanticSheafCapsule", "CanonicalSemanticSheafCategory", ["CanonicalParameterSheafFunctor", "GluedSemanticSheafFunctor"],
        ["RawToCanonicalParameterTransformation", "PresheafToSheafGluingTransformation"], ["RawCommandNaturalitySquare", "PresheafSheafGluingSquare"], ["SheafGluingUniquenessLaw", "RawCanonicalNaturalityLaw"],
        ["reta_architecture/sheaves.py", "reta_architecture/semantics_builder.py", "sheaves.py", "semantics_builder.py"], ["reta_architecture/sheaves.py", "reta_architecture/semantics_builder.py"], "SemanticSheafCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "InputPromptCapsule", "ActivatedArithmeticCategory", ["RawCommandPresheafFunctor", "RowRangeActivationFunctor", "CenterRowRangeCompatibilityFunctor", "RowRangeInputFunctor", "RowRangeValidationFunctor", "ArithmeticActivationFunctor", "CenterArithmeticCompatibilityFunctor", "ArithmeticRowRangeGluingFunctor", "ArithmeticValidationFunctor", "ConsoleIOActivationFunctor", "CenterConsoleIOCompatibilityFunctor", "WordCompletionActivationFunctor", "LegacyWordCompleterCompatibilityFunctor", "WordCompletionPromptFunctor", "WordCompletionValidationFunctor", "NestedCompletionActivationFunctor", "LegacyNestedCompleterCompatibilityFunctor", "NestedCompletionPromptFunctor", "NestedCompletionValidationFunctor"],
        ["RawToCanonicalParameterTransformation", "CenterRowRangeToArchitectureTransformation", "RowRangeValidationTransformation", "CenterArithmeticToArchitectureTransformation", "ArithmeticRowRangeGluingTransformation", "CenterConsoleIOToArchitectureTransformation", "WordCompleterToArchitectureTransformation", "WordCompletionValidationTransformation", "NestedCompleterToArchitectureTransformation", "NestedCompletionValidationTransformation"], ["RawCommandNaturalitySquare", "CenterRowRangeCompatibilitySquare", "RowRangeValidationSquare", "CenterArithmeticCompatibilitySquare", "ArithmeticRowRangeGluingSquare", "CenterConsoleIOCompatibilitySquare", "WordCompleterCompatibilitySquare", "WordCompletionValidationSquare", "NestedCompleterCompatibilitySquare", "NestedCompletionValidationSquare"], ["RawCanonicalNaturalityLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw", "ActivatedWordCompletionLaw", "ActivatedNestedCompletionLaw"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py"], ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_interaction.py", "retaPrompt.py", "libs/LibRetaPrompt.py", "libs/nestedAlx.py", "reta_architecture/row_ranges.py", "reta_architecture/arithmetic.py", "reta_architecture/console_io.py", "reta_architecture/completion_word.py", "reta_architecture/completion_nested.py"], "InputPromptCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "WorkflowGluingCapsule", "UniversalConstructionCategory", ["TableGenerationGluingFunctor"],
        ["TableGenerationGluingTransformation"], ["UniversalWorkflowTableSquare"], ["WorkflowUniversalConstructionLaw"],
        ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py", "reta.py"], ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py", "reta.py"], "WorkflowGluingCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "TableCoreCapsule", "TableSectionCategory", ["MutableTableRuntimeFunctor", "ExplicitTableStateFunctor", "TableGenerationGluingFunctor"],
        ["TableRuntimeToStateSectionsTransformation", "TableGenerationGluingTransformation"], ["RuntimeStateProjectionSquare", "UniversalWorkflowTableSquare"], ["RuntimeStateProjectionLaw", "WorkflowUniversalConstructionLaw"],
        ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py", "reta_architecture/number_theory.py"], ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py", "reta_architecture/number_theory.py", "libs/tableHandling.py", "libs/lib4tables_prepare.py"], "TableCoreCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "GeneratedRelationCapsule", "GeneratedColumnEndomorphismCategory", ["GeneratedColumnEndofunctorFamily"],
        ["GeneratedColumnsSheafSyncTransformation"], ["GeneratedColumnStateSyncSquare"], ["GeneratedColumnStateSyncLaw"],
        ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "libs/tableHandling.py"], ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "libs/tableHandling.py"], "GeneratedRelationCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "OutputRenderingCapsule", "OutputFormatCategory", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "ConsoleIOOutputRenderingFunctor", "ConsoleIOValidationFunctor"],
        ["RenderedOutputNormalizationTransformation", "ConsoleIOOutputValidationTransformation", "CenterConsoleIOToArchitectureTransformation", "WordCompleterToArchitectureTransformation", "WordCompletionValidationTransformation", "NestedCompleterToArchitectureTransformation", "NestedCompletionValidationTransformation"], ["RenderedOutputParitySquare", "ConsoleIOOutputValidationSquare", "CenterConsoleIOCompatibilitySquare", "WordCompleterCompatibilitySquare", "WordCompletionValidationSquare", "NestedCompleterCompatibilitySquare", "NestedCompletionValidationSquare"], ["OutputNormalizationNaturalityLaw", "ActivatedConsoleIOLaw", "ActivatedWordCompletionLaw", "ActivatedNestedCompletionLaw"],
        ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py", "reta_architecture/console_io.py", "output_syntax.py"], ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py", "reta_architecture/console_io.py"], "OutputRenderingCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "CompatibilityCapsule", "LegacyFacadeCategory", ["LegacyRuntimeFunctor", "ArchitectureRuntimeFunctor", "NormalizedOutputFunctor"],
        ["LegacyToArchitectureTransformation", "RenderedOutputNormalizationTransformation"], ["LegacyArchitectureCompatibilitySquare", "RenderedOutputParitySquare"], ["LegacyCompatibilityNaturalityLaw", "OutputNormalizationNaturalityLaw"],
        ["reta.py", "retaPrompt.py", "libs/tableHandling.py", "libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/lib4tables_concat.py"], ["reta.py", "retaPrompt.py", "libs/tableHandling.py", "libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/lib4tables_concat.py", "reta_architecture/package_integrity.py", "tests/test_command_parity.py"], "CompatibilityCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    capsules.append(CapsuleTraceSpec(
        "CategoricalMetaCapsule", "CommutativeArchitectureContractCategory", ["CategoryTheoryToContractFunctor", "ArchitectureMapToContractFunctor", "TraceBoundaryImpactFunctor", "ImpactGateValidationFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor", "MigrationGateCoherenceFunctor", "MigrationOrderingCoherenceFunctor", "MigrationStepRehearsalFunctor", "MigrationGateRehearsalFunctor", "RehearsalCoverFunctor", "RehearsalGateValidationFunctor", "RehearsalReadinessCoherenceFunctor", "RehearsalActivationFunctor", "GateActivationFunctor", "ActivationTransactionFunctor", "ActivationRollbackFunctor", "ActivationValidationFunctor", "ActivationCoherenceFunctor", "RowRangeActivationFunctor", "CenterRowRangeCompatibilityFunctor", "RowRangeInputFunctor", "RowRangeValidationFunctor", "ArithmeticActivationFunctor", "CenterArithmeticCompatibilityFunctor", "ArithmeticRowRangeGluingFunctor", "ArithmeticValidationFunctor", "WordCompletionActivationFunctor", "LegacyWordCompleterCompatibilityFunctor", "WordCompletionPromptFunctor", "WordCompletionValidationFunctor", "NestedCompletionActivationFunctor", "LegacyNestedCompleterCompatibilityFunctor", "NestedCompletionPromptFunctor", "NestedCompletionValidationFunctor"],
        ["ContractedNaturalityTransformation", "TraceBoundaryImpactTransformation", "ImpactGateValidationTransformation", "ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "MigrationRehearsalNaturalityTransformation", "RehearsalReadinessValidationTransformation", "RehearsalActivationNaturalityTransformation", "ActivationRollbackValidationTransformation", "CenterRowRangeToArchitectureTransformation", "RowRangeValidationTransformation", "CenterArithmeticToArchitectureTransformation", "ArithmeticRowRangeGluingTransformation", "CenterConsoleIOToArchitectureTransformation", "ConsoleIOOutputValidationTransformation", "WordCompleterToArchitectureTransformation", "WordCompletionValidationTransformation", "NestedCompleterToArchitectureTransformation", "NestedCompletionValidationTransformation"], ["ArchitectureMapContractReflectionTriangle", "TraceBoundaryImpactSquare", "ImpactGateValidationSquare", "ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare", "MigrationRehearsalSquare", "RehearsalReadinessValidationSquare", "RehearsalActivationSquare", "ActivationRollbackValidationSquare", "CenterRowRangeCompatibilitySquare", "RowRangeValidationSquare", "CenterArithmeticCompatibilitySquare", "ArithmeticRowRangeGluingSquare", "CenterConsoleIOCompatibilitySquare", "ConsoleIOOutputValidationSquare", "WordCompleterCompatibilitySquare", "WordCompletionValidationSquare", "NestedCompleterCompatibilitySquare", "NestedCompletionValidationSquare"], ["ContextRefinementCompositionLaw", "LegacyCompatibilityNaturalityLaw", "ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw", "ArchitectureRehearsalReadinessLaw", "ArchitectureActivationCommitLaw", "ActivatedRowRangeLaw", "ActivatedArithmeticLaw", "ActivatedConsoleIOLaw", "ActivatedWordCompletionLaw", "ActivatedNestedCompletionLaw"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py"], ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_activation.py"], "CategoricalMetaCapsule ist als Kapseltrace von Codebesitz bis Kategorie/Funktor/Diagramm navigierbar.",
    ))
    var stages = List[StageHistoryTraceSpec]()
    stages.append(StageHistoryTraceSpec(
        "Stage 1", "SchemaTopologyCapsule + LocalSectionCapsule + SemanticSheafCapsule", ["topology.py", "presheaves.py", "sheaves.py", "morphisms.py", "universal.py", "facade.py"],
        ["erste Benennung von Topologie, Prägarbe, Garbe, Morphismus und universeller Eigenschaft"], "topology.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 2", "SchemaTopologyCapsule + SemanticSheafCapsule", ["schema.py", "semantics_builder.py"],
        ["Schema wird Quelle der Topologie", "Semantikaufbau wird Gluing statt Programminline-Code"], "schema.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 3", "SchemaTopologyCapsule", ["words_context.py", "words_matrix.py", "words_runtime.py", "words.py facade"],
        ["Kontext-, Matrix- und Runtime-Sektionen werden getrennt"], "words_context.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 4", "InputPromptCapsule", ["input_semantics.py", "split_i18n.py"],
        ["Eingabe-Grammatik wird eigene Morphismenschicht"], "input_semantics.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 5", "OutputRenderingCapsule", ["output_semantics.py"],
        ["Ausgabemodi werden Renderer-Morphismen statt verstreuter Branches"], "output_semantics.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 6", "InputPromptCapsule", ["prompt_runtime.py"],
        ["Prompt-Semantik entsteht aus Architektur statt aus vollem CLI-Programm"], "prompt_runtime.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 7", "InputPromptCapsule", ["completion_runtime.py"],
        ["Completion wird eigene Laufzeitsektion"], "completion_runtime.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 8", "InputPromptCapsule", ["prompt_language.py"],
        ["Prompt-Sprache wird expliziter Morphismenblock"], "prompt_language.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 9", "InputPromptCapsule", ["prompt_session.py"],
        ["Interaktive Session wird eigene lokale Zustandssektion"], "prompt_session.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 10", "InputPromptCapsule", ["prompt_execution.py"],
        ["tiefe Prompt-Kommandos werden ausführende Morphismen"], "prompt_execution.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 11", "InputPromptCapsule + CompatibilityCapsule", ["prompt_preparation.py", "package_integrity.py"],
        ["Vorbereitung und Manifest werden inspizierbare Architekturteile"], "prompt_preparation.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 12", "InputPromptCapsule", ["prompt_interaction.py"],
        ["Prompt-Interaktion wird Orchestrationskapsel"], "prompt_interaction.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 13", "WorkflowGluingCapsule", ["column_selection.py", "table_generation.py"],
        ["Spalten-/Tabellenbau wird universelles Gluing"], "column_selection.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 14", "WorkflowGluingCapsule", ["parameter_runtime.py"],
        ["CLI-Parameter werden kanonische Runtime-Sektion"], "parameter_runtime.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 15", "WorkflowGluingCapsule", ["program_workflow.py"],
        ["Programmablauf wird Workflow-Diagramm"], "program_workflow.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 16", "TableCoreCapsule", ["table_preparation.py"],
        ["Prepare wird Tabellen-Morphismus"], "table_preparation.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 17", "GeneratedRelationCapsule", ["generated_columns.py"],
        ["generierte Spalten werden Tabellen-Endomorphismen"], "generated_columns.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 18", "GeneratedRelationCapsule", ["generated_columns.py", "meta_columns.py"],
        ["Meta-/Generated-Familien werden getrennte Morphismenkategorien"], "generated_columns.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 19", "GeneratedRelationCapsule + WorkflowGluingCapsule", ["concat_csv.py"],
        ["CSV-Prägarben werden über Bruch-/Concat-Morphismen angeklebt"], "concat_csv.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 20", "OutputRenderingCapsule", ["table_output.py"],
        ["Rendering wird Output-Morphismus über Tabellen-Sektion"], "table_output.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 21", "GeneratedRelationCapsule", ["combi_join.py", "generated_columns.py"],
        ["Kombi-Relationen werden Join-Morphismen", "Gestirn wird Generated-Column-Morphismus"], "combi_join.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 22", "TableCoreCapsule", ["row_filtering.py"],
        ["Zeilenkontexte werden explizit gefilterte Sektionen"], "row_filtering.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 23", "TableCoreCapsule", ["table_wrapping.py", "number_theory.py"],
        ["Zellumbruch und Zahlenlogik werden eigene Morphismen"], "table_wrapping.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 24", "OutputRenderingCapsule", ["output_syntax.py"],
        ["Ausgabe-Syntax wird von Ausgabe-Semantik getrennt"], "output_syntax.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 25", "TableCoreCapsule", ["table_runtime.py"],
        ["Tables wird globale Tabellensektion in der Architektur"], "table_runtime.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 26", "TableCoreCapsule", ["table_state.py"],
        ["mutable Tabellenzustände werden explizite Sektionen"], "table_state.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 27", "CategoricalMetaCapsule", ["category_theory.py"],
        ["kommutierende Architekturpfade werden benannt"], "category_theory.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 28", "CategoricalMetaCapsule", ["architecture_map.py", "architecture-map-json", "architecture-diagram-md"],
        ["Topologie/Morphismen/Gluing/Garben/Kategorien/Funktoren/Transformationen werden als Schichten- und Datenflussdiagramm sichtbar"], "architecture_map.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 29", "CategoricalMetaCapsule", ["architecture_contracts.py", "architecture-contracts-json", "architecture-contracts-md"],
        ["natürliche Transformationen werden als prüfbare kommutierende Refactor-Pfade und Gesetze sichtbar"], "architecture_contracts.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 30", "CategoricalMetaCapsule", ["architecture_witnesses.py", "architecture-witnesses-json", "architecture-witnesses-md"],
        ["Kategorien/Funktoren/natürliche Transformationen werden an konkrete reta-Dateien, Kapseln, Probes und Tests rückgebunden"], "architecture_witnesses.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 31", "CategoricalMetaCapsule", ["architecture_validation.py", "architecture-validation-json", "architecture-validation-md", "architecture-coherence-json", "architecture-coherence-md"],
        ["Kategorien, Funktoren, natürliche Transformationen, Diagramme, Witnesses, Paketintegrität und Markdown-Historie werden als ein Validierungsbericht geprüft"], "architecture_validation.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 32", "CategoricalMetaCapsule", ["architecture_traces.py", "architecture-traces-json", "architecture-traces-md", "architecture_boundaries.py", "architecture-boundaries-json", "architecture-boundaries-md"],
        ["alte reta-Komponenten werden als Trace-Graph verfolgbar", "reale Python-Importe werden als Kapselgrenzen geprüft"], "architecture_traces.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 33", "CategoricalMetaCapsule", ["architecture_impact.py", "architecture-impact-json", "architecture-impact-md", "TraceBoundaryImpactSquare", "ImpactGateValidationSquare", "ArchitectureImpactGateLaw"],
        ["Stage-32-Traces und Boundaries werden zu Impact-Routen", "spätere Umbauten müssen über Gate-Probes und natürliche Transformationen laufen"], "architecture_impact.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 34", "CategoricalMetaCapsule", ["architecture_migration.py", "architecture-migration-json", "architecture-migration-md", "ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare", "ArchitectureMigrationOrderingLaw"],
        ["Stage-33-Impact-Kandidaten werden zu geordneten, gate-geschützten Migrationswellen", "spätere Extraktionen erhalten klare Exit-Kriterien"], "architecture_migration.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 35", "CategoricalMetaCapsule", ["architecture_rehearsal.py", "architecture-rehearsal-json", "architecture-rehearsal-md", "MigrationRehearsalSquare", "RehearsalReadinessValidationSquare", "ArchitectureRehearsalReadinessLaw"],
        ["Stage-34-Migrationsschritte werden zu topologischen Trockenlauf-Umgebungen, Refactor-Morphismen, Gate-Suites und universellen Readiness-Covers"], "architecture_rehearsal.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 36", "CategoricalMetaCapsule", ["architecture_activation.py", "architecture-activation-json", "architecture-activation-md", "RehearsalActivationSquare", "ActivationRollbackValidationSquare", "ArchitectureActivationCommitLaw"],
        ["Stage-35-Rehearsal-Moves werden zu commit-geschützten Aktivierungsfenstern, Rollback-Sektionen und universell geklebten Transaktionen", "weiterhin ohne Runtime-Verhaltensänderung"], "architecture_activation.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 37", "InputPromptCapsule", ["row_ranges.py", "row-ranges-json", "CenterRowRangeCompatibilitySquare", "ActivatedRowRangeLaw"],
        ["Erster echter Aktivierungsschritt: BereichToNumbers2/isZeilenAngabe/Generator-Literal-Parsing wandern aus center.py in RowRangeMorphismBundle", "center.py bleibt Legacy-Fassade"], "row_ranges.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 38", "InputPromptCapsule", ["arithmetic.py", "arithmetic-json", "CenterArithmeticCompatibilitySquare", "ActivatedArithmeticLaw"],
        ["Zweiter echter Aktivierungsschritt: multiples/teiler/primfaktoren/primRepeat/textHatZiffer wandern aus center.py in ArithmeticMorphismBundle", "center.py bleibt Legacy-Fassade"], "arithmetic.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 39", "OutputRenderingCapsule + InputPromptCapsule", ["console_io.py", "console-io-json", "CenterConsoleIOCompatibilitySquare", "ActivatedConsoleIOLaw"],
        ["Dritter echter Aktivierungsschritt: retaHilfe/retaPromptHilfe/getTextWrapThings/cliout/x/alxp/chunks/unique_everseen/DefaultOrderedDict wandern aus center.py in ConsoleIOMorphismBundle", "center.py bleibt Legacy-Fassade"], "console_io.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 40", "InputPromptCapsule", ["completion_word.py", "word-completion-json", "WordCompleterCompatibilitySquare", "ActivatedWordCompletionLaw"],
        ["Vierter echter Aktivierungsschritt: WordCompleter wandert aus word_completerAlx.py in WordCompletionMorphismBundle", "word_completerAlx.py bleibt Legacy-Fassade"], "completion_word.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 41", "InputPromptCapsule", ["completion_nested.py", "nested-completion-json", "NestedCompleterCompatibilitySquare", "ActivatedNestedCompletionLaw"],
        ["Fünfter echter Aktivierungsschritt: NestedCompleter wandert aus nestedAlx.py in NestedCompletionMorphismBundle", "nestedAlx.py bleibt Legacy-Fassade"], "completion_nested.py",
    ))
    stages.append(StageHistoryTraceSpec(
        "Stage 42", "CategoricalMetaCapsule", ["architecture_progress.py", "architecture-progress-json", "architecture-progress-md", "ARCHITECTURE_STATUS_STAGE42.md"],
        ["Stage 42 legt eine explizite Fortschritts- und Bestandsaufnahmeschicht über den Migrationsplan: sie markiert reale Kompatibilitätsfassaden, aktive Architektur-Owner und die wenigen verbleibenden gemischten Rest-Owner."], "architecture_progress.py",
    ))
    var validation = TraceValidationSpec(
        "passed",
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        204, 34,
    )
    var plan = Stage32ArchitecturePlan(
        ["Kohärenzmatrix als navigierbare Trace-Routen ausgeben", "alte reta-Teile stufenweise und kapselweise abbilden"], ["reta_architecture/architecture_traces.py", "architecture-traces-json", "architecture-traces-md"],
        ["CategoryTheoryBundle", "ArchitectureMapBundle", "ArchitectureContractsBundle", "ArchitectureWitnessBundle", "ArchitectureCoherenceBundle"], "keine beabsichtigte CLI-/Prompt-/Tabellen-/Output-Verhaltensänderung; Stage 32 ist eine Trace-Metaschicht",
    )
    return ArchitectureTraceBundle(
        components^, capsules^, stages^, validation^, "ArchitectureTraceBundle\n├─ legacy owner traces\n│  └─ reta.py / retaPrompt.py / libs / i18n / csv / reta_architecture\n├─ capsule traces\n│  └─ capsule → category → functor/transformation → diagram → witness → law\n└─ stage history traces\n   └─ Stage 1 … Stage 32\n",
        "```mermaid\nflowchart TD\n    Legacy[alte reta-Komponente] --> Capsule[Architektur-Kapsel]\n    Capsule --> Category[math Kategorie]\n    Category --> Functor[Functor]\n    Functor --> NT[natürliche Transformation]\n    NT --> Diagram[kommutierendes Diagramm]\n    Diagram --> Witness[Witness / Probe / Test]\n    Witness --> Law[Refactor-Gesetz]\n```\n", plan^,
    )
