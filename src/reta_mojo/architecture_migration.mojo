"""Generated native Mojo representation of architecture_migration.
The Python reference is evaluated only during explicit regeneration; runtime
navigation and validation are fully native.
Regenerate with tools/generate_architecture_migration.py.
"""

from std.collections import List

@fieldwise_init
struct MigrationWaveSpec(Copyable):
    var wave_id: String
    var order: Int
    var name: String
    var focus: String
    var owner_capsules: List[String]
    var candidates: List[String]
    var universal_property: String
    var functorial_route: List[String]
    var naturality_requirement: String
    var required_gates: List[String]
    var status: String

@fieldwise_init
struct MigrationStepSpec(Copyable):
    var step_id: String
    var wave_id: String
    var candidate: String
    var legacy_owner: String
    var current_capsule: String
    var target_capsule: String
    var action_type: String
    var target_owner: String
    var category: String
    var functors: List[String]
    var natural_transformations: List[String]
    var diagrams: List[String]
    var laws: List[String]
    var gates: List[String]
    var prerequisites: List[String]
    var observable_invariant: String
    var status: String

@fieldwise_init
struct GateCommandSpec(Copyable):
    var name: String
    var command: String

@fieldwise_init
struct MigrationGateBindingSpec(Copyable):
    var step_id: String
    var candidate: String
    var gates: List[String]
    var gate_commands: List[GateCommandSpec]
    var command_parity_required: Bool
    var bound_diagrams: List[String]
    var missing_gates: List[String]
    var status: String
    var reading: String

@fieldwise_init
struct MigrationInvariantSpec(Copyable):
    var name: String
    var wave_id: String
    var applies_to: List[String]
    var diagrams: List[String]
    var laws: List[String]
    var natural_transformations: List[String]
    var required_gates: List[String]
    var proof_obligation: String
    var status: String

@fieldwise_init
struct MigrationCheckSpec(Copyable):
    var name: String
    var status: String
    var failed_items: List[String]
    var checked_count: Int
    var reading: String

@fieldwise_init
struct MigrationValidationSpec(Copyable):
    var status: String
    var missing_candidates: List[String]
    var steps_without_gate_binding: List[String]
    var unknown_gates: List[String]
    var unknown_diagrams: List[String]
    var unknown_natural_transformations: List[String]
    var unordered_waves: List[String]
    var empty_waves: List[String]
    var checks: List[MigrationCheckSpec]

@fieldwise_init
struct Stage34ArchitecturePlan(Copyable):
    var planned_after_stage_33: List[String]
    var implemented_in_stage_34: List[String]
    var inherited_from_previous_stages: List[String]
    var behaviour_change: String

@fieldwise_init
struct ArchitectureMigrationBundle(Copyable):
    var waves: List[MigrationWaveSpec]
    var steps: List[MigrationStepSpec]
    var gate_bindings: List[MigrationGateBindingSpec]
    var invariants: List[MigrationInvariantSpec]
    var validation: MigrationValidationSpec
    var text_diagram: String
    var mermaid_diagram: String
    var plan: Stage34ArchitecturePlan

def migration_wave_index(bundle: ArchitectureMigrationBundle, wave_id: String) -> Int:
    for index in range(len(bundle.waves)):
        if bundle.waves[index].wave_id == wave_id:
            return index
    return -1

def migration_step_index(bundle: ArchitectureMigrationBundle, step_id: String) -> Int:
    for index in range(len(bundle.steps)):
        if bundle.steps[index].step_id == step_id:
            return index
    return -1

def migration_gate_binding_index(bundle: ArchitectureMigrationBundle, step_id: String) -> Int:
    for index in range(len(bundle.gate_bindings)):
        if bundle.gate_bindings[index].step_id == step_id:
            return index
    return -1

def migration_invariant_index(bundle: ArchitectureMigrationBundle, wave_id: String) -> Int:
    for index in range(len(bundle.invariants)):
        if bundle.invariants[index].wave_id == wave_id:
            return index
    return -1

def migration_owner_step_count(bundle: ArchitectureMigrationBundle, owner: String) -> Int:
    var count = 0
    for index in range(len(bundle.steps)):
        if bundle.steps[index].legacy_owner == owner:
            count += 1
    return count

def migration_first_owner_step_index(bundle: ArchitectureMigrationBundle, owner: String) -> Int:
    for index in range(len(bundle.steps)):
        if bundle.steps[index].legacy_owner == owner:
            return index
    return -1

def migration_snapshot_validation_passed(bundle: ArchitectureMigrationBundle) -> Bool:
    return (
        bundle.validation.status == "passed"
        and len(bundle.validation.missing_candidates) == 0
        and len(bundle.validation.steps_without_gate_binding) == 0
        and len(bundle.validation.unknown_gates) == 0
        and len(bundle.validation.unknown_diagrams) == 0
        and len(bundle.validation.unknown_natural_transformations) == 0
        and len(bundle.validation.unordered_waves) == 0
        and len(bundle.validation.empty_waves) == 0
    )

def architecture_migration_count_line(bundle: ArchitectureMigrationBundle) -> String:
    return (
        "waves=" + String(len(bundle.waves))
        + " steps=" + String(len(bundle.steps))
        + " gate_bindings=" + String(len(bundle.gate_bindings))
        + " invariants=" + String(len(bundle.invariants))
    )

def bootstrap_architecture_migration() -> ArchitectureMigrationBundle:
    var waves = List[MigrationWaveSpec]()
    waves.append(MigrationWaveSpec(
        "M0", 0, "Meta-Kohärenz und Planungswelle", "Stage-27 bis Stage-34 Metaebenen selbst stabil halten",
        ["CategoricalMetaCapsule"], ["Stage33Guard::reta_architecture/architecture_contracts.py", "Stage33Guard::reta_architecture/architecture_witnesses.py", "Stage33Guard::reta_architecture/architecture_validation.py", "Stage33Guard::reta_architecture/architecture_coherence.py", "Stage33Guard::reta_architecture/architecture_traces.py", "Stage33Guard::reta_architecture/architecture_boundaries.py", "Stage33Guard::reta_architecture/architecture_impact.py", "Stage33Guard::reta_architecture/architecture_migration.py", "Stage33Guard::reta_architecture/architecture_rehearsal.py", "Stage33Guard::reta_architecture/architecture_activation.py", "Stage33Guard::reta_architecture/row_ranges.py", "Stage33Guard::reta_architecture/arithmetic.py", "Stage33Guard::reta_architecture/console_io.py", "Stage33Guard::reta_architecture/completion_word.py", "Stage33Guard::reta_architecture/completion_nested.py", "Stage33Guard::reta_architecture/architecture_progress.py"],
        "The meta stack is the universal audit object for later moves.", ["ImpactToMigrationPlanFunctor", "MigrationWaveOrderingFunctor"],
        "Impact-derived and gate-derived planning must name the same allowed move.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M1", 1, "Topologie-/Prägarben-Datenwelle", "i18n, CSV und Dokumentsektionen nur entlang Kontext- und Restriktionsgesetzen verändern",
        ["SchemaTopologyCapsule", "LocalSectionCapsule", "SemanticSheafCapsule"], ["Stage33Guard::i18n/words.py", "Stage33Guard::csv/*.csv", "Stage33Guard::libs/lib4tables_Enum.py", "Stage33Guard::readme*.md / doc/*.md"],
        "Local sections glue to canonical semantics after context restriction.", ["SchemaToTopologyFunctor", "LocalDataPresheafFunctor", "ImpactToMigrationPlanFunctor"],
        "Restrict-then-glue and glue-then-restrict remain equivalent.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate", "CommandParityGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M2", 2, "Prompt-/Input-Morphismuswelle", "Prompt- und CLI-Rohtext weiter aus Legacy-Fassaden lösen",
        ["InputPromptCapsule", "SemanticSheafCapsule"], ["Stage33Guard::retaPrompt.py", "Stage33Guard::libs/center.py", "Stage33Guard::libs/LibRetaPrompt.py", "Stage33Guard::libs/nestedAlx.py", "Stage33Guard::libs/center.py", "Stage33Guard::libs/center.py", "Stage33Guard::libs/center.py", "Stage33Guard::libs/word_completerAlx.py", "Stage33Guard::libs/nestedAlx.py"],
        "Raw command sections canonically map into semantic sheaves.", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor"],
        "Raw-to-canonical naturality must commute for each prompt context.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M3", 3, "Workflow-/Universal-Gluing-Welle", "reta.py als Workflow-Fassade auf universelle Konstruktionen reduzieren",
        ["WorkflowGluingCapsule", "CompatibilityCapsule"], ["Stage33Guard::reta.py"],
        "The table workflow is the universal glued object from semantic sections and column selection.", ["TableGenerationGluingFunctor", "ImpactToMigrationPlanFunctor"],
        "Workflow gluing before/after compatibility projection yields the same table section.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M4", 4, "Table-Core-State-Welle", "Table runtime/state/prepare ownership enger in TableCoreCapsule führen",
        ["TableCoreCapsule"], ["Stage33Guard::libs/lib4tables_prepare.py"],
        "The global table section and explicit state sections are two projections of the same object.", ["MutableTableRuntimeFunctor", "ExplicitTableStateFunctor", "ImpactToMigrationPlanFunctor"],
        "Runtime-state projection remains natural under prepare/filter/wrap morphisms.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M5", 5, "Generated-Relation-Welle", "Generated/meta/concat/combi Operationen als Endofunktoren konsolidieren",
        ["GeneratedRelationCapsule"], ["Stage33Guard::libs/lib4tables_concat.py"],
        "Generated relations are endomorphisms of table sections with sheaf-state sync.", ["GeneratedColumnEndofunctorFamily", "ImpactToMigrationPlanFunctor"],
        "Generated-column state sync remains independent of legacy entry path.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    waves.append(MigrationWaveSpec(
        "M6", 6, "Output-Rendering- und Paritätswelle", "Renderer-Funktoren und Normalisierung weiter von Legacy-Ausgabe entkoppeln",
        ["OutputRenderingCapsule", "CompatibilityCapsule"], ["Stage33Guard::libs/lib4tables.py", "Stage33Guard::libs/tableHandling.py"],
        "Rendered outputs are functorial images of table sections, compared through normalization.", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "ImpactToMigrationPlanFunctor"],
        "Render-then-normalize and legacy-normalize paths stay observationally equivalent.", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], "ready_planned",
    ))
    var steps = List[MigrationStepSpec]()
    steps.append(MigrationStepSpec(
        "MIG34-01", "M1", "Stage33Guard::i18n/words.py", "i18n/words.py",
        "SchemaTopologyCapsule + SemanticSheafCapsule", "SchemaTopologyCapsule + SemanticSheafCapsule", "maintain",
        "reta_architecture/schema.py + topology.py + i18n split modules", "OpenRetaContextCategory", ["SchemaToTopologyFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "PresheafToSheafGluingTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-02", "M1", "Stage33Guard::csv/*.csv", "csv/*.csv",
        "LocalSectionCapsule", "LocalSectionCapsule", "maintain",
        "reta_architecture/presheaves.py + csv/doc local sections", "LocalSectionCategory", ["LocalDataPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "PresheafToSheafGluingTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-03", "M3", "Stage33Guard::reta.py", "reta.py",
        "CompatibilityCapsule", "WorkflowGluingCapsule + CompatibilityCapsule", "extract",
        "reta_architecture/program_workflow.py + table_generation.py + column_selection.py", "UniversalConstructionCategory", ["TableGenerationGluingFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableGenerationGluingTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-04", "M2", "Stage33Guard::retaPrompt.py", "retaPrompt.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-05", "M2", "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-06", "M2", "Stage33Guard::libs/LibRetaPrompt.py", "libs/LibRetaPrompt.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-07", "M2", "Stage33Guard::libs/nestedAlx.py", "libs/nestedAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-08", "M6", "Stage33Guard::libs/lib4tables.py", "libs/lib4tables.py",
        "CompatibilityCapsule", "OutputRenderingCapsule + TableCoreCapsule", "extract",
        "reta_architecture/table_runtime.py + table_state.py + table_preparation.py", "TableSectionCategory", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "MutableTableRuntimeFunctor", "ExplicitTableStateFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableRuntimeToStateSectionsTransformation", "RenderedOutputNormalizationTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-09", "M6", "Stage33Guard::libs/tableHandling.py", "libs/tableHandling.py",
        "CompatibilityCapsule", "TableCoreCapsule + GeneratedRelationCapsule + OutputRenderingCapsule", "extract",
        "reta_architecture/table_runtime.py + table_state.py + table_preparation.py", "TableSectionCategory", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "GeneratedColumnEndofunctorFamily", "MutableTableRuntimeFunctor", "ExplicitTableStateFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableRuntimeToStateSectionsTransformation", "GeneratedColumnsSheafSyncTransformation", "RenderedOutputNormalizationTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-10", "M4", "Stage33Guard::libs/lib4tables_prepare.py", "libs/lib4tables_prepare.py",
        "CompatibilityCapsule", "TableCoreCapsule", "extract",
        "reta_architecture/table_runtime.py + table_state.py + table_preparation.py", "TableSectionCategory", ["MutableTableRuntimeFunctor", "ExplicitTableStateFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableRuntimeToStateSectionsTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-11", "M5", "Stage33Guard::libs/lib4tables_concat.py", "libs/lib4tables_concat.py",
        "CompatibilityCapsule", "GeneratedRelationCapsule", "extract",
        "reta_architecture/generated_columns.py + meta_columns.py + concat_csv.py + combi_join.py", "GeneratedColumnEndomorphismCategory", ["GeneratedColumnEndofunctorFamily", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "GeneratedColumnsSheafSyncTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-12", "M1", "Stage33Guard::libs/lib4tables_Enum.py", "libs/lib4tables_Enum.py",
        "CompatibilityCapsule", "SchemaTopologyCapsule + GeneratedRelationCapsule", "extract",
        "reta_architecture/generated_columns.py + meta_columns.py + concat_csv.py + combi_join.py", "GeneratedColumnEndomorphismCategory", ["SchemaToTopologyFunctor", "GeneratedColumnEndofunctorFamily", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "GeneratedColumnsSheafSyncTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-13", "M0", "Stage33Guard::reta_architecture/architecture_contracts.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-14", "M0", "Stage33Guard::reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-15", "M0", "Stage33Guard::reta_architecture/architecture_validation.py", "reta_architecture/architecture_validation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-16", "M0", "Stage33Guard::reta_architecture/architecture_coherence.py", "reta_architecture/architecture_coherence.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-17", "M1", "Stage33Guard::readme*.md / doc/*.md", "readme*.md / doc/*.md",
        "LocalSectionCapsule + CategoricalMetaCapsule", "LocalSectionCapsule + CategoricalMetaCapsule", "maintain",
        "reta_architecture/presheaves.py + csv/doc local sections", "LocalSectionCategory", ["LocalDataPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "PresheafToSheafGluingTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-18", "M0", "Stage33Guard::reta_architecture/architecture_traces.py", "reta_architecture/architecture_traces.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-19", "M0", "Stage33Guard::reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_boundaries.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-20", "M0", "Stage33Guard::reta_architecture/architecture_impact.py", "reta_architecture/architecture_impact.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-21", "M0", "Stage33Guard::reta_architecture/architecture_migration.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-22", "M0", "Stage33Guard::reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_rehearsal.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-23", "M0", "Stage33Guard::reta_architecture/architecture_activation.py", "reta_architecture/architecture_activation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-24", "M2", "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-25", "M0", "Stage33Guard::reta_architecture/row_ranges.py", "reta_architecture/row_ranges.py",
        "InputPromptCapsule", "InputPromptCapsule", "maintain",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-26", "M2", "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-27", "M0", "Stage33Guard::reta_architecture/arithmetic.py", "reta_architecture/arithmetic.py",
        "InputPromptCapsule", "InputPromptCapsule", "maintain",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-28", "M2", "Stage33Guard::libs/center.py", "libs/center.py",
        "CompatibilityCapsule", "OutputRenderingCapsule", "extract",
        "reta_architecture/output_syntax.py + output_semantics.py + table_output.py", "OutputFormatCategory", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RenderedOutputNormalizationTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-29", "M0", "Stage33Guard::reta_architecture/console_io.py", "reta_architecture/console_io.py",
        "OutputRenderingCapsule", "OutputRenderingCapsule", "maintain",
        "reta_architecture/output_syntax.py + output_semantics.py + table_output.py", "OutputFormatCategory", ["OutputRenderingFunctorFamily", "NormalizedOutputFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "RenderedOutputNormalizationTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-30", "M2", "Stage33Guard::libs/word_completerAlx.py", "libs/word_completerAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-31", "M0", "Stage33Guard::reta_architecture/completion_word.py", "reta_architecture/completion_word.py",
        "InputPromptCapsule", "InputPromptCapsule", "maintain",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-32", "M2", "Stage33Guard::libs/nestedAlx.py", "libs/nestedAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule", "extract",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-33", "M0", "Stage33Guard::reta_architecture/completion_nested.py", "reta_architecture/completion_nested.py",
        "InputPromptCapsule", "InputPromptCapsule", "maintain",
        "reta_architecture/prompt_runtime.py + prompt_language/session/execution/preparation/interaction", "LocalSectionCategory", ["RawCommandPresheafFunctor", "ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "RawToCanonicalParameterTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    steps.append(MigrationStepSpec(
        "MIG34-34", "M0", "Stage33Guard::reta_architecture/architecture_progress.py", "reta_architecture/architecture_progress.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "maintain",
        "reta_architecture/category_theory.py + architecture_* meta bundles", "ArchitectureMigrationCategory", ["ImpactToMigrationPlanFunctor", "ImpactGateBindingFunctor", "MigrationWaveOrderingFunctor"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation"], ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"],
        ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"], ["Stage33 impact candidate exists", "Stage34 migration gate binding exists", "all listed probes stay green"],
        "legacy command/API output and architecture snapshot remain observationally equivalent after this move", "planned_not_executed",
    ))
    var bindings = List[MigrationGateBindingSpec]()
    bindings.append(MigrationGateBindingSpec(
        "MIG34-01", "Stage33Guard::i18n/words.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-01 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-02", "Stage33Guard::csv/*.csv", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-02 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-03", "Stage33Guard::reta.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-03 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-04", "Stage33Guard::retaPrompt.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-04 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-05", "Stage33Guard::libs/center.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-05 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-06", "Stage33Guard::libs/LibRetaPrompt.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-06 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-07", "Stage33Guard::libs/nestedAlx.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-07 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-08", "Stage33Guard::libs/lib4tables.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-08 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-09", "Stage33Guard::libs/tableHandling.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-09 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-10", "Stage33Guard::libs/lib4tables_prepare.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-10 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-11", "Stage33Guard::libs/lib4tables_concat.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-11 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-12", "Stage33Guard::libs/lib4tables_Enum.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-12 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-13", "Stage33Guard::reta_architecture/architecture_contracts.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-13 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-14", "Stage33Guard::reta_architecture/architecture_witnesses.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-14 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-15", "Stage33Guard::reta_architecture/architecture_validation.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-15 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-16", "Stage33Guard::reta_architecture/architecture_coherence.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-16 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-17", "Stage33Guard::readme*.md / doc/*.md", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-17 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-18", "Stage33Guard::reta_architecture/architecture_traces.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-18 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-19", "Stage33Guard::reta_architecture/architecture_boundaries.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-19 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-20", "Stage33Guard::reta_architecture/architecture_impact.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-20 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-21", "Stage33Guard::reta_architecture/architecture_migration.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-21 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-22", "Stage33Guard::reta_architecture/architecture_rehearsal.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-22 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-23", "Stage33Guard::reta_architecture/architecture_activation.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-23 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-24", "Stage33Guard::libs/center.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-24 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-25", "Stage33Guard::reta_architecture/row_ranges.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-25 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-26", "Stage33Guard::libs/center.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-26 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-27", "Stage33Guard::reta_architecture/arithmetic.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-27 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-28", "Stage33Guard::libs/center.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-28 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-29", "Stage33Guard::reta_architecture/console_io.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-29 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-30", "Stage33Guard::libs/word_completerAlx.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-30 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-31", "Stage33Guard::reta_architecture/completion_word.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-31 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-32", "Stage33Guard::libs/nestedAlx.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("CommandParityGate", "python -m unittest tests.test_command_parity -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], True,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-32 may move only when 11 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-33", "Stage33Guard::reta_architecture/completion_nested.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-33 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    bindings.append(MigrationGateBindingSpec(
        "MIG34-34", "Stage33Guard::reta_architecture/architecture_progress.py", ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        [GateCommandSpec("CategoryTheoryProbeGate", "python -B -S reta_architecture_probe_py.py category-theory-json"), GateCommandSpec("ArchitectureMapProbeGate", "python -B -S reta_architecture_probe_py.py architecture-map-json"), GateCommandSpec("ArchitectureContractsProbeGate", "python -B -S reta_architecture_probe_py.py architecture-contracts-json"), GateCommandSpec("ArchitectureWitnessProbeGate", "python -B -S reta_architecture_probe_py.py architecture-witnesses-json"), GateCommandSpec("ArchitectureCoherenceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-coherence-json"), GateCommandSpec("ArchitectureTraceProbeGate", "python -B -S reta_architecture_probe_py.py architecture-traces-json"), GateCommandSpec("ArchitectureBoundaryProbeGate", "python -B -S reta_architecture_probe_py.py architecture-boundaries-json"), GateCommandSpec("ArchitectureImpactSelfGate", "python -B -S reta_architecture_probe_py.py architecture-impact-json"), GateCommandSpec("ArchitectureRegressionGate", "python -m unittest tests.test_architecture_refactor -v"), GateCommandSpec("ArchitectureMigrationSelfGate", "python -B -S reta_architecture_probe_py.py architecture-migration-json")], False,
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], [],
        "bound", "MIG34-34 may move only when 10 gate commands, including Stage-34 self validation, remain available.",
    ))
    var invariants = List[MigrationInvariantSpec]()
    invariants.append(MigrationInvariantSpec(
        "M0::Meta-Kohärenz und Planungswelle::NaturalityInvariant", "M0", ["reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_activation.py", "reta_architecture/row_ranges.py", "reta_architecture/arithmetic.py", "reta_architecture/console_io.py", "reta_architecture/completion_word.py", "reta_architecture/completion_nested.py", "reta_architecture/architecture_progress.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "TraceBoundaryImpactTransformation", "RawToCanonicalParameterTransformation", "RenderedOutputNormalizationTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate"],
        "Impact-derived and gate-derived planning must name the same allowed move.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M1::Topologie-/Prägarben-Datenwelle::NaturalityInvariant", "M1", ["i18n/words.py", "csv/*.csv", "libs/lib4tables_Enum.py", "readme*.md / doc/*.md"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "PresheafToSheafGluingTransformation", "LegacyToArchitectureTransformation", "GeneratedColumnsSheafSyncTransformation", "TraceBoundaryImpactTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "ArchitectureMigrationSelfGate", "CommandParityGate"],
        "Restrict-then-glue and glue-then-restrict remain equivalent.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M2::Prompt-/Input-Morphismuswelle::NaturalityInvariant", "M2", ["retaPrompt.py", "libs/center.py", "libs/LibRetaPrompt.py", "libs/nestedAlx.py", "libs/center.py", "libs/center.py", "libs/center.py", "libs/word_completerAlx.py", "libs/nestedAlx.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "RawToCanonicalParameterTransformation", "RenderedOutputNormalizationTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        "Raw-to-canonical naturality must commute for each prompt context.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M3::Workflow-/Universal-Gluing-Welle::NaturalityInvariant", "M3", ["reta.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableGenerationGluingTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        "Workflow gluing before/after compatibility projection yields the same table section.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M4::Table-Core-State-Welle::NaturalityInvariant", "M4", ["libs/lib4tables_prepare.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableRuntimeToStateSectionsTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        "Runtime-state projection remains natural under prepare/filter/wrap morphisms.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M5::Generated-Relation-Welle::NaturalityInvariant", "M5", ["libs/lib4tables_concat.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "GeneratedColumnsSheafSyncTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        "Generated-column state sync remains independent of legacy entry path.", "planned",
    ))
    invariants.append(MigrationInvariantSpec(
        "M6::Output-Rendering- und Paritätswelle::NaturalityInvariant", "M6", ["libs/lib4tables.py", "libs/tableHandling.py"],
        ["ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare"], ["ArchitectureImpactGateLaw", "ArchitectureMigrationOrderingLaw"],
        ["ImpactGateMigrationTransformation", "MigrationPlanCoherenceTransformation", "LegacyToArchitectureTransformation", "TableRuntimeToStateSectionsTransformation", "RenderedOutputNormalizationTransformation", "GeneratedColumnsSheafSyncTransformation"], ["CategoryTheoryProbeGate", "ArchitectureMapProbeGate", "ArchitectureContractsProbeGate", "ArchitectureWitnessProbeGate", "ArchitectureCoherenceProbeGate", "ArchitectureTraceProbeGate", "ArchitectureBoundaryProbeGate", "ArchitectureImpactSelfGate", "ArchitectureRegressionGate", "CommandParityGate", "ArchitectureMigrationSelfGate"],
        "Render-then-normalize and legacy-normalize paths stay observationally equivalent.", "planned",
    ))
    var checks = List[MigrationCheckSpec]()
    checks.append(MigrationCheckSpec(
        "MigrationCandidateCoverageCheck", "passed", [],
        30, "Jeder Stage-33-Impact-Kandidat wird in Stage 34 zu mindestens einem Migrationsschritt.",
    ))
    checks.append(MigrationCheckSpec(
        "MigrationGateBindingCheck", "passed", [],
        34, "Jeder Migrationsschritt besitzt konkrete Gate-Kommandos.",
    ))
    checks.append(MigrationCheckSpec(
        "MigrationDiagramReferenceCheck", "passed", [],
        68, "Migration steps reference known commutative diagrams.",
    ))
    checks.append(MigrationCheckSpec(
        "MigrationNaturalityReferenceCheck", "passed", [],
        121, "Migration steps reference known natural transformations.",
    ))
    checks.append(MigrationCheckSpec(
        "MigrationWaveOrderingCheck", "passed", [],
        7, "Migration waves are ordered and non-empty.",
    ))
    var validation = MigrationValidationSpec(
        "passed", [],
        [], [],
        [], [],
        [], [], checks^,
    )
    var plan = Stage34ArchitecturePlan(
        ["Turn Stage-33 impact candidates into a concrete, ordered migration plan instead of leaving them as a flat risk list.", "Make each future move stufenweise and kapselweise: wave, step, target owner, functor route, natural transformation, diagrams and gates.", "Preserve the adjusted architecture paradigm by treating later code movement as a naturality-preserving migration, not a direct rewrite."], ["reta_architecture/architecture_migration.py", "architecture-migration-json and architecture-migration-md probe commands", "ArchitectureMap containment/flow/stage step for ArchitectureMigrationBundle", "CategoryTheory ArchitectureMigrationCategory plus migration functors and natural transformations", "ArchitectureContracts migration diagrams and ArchitectureMigrationOrderingLaw"],
        ["Stage 27 CategoryTheoryBundle", "Stage 28 ArchitectureMapBundle", "Stage 29 ArchitectureContractsBundle", "Stage 30 ArchitectureWitnessBundle", "Stage 31 ArchitectureValidation/Coherence bundles", "Stage 32 ArchitectureTrace/Boundary bundles", "Stage 33 ArchitectureImpactBundle"], "keine beabsichtigte Laufzeit-/CLI-/Prompt-/Tabellen-/Output-Verhaltensänderung; Stage 34 ist ein geordneter Migrationsplan über den Stage-33 Impact-Gates",
    )
    return ArchitectureMigrationBundle(
        waves^, steps^, bindings^, invariants^, validation^,
        "ArchitectureMigrationBundle\n├─ MigrationWaveSpec\n│  └─ ordered capsule waves M0..M6\n├─ MigrationStepSpec\n│  └─ Stage-33 candidate → action → target owner → category/functor/naturality\n├─ MigrationGateBindingSpec\n│  └─ step → regression gates → concrete commands\n├─ MigrationInvariantSpec\n│  └─ wave → diagrams/laws/natural transformations that must keep commuting\n└─ MigrationValidationSpec\n   └─ candidate coverage, gate binding, diagram/naturality references and wave order\n", "```mermaid\nflowchart TD\n    Impact[ArchitectureImpactBundle<br/>sources + candidates + gates] --> Plan[ArchitectureMigrationBundle]\n    Plan --> Waves[ordered migration waves]\n    Plan --> Steps[MigrationStepSpec]\n    Steps --> Gates[MigrationGateBindingSpec]\n    Steps --> Invariants[MigrationInvariantSpec]\n    Gates --> Validation[MigrationValidationSpec]\n    Invariants --> Validation\n    Validation --> Future[future runtime extraction<br/>only after gates commute]\n```\n", plan^,
    )
