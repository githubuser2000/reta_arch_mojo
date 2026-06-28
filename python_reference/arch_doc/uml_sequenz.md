# UML-Sequenzdiagramm für `reta_arch`

Das Diagramm zeigt den typischen Ablauf:

```text
Benutzereingabe
→ Prompt-Prägarbe
→ kanonische Semantik
→ Tabellenaufbau
→ optionale Parallelisierung
→ Rendering
→ Persistenz
→ Ausgabe
```

```plantuml
@startuml
autonumber

actor Benutzer

participant "CLI / Prompt" as CLI
participant "PromptStatePresheaf" as PromptPresheaf
participant "FilesystemPresheaf" as FilePresheaf
participant "PresheafBundle" as PresheafBundle
participant "ParameterSemanticsSheaf" as SemanticsSheaf
participant "AliasMorphisms" as Alias
participant "RangeMorphisms" as Range
participant "TableGenerationGluingFunctor" as TableGeneration
participant "GeneratedColumnsSheaf" as GeneratedColumns
participant "TableChunkExecutionFunctor" as ChunkExecution
participant "ExecutionNetworkBundle" as ExecutionNetwork
participant "ExecutionResultGluingFunctor" as ResultGluing
participant "TableOutputSheaf" as TableOutput
participant "OutputRenderingFunctorFamily" as Renderer
participant "NormalizedOutputFunctor" as Normalizer
database "SQLite / PersistenceBundle" as Persistence

Benutzer -> CLI : reta-Befehl eingeben
activate CLI

CLI -> PromptPresheaf : Promptzustand als lokale Sektion speichern
activate PromptPresheaf
PromptPresheaf --> CLI : LocalSection
deactivate PromptPresheaf

CLI -> FilePresheaf : CSV, Übersetzungen und Assets laden
activate FilePresheaf
FilePresheaf --> CLI : lokale Dateisektionen
deactivate FilePresheaf

CLI -> PresheafBundle : lokale Sektionen bündeln
activate PresheafBundle

PresheafBundle -> SemanticsSheaf : lokale Sektionen kleben
activate SemanticsSheaf

SemanticsSheaf -> Alias : Aliase kanonisieren
activate Alias
Alias --> SemanticsSheaf : kanonische Parameter
deactivate Alias

SemanticsSheaf -> Range : Zeilenbereiche auswerten
activate Range
Range --> SemanticsSheaf : Zeilenmenge
deactivate Range

alt lokale Sektionen kompatibel
    SemanticsSheaf --> PresheafBundle : globale Parametersemantik
else lokale Sektionen unverträglich
    SemanticsSheaf --> CLI : Validierungsfehler
    CLI --> Benutzer : Fehlermeldung
    deactivate SemanticsSheaf
    deactivate PresheafBundle
    deactivate CLI
    stop
end

deactivate SemanticsSheaf
deactivate PresheafBundle

CLI -> TableGeneration : Tabelle aus Semantik erzeugen
activate TableGeneration
TableGeneration --> CLI : Tables / TableSection
deactivate TableGeneration

opt generierte Spalten angefordert
    CLI -> GeneratedColumns : generierte Spalten berechnen
    activate GeneratedColumns
    GeneratedColumns --> CLI : erweiterte Tabelle
    deactivate GeneratedColumns
end

alt parallele oder chunkbasierte Ausführung
    CLI -> ChunkExecution : Tabelle in Tasks zerlegen
    activate ChunkExecution
    ChunkExecution --> CLI : ExecutionTask-Liste
    deactivate ChunkExecution

    CLI -> ExecutionNetwork : Tasks einplanen
    activate ExecutionNetwork

    par Worker 1
        ExecutionNetwork -> ExecutionNetwork : Task 1 verarbeiten
    and Worker 2
        ExecutionNetwork -> ExecutionNetwork : Task 2 verarbeiten
    and Worker N
        ExecutionNetwork -> ExecutionNetwork : Task N verarbeiten
    end

    ExecutionNetwork --> CLI : ungeordnete ExecutionResults
    deactivate ExecutionNetwork

    CLI -> ResultGluing : Ergebnisse deterministisch reduzieren
    activate ResultGluing
    ResultGluing --> CLI : geordnete Gesamttabelle
    deactivate ResultGluing
else serielle Ausführung
    CLI -> CLI : Tabelle direkt weiterverarbeiten
end

CLI -> TableOutput : globale Ausgabesektion erzeugen
activate TableOutput
TableOutput --> CLI : TableOutput
deactivate TableOutput

opt Cache-Lesen aktiviert
    CLI -> Persistence : Cache-Schlüssel prüfen
    activate Persistence

    alt Cache-Eintrag vorhanden
        Persistence --> CLI : gespeicherte Ausgabe
        CLI --> Benutzer : gecachte Ausgabe
        deactivate Persistence
        deactivate CLI
        stop
    else kein Cache-Eintrag
        Persistence --> CLI : Cache Miss
    end

    deactivate Persistence
end

CLI -> Renderer : Tabelle rendern
activate Renderer

alt Ausgabeformat HTML
    Renderer -> Renderer : HTML erzeugen
else Ausgabeformat CSV
    Renderer -> Renderer : CSV erzeugen
else Ausgabeformat Markdown
    Renderer -> Renderer : Markdown erzeugen
else Ausgabeformat BBCode
    Renderer -> Renderer : BBCode erzeugen
else Ausgabeformat Shell
    Renderer -> Renderer : Terminalausgabe erzeugen
end

Renderer --> CLI : RenderedOutput
deactivate Renderer

opt Normalisierung für Vergleich oder Tests
    CLI -> Normalizer : Ausgabe normalisieren
    activate Normalizer
    Normalizer --> CLI : NormalizedOutput
    deactivate Normalizer
end

opt Persistenz, Cache oder Audit aktiviert
    CLI -> Persistence : Kontext speichern
    activate Persistence
    CLI -> Persistence : lokale Sektionen speichern
    CLI -> Persistence : Garben-Snapshot speichern
    CLI -> Persistence : Execution Run speichern
    CLI -> Persistence : Cache-Eintrag speichern
    CLI -> Persistence : Audit-Event speichern
    Persistence --> CLI : Speicherung bestätigt
    deactivate Persistence
end

CLI --> Benutzer : fertige Ausgabe
deactivate CLI

@enduml
```

## Vereinfachter Ablauf

```text
Benutzer
   │
   ▼
CLI / Prompt
   │
   ├──────────────► PromptStatePresheaf
   │
   ├──────────────► FilesystemPresheaf
   │
   ▼
PresheafBundle
   │
   ▼
ParameterSemanticsSheaf
   │
   ├──────────────► AliasMorphisms
   │
   └──────────────► RangeMorphisms
   │
   ▼
TableGenerationGluingFunctor
   │
   ▼
Tabelle
   │
   ├──────────────► GeneratedColumnsSheaf
   │
   └──────────────► ExecutionNetwork
                         │
                         ▼
               ExecutionResultGluingFunctor
   │
   ▼
TableOutputSheaf
   │
   ▼
OutputRenderingFunctorFamily
   │
   ▼
Normalisierung
   │
   ├──────────────► SQLite / Cache / Audit
   │
   ▼
Benutzer
```

## Parallelisierungsabschnitt

```text
Tabelle
   │
   ▼
TableChunkExecutionFunctor
   │
   ▼
ExecutionTask 1 ─────► Worker 1 ─────► Result 1
ExecutionTask 2 ─────► Worker 2 ─────► Result 2
ExecutionTask N ─────► Worker N ─────► Result N
                                           │
                                           ▼
                           ExecutionResultGluingFunctor
                                           │
                                           ▼
                               deterministisch geordnete
                                      Gesamttabelle
```

## Wichtigste Interaktionen

| Sender | Empfänger | Interaktion |
|---|---|---|
| `CLI` | `PromptStatePresheaf` | Prompt als lokale Sektion speichern |
| `CLI` | `FilesystemPresheaf` | CSV- und Asset-Daten laden |
| `PresheafBundle` | `ParameterSemanticsSheaf` | lokale Sektionen zu globaler Semantik kleben |
| `ParameterSemanticsSheaf` | `AliasMorphisms` | Parameter und Aliase kanonisieren |
| `ParameterSemanticsSheaf` | `RangeMorphisms` | Zeilenangaben in Zeilenmengen übersetzen |
| `CLI` | `TableGenerationGluingFunctor` | Tabelle aus Semantik erzeugen |
| `CLI` | `GeneratedColumnsSheaf` | berechnete Spalten hinzufügen |
| `CLI` | `ExecutionNetworkBundle` | Tasks ausführen |
| `CLI` | `ExecutionResultGluingFunctor` | parallele Ergebnisse geordnet zusammenführen |
| `CLI` | `OutputRenderingFunctorFamily` | Tabelle in Ausgabeformat übersetzen |
| `CLI` | `PersistenceBundle` | Kontexte, Snapshots, Cache und Audit speichern |
| `CLI` | `Benutzer` | fertige Ausgabe anzeigen |
