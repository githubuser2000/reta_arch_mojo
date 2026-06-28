# UML-Kompositionsdiagramm für `reta_arch`

```plantuml
@startuml
top to bottom direction

skinparam classAttributeIconSize 0
skinparam shadowing false
skinparam linetype ortho
hide empty members

legend right
  *--  starke Komposition
  o--  Aggregation
  -->  Abhängigkeit
endlegend

package "Gesamtarchitektur" {

  class RetaArchitecture {
    +repo_root
    --
    +bootstrap()
  }

  class RetaContextSchema
  class RetaContextTopology
  class PresheafBundle
  class SheafBundle
  class MorphismBundle
  class UniversalBundle
  class CategoryTheoryBundle
  class TableStateBundle
  class TableRuntimeBundle
  class ExecutionNetworkBundle
  class PersistenceBundle
  class OutputSyntaxBundle
}

RetaArchitecture *-- RetaContextSchema : schema
RetaArchitecture *-- RetaContextTopology : topology
RetaArchitecture *-- PresheafBundle : presheaves
RetaArchitecture *-- SheafBundle : sheaves
RetaArchitecture *-- MorphismBundle : morphisms
RetaArchitecture *-- UniversalBundle : universal
RetaArchitecture *-- CategoryTheoryBundle : category_theory
RetaArchitecture *-- TableStateBundle : table_state
RetaArchitecture *-- TableRuntimeBundle : table_runtime
RetaArchitecture *-- ExecutionNetworkBundle : execution_network
RetaArchitecture *-- PersistenceBundle : persistence
RetaArchitecture *-- OutputSyntaxBundle : output_syntax


package "Topologie" {

  class ContextDimension {
    +name
    +values
    +aliases
  }

  class ContextSelection {
    +language
    +main_parameters
    +sub_parameters
    +row_parameters
    +output_modes
    +tag_names
    +scopes
  }
}

RetaContextTopology *-- "1..*" ContextDimension : dimensions
RetaContextTopology --> RetaContextSchema : verwendet
RetaContextTopology ..> ContextSelection : erzeugt


package "Prägarben" {

  class Presheaf
  class FilesystemPresheaf
  class PromptStatePresheaf

  class LocalSection {
    +context
    +payload
    +source
  }
}

PresheafBundle *-- FilesystemPresheaf : csv
PresheafBundle *-- FilesystemPresheaf : translations
PresheafBundle *-- FilesystemPresheaf : assets
PresheafBundle *-- PromptStatePresheaf : prompt_state

FilesystemPresheaf *-- "0..*" LocalSection : sections
PromptStatePresheaf *-- "0..*" LocalSection : sections

LocalSection --> ContextSelection : context


package "Garben" {

  class ParameterSemanticsSheaf
  class GeneratedColumnsSheaf
  class TableOutputSheaf
  class HtmlReferenceSheaf
}

SheafBundle *-- ParameterSemanticsSheaf : parameter_semantics
SheafBundle *-- GeneratedColumnsSheaf : generated_columns
SheafBundle *-- TableOutputSheaf : table_output
SheafBundle *-- HtmlReferenceSheaf : html_reference

ParameterSemanticsSheaf --> RetaContextSchema : basiert auf


package "Morphismen" {

  class AliasMorphisms
  class RangeMorphisms
  class PromptMorphisms
  class RendererMorphisms
}

MorphismBundle *-- AliasMorphisms : alias
MorphismBundle *-- RangeMorphisms : ranges
MorphismBundle *-- PromptMorphisms : prompt
MorphismBundle *-- RendererMorphisms : renderers

AliasMorphisms --> ParameterSemanticsSheaf
AliasMorphisms --> RetaContextTopology
RangeMorphisms --> RetaContextTopology
PromptMorphisms --> RetaContextTopology
RendererMorphisms --> RetaContextTopology

UniversalBundle --> SheafBundle : synchronisiert


package "Kategorientheorie" {

  class CategorySpec
  class CategoryObjectSpec
  class CategoryMorphismSpec
  class FunctorSpec
  class NaturalTransformationSpec
  class ParadigmTermSpec
}

CategoryTheoryBundle *-- "0..*" CategorySpec : categories
CategoryTheoryBundle *-- "0..*" FunctorSpec : functors
CategoryTheoryBundle *-- "0..*" NaturalTransformationSpec : transformations
CategoryTheoryBundle *-- "0..*" ParadigmTermSpec : paradigm_terms

CategorySpec *-- "0..*" CategoryObjectSpec : objects
CategorySpec *-- "0..*" CategoryMorphismSpec : morphisms

FunctorSpec --> CategorySpec : Quell- und Zielkategorie
NaturalTransformationSpec --> FunctorSpec : verbindet


package "Tabellenzustand" {

  class TableStateSections
  class TableDisplayState
  class GeneratedColumnSection
  class Tables
}

TableStateBundle *-- TableStateSections : erzeugter Zustand

TableStateSections *-- TableDisplayState : display
TableStateSections *-- GeneratedColumnSection : generated_columns

TableRuntimeBundle *-- Tables : aktive Tabelle
TableRuntimeBundle --> TableStateBundle : Zustandserzeugung


package "Ausführungsnetzwerk" {

  class ExecutionNetworkConfig
  class ResourceSemaphore
  class FifoTaskQueue
  class LifoTaskStack
  class PriorityTaskQueue
  class ExecutionTask
  class ExecutionRunResult
  class ExecutionResult
}

ExecutionNetworkBundle *-- ExecutionNetworkConfig : config

ExecutionNetworkBundle *-- ResourceSemaphore : cpu
ExecutionNetworkBundle *-- ResourceSemaphore : file_io
ExecutionNetworkBundle *-- ResourceSemaphore : output

FifoTaskQueue *-- "0..*" ExecutionTask : tasks
LifoTaskStack *-- "0..*" ExecutionTask : tasks
PriorityTaskQueue *-- "0..*" ExecutionTask : tasks

ExecutionRunResult *-- "0..*" ExecutionResult : results
ExecutionRunResult --> ExecutionNetworkConfig : config


package "Persistenz" {

  class PersistenceConfig
  class PersistedRecord
  database SQLite
}

PersistenceBundle *-- PersistenceConfig : config
PersistenceBundle --> SQLite : speichert
PersistenceBundle ..> PersistedRecord : erzeugt


package "Ausgabe" {

  class OutputSyntax
  class csvSyntax
  class markdownSyntax
  class htmlSyntax
  class bbCodeSyntax
  class emacsSyntax
  class NichtsSyntax
}

OutputSyntaxBundle o-- csvSyntax : csv
OutputSyntaxBundle o-- markdownSyntax : markdown
OutputSyntaxBundle o-- htmlSyntax : html
OutputSyntaxBundle o-- bbCodeSyntax : bbcode
OutputSyntaxBundle o-- emacsSyntax : emacs
OutputSyntaxBundle o-- NichtsSyntax : nichts

@enduml
```

## Vereinfachte Kompositionshierarchie

```text
RetaArchitecture
│
├── RetaContextSchema
│
├── RetaContextTopology
│   └── ContextDimension[]
│
├── PresheafBundle
│   ├── csv:FilesystemPresheaf
│   │   └── LocalSection[]
│   ├── translations:FilesystemPresheaf
│   │   └── LocalSection[]
│   ├── assets:FilesystemPresheaf
│   │   └── LocalSection[]
│   └── prompt_state:PromptStatePresheaf
│       └── LocalSection[]
│
├── SheafBundle
│   ├── ParameterSemanticsSheaf
│   ├── GeneratedColumnsSheaf
│   ├── TableOutputSheaf
│   └── HtmlReferenceSheaf
│
├── MorphismBundle
│   ├── AliasMorphisms
│   ├── RangeMorphisms
│   ├── PromptMorphisms
│   └── RendererMorphisms
│
├── UniversalBundle
│
├── CategoryTheoryBundle
│   ├── CategorySpec[]
│   │   ├── CategoryObjectSpec[]
│   │   └── CategoryMorphismSpec[]
│   ├── FunctorSpec[]
│   ├── NaturalTransformationSpec[]
│   └── ParadigmTermSpec[]
│
├── TableStateBundle
│   └── TableStateSections
│       ├── TableDisplayState
│       └── GeneratedColumnSection
│
├── TableRuntimeBundle
│   └── Tables
│
├── ExecutionNetworkBundle
│   ├── ExecutionNetworkConfig
│   └── ResourceSemaphore[]
│
├── PersistenceBundle
│   └── PersistenceConfig
│
└── OutputSyntaxBundle
    ├── csvSyntax
    ├── markdownSyntax
    ├── htmlSyntax
    ├── bbCodeSyntax
    ├── emacsSyntax
    └── NichtsSyntax
```

## Komposition gegenüber Aggregation

### Starke Komposition

PlantUML:

```plantuml
Ganzes *-- Teil
```

Bedeutung:

```text
Das Teilobjekt gehört strukturell zum Ganzen.
Das Ganze kontrolliert typischerweise Erzeugung und Lebensdauer.
```

Beispiele aus `reta_arch`:

```text
RetaArchitecture *-- SheafBundle
SheafBundle *-- ParameterSemanticsSheaf
MorphismBundle *-- AliasMorphisms
CategorySpec *-- CategoryObjectSpec
TableStateSections *-- TableDisplayState
```

### Aggregation

PlantUML:

```plantuml
Ganzes o-- Teil
```

Bedeutung:

```text
Das Ganze sammelt oder registriert Teile.
Die Teile können grundsätzlich unabhängig davon existieren.
```

Beispiel:

```text
OutputSyntaxBundle o-- markdownSyntax
```

Das Bundle registriert die Syntaxklasse, besitzt aber nicht zwingend jede später erzeugte Rendererinstanz.

## Architektonische Kernaussage

`reta_arch` verwendet Komposition auf mehreren Ebenen:

```text
RetaArchitecture
    komponiert Architektur-Bundles

Architektur-Bundles
    komponieren fachliche Dienste

fachliche Dienste
    komponieren Datenobjekte und Laufzeitzustände
```

Dadurch entsteht:

```text
kleine spezialisierte Klassen
+ klar begrenzte Zuständigkeiten
+ austauschbare Komponenten
+ wenig tiefe Vererbung
+ hierarchische Objektkomposition
```

