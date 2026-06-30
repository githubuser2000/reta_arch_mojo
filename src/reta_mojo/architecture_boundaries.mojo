"""Generated native Mojo representation of reta_architecture.architecture_boundaries.
The Python reference scans its source tree at generation time. Runtime lookup,
validation access and capsule navigation are fully native Mojo. Regenerate with
tools/generate_architecture_boundaries.py after changing Python module ownership.
"""

from std.collections import List

@fieldwise_init
struct ModuleOwnershipSpec(Copyable):
    var path: String
    var capsule: String
    var owner_kind: String
    var reason: String

@fieldwise_init
struct ImportEdgeSpec(Copyable):
    var importer: String
    var imported: String
    var importer_capsule: String
    var imported_capsule: String
    var import_kind: String
    var categorical_kind: String
    var allowed: Bool
    var reason: String

@fieldwise_init
struct CapsuleImportEdgeSpec(Copyable):
    var source_capsule: String
    var target_capsule: String
    var edge_count: Int
    var categorical_kind: String
    var representative_imports: List[String]

@fieldwise_init
struct CapsuleBoundarySpec(Copyable):
    var capsule: String
    var owns_modules: List[String]
    var allowed_outbound_capsules: List[String]
    var inbound_capsules: List[String]
    var boundary_reading: String

@fieldwise_init
struct BoundaryCheckSpec(Copyable):
    var name: String
    var status: String
    var failed_items: List[String]
    var checked_count: Int
    var reading: String

@fieldwise_init
struct BoundaryValidationSpec(Copyable):
    var status: String
    var violation_edges: List[String]
    var unresolved_internal_imports: List[String]
    var unowned_scanned_paths: List[String]
    var missing_capsule_boundaries: List[String]
    var checks: List[BoundaryCheckSpec]

@fieldwise_init
struct Stage32BoundaryPlan(Copyable):
    var planned_after_stage_31: List[String]
    var implemented_in_stage_32: List[String]
    var inherited_from_previous_stages: List[String]
    var behaviour_change: String

@fieldwise_init
struct ArchitectureBoundariesBundle(Copyable):
    var module_ownership: List[ModuleOwnershipSpec]
    var import_edges: List[ImportEdgeSpec]
    var capsule_edges: List[CapsuleImportEdgeSpec]
    var capsule_boundaries: List[CapsuleBoundarySpec]
    var validation: BoundaryValidationSpec
    var text_diagram: String
    var mermaid_diagram: String
    var plan: Stage32BoundaryPlan

def ownership_index(bundle: ArchitectureBoundariesBundle, path: String) -> Int:
    for index in range(len(bundle.module_ownership)):
        if bundle.module_ownership[index].path == path:
            return index
    return -1

def capsule_boundary_index(bundle: ArchitectureBoundariesBundle, capsule: String) -> Int:
    for index in range(len(bundle.capsule_boundaries)):
        if bundle.capsule_boundaries[index].capsule == capsule:
            return index
    return -1

def boundary_check_index(bundle: ArchitectureBoundariesBundle, name: String) -> Int:
    for index in range(len(bundle.validation.checks)):
        if bundle.validation.checks[index].name == name:
            return index
    return -1

def boundary_validation_passed(bundle: ArchitectureBoundariesBundle) -> Bool:
    if bundle.validation.status != "passed":
        return False
    for index in range(len(bundle.validation.checks)):
        if bundle.validation.checks[index].status != "passed":
            return False
    return True

def architecture_boundaries_count_line(bundle: ArchitectureBoundariesBundle) -> String:
    return (
        "module_ownership=" + String(len(bundle.module_ownership))
        + " import_edges=" + String(len(bundle.import_edges))
        + " capsule_edges=" + String(len(bundle.capsule_edges))
        + " capsule_boundaries=" + String(len(bundle.capsule_boundaries))
        + " checks=" + String(len(bundle.validation.checks))
    )

def bootstrap_architecture_boundaries() -> ArchitectureBoundariesBundle:
    var ownership = List[ModuleOwnershipSpec]()
    ownership.append(ModuleOwnershipSpec("csv/2024-07-06-symbols-alt-ak-circle-sphere-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-dualism-trinities-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-gebrochen-rational-emotionen.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-gebrochen-rational-galaxie.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-gebrochen-rational-strukturgroesse.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-gebrochen-rational-universum.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kombi-gedanken17-absichten13-bewusstsein15.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kombi-meta-systeme.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kombi-meta.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kombi-universelle-wirklichkeit.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kombi.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-kreisVomTyp18.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-meaningOfLife.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-primenumbers.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-religion.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-sunMoonEtc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/cn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/dualism-trinities-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-dualism-trinities-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-gebrochen-rational-emotionen.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-gebrochen-rational-galaxie.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-gebrochen-rational-strukturgroesse.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-gebrochen-rational-universum.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kombi-gedanken17-absichten13-bewusstsein15.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kombi-meta-systeme.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kombi-meta.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kombi-universelle-wirklichkeit.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kombi.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-kreisVomTyp18.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-meaningOfLife.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-primenumbers.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-religion.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/en-sunMoonEtc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/gebrochen-rational-emotionen.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/gebrochen-rational-galaxie.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/gebrochen-rational-strukturgroesse.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/gebrochen-rational-universum.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kombi-gedanken17-absichten13-bewusstsein15.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kombi-meta-systeme.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kombi-meta.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kombi-universelle-wirklichkeit.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kombi.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-dualism-trinities-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-gebrochen-rational-emotionen.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-gebrochen-rational-galaxie.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-gebrochen-rational-strukturgroesse.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-gebrochen-rational-universum.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kombi-gedanken17-absichten13-bewusstsein15.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kombi-meta-systeme.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kombi-meta.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kombi-universelle-wirklichkeit.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kombi.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-kreisVomTyp18.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-meaningOfLife.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-primenumbers.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-religion.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-sunMoonEtc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kr-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/kreisVomTyp18.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/meaningOfLife.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/primenumbers.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/religion.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/sunMoonEtc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-dualism-trinities-etc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-gebrochen-rational-emotionen.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-gebrochen-rational-galaxie.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-gebrochen-rational-strukturgroesse.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-gebrochen-rational-universum.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kombi-gedanken17-absichten13-bewusstsein15.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kombi-meta-systeme.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kombi-meta.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kombi-universelle-wirklichkeit.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kombi.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-kreisVomTyp18.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-meaningOfLife.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-primenumbers.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-religion.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-sunMoonEtc.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("csv/vn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("doc/readme-reta-en.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("doc/readme-reta.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("doc/readme-retaPrompt-en.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("doc/readme-retaPrompt.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("doc/readme-startFiles.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("i18n/words_context.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("i18n/words_matrix.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("i18n/words_runtime.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/LibRetaPrompt.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/lib4tables.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/lib4tables_concat.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/lib4tables_prepare.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/nestedAlx.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("libs/tableHandling.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("readme-reta-en.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("readme-reta.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("readme-retaPrompt-en.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("readme-retaPrompt.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("readme-startFiles.md", "LocalSectionCapsule", "glob", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("retaPrompt.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/__init__.py", "RetaArchitectureRoot", "declared", "declared by RetaArchitectureRoot.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_activation.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_boundaries.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_coherence.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_contracts.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_impact.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_map.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_migration.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_progress.py", "CategoricalMetaCapsule", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_rehearsal.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_traces.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_validation.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/architecture_witnesses.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/arithmetic.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/category_theory.py", "CategoricalMetaCapsule", "declared", "declared by CategoricalMetaCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/column_selection.py", "WorkflowGluingCapsule", "declared", "declared by WorkflowGluingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/combi_join.py", "GeneratedRelationCapsule", "declared", "declared by GeneratedRelationCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/completion_nested.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/completion_runtime.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/completion_word.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/concat_csv.py", "GeneratedRelationCapsule", "declared", "declared by GeneratedRelationCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/console_io.py", "OutputRenderingCapsule", "declared", "declared by OutputRenderingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/execution_network.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/facade.py", "RetaArchitectureRoot", "declared", "declared by RetaArchitectureRoot.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/generated_columns.py", "GeneratedRelationCapsule", "declared", "declared by GeneratedRelationCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/input_semantics.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/meta_columns.py", "GeneratedRelationCapsule", "declared", "declared by GeneratedRelationCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/morphisms.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/number_theory.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/output_semantics.py", "OutputRenderingCapsule", "declared", "declared by OutputRenderingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/output_syntax.py", "OutputRenderingCapsule", "declared", "declared by OutputRenderingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/package_integrity.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/parallel_execution.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/parameter_runtime.py", "WorkflowGluingCapsule", "declared", "declared by WorkflowGluingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/persistence.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/presheaves.py", "LocalSectionCapsule", "declared", "declared by LocalSectionCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/program_workflow.py", "WorkflowGluingCapsule", "declared", "declared by WorkflowGluingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_execution.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_interaction.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_language.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_preparation.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_runtime.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/prompt_session.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/row_filtering.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/row_ranges.py", "InputPromptCapsule", "declared", "declared by InputPromptCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/runtime_compat.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/schema.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/semantics_builder.py", "SemanticSheafCapsule", "declared", "declared by SemanticSheafCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/sheaves.py", "SemanticSheafCapsule", "declared", "declared by SemanticSheafCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/split_i18n.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_adapters.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_generation.py", "WorkflowGluingCapsule", "declared", "declared by WorkflowGluingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_output.py", "OutputRenderingCapsule", "declared", "declared by OutputRenderingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_preparation.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_runtime.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_state.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/table_wrapping.py", "TableCoreCapsule", "declared", "declared by TableCoreCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/tag_schema.py", "RetaArchitectureRoot", "scanned", "scanned architecture module"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/topology.py", "SchemaTopologyCapsule", "declared", "declared by SchemaTopologyCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("reta_architecture/universal.py", "WorkflowGluingCapsule", "declared", "declared by WorkflowGluingCapsule.code_owners"))
    ownership.append(ModuleOwnershipSpec("tests/test_command_parity.py", "CompatibilityCapsule", "declared", "declared by CompatibilityCapsule.code_owners"))
    var import_edges = List[ImportEdgeSpec]()
    import_edges.append(ImportEdgeSpec(
        "i18n/words_matrix.py", "i18n/words_context.py",
        "SchemaTopologyCapsule", "SchemaTopologyCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "i18n/words_runtime.py", "i18n/words_matrix.py",
        "SchemaTopologyCapsule", "SchemaTopologyCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/LibRetaPrompt.py", "reta_architecture/__init__.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables.py", "reta_architecture/output_syntax.py",
        "CompatibilityCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables.py", "reta_architecture/number_theory.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_concat.py", "libs/lib4tables.py",
        "CompatibilityCapsule", "CompatibilityCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_concat.py", "reta_architecture/__init__.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_concat.py", "reta_architecture/__init__.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_concat.py", "reta_architecture/__init__.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_prepare.py", "libs/lib4tables.py",
        "CompatibilityCapsule", "CompatibilityCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_prepare.py", "reta_architecture/table_preparation.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_prepare.py", "reta_architecture/row_filtering.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/lib4tables_prepare.py", "reta_architecture/table_wrapping.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/nestedAlx.py", "reta_architecture/completion_nested.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/tableHandling.py", "libs/lib4tables_prepare.py",
        "CompatibilityCapsule", "CompatibilityCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/tableHandling.py", "reta_architecture/number_theory.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/tableHandling.py", "reta_architecture/output_syntax.py",
        "CompatibilityCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "libs/tableHandling.py", "reta_architecture/table_runtime.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta.py", "reta_architecture/__init__.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta.py", "reta_architecture/parallel_execution.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta.py", "reta_architecture/parameter_runtime.py",
        "CompatibilityCapsule", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta.py", "reta_architecture/output_syntax.py",
        "CompatibilityCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta.py", "reta_architecture/number_theory.py",
        "CompatibilityCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "libs/LibRetaPrompt.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "libs/nestedAlx.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "reta_architecture/__init__.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "reta_architecture/parallel_execution.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "reta_architecture/prompt_execution.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "retaPrompt.py", "reta_architecture/prompt_interaction.py",
        "CompatibilityCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_activation.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_activation.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_activation.py", "reta_architecture/architecture_rehearsal.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_activation.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_coherence.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_coherence.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_contracts.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_boundaries.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_coherence.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_traces.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_impact.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_migration.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_migration.py", "reta_architecture/architecture_impact.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_migration.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_migration.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_progress.py", "reta_architecture/architecture_activation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_progress.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_impact.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_rehearsal.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/architecture_coherence.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_traces.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_witnesses.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_traces.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_boundaries.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_impact.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_migration.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_rehearsal.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/architecture_activation.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/row_ranges.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/arithmetic.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/console_io.py",
        "CategoricalMetaCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/completion_word.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/completion_nested.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/package_integrity.py",
        "CategoricalMetaCapsule", "CompatibilityCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/completion_word.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_validation.py", "reta_architecture/completion_nested.py",
        "CategoricalMetaCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_contracts.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_witnesses.py", "reta_architecture/architecture_map.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/architecture_witnesses.py", "reta_architecture/category_theory.py",
        "CategoricalMetaCapsule", "CategoricalMetaCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/arithmetic.py", "reta_architecture/row_ranges.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/arithmetic.py", "reta_architecture/parallel_execution.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "reta_architecture/output_syntax.py",
        "GeneratedRelationCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "reta_architecture/runtime_compat.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "reta_architecture/table_wrapping.py",
        "GeneratedRelationCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "i18n/words_runtime.py",
        "GeneratedRelationCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "reta_architecture/parallel_execution.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/combi_join.py", "reta_architecture/parallel_execution.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/completion_word.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/input_semantics.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/row_ranges.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/split_i18n.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/completion_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_nested.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_runtime.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_runtime.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/completion_runtime.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/concat_csv.py", "reta_architecture/runtime_compat.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/input_semantics.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/row_ranges.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/arithmetic.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/console_io.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/completion_word.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/completion_nested.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/column_selection.py",
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/output_semantics.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/output_syntax.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_generation.py",
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/generated_columns.py",
        "RetaArchitectureRoot", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/meta_columns.py",
        "RetaArchitectureRoot", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/concat_csv.py",
        "RetaArchitectureRoot", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/combi_join.py",
        "RetaArchitectureRoot", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_preparation.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_wrapping.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_state.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/parameter_runtime.py",
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/program_workflow.py",
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/morphisms.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/presheaves.py",
        "RetaArchitectureRoot", "LocalSectionCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/schema.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/sheaves.py",
        "RetaArchitectureRoot", "SemanticSheafCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/topology.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/universal.py",
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/category_theory.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_map.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_contracts.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_witnesses.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_validation.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_coherence.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_traces.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_boundaries.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_impact.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_migration.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_rehearsal.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_activation.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/architecture_progress.py",
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/parallel_execution.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/execution_network.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/persistence.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_context.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_matrix.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_runtime.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/tag_schema.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/row_filtering.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_output.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_runtime.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_runtime.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_runtime.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_runtime.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/row_filtering.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_output.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/table_runtime.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_runtime.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/completion_runtime.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_language.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_session.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_execution.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_preparation.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "reta_architecture/prompt_interaction.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/facade.py", "i18n/words_runtime.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/runtime_compat.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/number_theory.py",
        "GeneratedRelationCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/tag_schema.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/number_theory.py",
        "GeneratedRelationCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/runtime_compat.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/generated_columns.py", "reta_architecture/tag_schema.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/input_semantics.py", "reta_architecture/schema.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/meta_columns.py", "reta_architecture/runtime_compat.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/meta_columns.py", "reta_architecture/number_theory.py",
        "GeneratedRelationCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/meta_columns.py", "reta_architecture/tag_schema.py",
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/morphisms.py", "reta_architecture/topology.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/output_semantics.py", "i18n/words_context.py",
        "OutputRenderingCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/output_semantics.py", "reta_architecture/output_syntax.py",
        "OutputRenderingCapsule", "OutputRenderingCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/output_syntax.py", "reta_architecture/number_theory.py",
        "OutputRenderingCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/output_syntax.py", "reta_architecture/split_i18n.py",
        "OutputRenderingCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/package_integrity.py", "reta_architecture/parallel_execution.py",
        "CompatibilityCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/table_preparation.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/table_wrapping.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/execution_network.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/arithmetic.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/table_wrapping.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parallel_execution.py", "reta_architecture/number_theory.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parameter_runtime.py", "reta_architecture/universal.py",
        "WorkflowGluingCapsule", "WorkflowGluingCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parameter_runtime.py", "reta_architecture/runtime_compat.py",
        "WorkflowGluingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/parameter_runtime.py", "libs/LibRetaPrompt.py",
        "WorkflowGluingCapsule", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/persistence.py", "reta_architecture/parallel_execution.py",
        "RetaArchitectureRoot", "RetaArchitectureRoot",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/presheaves.py", "reta_architecture/topology.py",
        "LocalSectionCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/program_workflow.py", "reta_architecture/parallel_execution.py",
        "WorkflowGluingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/runtime_compat.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/prompt_session.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta.py",
        "InputPromptCapsule", "CompatibilityCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta.py",
        "InputPromptCapsule", "CompatibilityCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta_architecture/completion_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta.py",
        "InputPromptCapsule", "CompatibilityCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta.py",
        "InputPromptCapsule", "CompatibilityCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_execution.py", "reta.py",
        "InputPromptCapsule", "CompatibilityCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/completion_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_execution.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_preparation.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_session.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_interaction.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_language.py", "reta_architecture/completion_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_language.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_language.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_language.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/runtime_compat.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_execution.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_session.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_session.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_runtime.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_runtime.py", "reta_architecture/input_semantics.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_runtime.py", "reta_architecture/semantics_builder.py",
        "InputPromptCapsule", "SemanticSheafCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_runtime.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "reta_architecture/completion_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "reta_architecture/facade.py",
        "InputPromptCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "reta_architecture/prompt_language.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "reta_architecture/prompt_runtime.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "reta_architecture/topology.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/prompt_session.py", "i18n/words_runtime.py",
        "InputPromptCapsule", "SchemaTopologyCapsule",
        "import", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/runtime_compat.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/number_theory.py",
        "TableCoreCapsule", "TableCoreCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_filtering.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/row_ranges.py", "reta_architecture/input_semantics.py",
        "InputPromptCapsule", "InputPromptCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/runtime_compat.py", "reta_architecture/arithmetic.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/runtime_compat.py", "reta_architecture/console_io.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/runtime_compat.py", "reta_architecture/input_semantics.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/runtime_compat.py", "reta_architecture/row_ranges.py",
        "RetaArchitectureRoot", "InputPromptCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/runtime_compat.py", "reta_architecture/split_i18n.py",
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/semantics_builder.py", "reta_architecture/schema.py",
        "SemanticSheafCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/semantics_builder.py", "reta_architecture/universal.py",
        "SemanticSheafCapsule", "WorkflowGluingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/sheaves.py", "reta_architecture/schema.py",
        "SemanticSheafCapsule", "SchemaTopologyCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_adapters.py", "reta_architecture/console_io.py",
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_adapters.py", "reta_architecture/table_preparation.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_adapters.py", "reta_architecture/row_filtering.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_adapters.py", "reta_architecture/table_wrapping.py",
        "RetaArchitectureRoot", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_generation.py", "reta_architecture/generated_columns.py",
        "WorkflowGluingCapsule", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_generation.py", "reta_architecture/concat_csv.py",
        "WorkflowGluingCapsule", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_generation.py", "reta_architecture/combi_join.py",
        "WorkflowGluingCapsule", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_output.py", "reta_architecture/runtime_compat.py",
        "OutputRenderingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_output.py", "reta_architecture/output_syntax.py",
        "OutputRenderingCapsule", "OutputRenderingCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_output.py", "reta_architecture/number_theory.py",
        "OutputRenderingCapsule", "TableCoreCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_output.py", "reta_architecture/parallel_execution.py",
        "OutputRenderingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_output.py", "reta_architecture/parallel_execution.py",
        "OutputRenderingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_preparation.py", "reta_architecture/parallel_execution.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/output_semantics.py",
        "TableCoreCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/output_syntax.py",
        "TableCoreCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/table_output.py",
        "TableCoreCapsule", "OutputRenderingCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/combi_join.py",
        "TableCoreCapsule", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/generated_columns.py",
        "TableCoreCapsule", "GeneratedRelationCapsule",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/table_state.py",
        "TableCoreCapsule", "TableCoreCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/runtime_compat.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/table_adapters.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_runtime.py", "reta_architecture/table_adapters.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/table_wrapping.py", "reta_architecture/runtime_compat.py",
        "TableCoreCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/topology.py", "reta_architecture/schema.py",
        "SchemaTopologyCapsule", "SchemaTopologyCapsule",
        "from", "internal_morphism", True,
        "known module import classified as capsule boundary",
    ))
    import_edges.append(ImportEdgeSpec(
        "reta_architecture/universal.py", "reta_architecture/parallel_execution.py",
        "WorkflowGluingCapsule", "RetaArchitectureRoot",
        "from", "boundary_morphism", True,
        "known module import classified as capsule boundary",
    ))
    var capsule_edges = List[CapsuleImportEdgeSpec]()
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CategoricalMetaCapsule", "CompatibilityCapsule",
        1, "boundary_morphism",
        ["reta_architecture/architecture_validation.py->reta_architecture/package_integrity.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CategoricalMetaCapsule", "InputPromptCapsule",
        6, "boundary_morphism",
        ["reta_architecture/architecture_validation.py->reta_architecture/row_ranges.py", "reta_architecture/architecture_validation.py->reta_architecture/arithmetic.py", "reta_architecture/architecture_validation.py->reta_architecture/completion_word.py", "reta_architecture/architecture_validation.py->reta_architecture/completion_nested.py", "reta_architecture/architecture_validation.py->reta_architecture/completion_word.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CategoricalMetaCapsule", "OutputRenderingCapsule",
        1, "boundary_morphism",
        ["reta_architecture/architecture_validation.py->reta_architecture/console_io.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CompatibilityCapsule", "InputPromptCapsule",
        4, "boundary_morphism",
        ["retaPrompt.py->libs/LibRetaPrompt.py", "retaPrompt.py->libs/nestedAlx.py", "retaPrompt.py->reta_architecture/prompt_execution.py", "retaPrompt.py->reta_architecture/prompt_interaction.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CompatibilityCapsule", "OutputRenderingCapsule",
        3, "boundary_morphism",
        ["libs/lib4tables.py->reta_architecture/output_syntax.py", "libs/tableHandling.py->reta_architecture/output_syntax.py", "reta.py->reta_architecture/output_syntax.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CompatibilityCapsule", "RetaArchitectureRoot",
        8, "boundary_morphism",
        ["libs/lib4tables_concat.py->reta_architecture/__init__.py", "libs/lib4tables_concat.py->reta_architecture/__init__.py", "libs/lib4tables_concat.py->reta_architecture/__init__.py", "reta.py->reta_architecture/__init__.py", "reta.py->reta_architecture/parallel_execution.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CompatibilityCapsule", "TableCoreCapsule",
        7, "boundary_morphism",
        ["libs/lib4tables.py->reta_architecture/number_theory.py", "libs/lib4tables_prepare.py->reta_architecture/table_preparation.py", "libs/lib4tables_prepare.py->reta_architecture/row_filtering.py", "libs/lib4tables_prepare.py->reta_architecture/table_wrapping.py", "libs/tableHandling.py->reta_architecture/number_theory.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "CompatibilityCapsule", "WorkflowGluingCapsule",
        1, "boundary_morphism",
        ["reta.py->reta_architecture/parameter_runtime.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "GeneratedRelationCapsule", "OutputRenderingCapsule",
        1, "boundary_morphism",
        ["reta_architecture/combi_join.py->reta_architecture/output_syntax.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "GeneratedRelationCapsule", "RetaArchitectureRoot",
        10, "boundary_morphism",
        ["reta_architecture/combi_join.py->reta_architecture/runtime_compat.py", "reta_architecture/combi_join.py->reta_architecture/parallel_execution.py", "reta_architecture/combi_join.py->reta_architecture/parallel_execution.py", "reta_architecture/concat_csv.py->reta_architecture/runtime_compat.py", "reta_architecture/generated_columns.py->reta_architecture/runtime_compat.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "GeneratedRelationCapsule", "SchemaTopologyCapsule",
        1, "boundary_morphism",
        ["reta_architecture/combi_join.py->i18n/words_runtime.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "GeneratedRelationCapsule", "TableCoreCapsule",
        4, "boundary_morphism",
        ["reta_architecture/combi_join.py->reta_architecture/table_wrapping.py", "reta_architecture/generated_columns.py->reta_architecture/number_theory.py", "reta_architecture/generated_columns.py->reta_architecture/number_theory.py", "reta_architecture/meta_columns.py->reta_architecture/number_theory.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "InputPromptCapsule", "CompatibilityCapsule",
        5, "boundary_morphism",
        ["reta_architecture/prompt_execution.py->reta.py", "reta_architecture/prompt_execution.py->reta.py", "reta_architecture/prompt_execution.py->reta.py", "reta_architecture/prompt_execution.py->reta.py", "reta_architecture/prompt_execution.py->reta.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "InputPromptCapsule", "RetaArchitectureRoot",
        10, "boundary_morphism",
        ["libs/LibRetaPrompt.py->reta_architecture/__init__.py", "reta_architecture/arithmetic.py->reta_architecture/parallel_execution.py", "reta_architecture/completion_nested.py->reta_architecture/facade.py", "reta_architecture/completion_runtime.py->reta_architecture/facade.py", "reta_architecture/prompt_execution.py->reta_architecture/runtime_compat.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "InputPromptCapsule", "SchemaTopologyCapsule",
        9, "boundary_morphism",
        ["reta_architecture/completion_nested.py->reta_architecture/split_i18n.py", "reta_architecture/completion_runtime.py->i18n/words_runtime.py", "reta_architecture/input_semantics.py->reta_architecture/schema.py", "reta_architecture/prompt_interaction.py->i18n/words_runtime.py", "reta_architecture/prompt_language.py->i18n/words_runtime.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "InputPromptCapsule", "SemanticSheafCapsule",
        1, "boundary_morphism",
        ["reta_architecture/prompt_runtime.py->reta_architecture/semantics_builder.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "LocalSectionCapsule", "SchemaTopologyCapsule",
        1, "boundary_morphism",
        ["reta_architecture/presheaves.py->reta_architecture/topology.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "OutputRenderingCapsule", "RetaArchitectureRoot",
        3, "boundary_morphism",
        ["reta_architecture/table_output.py->reta_architecture/runtime_compat.py", "reta_architecture/table_output.py->reta_architecture/parallel_execution.py", "reta_architecture/table_output.py->reta_architecture/parallel_execution.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "OutputRenderingCapsule", "SchemaTopologyCapsule",
        2, "boundary_morphism",
        ["reta_architecture/output_semantics.py->i18n/words_context.py", "reta_architecture/output_syntax.py->reta_architecture/split_i18n.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "OutputRenderingCapsule", "TableCoreCapsule",
        2, "boundary_morphism",
        ["reta_architecture/output_syntax.py->reta_architecture/number_theory.py", "reta_architecture/table_output.py->reta_architecture/number_theory.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "CategoricalMetaCapsule",
        13, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/category_theory.py", "reta_architecture/facade.py->reta_architecture/architecture_map.py", "reta_architecture/facade.py->reta_architecture/architecture_contracts.py", "reta_architecture/facade.py->reta_architecture/architecture_witnesses.py", "reta_architecture/facade.py->reta_architecture/architecture_validation.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "GeneratedRelationCapsule",
        4, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/generated_columns.py", "reta_architecture/facade.py->reta_architecture/meta_columns.py", "reta_architecture/facade.py->reta_architecture/concat_csv.py", "reta_architecture/facade.py->reta_architecture/combi_join.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "InputPromptCapsule",
        16, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/input_semantics.py", "reta_architecture/facade.py->reta_architecture/row_ranges.py", "reta_architecture/facade.py->reta_architecture/arithmetic.py", "reta_architecture/facade.py->reta_architecture/completion_word.py", "reta_architecture/facade.py->reta_architecture/completion_nested.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "LocalSectionCapsule",
        1, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/presheaves.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "OutputRenderingCapsule",
        7, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/console_io.py", "reta_architecture/facade.py->reta_architecture/output_semantics.py", "reta_architecture/facade.py->reta_architecture/output_syntax.py", "reta_architecture/facade.py->reta_architecture/table_output.py", "reta_architecture/facade.py->reta_architecture/table_output.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "SchemaTopologyCapsule",
        11, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/schema.py", "reta_architecture/facade.py->reta_architecture/topology.py", "reta_architecture/facade.py->i18n/words_context.py", "reta_architecture/facade.py->i18n/words_matrix.py", "reta_architecture/facade.py->i18n/words_runtime.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "SemanticSheafCapsule",
        1, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/sheaves.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "TableCoreCapsule",
        19, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/table_preparation.py", "reta_architecture/facade.py->reta_architecture/table_wrapping.py", "reta_architecture/facade.py->reta_architecture/table_state.py", "reta_architecture/facade.py->reta_architecture/number_theory.py", "reta_architecture/facade.py->reta_architecture/row_filtering.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "RetaArchitectureRoot", "WorkflowGluingCapsule",
        5, "boundary_morphism",
        ["reta_architecture/facade.py->reta_architecture/column_selection.py", "reta_architecture/facade.py->reta_architecture/table_generation.py", "reta_architecture/facade.py->reta_architecture/parameter_runtime.py", "reta_architecture/facade.py->reta_architecture/program_workflow.py", "reta_architecture/facade.py->reta_architecture/universal.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "SemanticSheafCapsule", "SchemaTopologyCapsule",
        2, "boundary_morphism",
        ["reta_architecture/semantics_builder.py->reta_architecture/schema.py", "reta_architecture/sheaves.py->reta_architecture/schema.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "SemanticSheafCapsule", "WorkflowGluingCapsule",
        1, "boundary_morphism",
        ["reta_architecture/semantics_builder.py->reta_architecture/universal.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "TableCoreCapsule", "GeneratedRelationCapsule",
        2, "boundary_morphism",
        ["reta_architecture/table_runtime.py->reta_architecture/combi_join.py", "reta_architecture/table_runtime.py->reta_architecture/generated_columns.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "TableCoreCapsule", "OutputRenderingCapsule",
        3, "boundary_morphism",
        ["reta_architecture/table_runtime.py->reta_architecture/output_semantics.py", "reta_architecture/table_runtime.py->reta_architecture/output_syntax.py", "reta_architecture/table_runtime.py->reta_architecture/table_output.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "TableCoreCapsule", "RetaArchitectureRoot",
        11, "boundary_morphism",
        ["reta_architecture/row_filtering.py->reta_architecture/runtime_compat.py", "reta_architecture/row_filtering.py->reta_architecture/parallel_execution.py", "reta_architecture/row_filtering.py->reta_architecture/parallel_execution.py", "reta_architecture/row_filtering.py->reta_architecture/parallel_execution.py", "reta_architecture/row_filtering.py->reta_architecture/parallel_execution.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "WorkflowGluingCapsule", "GeneratedRelationCapsule",
        3, "boundary_morphism",
        ["reta_architecture/table_generation.py->reta_architecture/generated_columns.py", "reta_architecture/table_generation.py->reta_architecture/concat_csv.py", "reta_architecture/table_generation.py->reta_architecture/combi_join.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "WorkflowGluingCapsule", "InputPromptCapsule",
        1, "boundary_morphism",
        ["reta_architecture/parameter_runtime.py->libs/LibRetaPrompt.py"],
    ))
    capsule_edges.append(CapsuleImportEdgeSpec(
        "WorkflowGluingCapsule", "RetaArchitectureRoot",
        3, "boundary_morphism",
        ["reta_architecture/parameter_runtime.py->reta_architecture/runtime_compat.py", "reta_architecture/program_workflow.py->reta_architecture/parallel_execution.py", "reta_architecture/universal.py->reta_architecture/parallel_execution.py"],
    ))
    var capsule_boundaries = List[CapsuleBoundarySpec]()
    capsule_boundaries.append(CapsuleBoundarySpec(
        "RetaArchitectureRoot", ["reta_architecture/__init__.py", "reta_architecture/execution_network.py", "reta_architecture/facade.py", "reta_architecture/morphisms.py", "reta_architecture/parallel_execution.py", "reta_architecture/persistence.py", "reta_architecture/runtime_compat.py", "reta_architecture/table_adapters.py", "reta_architecture/tag_schema.py"],
        ["CategoricalMetaCapsule", "GeneratedRelationCapsule", "InputPromptCapsule", "LocalSectionCapsule", "OutputRenderingCapsule", "SchemaTopologyCapsule", "SemanticSheafCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        ["CompatibilityCapsule", "GeneratedRelationCapsule", "InputPromptCapsule", "OutputRenderingCapsule", "TableCoreCapsule", "WorkflowGluingCapsule"],
        "RetaArchitectureRoot besitzt 9 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "SchemaTopologyCapsule", ["i18n/words_context.py", "i18n/words_matrix.py", "i18n/words_runtime.py", "reta_architecture/schema.py", "reta_architecture/split_i18n.py", "reta_architecture/topology.py"],
        List[String](),
        ["GeneratedRelationCapsule", "InputPromptCapsule", "LocalSectionCapsule", "OutputRenderingCapsule", "RetaArchitectureRoot", "SemanticSheafCapsule"],
        "SchemaTopologyCapsule besitzt 6 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "LocalSectionCapsule", ["csv/2024-07-06-symbols-alt-ak-circle-sphere-etc.csv", "csv/cn-dualism-trinities-etc.csv", "csv/cn-gebrochen-rational-emotionen.csv", "csv/cn-gebrochen-rational-galaxie.csv", "csv/cn-gebrochen-rational-strukturgroesse.csv", "csv/cn-gebrochen-rational-universum.csv", "csv/cn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/cn-kombi-meta-systeme.csv", "csv/cn-kombi-meta.csv", "csv/cn-kombi-universelle-wirklichkeit.csv", "csv/cn-kombi.csv", "csv/cn-kreisVomTyp18.csv", "csv/cn-meaningOfLife.csv", "csv/cn-primenumbers.csv", "csv/cn-religion.csv", "csv/cn-sunMoonEtc.csv", "csv/cn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/dualism-trinities-etc.csv", "csv/en-dualism-trinities-etc.csv", "csv/en-gebrochen-rational-emotionen.csv", "csv/en-gebrochen-rational-galaxie.csv", "csv/en-gebrochen-rational-strukturgroesse.csv", "csv/en-gebrochen-rational-universum.csv", "csv/en-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/en-kombi-meta-systeme.csv", "csv/en-kombi-meta.csv", "csv/en-kombi-universelle-wirklichkeit.csv", "csv/en-kombi.csv", "csv/en-kreisVomTyp18.csv", "csv/en-meaningOfLife.csv", "csv/en-primenumbers.csv", "csv/en-religion.csv", "csv/en-sunMoonEtc.csv", "csv/gebrochen-rational-emotionen.csv", "csv/gebrochen-rational-galaxie.csv", "csv/gebrochen-rational-strukturgroesse.csv", "csv/gebrochen-rational-universum.csv", "csv/kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kombi-meta-systeme.csv", "csv/kombi-meta.csv", "csv/kombi-universelle-wirklichkeit.csv", "csv/kombi.csv", "csv/kr-dualism-trinities-etc.csv", "csv/kr-gebrochen-rational-emotionen.csv", "csv/kr-gebrochen-rational-galaxie.csv", "csv/kr-gebrochen-rational-strukturgroesse.csv", "csv/kr-gebrochen-rational-universum.csv", "csv/kr-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/kr-kombi-meta-systeme.csv", "csv/kr-kombi-meta.csv", "csv/kr-kombi-universelle-wirklichkeit.csv", "csv/kr-kombi.csv", "csv/kr-kreisVomTyp18.csv", "csv/kr-meaningOfLife.csv", "csv/kr-primenumbers.csv", "csv/kr-religion.csv", "csv/kr-sunMoonEtc.csv", "csv/kr-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "csv/kreisVomTyp18.csv", "csv/meaningOfLife.csv", "csv/primenumbers.csv", "csv/religion.csv", "csv/sunMoonEtc.csv", "csv/vn-dualism-trinities-etc.csv", "csv/vn-gebrochen-rational-emotionen.csv", "csv/vn-gebrochen-rational-galaxie.csv", "csv/vn-gebrochen-rational-strukturgroesse.csv", "csv/vn-gebrochen-rational-universum.csv", "csv/vn-kombi-gedanken17-absichten13-bewusstsein15.csv", "csv/vn-kombi-meta-systeme.csv", "csv/vn-kombi-meta.csv", "csv/vn-kombi-universelle-wirklichkeit.csv", "csv/vn-kombi.csv", "csv/vn-kreisVomTyp18.csv", "csv/vn-meaningOfLife.csv", "csv/vn-primenumbers.csv", "csv/vn-religion.csv", "csv/vn-sunMoonEtc.csv", "csv/vn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv", "doc/readme-reta-en.md", "doc/readme-reta.md", "doc/readme-retaPrompt-en.md", "doc/readme-retaPrompt.md", "doc/readme-startFiles.md", "readme-reta-en.md", "readme-reta.md", "readme-retaPrompt-en.md", "readme-retaPrompt.md", "readme-startFiles.md", "reta_architecture/presheaves.py"],
        ["SchemaTopologyCapsule"],
        ["RetaArchitectureRoot"],
        "LocalSectionCapsule besitzt 90 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "SemanticSheafCapsule", ["reta_architecture/semantics_builder.py", "reta_architecture/sheaves.py"],
        ["SchemaTopologyCapsule", "WorkflowGluingCapsule"],
        ["InputPromptCapsule", "RetaArchitectureRoot"],
        "SemanticSheafCapsule besitzt 2 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "InputPromptCapsule", ["libs/LibRetaPrompt.py", "libs/nestedAlx.py", "reta_architecture/arithmetic.py", "reta_architecture/completion_nested.py", "reta_architecture/completion_runtime.py", "reta_architecture/completion_word.py", "reta_architecture/input_semantics.py", "reta_architecture/prompt_execution.py", "reta_architecture/prompt_interaction.py", "reta_architecture/prompt_language.py", "reta_architecture/prompt_preparation.py", "reta_architecture/prompt_runtime.py", "reta_architecture/prompt_session.py", "reta_architecture/row_ranges.py"],
        ["CompatibilityCapsule", "RetaArchitectureRoot", "SchemaTopologyCapsule", "SemanticSheafCapsule"],
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "RetaArchitectureRoot", "WorkflowGluingCapsule"],
        "InputPromptCapsule besitzt 14 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "WorkflowGluingCapsule", ["reta_architecture/column_selection.py", "reta_architecture/parameter_runtime.py", "reta_architecture/program_workflow.py", "reta_architecture/table_generation.py", "reta_architecture/universal.py"],
        ["GeneratedRelationCapsule", "InputPromptCapsule", "RetaArchitectureRoot"],
        ["CompatibilityCapsule", "RetaArchitectureRoot", "SemanticSheafCapsule"],
        "WorkflowGluingCapsule besitzt 5 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "TableCoreCapsule", ["reta_architecture/number_theory.py", "reta_architecture/row_filtering.py", "reta_architecture/table_preparation.py", "reta_architecture/table_runtime.py", "reta_architecture/table_state.py", "reta_architecture/table_wrapping.py"],
        ["GeneratedRelationCapsule", "OutputRenderingCapsule", "RetaArchitectureRoot"],
        ["CompatibilityCapsule", "GeneratedRelationCapsule", "OutputRenderingCapsule", "RetaArchitectureRoot"],
        "TableCoreCapsule besitzt 6 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "GeneratedRelationCapsule", ["reta_architecture/combi_join.py", "reta_architecture/concat_csv.py", "reta_architecture/generated_columns.py", "reta_architecture/meta_columns.py"],
        ["OutputRenderingCapsule", "RetaArchitectureRoot", "SchemaTopologyCapsule", "TableCoreCapsule"],
        ["RetaArchitectureRoot", "TableCoreCapsule", "WorkflowGluingCapsule"],
        "GeneratedRelationCapsule besitzt 4 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "OutputRenderingCapsule", ["reta_architecture/console_io.py", "reta_architecture/output_semantics.py", "reta_architecture/output_syntax.py", "reta_architecture/table_output.py"],
        ["RetaArchitectureRoot", "SchemaTopologyCapsule", "TableCoreCapsule"],
        ["CategoricalMetaCapsule", "CompatibilityCapsule", "GeneratedRelationCapsule", "RetaArchitectureRoot", "TableCoreCapsule"],
        "OutputRenderingCapsule besitzt 4 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "CompatibilityCapsule", ["libs/lib4tables.py", "libs/lib4tables_concat.py", "libs/lib4tables_prepare.py", "libs/tableHandling.py", "reta.py", "retaPrompt.py", "reta_architecture/package_integrity.py", "tests/test_command_parity.py"],
        ["InputPromptCapsule", "OutputRenderingCapsule", "RetaArchitectureRoot", "TableCoreCapsule", "WorkflowGluingCapsule"],
        ["CategoricalMetaCapsule", "InputPromptCapsule"],
        "CompatibilityCapsule besitzt 8 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    capsule_boundaries.append(CapsuleBoundarySpec(
        "CategoricalMetaCapsule", ["reta_architecture/architecture_activation.py", "reta_architecture/architecture_boundaries.py", "reta_architecture/architecture_coherence.py", "reta_architecture/architecture_contracts.py", "reta_architecture/architecture_impact.py", "reta_architecture/architecture_map.py", "reta_architecture/architecture_migration.py", "reta_architecture/architecture_progress.py", "reta_architecture/architecture_rehearsal.py", "reta_architecture/architecture_traces.py", "reta_architecture/architecture_validation.py", "reta_architecture/architecture_witnesses.py", "reta_architecture/category_theory.py"],
        ["CompatibilityCapsule", "InputPromptCapsule", "OutputRenderingCapsule"],
        ["RetaArchitectureRoot"],
        "CategoricalMetaCapsule besitzt 13 Module und seine Cross-Capsule-Importe sind explizit sichtbar.",
    ))
    var checks = List[BoundaryCheckSpec]()
    checks.append(BoundaryCheckSpec(
        "ModuleOwnershipCoverageCheck", "passed",
        List[String](), 161,
        "Jedes relevante Python-Modul hat einen Kapselbesitzer.",
    ))
    checks.append(BoundaryCheckSpec(
        "ImportEdgeClassificationCheck", "passed",
        List[String](), 279,
        "Jede aufgelöste interne Importkante ist als interner oder Boundary-Morphismus klassifiziert.",
    ))
    checks.append(BoundaryCheckSpec(
        "CapsuleBoundaryCoverageCheck", "passed",
        List[String](), 11,
        "Jede Kapsel hat einen Boundary-Eintrag.",
    ))
    checks.append(BoundaryCheckSpec(
        "BoundaryViolationCheck", "passed",
        List[String](), 279,
        "Stage 32 verbietet keine bekannten Legacy-Kanten, sondern macht sie sichtbar.",
    ))
    checks.append(BoundaryCheckSpec(
        "CoherenceBoundaryReflectionCheck", "passed",
        List[String](), 11,
        "Boundary-Graph reflektiert die Kapseln der Architekturkarte.",
    ))
    var validation = BoundaryValidationSpec(
        "passed",
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        checks^,
    )
    var plan = Stage32BoundaryPlan(
        ["reale Python-Importe als Kapselgrenzen sichtbar machen", "Kohärenzmatrix mit Modulbesitz rückbinden"],
        ["reta_architecture/architecture_boundaries.py", "architecture-boundaries-json", "architecture-boundaries-md"],
        ["ArchitectureMapBundle", "ArchitectureCoherenceBundle"],
        "keine beabsichtigte Laufzeitänderung; Stage 32 klassifiziert bestehende Importe",
    )
    return ArchitectureBoundariesBundle(
        ownership^, import_edges^, capsule_edges^, capsule_boundaries^,
        validation^, "ArchitectureBoundariesBundle\n├─ ModuleOwnershipSpec: Python-Datei → Kapsel\n├─ ImportEdgeSpec: Python-Import → Morphismus\n└─ CapsuleImportEdgeSpec: Kapsel → Kapsel Boundary-Kante\n", "```mermaid\nflowchart TD\n    Module[Python-Modul] --> Owner[ModuleOwnershipSpec]\n    Owner --> Capsule[Kapsel]\n    Module --> Import[ImportEdgeSpec]\n    Import --> Boundary[CapsuleImportEdgeSpec]\n    Boundary --> Validation[BoundaryValidationSpec]\n```\n", plan^,
    )
