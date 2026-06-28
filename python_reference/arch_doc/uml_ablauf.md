Eingabe
→ Prägarben
→ Garben/Gluing
→ kanonische Semantik
→ Tabellen
→ optionale generierte Spalten
→ optionale Parallelisierung
→ optionale SQLite-Persistenz
→ Rendering
→ Ausgabe


@startuml
start

:Benutzereingabe / CLI / Prompt;

:PromptStatePresheaf erzeugen;
:FilesystemPresheaf lädt CSV, Übersetzungen, Assets;

:PresheafBundle sammeln;

if (Lokale Sektionen kompatibel?) then (ja)
  :PresheafToSheafGluingTransformation;
  :ParameterSemanticsSheaf erzeugen;
else (nein)
  :Fehler / Validierung abbrechen;
  stop
endif

:AliasMorphisms anwenden;
:RangeMorphisms anwenden;
:PromptMorphisms anwenden;

:CanonicalParameterSheafFunctor;
:kanonische Parametersemantik;

:TableGenerationGluingFunctor;
:Tables / TableSection erzeugen;

if (generierte Spalten?) then (ja)
  :GeneratedColumnEndofunctorFamily;
  :GeneratedColumnsSheaf synchronisieren;
endif

if (parallel / chunked execution?) then (ja)
  :TableChunkExecutionFunctor;
  :ExecutionTask erzeugen;
  :Queue / Scheduler / Worker;
  :ExecutionResult sammeln;
  :ExecutionResultGluingFunctor;
  :deterministische Reduktion;
endif

:TableOutputSheaf erzeugen;

if (Cache/Persistenz aktiv?) then (ja)
  :PersistenceBundle;
  :SQLite speichern;
  :Snapshots / Cache / Audit;
endif

:OutputRenderingFunctorFamily;
:RendererMorphisms anwenden;

if (Normalisierung nötig?) then (ja)
  :RenderedOutputNormalizationTransformation;
endif

:Ausgabe erzeugen;
:Shell / HTML / CSV / Markdown / BBCode;

stop
@enduml
