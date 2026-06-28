# Graph-/DAG-Diagramm für `reta_arch`

Dieses Diagramm stellt `reta_arch` als **gerichteten azyklischen Abhängigkeitsgraphen** dar.

```plantuml
@startuml
top to bottom direction

skinparam shadowing false
skinparam componentStyle rectangle
skinparam linetype ortho

rectangle "Eingabequellen" {
  component "CLI\nreta.py" as CLI
  component "Prompt\nretaPrompt.py" as Prompt
  database "CSV-Dateien" as CSV
  database "Sprachdaten / i18n" as I18N
  database "SQLite-Cache" as SQLite
}

rectangle "Ebene 1: Eingabeinterpretation" {
  component "prompt_runtime.py" as PromptRuntime
  component "prompt_session.py" as PromptSession
  component "prompt_preparation.py" as PromptPreparation
  component "prompt_interaction.py" as PromptInteraction
  component "prompt_execution.py" as PromptExecution
  component "input_semantics.py" as InputSemantics
  component "parameter_runtime.py" as ParameterRuntime
}

rectangle "Ebene 2: Schema und Kontext" {
  component "tag_schema.py" as TagSchema
  component "schema.py" as Schema
  component "topology.py" as Topology
}

rectangle "Ebene 3: lokale und globale Semantik" {
  component "presheaves.py" as Presheaves
  component "morphisms.py" as Morphisms
  component "sheaves.py" as Sheaves
  component "universal.py" as Universal
  component "category_theory.py" as CategoryTheory
  component "semantics_builder.py" as SemanticsBuilder
}

rectangle "Ebene 4: Auswahlgraph" {
  component "row_ranges.py" as RowRanges
  component "row_filtering.py" as RowFiltering
  component "column_selection.py" as ColumnSelection
}

rectangle "Ebene 5: Berechnungsgraph" {
  component "number_theory.py" as NumberTheory
  component "arithmetic.py" as Arithmetic
  component "generated_columns.py" as GeneratedColumns
  component "meta_columns.py" as MetaColumns
  component "concat_csv.py" as ConcatCSV
  component "combi_join.py" as CombiJoin
}

rectangle "Ebene 6: Tabellengraph" {
  component "table_preparation.py" as TablePreparation
  component "table_generation.py" as TableGeneration
  component "table_state.py" as TableState
  component "table_runtime.py" as TableRuntime
  component "program_workflow.py" as Workflow
}

rectangle "Ebene 7: paralleler Ausführungsgraph" {
  component "parallel_execution.py" as ParallelExecution
  component "Task 1" as Task1
  component "Task 2" as Task2
  component "Task N" as TaskN

  component "execution_network.py\nFIFO / LIFO / Priority" as ExecutionNetwork

  component "Worker 1" as Worker1
  component "Worker 2" as Worker2
  component "Worker N" as WorkerN

  component "Result 1" as Result1
  component "Result 2" as Result2
  component "Result N" as ResultN

  component "deterministische\nReduktion" as Reduction
}

rectangle "Ebene 8: Ausgabeverarbeitung" {
  component "table_wrapping.py" as TableWrapping
  component "table_output.py" as TableOutput
  component "table_adapters.py" as TableAdapters
  component "output_semantics.py" as OutputSemantics
  component "output_syntax.py" as OutputSyntax
  component "console_io.py" as ConsoleIO
}

rectangle "Ausgabeziele" {
  component "Shell" as Shell
  component "HTML" as HTML
  component "CSV" as CSVOutput
  component "Markdown" as Markdown
  component "BBCode" as BBCode
  component "Emacs" as Emacs
}

rectangle "Persistenz-Seitengraph" {
  component "persistence.py" as Persistence
}

CLI --> InputSemantics
Prompt --> PromptRuntime

PromptRuntime --> PromptSession
PromptSession --> PromptPreparation
PromptPreparation --> PromptInteraction
PromptInteraction --> PromptExecution
PromptExecution --> InputSemantics

I18N --> InputSemantics
TagSchema --> Schema
Schema --> InputSemantics
Schema --> Topology

InputSemantics --> ParameterRuntime

Topology --> Presheaves
ParameterRuntime --> Presheaves
ParameterRuntime --> Morphisms

Presheaves --> Sheaves
Morphisms --> Sheaves

CategoryTheory --> Universal
Topology --> Universal
Sheaves --> Universal

Sheaves --> SemanticsBuilder
Universal --> SemanticsBuilder
Morphisms --> SemanticsBuilder

ParameterRuntime --> RowRanges
RowRanges --> RowFiltering

ParameterRuntime --> ColumnSelection

ColumnSelection --> GeneratedColumns
NumberTheory --> GeneratedColumns
Arithmetic --> GeneratedColumns
GeneratedColumns --> MetaColumns

CSV --> ConcatCSV
CSV --> CombiJoin
CSV --> TablePreparation

ConcatCSV --> TablePreparation
CombiJoin --> TablePreparation

RowFiltering --> TablePreparation
ColumnSelection --> TablePreparation
GeneratedColumns --> TablePreparation
MetaColumns --> TablePreparation
SemanticsBuilder --> TablePreparation

TablePreparation --> TableGeneration
TableGeneration --> TableState
TableState --> TableRuntime
TableRuntime --> Workflow

Workflow --> ParallelExecution

ParallelExecution --> Task1
ParallelExecution --> Task2
ParallelExecution --> TaskN

Task1 --> ExecutionNetwork
Task2 --> ExecutionNetwork
TaskN --> ExecutionNetwork

ExecutionNetwork --> Worker1
ExecutionNetwork --> Worker2
ExecutionNetwork --> WorkerN

Worker1 --> Result1
Worker2 --> Result2
WorkerN --> ResultN

Result1 --> Reduction
Result2 --> Reduction
ResultN --> Reduction

Reduction --> TableWrapping

Workflow --> TableWrapping : serieller Pfad

TableWrapping --> TableOutput
TableAdapters --> TableOutput

ParameterRuntime --> OutputSemantics
OutputSemantics --> OutputSyntax
TableOutput --> OutputSyntax

OutputSyntax --> ConsoleIO
OutputSyntax --> HTML
OutputSyntax --> CSVOutput
OutputSyntax --> Markdown
OutputSyntax --> BBCode
OutputSyntax --> Emacs

ConsoleIO --> Shell

Topology --> Persistence
Presheaves --> Persistence
Sheaves --> Persistence
ExecutionNetwork --> Persistence
Reduction --> Persistence
OutputSyntax --> Persistence

Persistence --> SQLite

SQLite --> Persistence
Persistence --> TablePreparation : Cache-Treffer

@enduml
```

## Vereinfachter Gesamt-DAG

```text
                         ┌──────────────┐
                         │ CLI / Prompt │
                         └──────┬───────┘
                                │
                                ▼
                     ┌─────────────────────┐
                     │ Eingabesemantik     │
                     │ input_semantics.py  │
                     └──────────┬──────────┘
                                │
                                ▼
                     ┌─────────────────────┐
                     │ Parametersemantik   │
                     │ parameter_runtime   │
                     └───┬───────────┬─────┘
                         │           │
              ┌──────────┘           └──────────┐
              ▼                                 ▼
     ┌─────────────────┐              ┌──────────────────┐
     │ Zeilenauswahl   │              │ Spaltenauswahl   │
     │ row_ranges      │              │ column_selection │
     │ row_filtering   │              └────────┬─────────┘
     └────────┬────────┘                       │
              │                     ┌──────────┼───────────┐
              │                     ▼          ▼           ▼
              │              Zahlentheorie  Arithmetik   Meta
              │                     \          |          /
              │                      \         |         /
              │                       ▼        ▼        ▼
              │                      generated_columns
              │                              │
              └───────────────┬──────────────┘
                              │
                              ▼
                       ┌─────────────┐
                       │ CSV-Daten   │
                       │ Kombi-Daten │
                       └──────┬──────┘
                              │
                              ▼
                   ┌────────────────────┐
                   │ Tabellenvorbereitung│
                   └─────────┬──────────┘
                             │
                             ▼
                   ┌────────────────────┐
                   │ Tabellengenerierung│
                   └─────────┬──────────┘
                             │
                             ▼
                    ┌───────────────────┐
                    │ Tabellenzustand   │
                    └─────────┬─────────┘
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
             serieller Pfad       paralleler Pfad
                    │                    │
                    │              ┌─────┴─────┐
                    │              ▼     ▼     ▼
                    │            Task1 Task2 TaskN
                    │              │     │     │
                    │              ▼     ▼     ▼
                    │           Worker Worker Worker
                    │              │     │     │
                    │              ▼     ▼     ▼
                    │           Result Result Result
                    │              └─────┬─────┘
                    │                    ▼
                    │          deterministische
                    │              Reduktion
                    │                    │
                    └──────────┬─────────┘
                               │
                               ▼
                      ┌─────────────────┐
                      │ Tabellenoutput  │
                      └────────┬────────┘
                               │
                               ▼
                      ┌─────────────────┐
                      │ Output-Syntax   │
                      └────────┬────────┘
                               │
             ┌─────────┬───────┼───────┬─────────┐
             ▼         ▼       ▼       ▼         ▼
           Shell      HTML     CSV   Markdown   BBCode
```

## Semantischer Teilgraph

```text
Schema
  │
  ▼
Topologie
  │
  ▼
Prägarben
  │
  ▼
Garben
  │
  ├──────────────┐
  │              │
  ▼              ▼
Morphismen   universelle
             Eigenschaften
  │              │
  └──────┬───────┘
         ▼
semantics_builder.py
         │
         ▼
globale kanonische Semantik
```

## Paralleler DAG

```text
                     Tabellenarbeit
                           │
                           ▼
                 parallel_execution.py
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
     ExecutionTask 1  ExecutionTask 2  ExecutionTask N
          │                │                │
          └────────────────┼────────────────┘
                           ▼
                 execution_network.py
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
       Worker 1         Worker 2         Worker N
          │                │                │
          ▼                ▼                ▼
       Result 1         Result 2         Result N
          │                │                │
          └────────────────┼────────────────┘
                           ▼
                deterministische Reduktion
                           │
                           ▼
                 geordnete Gesamttabelle
```

## Ebenen des DAG

| Ebene | Inhalt | Parallelisierbarkeit |
|---:|---|---|
| 1 | Eingabe und Prompt | gering |
| 2 | Schema und Topologie | meist statisch |
| 3 | Prägarben, Garben und Semantik | teilweise |
| 4 | Zeilen- und Spaltenauswahl | gut parallelisierbar |
| 5 | Zahlentheorie und generierte Spalten | sehr gut parallelisierbar |
| 6 | Tabellenvorbereitung und Generierung | teilweise |
| 7 | Tasks, Worker und Ergebnisse | explizit parallel |
| 8 | Rendering der Ausgabeformate | je Format parallel möglich |

## Warum es ein DAG ist

Der Graph ist gerichtet:

```text
Eingabe → Semantik → Auswahl → Tabelle → Ausgabe
```

Er ist azyklisch, wenn eine einzelne Programmausführung betrachtet wird:

```text
Ein Verarbeitungsschritt benötigt Ergebnisse vorheriger Schritte,
liefert aber keine Daten an einen bereits abgeschlossenen Vorgänger zurück.
```

Cache-Lesen und Persistenz sind dabei Seitengraphen. Sie dürfen nicht als Rückkopplung innerhalb derselben Berechnung interpretiert werden:

```text
frühere Ausführung
      │
      ▼
SQLite-Cache
      │
      ▼
neue Ausführung
```

## Zentrale Faktorisierung

Der Gesamtablauf wird in Teilmorphismen zerlegt:

```text
f =
Ausgabe
∘ Rendering
∘ Reduktion
∘ Ausführung
∘ Tabellengenerierung
∘ Auswahl
∘ Semantikbildung
∘ Eingabeinterpretation
```

Der DAG erweitert diese reine Kette um unabhängige parallele Zweige:

```text
                     ┌→ Zeilenauswahl ─────┐
Parametersemantik ───┼→ Spaltenauswahl ────┼→ Tabelle
                     ├→ generierte Spalten ┤
                     └→ Kombinationsdaten ─┘
```

Damit ist der `reta_arch`-Ablauf nicht bloß eine Pipeline, sondern eine Kombination aus:

```text
Pipeline
+ Verzweigungen
+ Diamanten
+ Parallelitätsgraphen
+ deterministischer Zusammenführung
```
