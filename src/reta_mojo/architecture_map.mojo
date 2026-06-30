"""Generated native Mojo representation of reta_architecture.architecture_map.
Do not edit the generated bootstrap section manually; regenerate it with
tools/generate_architecture_map.py from the Python reference snapshot.
"""

from std.collections import List

@fieldwise_init
struct ArchitectureCapsuleSpec(Copyable):
    var name: String
    var layer: String
    var contains: List[String]
    var code_owners: List[String]
    var paradigm_roles: List[String]
    var inbound: List[String]
    var outbound: List[String]
    var stage_span: String
    var description: String

@fieldwise_init
struct ArchitectureFlowSpec(Copyable):
    var source: String
    var target: String
    var morphism: String
    var functor_or_transformation: String
    var code_owner: String
    var description: String

@fieldwise_init
struct RetaPartMappingSpec(Copyable):
    var legacy_owner: String
    var old_responsibility: String
    var new_capsule: String
    var new_owner: List[String]
    var paradigm_role: List[String]
    var stage: String
    var compatibility_surface: String
    var notes: String

@fieldwise_init
struct StageArchitectureStep(Copyable):
    var stage: String
    var focus: String
    var moved_from: List[String]
    var moved_to: List[String]
    var capsule: String
    var paradigm_shift: String

@fieldwise_init
struct CapsuleContainmentSpec(Copyable):
    var parent: String
    var child: String
    var relation: String

@fieldwise_init
struct MarkdownAuditSpec(Copyable):
    var source_package: String
    var markdown_files_in_stage27_package: Int
    var uploaded_tar_markdown_files: Int
    var important_families: List[String]
    var conclusion: String

@fieldwise_init
struct ArchitectureMapBundle(Copyable):
    var capsules: List[ArchitectureCapsuleSpec]
    var containment: List[CapsuleContainmentSpec]
    var flows: List[ArchitectureFlowSpec]
    var legacy_mappings: List[RetaPartMappingSpec]
    var stage_steps: List[StageArchitectureStep]
    var mermaid_diagram: String
    var text_diagram: String
    var markdown_audit: MarkdownAuditSpec

def capsule_index(bundle: ArchitectureMapBundle, name: String) -> Int:
    for index in range(len(bundle.capsules)):
        if bundle.capsules[index].name == name:
            return index
    return -1

def capsule_named(bundle: ArchitectureMapBundle, name: String) raises -> ArchitectureCapsuleSpec:
    var index = capsule_index(bundle, name)
    if index < 0:
        raise Error("Unknown architecture capsule: " + name)
    return bundle.capsules[index].copy()

def architecture_map_count_line(bundle: ArchitectureMapBundle) -> String:
    return (
        "capsules=" + String(len(bundle.capsules))
        + " containment=" + String(len(bundle.containment))
        + " flows=" + String(len(bundle.flows))
        + " legacy_mappings=" + String(len(bundle.legacy_mappings))
        + " stage_steps=" + String(len(bundle.stage_steps))
    )

def bootstrap_architecture_map() -> ArchitectureMapBundle:
    var capsules = List[ArchitectureCapsuleSpec]()
    capsules.append(ArchitectureCapsuleSpec(
        "RetaArchitectureRoot", "0 root / facade",
        ["SchemaTopologyCapsule", "LocalSectionCapsule", "SemanticSheafCapsule", "InputPromptCapsule", "WorkflowGluingCapsule", "TableCoreCapsule", "GeneratedRelationCapsule", "OutputRenderingCapsule", "CompatibilityCapsule", "CategoricalMetaCapsule"],
        ["reta_architecture/facade.py", "reta_architecture/__init__.py"],
        ["Gesamtfunktor-Fassade", "Kapsel-Root"],
        ["Legacy CLI/Prompt/import paths"],
        ["architecture snapshot", "runtime bundles", "probe JSON"],
        "Stages 1-31", "Die oberste Fassade hält die neue Architektur zusammen und ersetzt den alten impliziten Monolithverbund als Orientierungspunkt.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "SchemaTopologyCapsule", "1 schema + topology",
        ["RetaContextSchema", "ContextSelection", "RetaContextTopology", "split i18n modules", "tag/domain skeleton"],
        ["reta_architecture/schema.py", "reta_architecture/topology.py", "reta_architecture/split_i18n.py", "i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py"],
        ["Topologie", "math Kategorie: OpenRetaContextCategory"],
        ["legacy i18n words data", "CLI/prompt language domains"],
        ["open contexts", "basis covers", "schema snapshot"],
        "Stages 1-4", "Hier werden die früher verstreuten Parameter-, Sprach-, Zeilen-, Ausgabe- und Scope-Domänen zu offenen Kontexten über reta.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "LocalSectionCapsule", "2 presheaves / local data",
        ["FilesystemPresheaf", "PromptStatePresheaf", "LocalSection", "CSV sections", "translation/readme/assets sections"],
        ["reta_architecture/presheaves.py", "csv/*.csv", "doc/*.md", "readme*.md"],
        ["Prägarbe", "Restriktionsmorphismus", "LocalSectionCategory"],
        ["open contexts", "filesystem", "prompt raw text"],
        ["restricted local sections", "presheaf snapshot"],
        "Stage 1 onward", "Rohdaten bleiben lokal: CSVs, Übersetzungen, Assets und Prompt-Zustand werden als kontextabhängige Sektionen verstanden.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "SemanticSheafCapsule", "3 sheaves / canonical semantics",
        ["ParameterSemanticsSheaf", "GeneratedColumnsSheaf", "TableOutputSheaf", "HtmlReferenceSheaf", "ParameterSemanticsBuilder"],
        ["reta_architecture/sheaves.py", "reta_architecture/semantics_builder.py"],
        ["Garbe", "Sheafification", "CanonicalSemanticSheafCategory"],
        ["local sections", "schema topology", "legacy parameter matrices"],
        ["canonical pairs", "column numbers", "global semantic dictionaries"],
        "Stages 1-3 and 27", "Lokale Matrix-/CSV-/Aliasdaten werden zu kanonischer, global nutzbarer Parametersemantik verklebt.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "InputPromptCapsule", "4 input + prompt stack",
        ["InputBundle", "RowRangeSyntax", "PromptVocabulary", "PromptRuntimeBundle", "CompletionRuntimeBundle", "PromptLanguageBundle", "PromptSessionBundle", "PromptExecutionBundle", "PromptPreparationBundle", "PromptInteractionBundle", "RowRangeMorphismBundle", "RowRangeExpression", "RowIndexSet", "ArithmeticMorphismBundle", "ArithmeticExpression", "FactorPairSet", "PrimeFactorSection", "DivisorSection", "ConsoleIOMorphismBundle", "HelpMarkdownSection", "FiniteUtilitySection", "WordCompletionMorphismBundle", "CompletionCandidateSection", "CursorPrefixOpenSet", "NestedCompletionMorphismBundle", "NestedCompletionOpenSet", "NestedOptionSection", "NestedCompletionCandidateSection"],
        ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_interaction.py", "retaPrompt.py", "libs/LibRetaPrompt.py", "libs/nestedAlx.py", "reta_architecture/row_ranges.py", "reta_architecture/arithmetic.py", "reta_architecture/console_io.py", "reta_architecture/completion_word.py", "reta_architecture/completion_nested.py"],
        ["Morphismen", "RawCommandPresheafFunctor", "RawToCanonicalParameterTransformation", "aktivierter Zeilenbereichs-Morphismus", "aktivierter Arithmetik-Morphismus", "Teiler-Gluing über Row-Range-Topologie", "aktivierte Hilfe-/Debug-/Utility-Morphismen", "aktivierte Word-Completion-Morphismen", "aktivierte hierarchische Prompt-Completion-Morphismen"],
        ["raw CLI/prompt text", "interactive session state", "completion requests", "RowRangeActivationFunctor", "CenterRowRangeCompatibilityFunctor", "ArithmeticActivationFunctor", "CenterArithmeticCompatibilityFunctor", "ArithmeticRowRangeGluingFunctor", "ConsoleIOActivationFunctor", "CenterConsoleIOCompatibilityFunctor", "WordCompletionActivationFunctor", "LegacyWordCompleterCompatibilityFunctor", "NestedCompletionActivationFunctor", "LegacyNestedCompleterCompatibilityFunctor"],
        ["canonical command tokens", "prompt execution calls", "row/column requests", "row-ranges-json", "RowRangeInputFunctor", "RowRangeValidationFunctor", "arithmetic-json", "ArithmeticValidationFunctor", "console-io-json", "ConsoleIOValidationFunctor", "word-completion-json", "WordCompletionValidationFunctor", "nested-completion-json", "NestedCompletionValidationFunctor"],
        "Stages 4, 6-12, 37-41", "Der alte Prompt-Monolith ist in Runtime, Completion, Sprache, Session, Execution, Vorbereitung und Interaktion gekapselt. Stage 37 aktiviert die Zeilenbereichslogik: center.py delegiert an RowRangeMorphismBundle. Stage 38 aktiviert die center-Arithmetik: multiples/teiler/primfaktoren/primRepeat werden Wrapper über ArithmeticMorphismBundle. Stage 39 aktiviert center-Hilfe-/Debug-/Utility-Funktionen als ConsoleIOMorphismBundle. Stage 40 aktiviert word_completerAlx.WordCompleter als WordCompletionMorphismBundle. Stage 41 aktiviert nestedAlx.NestedCompleter als NestedCompletionMorphismBundle.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "WorkflowGluingCapsule", "5 universal workflow / gluing",
        ["ParameterRuntimeBundle", "ColumnSelectionBundle", "ProgramWorkflowBundle", "TableGenerationBundle", "UniversalBundle", "merge_parameter_dicts", "normalize_column_buckets"],
        ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py", "reta.py"],
        ["universelle Eigenschaft", "Gluing", "TableGenerationGluingFunctor", "TableGenerationGluingTransformation"],
        ["canonical semantics", "CLI arguments", "selected rows/columns"],
        ["global table section", "workflow result", "table generation snapshot"],
        "Stages 2, 13-15, 19, 21", "Diese Kapsel ersetzt die früher in reta.py versteckte Orchestrierung durch kanonische Merge-/Normalisierungs-/Tabellenbau-Knoten.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "TableCoreCapsule", "6 global table section + state",
        ["Tables", "TableRuntimeBundle", "TableStateBundle", "TableStateSections", "GeneratedColumnSection", "TableDisplayState", "TablePreparationBundle", "RowFilteringBundle", "TableWrappingBundle", "NumberTheoryBundle"],
        ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py", "reta_architecture/number_theory.py", "libs/tableHandling.py", "libs/lib4tables_prepare.py"],
        ["globale Garbensektion", "Tabellen-Morphismen", "ExplicitTableStateFunctor", "TableRuntimeToStateSectionsTransformation"],
        ["workflow gluing result", "generated-column effects", "row filters"],
        ["prepared table", "explicit state snapshot", "output-ready table"],
        "Stages 16, 20, 22-23, 25-26", "Die Tabelle ist jetzt eine globale Sektion mit explizitem Zustand; alte mutable Attribute bleiben nur noch Kompatibilitätsoberfläche.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "GeneratedRelationCapsule", "7 generated/meta/concat/combi morphisms",
        ["GeneratedColumnsBundle", "GeneratedColumnRegistry", "MetaColumnsBundle", "ConcatCsvBundle", "KombiJoinBundle", "fraction/csv gluing morphisms", "generated table endomorphisms"],
        ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py", "libs/lib4tables_concat.py", "libs/tableHandling.py"],
        ["Morphismen", "Endofunktoren", "GeneratedColumnEndomorphismCategory", "GeneratedColumnsSheafSyncTransformation"],
        ["global table section", "local CSV sections", "selected generated parameters"],
        ["enriched table section", "generated-column state", "combi-joined table"],
        "Stages 17-19, 21", "Alle ehemals im Concat-/Combi-Monolithen liegenden Erzeuger werden als Tabellen-Endomorphismen oder CSV-Gluing-Morphismen geführt.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "OutputRenderingCapsule", "8 syntax + output rendering",
        ["OutputSyntaxBundle", "RetaOutputSemantics", "TableOutputBundle", "TableOutput", "shell/markdown/html/csv/emacs/bbcode/nichts modes", "ConsoleIOMorphismBundle", "ConsoleOutputSection"],
        ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/table_output.py", "libs/lib4tables.py", "reta_architecture/console_io.py"],
        ["Renderer-Morphismus", "OutputRenderingFunctorFamily", "RenderedOutputNormalizationTransformation", "aktivierter Console-Output-Morphismus"],
        ["prepared global table", "output mode selection", "ConsoleIOOutputRenderingFunctor", "CenterConsoleIOCompatibilityFunctor"],
        ["rendered output", "normalized parity output", "console-io-json", "ConsoleIOValidationFunctor"],
        "Stages 5, 20, 24, 27, 39", "Ausgabeformate sind nicht mehr Tabellenbesitz, sondern Darstellungsmorphismen über der globalen Tabellensektion. Stage 39 macht CLI-Ausgabe, Hilfe-Rendering und Terminal-Wrapping zu einem aktivierten Output-Service.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "CompatibilityCapsule", "9 legacy compatibility + parity",
        ["reta.py", "retaPrompt.py", "libs facades", "tests/test_command_parity.py", "RepoManifest"],
        ["reta.py", "retaPrompt.py", "libs/tableHandling.py", "libs/lib4tables.py", "libs/lib4tables_prepare.py", "libs/lib4tables_concat.py", "reta_architecture/package_integrity.py", "tests/test_command_parity.py"],
        ["LegacyRuntimeFunctor", "ArchitectureRuntimeFunctor", "LegacyToArchitectureTransformation"],
        ["old import paths", "old command lines", "original archive"],
        ["same observable output", "package audit", "compatibility snapshots"],
        "Stages 3-28", "Die alte Oberfläche bleibt bedienbar; die Eigentümerschaft liegt schrittweise in den neuen Kapseln.",
    ))
    capsules.append(ArchitectureCapsuleSpec(
        "CategoricalMetaCapsule", "10 category theory + map",
        ["CategoryTheoryBundle", "CategorySpec", "FunctorSpec", "NaturalTransformationSpec", "ArchitectureMapBundle", "ArchitectureContractsBundle", "ArchitectureWitnessBundle", "ArchitectureValidationBundle", "ArchitectureCoherenceBundle", "CommutativeDiagramSpec", "CapsuleContractSpec", "RefactorLawSpec", "AnchorWitnessSpec", "CapsuleSliceSpec", "DiagramWitnessSpec", "ArchitectureValidationCheckSpec", "ArchitectureValidationSummarySpec", "CapsuleCoherenceSpec", "FunctorialRouteSpec", "NaturalityCoherenceSpec", "LawCoherenceSpec", "Stage31ArchitecturePlan", "capsule diagram", "ArchitectureTraceBundle", "ArchitectureBoundariesBundle", "RetaComponentTraceSpec", "CapsuleTraceSpec", "StageHistoryTraceSpec", "TraceHopSpec", "CapsuleBoundarySpec", "ModuleOwnershipSpec", "ImportEdgeSpec", "CapsuleImportEdgeSpec", "Stage32ArchitecturePlan", "Stage32BoundaryPlan", "ArchitectureImpactBundle", "ImpactSourceSpec", "ImpactContractSpec", "RegressionGateSpec", "MigrationCandidateSpec", "ImpactValidationSpec", "Stage33ArchitecturePlan", "ArchitectureMigrationBundle", "MigrationWaveSpec", "MigrationStepSpec", "MigrationGateBindingSpec", "MigrationInvariantSpec", "MigrationValidationSpec", "Stage34ArchitecturePlan", "ArchitectureRehearsalBundle", "RehearsalOpenSetSpec", "RehearsalMoveSpec", "GateRehearsalSpec", "RehearsalCoverSpec", "RehearsalValidationSpec", "Stage35ArchitecturePlan", "ArchitectureActivationBundle", "ActivationWindowSpec", "ActivationUnitSpec", "ActivationGateSpec", "ActivationRollbackSpec", "ActivationTransactionSpec", "ActivationValidationSpec", "Stage36ArchitecturePlan"],
        ["reta_architecture/category_theory.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_activation.py"],
        ["math Kategorie", "Funktor", "natürliche Transformation", "kommutierendes Diagramm", "Architekturkarte", "Witness", "Validierung", "Proof obligation", "Kohärenzmatrix", "Trace-Index", "Boundary-Importgraph", "Impact- und Migration-Gate-Schicht", "Migration-Plan-Schicht", "Rehearsal-/Readiness-Schicht", "Activation-/Commit-/Rollback-Schicht"],
        ["all architecture bundles", "stage markdown history"],
        ["category-theory-json", "architecture-map-json", "architecture-diagram-md", "architecture-contracts-json", "architecture-contracts-md", "architecture-witnesses-json", "architecture-witnesses-md", "architecture-validation-json", "architecture-validation-md", "architecture-coherence-json", "architecture-coherence-md", "architecture-traces-json", "architecture-boundaries-json", "architecture-impact-json", "architecture-impact-md", "architecture-migration-json", "architecture-migration-md", "architecture-rehearsal-json", "architecture-rehearsal-md", "architecture-activation-json", "architecture-activation-md"],
        "Stages 27-36", "Diese Ebene benennt mathematische Objekte, zeigt die Kapselung, hält seit Stage 29 kommutierende Pfade als Gesetze fest, verbindet sie seit Stage 30 mit Witnesses und prüft seit Stage 31 die Gesamtarchitektur als ausführbaren Validierungsbericht plus Kohärenzmatrix. Stage 32 ergänzt navigierbare Traces und reale Import-Boundaries. Stage 33 ergänzt Impact-Routen und Regression-Gates über Trace- und Boundary-Morphismen. Stage 34 ergänzt einen Migration-Plan über Impact-Kandidaten, Wellen, Schritte und Gate-Bindings. Stage 35 ergänzt Trockenlauf-Readiness über geplante Migrationsschritte und Gate-Suites. Stage 36 ergänzt commit-geschützte Aktivierungsfenster, Rollback-Sektionen und Transaktionen über Stage-35-Rehearsals.",
    ))
    var containment = List[CapsuleContainmentSpec]()
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "SchemaTopologyCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "LocalSectionCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "SemanticSheafCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "InputPromptCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "WorkflowGluingCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "TableCoreCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "GeneratedRelationCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "OutputRenderingCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "CompatibilityCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("RetaArchitectureRoot", "CategoricalMetaCapsule", "RetaArchitecture bootstraps, owns or exposes this capsule through a bundle/probe snapshot."))
    containment.append(CapsuleContainmentSpec("SchemaTopologyCapsule", "LocalSectionCapsule", "Local sections are indexed over open contexts."))
    containment.append(CapsuleContainmentSpec("LocalSectionCapsule", "SemanticSheafCapsule", "Compatible local sections glue into sheaves."))
    containment.append(CapsuleContainmentSpec("SemanticSheafCapsule", "WorkflowGluingCapsule", "Canonical semantics drives workflow and table generation."))
    containment.append(CapsuleContainmentSpec("WorkflowGluingCapsule", "TableCoreCapsule", "Universal workflow constructs the global table section."))
    containment.append(CapsuleContainmentSpec("TableCoreCapsule", "GeneratedRelationCapsule", "Generated/meta/concat/combi morphisms act on table sections."))
    containment.append(CapsuleContainmentSpec("TableCoreCapsule", "OutputRenderingCapsule", "Prepared table sections are rendered by output morphisms."))
    containment.append(CapsuleContainmentSpec("CompatibilityCapsule", "RetaArchitectureRoot", "Legacy surfaces route into the architecture root and parity tests check commutation."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "RetaArchitectureRoot", "The meta layer describes the whole root without owning runtime behaviour."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureContractsBundle", "Stage 29 stores commutative diagrams, capsule contracts and refactor laws inside the categorical meta layer."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureWitnessBundle", "Stage 30 stores concrete repository witnesses for diagrams, laws, natural transformations and capsule slices."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureValidationBundle", "Stage 31 validates categories, functors, natural transformations, contracts, witnesses, package integrity and Markdown history together."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureCoherenceBundle", "Stage 31 also exposes a coherence matrix from capsule to category, functor, natural transformation, diagram, law and witness."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureTraceBundle", "Stage 32 makes old reta owner to capsule/category/functor/transformation/diagram/witness paths navigable."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureBoundariesBundle", "Stage 32 records concrete Python import morphisms as explicit capsule-boundary edges."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureImpactBundle", "Stage 33 maps trace and boundary morphisms to impact contracts, regression gates and guarded migration candidates."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureMigrationBundle", "Stage 34 translates impact candidates and regression gates into ordered migration waves, guarded steps, gate bindings and invariants."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureRehearsalBundle", "Stage 35 rehearses Stage-34 migration waves as open sets, moves, gate suites and readiness covers."))
    containment.append(CapsuleContainmentSpec("CategoricalMetaCapsule", "ArchitectureActivationBundle", "Stage 36 lifts Stage-35 rehearsal moves into activation windows, commit gates, rollback sections and transaction covers."))
    containment.append(CapsuleContainmentSpec("InputPromptCapsule", "RowRangeMorphismBundle", "Stage 37 moves BereichToNumbers2/isZeilenAngabe logic from center.py into an activated architecture morphism bundle."))
    containment.append(CapsuleContainmentSpec("InputPromptCapsule", "ArithmeticMorphismBundle", "Stage 38 moves center-level arithmetic helpers into an activated architecture morphism bundle that glues over the Stage-37 row-range topology."))
    containment.append(CapsuleContainmentSpec("InputPromptCapsule", "ConsoleIOMorphismBundle", "Stage 39 moves center-level help/debug/utility helpers into an activated architecture morphism bundle."))
    containment.append(CapsuleContainmentSpec("OutputRenderingCapsule", "ConsoleIOMorphismBundle", "Stage 39 treats CLI output and terminal wrapping as an activated output-rendering service."))
    containment.append(CapsuleContainmentSpec("InputPromptCapsule", "WordCompletionMorphismBundle", "Stage 40 moves word_completerAlx.WordCompleter matching into an activated architecture morphism bundle."))
    containment.append(CapsuleContainmentSpec("InputPromptCapsule", "NestedCompletionMorphismBundle", "Stage 41 moves nestedAlx.NestedCompleter hierarchical prompt completion into an activated architecture morphism bundle."))
    var flows = List[ArchitectureFlowSpec]()
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "SchemaTopologyCapsule", "bootstrap schema from split i18n modules",
        "SchemaToTopologyFunctor", "RetaArchitecture.bootstrap + RetaContextSchema.from_words_parts",
        "Legacy words/context/matrix/runtime data becomes the typed topology base.",
    ))
    flows.append(ArchitectureFlowSpec(
        "SchemaTopologyCapsule", "LocalSectionCapsule", "restrict/open_for/cover_for_main",
        "LocalDataPresheafFunctor", "RetaContextTopology + PresheafBundle",
        "Open contexts index local files, prompt state and translation sections.",
    ))
    flows.append(ArchitectureFlowSpec(
        "LocalSectionCapsule", "SemanticSheafCapsule", "sheafification/gluing of compatible sections",
        "PresheafToSheafGluingTransformation", "PresheafBundle + SheafBundle + UniversalBundle",
        "Local CSV/translation/prompt sections are glued to global semantic sheaves.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "SemanticSheafCapsule", "alias and prompt-token canonicalization",
        "RawToCanonicalParameterTransformation", "morphisms.py + prompt_language.py + sheaves.py",
        "Raw prompt or CLI text becomes canonical parameter semantics.",
    ))
    flows.append(ArchitectureFlowSpec(
        "SemanticSheafCapsule", "WorkflowGluingCapsule", "column selection + parameter runtime + universal merge",
        "TableGenerationGluingTransformation", "column_selection.py + parameter_runtime.py + universal.py",
        "Canonical pairs and local parameter dictionaries become normalized workflow input.",
    ))
    flows.append(ArchitectureFlowSpec(
        "WorkflowGluingCapsule", "TableCoreCapsule", "create/prepare global table section",
        "TableGenerationGluingFunctor", "table_generation.py + program_workflow.py + table_runtime.py",
        "The universal workflow creates the mutable-but-owned global table section.",
    ))
    flows.append(ArchitectureFlowSpec(
        "TableCoreCapsule", "GeneratedRelationCapsule", "generated columns / CSV concat / combi join",
        "GeneratedColumnEndofunctorFamily", "generated_columns.py + concat_csv.py + combi_join.py",
        "Table sections are enriched by generated, meta, fractional and combination morphisms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "GeneratedRelationCapsule", "TableCoreCapsule", "sync generated metadata into explicit table state",
        "GeneratedColumnsSheafSyncTransformation", "generated_columns.py + table_state.py + universal.py",
        "Generated-column effects are mirrored into explicit state sections and sheaf metadata.",
    ))
    flows.append(ArchitectureFlowSpec(
        "TableCoreCapsule", "OutputRenderingCapsule", "render table output",
        "OutputRenderingFunctorFamily", "table_output.py + output_semantics.py + output_syntax.py",
        "Prepared table sections are rendered as shell, markdown, HTML, CSV, Emacs, BBCode or nothing.",
    ))
    flows.append(ArchitectureFlowSpec(
        "OutputRenderingCapsule", "CompatibilityCapsule", "normalize rendered output for parity",
        "RenderedOutputNormalizationTransformation", "tests/test_command_parity.py",
        "Renderer-specific syntax is normalized where needed for old-vs-new compatibility checks.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "RetaArchitectureRoot", "legacy facade delegation",
        "LegacyToArchitectureTransformation", "reta.py + retaPrompt.py + libs compatibility facades",
        "Old import and command paths keep working while delegating to the new owners.",
    ))
    flows.append(ArchitectureFlowSpec(
        "TableCoreCapsule", "CategoricalMetaCapsule", "runtime/state projection",
        "TableRuntimeToStateSectionsTransformation", "table_runtime.py + table_state.py + category_theory.py",
        "The mutable table runtime and the explicit table-state view are documented as a commutative projection.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "commutative architecture law checks",
        "LegacyToArchitectureTransformation", "architecture_contracts.py + tests/test_architecture_refactor.py",
        "Stage-29 diagrams state which category/functor/natural-transformation paths must keep commuting during later extractions.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "witness matrix ties contracts to files, tests and probes",
        "ContractedNaturalityTransformation", "architecture_witnesses.py + tests/test_architecture_refactor.py",
        "Stage-30 witnesses show where the architecture contracts are concretely evidenced in the repository.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "executable architecture validation",
        "ContractWitnessValidationTransformation", "architecture_validation.py + tests/test_architecture_refactor.py",
        "Stage-31 validation checks that category theory, map, contracts, witnesses, package integrity and Markdown history commute as one architecture report.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "coherence matrix over categories, routes, naturality and laws",
        "ContractWitnessValidationTransformation", "architecture_coherence.py + tests/test_architecture_refactor.py",
        "Stage-31 coherence makes the capsule/category/functor/transformation/diagram/law/witness chain visible as one matrix.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "trace old owner to categorical route",
        "CoherenceToTraceFunctor", "ArchitectureTraceBundle",
        "Stage 32 turns coherence into navigation.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "classify imports as capsule boundaries",
        "CoherenceToBoundaryFunctor", "ArchitectureBoundariesBundle",
        "Stage 32 turns real imports into boundary morphisms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "compute impact from traces and boundaries",
        "TraceBoundaryImpactFunctor", "ArchitectureImpactBundle",
        "Stage 33 turns visible routes into affected diagrams, laws and gates.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "validate guarded migration candidates",
        "ImpactGateValidationFunctor", "ArchitectureImpactBundle",
        "Stage 33 feeds impact gates back into compatibility/parity planning.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "plan guarded migration waves from impact candidates",
        "ImpactToMigrationPlanFunctor", "ArchitectureMigrationBundle",
        "Stage 34 turns impact gates into a future migration plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "bind migration gates before future extraction",
        "MigrationGateCoherenceFunctor", "ArchitectureMigrationBundle",
        "Stage 34 feeds gate bindings back into compatibility/parity planning.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "rehearse guarded migration moves before execution",
        "MigrationStepRehearsalFunctor", "ArchitectureRehearsalBundle",
        "Stage 35 turns planned migration steps into dry-run refactor morphisms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "WorkflowGluingCapsule", "lift migration gate bindings into rehearsal suites",
        "MigrationGateRehearsalFunctor", "ArchitectureRehearsalBundle",
        "Stage 35 maps Stage-34 gate bindings to preflight/postflight rehearsal suites.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "SchemaTopologyCapsule", "cover migration waves by rehearsal open sets",
        "RehearsalCoverFunctor", "ArchitectureRehearsalBundle",
        "Stage 35 treats each ordered migration wave as a topological open rehearsal region with a cover.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "validate rehearsal readiness gates",
        "RehearsalGateValidationFunctor", "ArchitectureRehearsalBundle",
        "Stage 35 feeds preflight/postflight gate suites into validation and compatibility planning.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "reflect rehearsal readiness back into coherence",
        "RehearsalReadinessCoherenceFunctor", "ArchitectureRehearsalBundle",
        "Stage 35 reflects successful rehearsal gates into the meta-coherence matrix.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "RetaArchitectureRoot", "activate rehearsed migration moves as commit envelopes",
        "RehearsalActivationFunctor", "ArchitectureActivationBundle",
        "Stage 36 turns dry-run moves into not-yet-executed activation units.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "bind activation gates to compatibility/parity safety",
        "GateActivationFunctor", "ArchitectureActivationBundle",
        "Stage 36 lifts gate rehearsals into preflight/commit/postflight/rollback gate suites.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "WorkflowGluingCapsule", "glue activation units into transaction windows",
        "ActivationTransactionFunctor", "ArchitectureActivationBundle",
        "Stage 36 treats each activation window as a universal transaction cover.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "retain rollback sections for future moves",
        "ActivationRollbackFunctor", "ArchitectureActivationBundle",
        "Stage 36 keeps every potential commit reversible before future runtime movement.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule", "validate activation commit gates",
        "ActivationValidationFunctor", "ArchitectureActivationBundle",
        "Stage 36 feeds activation gates and rollback sections into validation and compatibility planning.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "CategoricalMetaCapsule", "reflect activation transactions back into coherence",
        "ActivationCoherenceFunctor", "ArchitectureActivationBundle",
        "Stage 36 reflects successful activation transaction coverage into the meta-coherence matrix.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "InputPromptCapsule", "activate planned row-range migration unit",
        "RowRangeActivationFunctor", "reta_architecture/row_ranges.py",
        "Stage 37 performs the first controlled activation from the Stage-36 plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "InputPromptCapsule", "delegate legacy center row-range API to architecture",
        "CenterRowRangeCompatibilityFunctor", "libs/center.py",
        "center.py keeps old names but no longer owns the row-range expansion algorithm.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "LocalSectionCapsule", "treat expanded row sets as local input sections",
        "RowRangeInputFunctor", "reta_architecture/row_ranges.py",
        "Row-range expressions become local row-index sections for later prompt/workflow use.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "CategoricalMetaCapsule", "validate activated row-range morphism",
        "RowRangeValidationFunctor", "reta_architecture/architecture_validation.py",
        "Stage 37 adds direct validation for the activated parser and wrappers.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "InputPromptCapsule", "activate planned arithmetic migration unit",
        "ArithmeticActivationFunctor", "reta_architecture/arithmetic.py",
        "Stage 38 performs the second controlled activation from the Stage-36 plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "InputPromptCapsule", "delegate legacy center arithmetic API to architecture",
        "CenterArithmeticCompatibilityFunctor", "libs/center.py",
        "center.py keeps old arithmetic names but no longer owns the factor/prime/divisor algorithms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "InputPromptCapsule", "glue divisor ranges over activated row-range topology",
        "ArithmeticRowRangeGluingFunctor", "reta_architecture/arithmetic.py",
        "Stage 38 composes Stage-37 RowIndexSet sections with factor-pair morphisms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "CategoricalMetaCapsule", "validate activated arithmetic morphism",
        "ArithmeticValidationFunctor", "reta_architecture/architecture_validation.py",
        "Stage 38 adds direct validation for arithmetic wrappers and architecture results.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "OutputRenderingCapsule", "activate planned console-io migration unit",
        "ConsoleIOActivationFunctor", "reta_architecture/console_io.py",
        "Stage 39 performs the third controlled activation from the Stage-36 plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "OutputRenderingCapsule", "delegate legacy center console/help API to architecture",
        "CenterConsoleIOCompatibilityFunctor", "libs/center.py",
        "center.py keeps old console/help/utility names but no longer owns those algorithms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "OutputRenderingCapsule", "OutputRenderingCapsule", "render console output sections",
        "ConsoleIOOutputRenderingFunctor", "reta_architecture/console_io.py",
        "Stage 39 composes help text, cliout and terminal wrapping as output morphisms.",
    ))
    flows.append(ArchitectureFlowSpec(
        "OutputRenderingCapsule", "CategoricalMetaCapsule", "validate activated console/io morphism",
        "ConsoleIOValidationFunctor", "reta_architecture/architecture_validation.py",
        "Stage 39 adds direct validation for console/help/utility wrappers and architecture results.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "InputPromptCapsule", "activate planned word-completion migration unit",
        "WordCompletionActivationFunctor", "reta_architecture/completion_word.py",
        "Stage 40 performs the fourth controlled activation from the Stage-36 plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "InputPromptCapsule", "delegate legacy word_completerAlx WordCompleter to architecture",
        "LegacyWordCompleterCompatibilityFunctor", "libs/word_completerAlx.py",
        "word_completerAlx.py keeps the old WordCompleter name but no longer owns matching logic.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "InputPromptCapsule", "produce prompt completion candidate sections",
        "WordCompletionPromptFunctor", "reta_architecture/completion_word.py",
        "Stage 40 composes document prefix open sets with local word sections.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "CategoricalMetaCapsule", "validate activated word-completion morphism",
        "WordCompletionValidationFunctor", "reta_architecture/architecture_validation.py",
        "Stage 40 adds direct validation for legacy and architecture completion results.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CategoricalMetaCapsule", "InputPromptCapsule", "activate planned nested-completion migration unit",
        "NestedCompletionActivationFunctor", "reta_architecture/completion_nested.py",
        "Stage 41 performs the fifth controlled activation from the Stage-36 plan.",
    ))
    flows.append(ArchitectureFlowSpec(
        "CompatibilityCapsule", "InputPromptCapsule", "delegate legacy nestedAlx NestedCompleter to architecture",
        "LegacyNestedCompleterCompatibilityFunctor", "libs/nestedAlx.py",
        "nestedAlx.py keeps the old NestedCompleter and ComplSitua names but no longer owns hierarchical completion logic.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "InputPromptCapsule", "produce hierarchical prompt completion candidate sections",
        "NestedCompletionPromptFunctor", "reta_architecture/completion_nested.py",
        "Stage 41 composes prompt situations, runtime vocabulary and equality/comma value sections.",
    ))
    flows.append(ArchitectureFlowSpec(
        "InputPromptCapsule", "CategoricalMetaCapsule", "validate activated nested-completion morphism",
        "NestedCompletionValidationFunctor", "reta_architecture/architecture_validation.py",
        "Stage 41 adds direct validation for legacy and architecture nested-completion routes.",
    ))
    var mappings = List[RetaPartMappingSpec]()
    mappings.append(RetaPartMappingSpec(
        "i18n/words.py", "Monolith für Sprache, Hauptparameter, Matrixdaten, Runtime-Konstanten und Kommandowörter.",
        "SchemaTopologyCapsule + SemanticSheafCapsule", ["i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py", "reta_architecture/schema.py", "reta_architecture/semantics_builder.py"],
        ["Topologie", "Prägarben-Index", "Garbe nach Semantik-Gluing"], "Stages 2-3",
        "i18n/words.py remains a compatibility facade.", "words.py liefert nicht mehr selbst die Architektur; die gesplitteten Module sind Quelle für Schema, Topologie und Semantik.",
    ))
    mappings.append(RetaPartMappingSpec(
        "csv/*.csv", "Tabellenrohdaten für Religion, Primzahlen, Kombi, gebrochene Universen/Galaxien und Sprachvarianten.",
        "LocalSectionCapsule", ["reta_architecture/presheaves.py", "reta_architecture/concat_csv.py", "reta_architecture/table_generation.py"],
        ["Prägarbe", "LocalSection", "CSV-Gluing-Morphismus"], "Stages 1, 13, 19",
        "CSV file names stay unchanged.", "CSV-Dateien werden als lokale Sektionen gelesen und erst über Gluing in globale Tabellen-/Semantiksektionen gebracht.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta.py", "CLI-Programm, Parameterparser, Semantikaufbau, Spaltenauswahl, Tabellenbau und Ausgabe-Orchestrierung.",
        "WorkflowGluingCapsule + CompatibilityCapsule", ["reta_architecture/parameter_runtime.py", "reta_architecture/column_selection.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/facade.py"],
        ["universelle Eigenschaft", "Gluing", "ArchitectureRuntimeFunctor"], "Stages 2, 5, 13-15, 25-26",
        "reta.Program still exists and delegates to RetaArchitecture.", "reta.py wird zur CLI-/Legacy-Fassade; die großen Besitzerblöcke liegen in Architektur-Bundles.",
    ))
    mappings.append(RetaPartMappingSpec(
        "retaPrompt.py", "Interaktive Prompt-Shell, Speicherlogik, Regex-Vorbereitung, Completion, Sprache und tiefe Ausführung.",
        "InputPromptCapsule", ["reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_session.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_interaction.py"],
        ["RawCommandPresheafFunctor", "Prompt-Morphismen", "RawToCanonicalParameterTransformation"], "Stages 6-12",
        "retaPrompt.py remains the interactive entry surface.", "Prompt-Rohtext und Interaktion werden lokal gehalten, morphismisch normalisiert und dann an kanonische Semantik/Workflow übergeben.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/center.py", "Zeilenbereichs-Grammatik, zentrale Eingabe-/Hilfsdefinitionen und breite Legacy-Imports.",
        "InputPromptCapsule", ["reta_architecture/input_semantics.py", "reta_architecture/row_filtering.py"],
        ["Morphismen", "Restriktion auf Zeilenkontexte"], "Stages 4, 21-22",
        "center.py still exports legacy names and fallbacks.", "Die Eingabesyntax ist explizit; center.py bleibt Kompatibilitäts- und Fallback-Ort.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/LibRetaPrompt.py", "Prompt-Vokabular, Completion-Listen, promptsprachliche Hilfen und importzeitlicher Programmbau.",
        "InputPromptCapsule", ["reta_architecture/input_semantics.py", "reta_architecture/prompt_runtime.py", "reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"],
        ["Prägarbe für Prompt-Zustand", "Prompt-Funktor", "Morphismen"], "Stages 4, 6-8",
        "LibRetaPrompt.py is now a thin compatibility facade.", "Der frühere Importzeit-Bootstrap wurde durch Architektur-Bundles ersetzt.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/nestedAlx.py", "Prompt-Completion-UI und verschachtelte Prompt-Hilfen.",
        "InputPromptCapsule", ["reta_architecture/completion_runtime.py", "reta_architecture/prompt_language.py"],
        ["Completion-Funktor", "Prompt-Sprachmorphismus"], "Stages 7-8",
        "nestedAlx.py consumes explicit prompt bundles.", "Nested UI bleibt Legacy-Consumer, aber nicht mehr Besitzer der Completion-Semantik.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/lib4tables.py", "Output-Syntaxklassen, Formatdetails und einzelne mathematische Hilfen.",
        "OutputRenderingCapsule + TableCoreCapsule", ["reta_architecture/output_syntax.py", "reta_architecture/output_semantics.py", "reta_architecture/number_theory.py"],
        ["Renderer-Morphismus", "OutputFormatCategory", "Zahlen-Morphismus"], "Stages 5, 23-24",
        "lib4tables.py remains a facade for legacy syntax names.", "Syntax und Semantik der Ausgabe sind getrennt; Zahlenhilfen gehören zur Tabellen-Morphismik.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/tableHandling.py", "Tables-God-Object, verschachtelte Output-/Combi-/Maintable-Logik und mutable Tabellenzustände.",
        "TableCoreCapsule + GeneratedRelationCapsule + OutputRenderingCapsule", ["reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_output.py", "reta_architecture/combi_join.py", "reta_architecture/generated_columns.py"],
        ["globale Garbensektion", "Endofunktor", "TableRuntimeToStateSectionsTransformation"], "Stages 20-21, 25-26",
        "libs/tableHandling.py re-exports compatible classes.", "Tables bleibt sichtbar, aber nicht mehr als unstrukturierter Besitzer aller Zustände und Operationen.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/lib4tables_prepare.py", "Prepare-Klasse mit Zeilenfiltern, Bereichslogik, Tabellenumbruch und Prepare-Ausgabe.",
        "TableCoreCapsule", ["reta_architecture/table_preparation.py", "reta_architecture/row_filtering.py", "reta_architecture/table_wrapping.py"],
        ["Tabellen-Morphismus", "Zeilenfilter-Morphismus", "universelle Vorbereitung"], "Stages 16, 22-23",
        "Prepare remains as delegation facade.", "Prepare wird von einer Implementierungsklasse zu einem Legacy-Adapter auf getrennte Morphismen.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/lib4tables_concat.py", "Generated Columns, Meta-Spalten, Bruch-/CSV-Gluing und Concat-Hilfen.",
        "GeneratedRelationCapsule", ["reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py", "reta_architecture/concat_csv.py", "reta_architecture/combi_join.py"],
        ["Endofunktor", "CSV-Prägarben-Gluing", "GeneratedColumnEndomorphismCategory"], "Stages 17-19, 21",
        "Concat remains as compatibility wrapper.", "Concat-Methoden sind jetzt benannte Tabellenendomorphismen oder Gluing-Morphismen.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/lib4tables_Enum.py", "Tabellen-Tags und enumartige Markierungen.",
        "SchemaTopologyCapsule + GeneratedRelationCapsule", ["reta_architecture/tag_schema.py", "reta_architecture/schema.py", "reta_architecture/generated_columns.py", "reta_architecture/table_state.py"],
        ["Topologie-Tags", "Generated-column metadata", "Garbe"], "Stages 1, 17, 26",
        "Enum names stay import-compatible.", "Tags sind Teil der Kontext-Topologie und zugleich Metadaten der generierten Spalten.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_contracts.py", "Stage-29 Architekturverträge, kommutierende Quadrate, Kapselgrenzen und Referenzchecks über Kategorie- und Kapselkarte.",
        "CategoricalMetaCapsule", ["reta_architecture/architecture_contracts.py", "reta_architecture/category_theory.py", "reta_architecture/architecture_map.py"],
        ["kommutierendes Diagramm", "natürliche Transformation", "Refactor-Gesetz"], "Stage 29",
        "architecture-contracts-json and architecture-contracts-md expose the layer.", "Diese Datei besitzt keine Runtime-Semantik; sie hält fest, welche Pfade beim weiteren Umbau kommutieren müssen.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_witnesses.py", "Stage-30 Witness-Matrix für Kapseln, Diagramme, natürliche Transformationen und Refactor-Gesetze.",
        "CategoricalMetaCapsule", ["reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_contracts.py", "tests/test_architecture_refactor.py"],
        ["Witness", "Proof obligation", "natürliche Transformation"], "Stage 30",
        "architecture-witnesses-json and architecture-witnesses-md expose the layer.", "Diese Datei verbindet die mathematischen Verträge mit konkreten Repository-Ankern und Probe-Kommandos.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_validation.py", "Ausführbare Validierung über Kategorie-, Karten-, Vertrags-, Witness-, Paket- und Markdown-Schicht.",
        "CategoricalMetaCapsule", ["reta_architecture/architecture_validation.py", "reta_architecture/facade.py", "reta_architecture_probe_py.py"],
        ["Validierung", "kommutierendes Diagramm", "Proof obligation", "natürliche Transformationen als geprüfte Überlappungen"], "Stage 31",
        "architecture-validation-json and architecture-validation-md expose the layer.", "Die Meta-Architektur ist nicht mehr nur dokumentiert und bezeugt, sondern als Stage-31-Report ausführbar validierbar.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_coherence.py", "Kohärenzmatrix über Kapseln, Routen, natürliche Transformationen und Refactor-Gesetze.",
        "CategoricalMetaCapsule", ["reta_architecture/architecture_coherence.py", "reta_architecture/facade.py", "reta_architecture_probe_py.py"],
        ["Kohärenz", "Funktor-Route", "Natürlichkeitsmatrix", "Refactor-Gesetz"], "Stage 31",
        "architecture-coherence-json and architecture-coherence-md expose the layer.", "Diese Datei beantwortet stufenweise: welche Kapsel, Kategorie, welcher Funktor, welche natürliche Transformation, welches Diagramm, welches Gesetz und welcher Witness hängen an einer Änderung?",
    ))
    mappings.append(RetaPartMappingSpec(
        "readme*.md / doc/*.md", "Benutzerdokumentation zu CLI, Prompt und Startdateien.",
        "LocalSectionCapsule + CategoricalMetaCapsule", ["doc/*.md", "ARCHITECTURE_REFACTOR*.md", "STAGE*_CHANGES.md"],
        ["lokale Dokument-Sektion", "Architekturhistorie"], "Stages 1-28",
        "Documentation files stay data/documentation assets.", "Stage 28 nutzt die Markdown-Historie als Basis für die Kapselkarte.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_traces.py", "not present before Stage 32",
        "CategoricalMetaCapsule", ["ArchitectureTraceBundle"],
        ["Trace", "Functor", "natural transformation"], "Stage 32",
        "architecture-traces-json", "Navigable owner/capsule/category route.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_boundaries.py", "not present before Stage 32",
        "CategoricalMetaCapsule", ["ArchitectureBoundariesBundle"],
        ["Boundary", "Morphism", "category"], "Stage 32",
        "architecture-boundaries-json", "Concrete import boundary graph.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_impact.py", "not present before Stage 33",
        "CategoricalMetaCapsule", ["ArchitectureImpactBundle"],
        ["Impact", "Functor", "natural transformation", "Migration Gate"], "Stage 33",
        "architecture-impact-json", "Impact/gate calculus over trace and boundary morphisms.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_migration.py", "not present before Stage 34",
        "CategoricalMetaCapsule", ["ArchitectureMigrationBundle"],
        ["Migration Plan", "Functor", "natural transformation", "Gate Binding"], "Stage 34",
        "architecture-migration-json", "Migration-plan calculus over Stage-33 impact candidates, gate bindings and wave invariants.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_rehearsal.py", "not present before Stage 35",
        "CategoricalMetaCapsule", ["ArchitectureRehearsalBundle"],
        ["Rehearsal", "Topologie", "Morphism", "Functor", "natural transformation", "Readiness Gate"], "Stage 35",
        "architecture-rehearsal-json", "Dry-run/readiness calculus over Stage-34 migration waves, steps and gate bindings.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_activation.py", "not present before Stage 36",
        "CategoricalMetaCapsule", ["ArchitectureActivationBundle"],
        ["Activation", "Morphism", "Functor", "natural transformation", "Commit Gate", "Rollback Section"], "Stage 36",
        "architecture-activation-json", "Activation/commit/rollback calculus over Stage-35 rehearsal moves.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/center.py", "legacy row-range parser implementation: BereichToNumbers2/isZeilenAngabe",
        "InputPromptCapsule", ["reta_architecture/row_ranges.py", "libs/center.py"],
        ["Topologie", "Morphism", "LocalSection", "Functor", "natural transformation"], "Stage 37",
        "row-ranges-json", "Zeilenbereichslogik ist jetzt echter Architektur-Besitz; center.py ist Kompatibilitätsfassade.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/row_ranges.py", "not present before Stage 37",
        "InputPromptCapsule", ["RowRangeMorphismBundle"],
        ["aktivierter Morphismus", "Prägarben-Sektion", "natürliche Transformation"], "Stage 37",
        "row-ranges-json", "Activated row-range morphisms for input/prompt open sets.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/center.py", "legacy arithmetic implementation: multiples/teiler/primfaktoren/primRepeat/textHatZiffer",
        "InputPromptCapsule", ["reta_architecture/arithmetic.py", "libs/center.py"],
        ["Morphism", "universelle Eigenschaft", "Functor", "natural transformation"], "Stage 38",
        "arithmetic-json", "center-Arithmetik ist jetzt Architektur-Besitz; center.py bleibt Kompatibilitätsfassade.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/arithmetic.py", "not present before Stage 38",
        "InputPromptCapsule", ["ArithmeticMorphismBundle"],
        ["aktivierter Morphismus", "Teiler-Gluing", "natürliche Transformation"], "Stage 38",
        "arithmetic-json", "Activated arithmetic morphisms for center-level factor, divisor and prime helpers.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/center.py", "legacy console/help/debug/utility implementation: retaHilfe/retaPromptHilfe/getTextWrapThings/cliout/x/alxp/chunks/unique_everseen/DefaultOrderedDict",
        "OutputRenderingCapsule", ["reta_architecture/console_io.py", "libs/center.py"],
        ["Morphism", "Prägarbe", "Output-Functor", "natural transformation"], "Stage 39",
        "console-io-json", "center-Console-/Help-/Utility-Logik ist jetzt Architektur-Besitz; center.py bleibt Kompatibilitätsfassade.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/console_io.py", "not present before Stage 39",
        "OutputRenderingCapsule", ["ConsoleIOMorphismBundle"],
        ["aktivierter Output-Morphismus", "Help-Prägarbensektion", "natürliche Transformation"], "Stage 39",
        "console-io-json", "Activated console/help/wrapping/utility morphisms for center-level IO helpers.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/word_completerAlx.py", "legacy prompt WordCompleter implementation: word source resolution, cursor-prefix restriction, prefix/middle matching and Completion yielding",
        "InputPromptCapsule", ["reta_architecture/completion_word.py", "libs/word_completerAlx.py"],
        ["Topologie", "Morphism", "Prägarbe", "Functor", "natural transformation"], "Stage 40",
        "word-completion-json", "Word-completion matching is now architecture-owned; word_completerAlx.py remains a compatibility facade.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/completion_word.py", "not present before Stage 40",
        "InputPromptCapsule", ["WordCompletionMorphismBundle", "ArchitectureWordCompleter"],
        ["aktivierter Prompt-Morphismus", "Cursor-Open-Set", "Completion-Prägarbensektion", "natürliche Transformation"], "Stage 40",
        "word-completion-json", "Activated word-completion morphisms for prompt_toolkit completion matching.",
    ))
    mappings.append(RetaPartMappingSpec(
        "libs/nestedAlx.py", "legacy hierarchical prompt-completion implementation: situation enum, sub-completer selection, equality/comma value expansion and prompt_toolkit completion yielding",
        "InputPromptCapsule", ["reta_architecture/completion_nested.py", "libs/nestedAlx.py"],
        ["Topologie", "Morphism", "universelle Eigenschaft", "Prägarbe", "Functor", "natural transformation"], "Stage 41",
        "nested-completion-json", "Nested prompt completion is now architecture-owned; nestedAlx.py remains a compatibility facade.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/completion_nested.py", "not present before Stage 41",
        "InputPromptCapsule", ["NestedCompletionMorphismBundle", "ArchitectureNestedCompleter", "ComplSitua"],
        ["aktivierter Prompt-Morphismus", "Completion-Open-Set", "Completion-Prägarbensektion", "natürliche Transformation"], "Stage 41",
        "nested-completion-json", "Activated hierarchical completion morphisms for prompt_toolkit nested completion.",
    ))
    mappings.append(RetaPartMappingSpec(
        "reta_architecture/architecture_progress.py", "observed progress overlay that compares the Stage-34 migration plan with the actually extracted compatibility facades, active architecture owners and remaining mixed surfaces",
        "CategoricalMetaCapsule", ["ArchitectureProgressBundle", "MigrationExecutionSpec", "WaveExecutionSpec", "OutstandingWorkItemSpec"],
        ["Topologie", "Morphism", "universelle Eigenschaft", "Prägarbe", "Functor", "natural transformation"], "Stage 42",
        "architecture-progress-json", "Stage 42 does not move runtime behaviour; it turns the migration plan into an explicit current-status overlay.",
    ))
    var steps = List[StageArchitectureStep]()
    steps.append(StageArchitectureStep(
        "Stage 1", "Topologie-/Garben-/Morphismen-Architektur initial angelegt",
        ["implicit monolith layout"], ["topology.py", "presheaves.py", "sheaves.py", "morphisms.py", "universal.py", "facade.py"],
        "SchemaTopologyCapsule + LocalSectionCapsule + SemanticSheafCapsule", "erste Benennung von Topologie, Prägarbe, Garbe, Morphismus und universeller Eigenschaft",
    ))
    steps.append(StageArchitectureStep(
        "Stage 2", "Schema und Parameter-Semantik-Builder",
        ["i18n/words.py", "reta.py storeParamtersForColumns"], ["schema.py", "semantics_builder.py"],
        "SchemaTopologyCapsule + SemanticSheafCapsule", "Schema wird Quelle der Topologie; Semantikaufbau wird Gluing statt Programminline-Code",
    ))
    steps.append(StageArchitectureStep(
        "Stage 3", "Physischer i18n-Split",
        ["i", "1", "8", "n", "/", "w", "o", "r", "d", "s", ".", "p", "y", " ", "m", "o", "n", "o", "l", "i", "t", "h"], ["words_context.py", "words_matrix.py", "words_runtime.py", "words.py facade"],
        "SchemaTopologyCapsule", "Kontext-, Matrix- und Runtime-Sektionen werden getrennt",
    ))
    steps.append(StageArchitectureStep(
        "Stage 4", "Input-Semantik",
        ["center.py", "LibRetaPrompt.py"], ["input_semantics.py", "split_i18n.py"],
        "InputPromptCapsule", "Eingabe-Grammatik wird eigene Morphismenschicht",
    ))
    steps.append(StageArchitectureStep(
        "Stage 5", "Output-Semantik",
        ["reta.py output ladder", "tableHandling output booleans", "lib4tables syntax metadata"], ["output_semantics.py"],
        "OutputRenderingCapsule", "Ausgabemodi werden Renderer-Morphismen statt verstreuter Branches",
    ))
    steps.append(StageArchitectureStep(
        "Stage 6", "Prompt Runtime",
        ["LibRetaPrompt import-time Program"], ["prompt_runtime.py"],
        "InputPromptCapsule", "Prompt-Semantik entsteht aus Architektur statt aus vollem CLI-Programm",
    ))
    steps.append(StageArchitectureStep(
        "Stage 7", "Completion Runtime",
        ["spread prompt completion globals"], ["completion_runtime.py"],
        "InputPromptCapsule", "Completion wird eigene Laufzeitsektion",
    ))
    steps.append(StageArchitectureStep(
        "Stage 8", "Prompt Language",
        ["LibRetaPrompt helper block"], ["prompt_language.py"],
        "InputPromptCapsule", "Prompt-Sprache wird expliziter Morphismenblock",
    ))
    steps.append(StageArchitectureStep(
        "Stage 9", "Prompt Session",
        ["retaPrompt.py session/storage/input shell"], ["prompt_session.py"],
        "InputPromptCapsule", "Interaktive Session wird eigene lokale Zustandssektion",
    ))
    steps.append(StageArchitectureStep(
        "Stage 10", "Prompt Execution",
        ["retaPrompt.py deep command semantics"], ["prompt_execution.py"],
        "InputPromptCapsule", "tiefe Prompt-Kommandos werden ausführende Morphismen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 11", "Prompt Preparation und Paketintegrität",
        ["retaPrompt.py preparation helpers"], ["prompt_preparation.py", "package_integrity.py"],
        "InputPromptCapsule + CompatibilityCapsule", "Vorbereitung und Manifest werden inspizierbare Architekturteile",
    ))
    steps.append(StageArchitectureStep(
        "Stage 12", "Prompt Interaction Controller",
        ["retaPrompt.py interaction loop"], ["prompt_interaction.py"],
        "InputPromptCapsule", "Prompt-Interaktion wird Orchestrationskapsel",
    ))
    steps.append(StageArchitectureStep(
        "Stage 13", "Spaltenauswahl und Tabellen-Gluing",
        ["reta.py column buckets", "reta.py table generation block"], ["column_selection.py", "table_generation.py"],
        "WorkflowGluingCapsule", "Spalten-/Tabellenbau wird universelles Gluing",
    ))
    steps.append(StageArchitectureStep(
        "Stage 14", "Parameter Runtime",
        ["reta.py CLI parser and upper-limit logic"], ["parameter_runtime.py"],
        "WorkflowGluingCapsule", "CLI-Parameter werden kanonische Runtime-Sektion",
    ))
    steps.append(StageArchitectureStep(
        "Stage 15", "Program Workflow",
        ["reta.py orchestration"], ["program_workflow.py"],
        "WorkflowGluingCapsule", "Programmablauf wird Workflow-Diagramm",
    ))
    steps.append(StageArchitectureStep(
        "Stage 16", "Table Preparation",
        ["lib4tables_prepare.py prepare output table"], ["table_preparation.py"],
        "TableCoreCapsule", "Prepare wird Tabellen-Morphismus",
    ))
    steps.append(StageArchitectureStep(
        "Stage 17", "Generated-column Morphismen",
        ["lib4tables_concat.py simple generated methods"], ["generated_columns.py"],
        "GeneratedRelationCapsule", "generierte Spalten werden Tabellen-Endomorphismen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 18", "Schwere generated/meta columns",
        ["lib4tables_concat.py heavy generated/meta blocks"], ["generated_columns.py", "meta_columns.py"],
        "GeneratedRelationCapsule", "Meta-/Generated-Familien werden getrennte Morphismenkategorien",
    ))
    steps.append(StageArchitectureStep(
        "Stage 19", "CSV-/Bruch-Gluing",
        ["lib4tables_concat.py readConcatCsv/fraction helpers"], ["concat_csv.py"],
        "GeneratedRelationCapsule + WorkflowGluingCapsule", "CSV-Prägarben werden über Bruch-/Concat-Morphismen angeklebt",
    ))
    steps.append(StageArchitectureStep(
        "Stage 20", "Table Output",
        ["tableHandling.Tables.Output"], ["table_output.py"],
        "OutputRenderingCapsule", "Rendering wird Output-Morphismus über Tabellen-Sektion",
    ))
    steps.append(StageArchitectureStep(
        "Stage 21", "Combi Join und Gestirn-Spalte",
        ["tableHandling.Tables.Combi", "Maintable.createSpalteGestirn"], ["combi_join.py", "generated_columns.py"],
        "GeneratedRelationCapsule", "Kombi-Relationen werden Join-Morphismen; Gestirn wird Generated-Column-Morphismus",
    ))
    steps.append(StageArchitectureStep(
        "Stage 22", "Zeilenfilter-/Bereichsmorphismen",
        ["lib4tables_prepare.py row/range logic"], ["row_filtering.py"],
        "TableCoreCapsule", "Zeilenkontexte werden explizit gefilterte Sektionen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 23", "Wrapping und Number Theory",
        ["prepare/table formatting helpers", "number-theory helper logic"], ["table_wrapping.py", "number_theory.py"],
        "TableCoreCapsule", "Zellumbruch und Zahlenlogik werden eigene Morphismen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 24", "Output Syntax",
        ["lib4tables.py syntax classes"], ["output_syntax.py"],
        "OutputRenderingCapsule", "Ausgabe-Syntax wird von Ausgabe-Semantik getrennt",
    ))
    steps.append(StageArchitectureStep(
        "Stage 25", "Table Runtime",
        ["libs/tableHandling.py Tables owner"], ["table_runtime.py"],
        "TableCoreCapsule", "Tables wird globale Tabellensektion in der Architektur",
    ))
    steps.append(StageArchitectureStep(
        "Stage 26", "Explizite Table State Sections",
        ["mutable fields inside Tables"], ["table_state.py"],
        "TableCoreCapsule", "mutable Tabellenzustände werden explizite Sektionen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 27", "Kategorien, Funktoren, natürliche Transformationen",
        ["implicit categorical structure"], ["category_theory.py"],
        "CategoricalMetaCapsule", "kommutierende Architekturpfade werden benannt",
    ))
    steps.append(StageArchitectureStep(
        "Stage 28", "Gesamtarchitektur als Kapselkarte",
        ["scattered stage documentation", "pure name list of math objects"], ["architecture_map.py", "architecture-map-json", "architecture-diagram-md"],
        "CategoricalMetaCapsule", "Topologie/Morphismen/Gluing/Garben/Kategorien/Funktoren/Transformationen werden als Schichten- und Datenflussdiagramm sichtbar",
    ))
    steps.append(StageArchitectureStep(
        "Stage 29", "Kommutierende Diagramme und Architekturgesetze",
        ["implicit naturality/parity contracts"], ["architecture_contracts.py", "architecture-contracts-json", "architecture-contracts-md"],
        "CategoricalMetaCapsule", "natürliche Transformationen werden als prüfbare kommutierende Refactor-Pfade und Gesetze sichtbar",
    ))
    steps.append(StageArchitectureStep(
        "Stage 30", "Witness-Matrix und konkrete Nachweise",
        ["symbolic contracts without repository witness matrix"], ["architecture_witnesses.py", "architecture-witnesses-json", "architecture-witnesses-md"],
        "CategoricalMetaCapsule", "Kategorien/Funktoren/natürliche Transformationen werden an konkrete reta-Dateien, Kapseln, Probes und Tests rückgebunden",
    ))
    steps.append(StageArchitectureStep(
        "Stage 31", "Ausführbare Architekturvalidierung",
        ["separate category/map/contract/witness layers"], ["architecture_validation.py", "architecture-validation-json", "architecture-validation-md", "architecture-coherence-json", "architecture-coherence-md"],
        "CategoricalMetaCapsule", "Kategorien, Funktoren, natürliche Transformationen, Diagramme, Witnesses, Paketintegrität und Markdown-Historie werden als ein Validierungsbericht geprüft",
    ))
    steps.append(StageArchitectureStep(
        "Stage 32", "Trace-Navigation und Boundary-Importgraph",
        ["coherence matrix without direct old-owner navigation", "real Python imports not yet classified as capsule crossings"], ["architecture_traces.py", "architecture-traces-json", "architecture-traces-md", "architecture_boundaries.py", "architecture-boundaries-json", "architecture-boundaries-md"],
        "CategoricalMetaCapsule", "alte reta-Komponenten werden als Trace-Graph verfolgbar; reale Python-Importe werden als Kapselgrenzen geprüft",
    ))
    steps.append(StageArchitectureStep(
        "Stage 33", "Impact- und Migration-Gate-Schicht",
        ["trace routes and import boundaries are visible but not yet converted into change gates"], ["architecture_impact.py", "architecture-impact-json", "architecture-impact-md", "TraceBoundaryImpactSquare", "ImpactGateValidationSquare", "ArchitectureImpactGateLaw"],
        "CategoricalMetaCapsule", "Stage-32-Traces und Boundaries werden zu Impact-Routen; spätere Umbauten müssen über Gate-Probes und natürliche Transformationen laufen",
    ))
    steps.append(StageArchitectureStep(
        "Stage 34", "Migration-Plan und Gate-Binding",
        ["impact candidates and regression gates visible but not yet ordered into waves"], ["architecture_migration.py", "architecture-migration-json", "architecture-migration-md", "ImpactMigrationPlanningSquare", "MigrationGateCoherenceSquare", "ArchitectureMigrationOrderingLaw"],
        "CategoricalMetaCapsule", "Stage-33-Impact-Kandidaten werden zu geordneten, gate-geschützten Migrationswellen; spätere Extraktionen erhalten klare Exit-Kriterien",
    ))
    steps.append(StageArchitectureStep(
        "Stage 35", "Rehearsal-/Readiness-Schicht",
        ["ordered migration plan without dry-run moves"], ["architecture_rehearsal.py", "architecture-rehearsal-json", "architecture-rehearsal-md", "MigrationRehearsalSquare", "RehearsalReadinessValidationSquare", "ArchitectureRehearsalReadinessLaw"],
        "CategoricalMetaCapsule", "Stage-34-Migrationsschritte werden zu topologischen Trockenlauf-Umgebungen, Refactor-Morphismen, Gate-Suites und universellen Readiness-Covers",
    ))
    steps.append(StageArchitectureStep(
        "Stage 36", "Activation-/Commit-/Rollback-Schicht",
        ["rehearsal/readiness moves without activation envelope"], ["architecture_activation.py", "architecture-activation-json", "architecture-activation-md", "RehearsalActivationSquare", "ActivationRollbackValidationSquare", "ArchitectureActivationCommitLaw"],
        "CategoricalMetaCapsule", "Stage-35-Rehearsal-Moves werden zu commit-geschützten Aktivierungsfenstern, Rollback-Sektionen und universell geklebten Transaktionen; weiterhin ohne Runtime-Verhaltensänderung",
    ))
    steps.append(StageArchitectureStep(
        "Stage 37", "Aktivierte Row-Range-Morphismen",
        ["Stage-36 activation envelopes existed but no runtime logic had been moved by that activation path"], ["row_ranges.py", "row-ranges-json", "CenterRowRangeCompatibilitySquare", "ActivatedRowRangeLaw"],
        "InputPromptCapsule", "Erster echter Aktivierungsschritt: BereichToNumbers2/isZeilenAngabe/Generator-Literal-Parsing wandern aus center.py in RowRangeMorphismBundle; center.py bleibt Legacy-Fassade",
    ))
    steps.append(StageArchitectureStep(
        "Stage 38", "Aktivierte Arithmetik-Morphismen",
        ["Stage-37 row-range activation existed but center-level arithmetic still owned its own algorithms"], ["arithmetic.py", "arithmetic-json", "CenterArithmeticCompatibilitySquare", "ActivatedArithmeticLaw"],
        "InputPromptCapsule", "Zweiter echter Aktivierungsschritt: multiples/teiler/primfaktoren/primRepeat/textHatZiffer wandern aus center.py in ArithmeticMorphismBundle; center.py bleibt Legacy-Fassade",
    ))
    steps.append(StageArchitectureStep(
        "Stage 39", "Aktivierte Console-/Help-/Utility-Morphismen",
        ["Stage-38 arithmetic activation existed but center-level console/help/wrapping/utility helpers still owned their own algorithms"], ["console_io.py", "console-io-json", "CenterConsoleIOCompatibilitySquare", "ActivatedConsoleIOLaw"],
        "OutputRenderingCapsule + InputPromptCapsule", "Dritter echter Aktivierungsschritt: retaHilfe/retaPromptHilfe/getTextWrapThings/cliout/x/alxp/chunks/unique_everseen/DefaultOrderedDict wandern aus center.py in ConsoleIOMorphismBundle; center.py bleibt Legacy-Fassade",
    ))
    steps.append(StageArchitectureStep(
        "Stage 40", "Aktivierte Word-Completion-Morphismen",
        ["Stage-39 console/io activation existed but word_completerAlx still owned its matching algorithm"], ["completion_word.py", "word-completion-json", "WordCompleterCompatibilitySquare", "ActivatedWordCompletionLaw"],
        "InputPromptCapsule", "Vierter echter Aktivierungsschritt: WordCompleter wandert aus word_completerAlx.py in WordCompletionMorphismBundle; word_completerAlx.py bleibt Legacy-Fassade",
    ))
    steps.append(StageArchitectureStep(
        "Stage 41", "Aktivierte Nested-Completion-Morphismen",
        ["Stage-40 word completion was activated but nestedAlx still owned hierarchical completion transitions"], ["completion_nested.py", "nested-completion-json", "NestedCompleterCompatibilitySquare", "ActivatedNestedCompletionLaw"],
        "InputPromptCapsule", "Fünfter echter Aktivierungsschritt: NestedCompleter wandert aus nestedAlx.py in NestedCompletionMorphismBundle; nestedAlx.py bleibt Legacy-Fassade",
    ))
    steps.append(StageArchitectureStep(
        "Stage 42", "Architektur-Fortschritt als explizite Statusschicht",
        ["Stage-34 migration metadata still described all moves as planned even though Stage-37 to Stage-41 had already activated several runtime owners"], ["architecture_progress.py", "architecture-progress-json", "architecture-progress-md", "ARCHITECTURE_STATUS_STAGE42.md"],
        "CategoricalMetaCapsule", "Stage 42 legt eine explizite Fortschritts- und Bestandsaufnahmeschicht über den Migrationsplan: sie markiert reale Kompatibilitätsfassaden, aktive Architektur-Owner und die wenigen verbleibenden gemischten Rest-Owner.",
    ))
    var audit = MarkdownAuditSpec(
        "Stage-27 repository package plus the newly uploaded tarball check",
        58,
        0,
        ["ARCHITECTURE_REFACTOR*.md", "STAGE*_CHANGES.md", "PACKAGE_AUDIT_STAGE*.md", "readme-reta*.md", "readme-retaPrompt*.md", "readme-startFiles.md"],
        "The uploaded retaPyNewArch.tar.bz2 contains no Markdown files in this environment; Stage 28 is therefore based on the Stage-27 package Markdown history and records the tarball discrepancy explicitly.",
    )
    return ArchitectureMapBundle(
        capsules^, containment^, flows^, mappings^, steps^,
        "```mermaid\nflowchart TD\n    Legacy[Legacy surfaces<br/>reta.py / retaPrompt.py / libs] --> Root[RetaArchitectureRoot]\n    Root --> Schema[SchemaTopologyCapsule<br/>schema + open contexts]\n    Schema --> Presheaf[LocalSectionCapsule<br/>CSV/doc/prompt presheaves]\n    Presheaf -->|PresheafToSheafGluingTransformation| Sheaf[SemanticSheafCapsule<br/>canonical semantic sheaves]\n    Input[InputPromptCapsule<br/>CLI/prompt raw text] -->|RawToCanonicalParameterTransformation| Sheaf\n    Sheaf -->|TableGenerationGluingTransformation| Workflow[WorkflowGluingCapsule<br/>parameter runtime + columns + table generation]\n    Workflow --> Table[TableCoreCapsule<br/>Tables + explicit state sections]\n    Table -->|GeneratedColumnEndofunctorFamily| Generated[GeneratedRelationCapsule<br/>generated/meta/concat/combi]\n    Generated -->|GeneratedColumnsSheafSyncTransformation| Table\n    Table -->|OutputRenderingFunctorFamily| Output[OutputRenderingCapsule<br/>shell/md/html/csv/...]\n    Output -->|RenderedOutputNormalizationTransformation| Parity[CompatibilityCapsule<br/>legacy parity]\n    Legacy -->|LegacyToArchitectureTransformation| Parity\n    Meta[CategoricalMetaCapsule<br/>categories/functors/natural transformations/map/laws/witnesses/validation/coherence/traces/boundaries/impact/migration/rehearsal/activation/activated row ranges/arithmetic/console io/nested completion] -. describes .-> Root\n    Meta -. describes .-> Schema\n    Meta -. describes .-> Sheaf\n    Meta -. describes .-> Table\n    Meta -. law checks .-> Parity\n    Meta -. witness matrix .-> Parity\n    Meta -. validation report .-> Root\n    Meta -. coherence matrix .-> Root\n    Meta -->|CoherenceToTraceFunctor| Root\n    Meta -->|CoherenceToBoundaryFunctor| Root\n    Meta -->|TraceBoundaryImpactFunctor| Root\n    Meta -->|ImpactGateValidationFunctor| Root\n    Meta -->|ImpactToMigrationPlanFunctor| Root\n    Meta -->|MigrationGateCoherenceFunctor| Parity\n    Meta -->|MigrationStepRehearsalFunctor| Root\n    Meta -->|MigrationGateRehearsalFunctor| Workflow\n    Meta -->|RehearsalCoverFunctor| Schema\n    Meta -->|RehearsalGateValidationFunctor| Parity\n    Meta -->|RehearsalReadinessCoherenceFunctor| Meta\n    Meta -->|RehearsalActivationFunctor| Root\n    Meta -->|GateActivationFunctor| Parity\n    Meta -->|ActivationTransactionFunctor| Workflow\n    Meta -->|ActivationRollbackFunctor| Meta\n    Meta -->|ActivationValidationFunctor| Parity\n    Meta -->|ActivationCoherenceFunctor| Meta\n    Meta -->|RowRangeActivationFunctor| Input\n    Legacy -->|CenterRowRangeCompatibilityFunctor| Input\n    Input -->|RowRangeInputFunctor| Presheaf\n    Input -->|RowRangeValidationFunctor| Meta\n    Meta -->|ArithmeticActivationFunctor| Input\n    Legacy -->|CenterArithmeticCompatibilityFunctor| Input\n    Input -->|ArithmeticValidationFunctor| Meta\n    Meta -->|ConsoleIOActivationFunctor| Output\n    Legacy -->|CenterConsoleIOCompatibilityFunctor| Output\n    Output -->|ConsoleIOOutputValidationFunctor| Meta\n    Meta -->|WordCompletionActivationFunctor| Input\n    Legacy -->|LegacyWordCompleterCompatibilityFunctor| Input\n    Input -->|WordCompletionValidationFunctor| Meta\n    Meta -->|NestedCompletionActivationFunctor| Input\n    Legacy -->|LegacyNestedCompleterCompatibilityFunctor| Input\n    Input -->|NestedCompletionValidationFunctor| Meta\n    Meta -. validation report .-> Root\n```\n", "RetaArchitectureRoot\n├─ SchemaTopologyCapsule\n│  ├─ i18n words_context / words_matrix / words_runtime\n│  ├─ RetaContextSchema\n│  └─ RetaContextTopology + ContextSelection\n├─ LocalSectionCapsule\n│  ├─ CSV / docs / translations / prompt raw state\n│  └─ PresheafBundle(LocalSection, FilesystemPresheaf, PromptStatePresheaf)\n├─ SemanticSheafCapsule\n│  ├─ ParameterSemanticsSheaf\n│  ├─ GeneratedColumnsSheaf\n│  ├─ TableOutputSheaf\n│  └─ HtmlReferenceSheaf\n├─ InputPromptCapsule\n│  ├─ InputBundle + RowRangeSyntax + PromptVocabulary\n│  ├─ RowRangeMorphismBundle = activated row-range parser\n│  ├─ ArithmeticMorphismBundle = activated center arithmetic\n│  ├─ ConsoleIOMorphismBundle = activated center console/help utilities\n│  ├─ WordCompletionMorphismBundle = activated word-completion matching\n│  ├─ NestedCompletionMorphismBundle = activated hierarchical prompt completion\n│  ├─ PromptRuntime + CompletionRuntime + PromptLanguage\n│  └─ PromptSession + PromptExecution + PromptPreparation + PromptInteraction\n├─ WorkflowGluingCapsule\n│  ├─ ParameterRuntime\n│  ├─ ColumnSelection\n│  ├─ ProgramWorkflow\n│  └─ TableGeneration + UniversalBundle\n├─ TableCoreCapsule\n│  ├─ TableRuntime.Tables = global table section\n│  ├─ TableStateSections = explicit mutable sections\n│  ├─ TablePreparation + RowFiltering + Wrapping\n│  └─ NumberTheory\n├─ GeneratedRelationCapsule\n│  ├─ GeneratedColumns + MetaColumns\n│  ├─ ConcatCsv / fractional CSV gluing\n│  └─ KombiJoin\n├─ OutputRenderingCapsule\n│  ├─ OutputSyntax\n│  ├─ OutputSemantics\n│  ├─ ConsoleIOMorphismBundle = activated console/help/wrapping output service\n│  └─ TableOutput renderers\n├─ CompatibilityCapsule\n│  ├─ reta.py / retaPrompt.py\n│  ├─ libs compatibility facades\n│  └─ parity + package integrity\n└─ CategoricalMetaCapsule\n   ├─ CategoryTheoryBundle\n   ├─ ArchitectureMapBundle\n   ├─ ArchitectureContractsBundle\n   ├─ ArchitectureWitnessBundle\n   ├─ ArchitectureCoherenceBundle\n   ├─ ArchitectureValidationBundle\n   ├─ ArchitectureTraceBundle\n   ├─ ArchitectureBoundariesBundle\n   ├─ ArchitectureImpactBundle\n   ├─ ArchitectureMigrationBundle\n   ├─ ArchitectureRehearsalBundle\n   └─ ArchitectureActivationBundle\n", audit^,
    )
