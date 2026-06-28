# UML-Klassendiagramm und Objektdiagramm für `reta_arch`

## 1. UML-Klassendiagramm

```plantuml
@startuml
top to bottom direction

skinparam classAttributeIconSize 0
skinparam shadowing false
skinparam linetype ortho
hide empty methods

package "Zentrale Architektur" {

  class RetaArchitecture <<dataclass>> {
    +repo_root: Path
    +schema: RetaContextSchema
    +topology: RetaContextTopology
    +presheaves: PresheafBundle
    +sheaves: SheafBundle
    +morphisms: MorphismBundle
    +universal: UniversalBundle
    +category_theory: CategoryTheoryBundle
    +execution_network: ExecutionNetworkBundle
    +persistence: PersistenceBundle
    +table_state: TableStateBundle
    +table_runtime: TableRuntimeBundle
    +output_syntax: OutputSyntaxBundle
    --
    +bootstrap(): RetaArchitecture
  }

  class RetaContextSchema <<dataclass>> {
    +language_aliases
    +parameters_main
    +row_parameters
    +output_parameters
    +output_modes
    +combination_parameters
    +tag_names
    --
    +from_words_parts()
    +main_alias_map()
    +snapshot()
  }

  class RetaContextTopology {
    +schema: RetaContextSchema
    +dimensions: Dict
    --
    +from_schema()
    +canonicalize()
    +open_for()
    +basis_open_sets()
    +refine()
  }

  class ContextDimension <<dataclass>> {
    +name: str
    +values: Set
    +aliases: Dict
    --
    +canonicalize()
    +include()
  }

  class ContextSelection <<dataclass, frozen>> {
    +language
    +main_parameters
    +sub_parameters
    +row_parameters
    +output_modes
    +tag_names
    +combination_parameters
    +scopes
    --
    +restrict()
    +refine()
    +is_empty()
    +as_dict()
  }
}

RetaArchitecture *-- RetaContextSchema : schema
RetaArchitecture *-- RetaContextTopology : topology

RetaContextTopology o-- RetaContextSchema : schema
RetaContextTopology *-- "8" ContextDimension : dimensions
RetaContextTopology ..> ContextSelection : erzeugt/refiniert


package "Prägarben" {

  class LocalSection <<dataclass>> {
    +context: ContextSelection
    +payload: object
    +source: str
    --
    +as_dict()
  }

  class Presheaf {
    +name: str
    -_sections: List<LocalSection>
    --
    +add_section()
    +restrict()
    +sections()
    +snapshot()
  }

  class FilesystemPresheaf {
    +root: Path
    --
    +discover()
  }

  class PromptStatePresheaf {
    +raw_text: str
    +tokenized_text: List
    --
    +update()
  }

  class PresheafBundle <<dataclass>> {
    +csv: FilesystemPresheaf
    +translations: FilesystemPresheaf
    +assets: FilesystemPresheaf
    +prompt_state: PromptStatePresheaf
    --
    +discover()
    +snapshot()
  }
}

Presheaf <|-- FilesystemPresheaf
Presheaf <|-- PromptStatePresheaf

Presheaf *-- "0..*" LocalSection
LocalSection --> ContextSelection

PresheafBundle *-- FilesystemPresheaf : csv
PresheafBundle *-- FilesystemPresheaf : translations
PresheafBundle *-- FilesystemPresheaf : assets
PresheafBundle *-- PromptStatePresheaf : prompt_state

RetaArchitecture *-- PresheafBundle : presheaves


package "Garben" {

  class ParameterSemanticsSheaf <<dataclass>> {
    +main_alias_map
    +parameter_alias_groups
    +pair_to_columns
    +global_parameter_dict
    +global_data_dicts
    --
    +from_schema()
    +resolve_main_alias()
    +resolve_parameter_alias()
    +canonicalize_pair()
    +sync_program_semantics()
  }

  class GeneratedColumnsSheaf <<dataclass>> {
    +generated_spalten_parameter
    +generated_spalten_parameter_tags
    --
    +sync_from_tables()
  }

  class TableOutputSheaf <<dataclass>> {
    +sections
    --
    +sync_from_tables()
  }

  class HtmlReferenceSheaf {
    +reference_map
    --
    +from_jsonl()
    +html_meta_for_column()
  }

  class SheafBundle <<dataclass>> {
    +parameter_semantics
    +generated_columns
    +table_output
    +html_reference
    --
    +from_repo()
    +snapshot()
  }
}

SheafBundle *-- ParameterSemanticsSheaf
SheafBundle *-- GeneratedColumnsSheaf
SheafBundle *-- TableOutputSheaf
SheafBundle *-- HtmlReferenceSheaf

ParameterSemanticsSheaf ..> RetaContextSchema : from_schema()

RetaArchitecture *-- SheafBundle : sheaves


package "Morphismen und Universalität" {

  class AliasMorphisms <<dataclass>> {
    +topology
    +parameter_semantics
    --
    +resolve_main_alias()
    +resolve_parameter_alias()
    +canonicalize_pair()
  }

  class RangeMorphisms <<dataclass>> {
    +topology
    --
    +parse_row_range()
  }

  class PromptMorphisms <<dataclass>> {
    +topology
    --
    +split()
    +split_command_words()
    +expand_shorthand()
  }

  class RendererMorphisms <<dataclass>> {
    +topology
    +output_semantics
    --
    +output_mode_for_tables()
    +apply_output_mode()
  }

  class MorphismBundle <<dataclass>> {
    +alias
    +ranges
    +prompt
    +renderers
    --
    +from_topology_and_sheaves()
  }

  class UniversalBundle <<dataclass>> {
    +sheaves
    --
    +merge_parameter_dicts()
    +normalize_column_buckets()
    +sync_tables()
  }
}

MorphismBundle *-- AliasMorphisms
MorphismBundle *-- RangeMorphisms
MorphismBundle *-- PromptMorphisms
MorphismBundle *-- RendererMorphisms

AliasMorphisms --> RetaContextTopology
RangeMorphisms --> RetaContextTopology
PromptMorphisms --> RetaContextTopology
RendererMorphisms --> RetaContextTopology

AliasMorphisms --> ParameterSemanticsSheaf

UniversalBundle --> SheafBundle

RetaArchitecture *-- MorphismBundle : morphisms
RetaArchitecture *-- UniversalBundle : universal


package "Kategorientheorie" {

  class CategoryObjectSpec <<dataclass, frozen>> {
    +name: str
    +code_owner: str
    +role: str
  }

  class CategoryMorphismSpec <<dataclass, frozen>> {
    +name: str
    +source: str
    +target: str
    +code_owner: str
    +role: str
  }

  class CategorySpec <<dataclass, frozen>> {
    +name: str
    +description: str
    +objects
    +morphisms
    +implemented_by
  }

  class FunctorSpec <<dataclass, frozen>> {
    +name: str
    +source_category: str
    +target_category: str
    +object_map
    +morphism_map
  }

  class NaturalTransformationSpec <<dataclass, frozen>> {
    +name: str
    +source_functor: str
    +target_functor: str
    +components
    +naturality_condition
  }

  class CategoryTheoryBundle <<dataclass, frozen>> {
    +categories
    +functors
    +natural_transformations
    +paradigm_terms
    +plan
    --
    +category_named()
    +functor_named()
    +natural_transformation_named()
  }
}

CategorySpec *-- "0..*" CategoryObjectSpec
CategorySpec *-- "0..*" CategoryMorphismSpec

CategoryTheoryBundle *-- "0..*" CategorySpec
CategoryTheoryBundle *-- "0..*" FunctorSpec
CategoryTheoryBundle *-- "0..*" NaturalTransformationSpec

FunctorSpec --> CategorySpec : source/target
NaturalTransformationSpec --> FunctorSpec : source/target

RetaArchitecture *-- CategoryTheoryBundle : category_theory


package "Tabellenzustand und Tabellenlaufzeit" {

  class GeneratedColumnSection <<dataclass>> {
    +parameters
    +tags
  }

  class TableDisplayState <<dataclass>> {
    +keine_ueberschriften: bool
    +keine_leeren_inhalte: bool
    +spalte_gestirn: bool
    +religion_numbers: list
  }

  class TableStateSections <<dataclass>> {
    +highest_rows
    +display
    +generated_columns
    +row_display_to_original
    --
    +new_generated_rows()
  }

  class TableStateBundle <<dataclass, frozen>> {
    +ordered_dict_factory
    +ordered_set_factory
    --
    +create_sections()
  }

  class Tables {
    +outType
    +hoechsteZeile
    +generRows
    +breitenn
    +nummeriere
    +textWidth
    --
    +fillBoth()
    +tableReducedInLinesByTypeSet()
  }

  class TableRuntimeBundle <<dataclass, frozen>> {
    +table_class: type
    +output_semantics
    +table_state
    --
    +create_tables()
  }

  class TableOutput {
    +outType
    +color
    +oneTable
    +breitenn
    +nummeriere
    +textWidth
    --
    +cliOut()
    +cliout2()
    +colorize()
  }

  class TableOutputBundle <<dataclass, frozen>> {
    +output_class: Type<TableOutput>
    --
    +create()
  }

  class BreakoutException
}

TableStateSections *-- TableDisplayState
TableStateSections *-- GeneratedColumnSection

TableStateBundle ..> TableStateSections : create_sections()

TableRuntimeBundle --> TableStateBundle
TableRuntimeBundle --> Tables : table_class

TableOutputBundle --> TableOutput : output_class
Exception <|-- BreakoutException

RetaArchitecture *-- TableStateBundle : table_state
RetaArchitecture *-- TableRuntimeBundle : table_runtime
RetaArchitecture *-- TableOutputBundle : table_output


package "Ausführungsnetzwerk" {

  class ExecutionNetworkConfig <<dataclass, frozen>> {
    +max_workers: int
    +queue_discipline: str
    +use_processes: bool
    +preserve_input_order: bool
  }

  class ExecutionTask <<dataclass, frozen>> {
    +index: int
    +payload
    +operation: str
    +priority: int
    +metadata
  }

  class ExecutionResult <<dataclass, frozen>> {
    +task_index: int
    +value
    +operation: str
    +metadata
  }

  class ExecutionRunResult <<dataclass, frozen>> {
    +values
    +results
    +config
    +workers: int
    +task_count: int
    +mode: str
  }

  class FifoTaskQueue
  class LifoTaskStack
  class PriorityTaskQueue

  class ResourceSemaphore
  class HalfDuplexChannel
  class FullDuplexChannel

  class ExecutionNetworkBundle <<dataclass, frozen>> {
    +config
    +cpu_semaphore
    +file_io_semaphore
    +output_semaphore
  }
}

ExecutionNetworkBundle *-- ExecutionNetworkConfig
ExecutionNetworkBundle *-- "3" ResourceSemaphore

FifoTaskQueue o-- "0..*" ExecutionTask
LifoTaskStack o-- "0..*" ExecutionTask
PriorityTaskQueue o-- "0..*" ExecutionTask

ExecutionResult --> ExecutionTask : task_index
ExecutionRunResult *-- "0..*" ExecutionResult
ExecutionRunResult --> ExecutionNetworkConfig

ExecutionNetworkBundle ..> FifoTaskQueue : erzeugt/verwendet
ExecutionNetworkBundle ..> LifoTaskStack : erzeugt/verwendet
ExecutionNetworkBundle ..> PriorityTaskQueue : erzeugt/verwendet
ExecutionNetworkBundle ..> HalfDuplexChannel
ExecutionNetworkBundle ..> FullDuplexChannel
ExecutionNetworkBundle ..> ExecutionRunResult

RetaArchitecture *-- ExecutionNetworkBundle : execution_network


package "Ausgabe-Syntax" {

  class NichtsSyntax

  class OutputSyntax {
    +force_one_table
    +force_zero_width
    +marks_html_or_bbcode
  }

  class csvSyntax
  class emacsSyntax
  class markdownSyntax
  class bbCodeSyntax
  class htmlSyntax

  class OutputSyntaxBundle <<dataclass, frozen>> {
    +classes: Dict<str, type>
    --
    +class_for()
  }
}

OutputSyntax <|-- csvSyntax
OutputSyntax <|-- emacsSyntax
OutputSyntax <|-- markdownSyntax
OutputSyntax <|-- bbCodeSyntax
OutputSyntax <|-- htmlSyntax

OutputSyntaxBundle o-- OutputSyntax : shell
OutputSyntaxBundle o-- csvSyntax : csv
OutputSyntaxBundle o-- emacsSyntax : emacs
OutputSyntaxBundle o-- markdownSyntax : markdown
OutputSyntaxBundle o-- bbCodeSyntax : bbcode
OutputSyntaxBundle o-- htmlSyntax : html
OutputSyntaxBundle o-- NichtsSyntax : nichts

RetaArchitecture *-- OutputSyntaxBundle : output_syntax


package "Prompt und Vervollständigung" {

  abstract class Completer

  class ArchitectureWordCompleter
  class ArchitectureNestedCompleter

  class PromptRuntimeBundle <<dataclass>> {
    +program
    +vocabulary
    +semantics
    +validation
  }

  class PromptRuntimeBuilder {
    +build_semantics()
    +build_program_view()
    +build()
  }

  class PromptTextState <<dataclass>> {
    +architecture
    +i18n
    -_text
    -_stext
    -_befehlDavor
  }

  class PromptSessionBundle <<dataclass>> {
    +architecture
    +i18n
    +prompt_runtime
    +completion_runtime
    +prompt_language
    +history_file
  }
}

Completer <|-- ArchitectureWordCompleter
Completer <|-- ArchitectureNestedCompleter

PromptRuntimeBuilder ..> PromptRuntimeBundle : build()
PromptSessionBundle --> RetaArchitecture
PromptSessionBundle --> PromptRuntimeBundle
PromptSessionBundle ..> PromptTextState : new_text_state()


package "Persistenz" {

  class PersistenceConfig <<dataclass, frozen>> {
    +db_path: str
    +initialise: bool
    +journal_mode: str
  }

  class PersistedRecord <<dataclass, frozen>> {
    +table: str
    +key: str
    +digest: str
    +rowid: int
  }

  class PersistenceBundle <<dataclass, frozen>> {
    +config: PersistenceConfig
  }

  database SQLite
}

PersistenceBundle *-- PersistenceConfig
PersistenceBundle ..> PersistedRecord : erzeugt
PersistenceBundle --> SQLite

RetaArchitecture *-- PersistenceBundle : persistence

@enduml
```

## 2. Vererbungsübersicht

```text
Presheaf
├── FilesystemPresheaf
└── PromptStatePresheaf

OutputSyntax
├── csvSyntax
├── emacsSyntax
├── markdownSyntax
├── bbCodeSyntax
└── htmlSyntax

prompt_toolkit.completion.Completer
├── ArchitectureWordCompleter
└── ArchitectureNestedCompleter

Exception
└── BreakoutException
```

Weitere Enum-Ableitungen:

```text
Enum
├── ST
├── PromptModus
├── Wraptype
└── ComplSitua

IntEnum
└── nPmEnum
```

Die Architektur verwendet insgesamt deutlich mehr **Komposition** als Vererbung:

```text
RetaArchitecture
├── Schema
├── Topologie
├── Prägarben
├── Garben
├── Morphismen
├── universelle Eigenschaften
├── Kategorientheorie
├── Tabellenlaufzeit
├── Ausführungsnetzwerk
├── Persistenz
└── Ausgabe-Syntax
```

---

# 3. UML-Objektdiagramm

Das Objektdiagramm zeigt einen typischen Zustand nach:

```python
architecture = RetaArchitecture.bootstrap()
```

```plantuml
@startuml
top to bottom direction

skinparam objectAttributeIconSize 0
skinparam shadowing false
skinparam linetype ortho

object architecture as "architecture:RetaArchitecture" {
  repo_root = reta.arch/
}

object schema as "schema:RetaContextSchema"
object topology as "topology:RetaContextTopology"

architecture *-- schema
architecture *-- topology
topology --> schema


object language_dimension as "language:ContextDimension" {
  name = "language"
}

object main_dimension as "main_parameters:ContextDimension" {
  name = "main_parameters"
}

object output_dimension as "output_modes:ContextDimension" {
  name = "output_modes"
}

object scope_dimension as "scopes:ContextDimension" {
  name = "scopes"
}

topology *-- language_dimension
topology *-- main_dimension
topology *-- output_dimension
topology *-- scope_dimension


object presheaves as "presheaves:PresheafBundle"

object csv_presheaf as "csv:FilesystemPresheaf" {
  name = "csv"
}

object translations_presheaf as "translations:FilesystemPresheaf" {
  name = "translations"
}

object assets_presheaf as "assets:FilesystemPresheaf" {
  name = "assets"
}

object prompt_presheaf as "prompt_state:PromptStatePresheaf" {
  name = "prompt_state"
  raw_text = ""
}

architecture *-- presheaves

presheaves *-- csv_presheaf
presheaves *-- translations_presheaf
presheaves *-- assets_presheaf
presheaves *-- prompt_presheaf


object csv_context as "csv_context:ContextSelection" {
  scopes = {"csv"}
}

object csv_section as "csv_section:LocalSection" {
  source = "csv/religion.csv"
}

csv_presheaf *-- csv_section
csv_section --> csv_context


object prompt_context as "prompt_context:ContextSelection" {
  scopes = {"prompt"}
}

object prompt_section as "prompt_section:LocalSection" {
  source = "prompt"
}

prompt_presheaf *-- prompt_section
prompt_section --> prompt_context


object sheaves as "sheaves:SheafBundle"

object parameter_sheaf as "parameter_semantics:ParameterSemanticsSheaf"
object generated_sheaf as "generated_columns:GeneratedColumnsSheaf"
object output_sheaf as "table_output:TableOutputSheaf"
object html_sheaf as "html_reference:HtmlReferenceSheaf"

architecture *-- sheaves

sheaves *-- parameter_sheaf
sheaves *-- generated_sheaf
sheaves *-- output_sheaf
sheaves *-- html_sheaf

parameter_sheaf --> schema


object morphisms as "morphisms:MorphismBundle"

object alias_morphisms as "alias:AliasMorphisms"
object range_morphisms as "ranges:RangeMorphisms"
object prompt_morphisms as "prompt:PromptMorphisms"
object renderer_morphisms as "renderers:RendererMorphisms"

architecture *-- morphisms

morphisms *-- alias_morphisms
morphisms *-- range_morphisms
morphisms *-- prompt_morphisms
morphisms *-- renderer_morphisms

alias_morphisms --> topology
alias_morphisms --> parameter_sheaf

range_morphisms --> topology
prompt_morphisms --> topology
renderer_morphisms --> topology


object universal as "universal:UniversalBundle"
architecture *-- universal
universal --> sheaves


object category_theory as "category_theory:CategoryTheoryBundle"

object context_category as "context_category:CategorySpec" {
  name = "OpenRetaContextCategory"
}

object sheaf_category as "sheaf_category:CategorySpec" {
  name = "CanonicalSemanticSheafCategory"
}

object table_functor as "table_functor:FunctorSpec"
object rendering_functor as "rendering_functor:FunctorSpec"
object transformation as "transformation:NaturalTransformationSpec"

architecture *-- category_theory

category_theory *-- context_category
category_theory *-- sheaf_category
category_theory *-- table_functor
category_theory *-- rendering_functor
category_theory *-- transformation


object table_state as "table_state:TableStateBundle"

object state_sections as "sections:TableStateSections"
object display_state as "display:TableDisplayState" {
  keine_ueberschriften = false
  keine_leeren_inhalte = false
}

object generated_section as "generated:GeneratedColumnSection"

architecture *-- table_state

table_state ..> state_sections : create_sections()
state_sections *-- display_state
state_sections *-- generated_section


object table_runtime as "table_runtime:TableRuntimeBundle"

object tables as "tables:Tables"

architecture *-- table_runtime
table_runtime --> table_state
table_runtime ..> tables : create_tables()


object execution as "execution_network:ExecutionNetworkBundle"

object execution_config as "config:ExecutionNetworkConfig" {
  queue_discipline = "fifo"
  use_processes = false
  preserve_input_order = true
}

object cpu_semaphore as "cpu:ResourceSemaphore"
object file_semaphore as "file_io:ResourceSemaphore"
object output_semaphore as "output:ResourceSemaphore"

architecture *-- execution

execution *-- execution_config
execution *-- cpu_semaphore
execution *-- file_semaphore
execution *-- output_semaphore


object task0 as "task0:ExecutionTask" {
  index = 0
  operation = "identity"
  priority = 0
}

object task1 as "task1:ExecutionTask" {
  index = 1
  operation = "identity"
  priority = 0
}

object fifo as "queue:FifoTaskQueue"

object result0 as "result0:ExecutionResult" {
  task_index = 0
}

object result1 as "result1:ExecutionResult" {
  task_index = 1
}

object run_result as "run:ExecutionRunResult" {
  task_count = 2
  queue_discipline = "fifo"
}

fifo o-- task0
fifo o-- task1

task0 ..> result0 : Verarbeitung
task1 ..> result1 : Verarbeitung

run_result *-- result0
run_result *-- result1
run_result --> execution_config


object output_syntax as "output_syntax:OutputSyntaxBundle"

object csv_class as "csvSyntax:type"
object markdown_class as "markdownSyntax:type"
object html_class as "htmlSyntax:type"
object bbcode_class as "bbCodeSyntax:type"

architecture *-- output_syntax

output_syntax o-- csv_class : classes["csv"]
output_syntax o-- markdown_class : classes["markdown"]
output_syntax o-- html_class : classes["html"]
output_syntax o-- bbcode_class : classes["bbcode"]


object csv_renderer as "csv_renderer:csvSyntax"
object markdown_renderer as "markdown_renderer:markdownSyntax"
object html_renderer as "html_renderer:htmlSyntax"

csv_class ..> csv_renderer : instanziiert
markdown_class ..> markdown_renderer : instanziiert
html_class ..> html_renderer : instanziiert


object persistence as "persistence:PersistenceBundle"

object persistence_config as "config:PersistenceConfig" {
  journal_mode = "WAL"
}

database sqlite as "SQLite"

architecture *-- persistence
persistence *-- persistence_config
persistence --> sqlite


object prompt_runtime as "prompt_runtime:PromptRuntimeBundle"
object prompt_session as "prompt_session:PromptSessionBundle"
object text_state as "text_state:PromptTextState"

object word_completer as "word_completer:ArchitectureWordCompleter"
object nested_completer as "nested_completer:ArchitectureNestedCompleter"

prompt_session --> architecture
prompt_session --> prompt_runtime
prompt_session ..> text_state : new_text_state()

prompt_session --> word_completer
prompt_session --> nested_completer

@enduml
```

## 4. Ableitungen im Objektdiagramm

Ein Objektdiagramm zeigt normalerweise keine Vererbungsbeziehungen. Es zeigt aber konkrete Instanzen der abgeleiteten Klassen:

```text
csv_presheaf:FilesystemPresheaf
    ist eine Instanz einer Unterklasse von Presheaf

prompt_presheaf:PromptStatePresheaf
    ist eine Instanz einer Unterklasse von Presheaf

csv_renderer:csvSyntax
    ist eine Instanz einer Unterklasse von OutputSyntax

markdown_renderer:markdownSyntax
    ist eine Instanz einer Unterklasse von OutputSyntax

html_renderer:htmlSyntax
    ist eine Instanz einer Unterklasse von OutputSyntax

word_completer:ArchitectureWordCompleter
    ist eine Instanz einer Unterklasse von Completer

nested_completer:ArchitectureNestedCompleter
    ist eine Instanz einer Unterklasse von Completer
```

## 5. Vereinfachte kombinierte Darstellung

```text
RetaArchitecture
│
├── schema:RetaContextSchema
│
├── topology:RetaContextTopology
│   └── ContextDimension[]
│
├── presheaves:PresheafBundle
│   ├── csv:FilesystemPresheaf
│   │   └── LocalSection[]
│   ├── translations:FilesystemPresheaf
│   ├── assets:FilesystemPresheaf
│   └── prompt_state:PromptStatePresheaf
│
├── sheaves:SheafBundle
│   ├── ParameterSemanticsSheaf
│   ├── GeneratedColumnsSheaf
│   ├── TableOutputSheaf
│   └── HtmlReferenceSheaf
│
├── morphisms:MorphismBundle
│   ├── AliasMorphisms
│   ├── RangeMorphisms
│   ├── PromptMorphisms
│   └── RendererMorphisms
│
├── universal:UniversalBundle
│
├── category_theory:CategoryTheoryBundle
│   ├── CategorySpec[]
│   ├── FunctorSpec[]
│   └── NaturalTransformationSpec[]
│
├── table_state:TableStateBundle
│   └── TableStateSections
│       ├── TableDisplayState
│       └── GeneratedColumnSection
│
├── table_runtime:TableRuntimeBundle
│   └── Tables
│
├── execution_network:ExecutionNetworkBundle
│   ├── ExecutionNetworkConfig
│   ├── ResourceSemaphore
│   ├── ExecutionTask[]
│   └── ExecutionResult[]
│
├── output_syntax:OutputSyntaxBundle
│   ├── csvSyntax
│   ├── markdownSyntax
│   ├── htmlSyntax
│   ├── bbCodeSyntax
│   └── emacsSyntax
│
└── persistence:PersistenceBundle
    ├── PersistenceConfig
    └── SQLite
```

## 6. Kernaussage

Das wichtigste Strukturprinzip von `reta_arch` ist:

```text
wenig tiefe Vererbung
+
viele kleine Bundle- und Dataclass-Objekte
+
Komposition in RetaArchitecture
```

Die zentralen Vererbungen betreffen hauptsächlich:

```text
Prägarben
Ausgabe-Syntaxen
Prompt-Completer
Enums
Exceptions
```

Die übrige Architektur wird überwiegend durch Objektbeziehungen aufgebaut:

```text
Aggregation
Komposition
Abhängigkeit
Faktorisierung
Funktoren
natürliche Transformationen
```

