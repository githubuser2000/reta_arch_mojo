# Öffentliche Programme und Compilerziele

## Öffentliche Startnamen

Die historischen Namen bleiben in der Projektwurzel sowie unter `bin/` beziehungsweise `run/` verfügbar:

```text
reta                 reta-native
reta.english         retaPrompt
retaPrompt.english   rp rpl rpb rpe
prim prim24          multis multis3 modulo math
grundStrukHtml       grundStrukHtml.py
generate_html          reta-mojo-boundaries
reta-mojo-contracts     reta-mojo-witnesses
reta-mojo-coherence     reta-mojo-traces
reta-mojo-impact        reta-mojo-migration
reta-mojo-rehearsal     reta-mojo-activation
reta-mojo-validation    reta-mojo-progress
reta-mojo-persistence     reta-mojo-execution-network
reta-mojo-parallel-execution  reta-mojo-row-preparation
```

## Wichtige Tabellenpfade

Vollständige Kompatibilität über die Python-Referenz:

```bash
./reta -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon
```

Expliziter nativer Stufe-6-Pfad:

```bash
./reta-native -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Derselbe Pfad über den historischen Namen:

```bash
RETA_NATIVE=1 ./reta -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Der Umschalter ist absichtlich explizit, solange nicht sämtliche Tabellenfunktionen nativ sind.

## Native Inspektionsprogramme

```bash
./bin/reta-mojo --mojo-prime 60
./bin/reta-mojo --mojo-range '1-9,-3' 100
./bin/reta-mojo --mojo-csv-info
./bin/reta-mojo --mojo-table-state 42
./bin/reta-mojo --mojo-wrap 2 'äöü漢字'
./bin/reta-mojo --mojo-tags 216
./bin/reta-mojo --mojo-tag-columns sternPolygon,universum
./bin/reta-mojo-boundaries --summary
./bin/reta-mojo-boundaries --module reta.py
./bin/reta-mojo-boundaries --capsule InputPromptCapsule
./bin/reta-mojo-contracts --summary
./bin/reta-mojo-contracts --diagram RawCommandNaturalitySquare
./bin/reta-mojo-witnesses --summary
./bin/reta-mojo-witnesses --anchor RetaArchitectureRoot reta_architecture/facade.py
./bin/reta-mojo-coherence --summary
./bin/reta-mojo-coherence --route SchemaTopologyCapsule LocalSectionCapsule
./bin/reta-mojo-traces --summary
./bin/reta-mojo-traces --component reta.py
./bin/reta-mojo-impact --summary
./bin/reta-mojo-impact --source reta.py
./bin/reta-mojo-migration --summary
./bin/reta-mojo-migration --wave M3
./bin/reta-mojo-rehearsal --summary
./bin/reta-mojo-rehearsal --move REH35-MOVE-MIG34-01
./bin/reta-mojo-activation --summary
./bin/reta-mojo-activation --transaction ACT36-TX-M0
./bin/reta-mojo-validation --summary
./bin/reta-mojo-validation --check CategoryFunctorReferenceCheck
./bin/reta-mojo-progress --summary
./bin/reta-mojo-progress --surface reta.py
./bin/reta-mojo-persistence --summary
./bin/reta-mojo-persistence --demo /tmp/reta-persistence.db
./bin/reta-mojo-execution-network --summary
./bin/reta-mojo-execution-network --run-process fifo
./bin/reta-mojo-parallel-execution --summary
./bin/reta-mojo-parallel-execution --demo 2 2
./bin/reta-mojo-parallel-execution --demo-threads 2 2
./bin/reta-mojo-row-preparation --summary 8 128 512
./bin/reta-mojo-row-preparation --demo 2 2
```

## Zuordnung

| Oberfläche | Compilerziel | Grenze |
|---|---|---|
| `reta-native`, `RETA_NATIVE=1 ./reta` | `target/bin/reta-native` | erster nativer Tabellenpfad |
| normale `reta`-Ausführung | `target/bin/reta-mojo-compat-bin` | vollständige historische Oberfläche |
| `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*` | `target/bin/reta-prompt-native` | explizite One-shots, besessene Tabellen, sämtliche kompakte Tabellenfamilien sowie reine Zahlen-/Bruch-, Null-/Negativ-, Ausschluss- und wiederholte 15/16-Katalogkompositionen laufen ohne Python-/`reta-native`-Kindprozess; echte `v n/m`-Vielfache mit Zähler größer 1 und seltene hintere Sonderzweige bleiben an der Bridge |
| interaktive verschachtelte Completion | `target/bin/reta-prompt-complete` | persistenter Mojo-Arbeiter; Readline ist nur Terminalgrenze |
| `grundStrukHtml*` | `target/bin/grundStrukHtml-native` | Renderer nativ |
| `generate_html` | `target/bin/generate-html-native` | Komposition nativ, große Mitteltabelle noch Bridge |
| Tabellenzustand/CSV/Wrapping | `target/bin/reta-mojo-table` | nativ |
| Tag-Schema | `target/bin/reta-mojo-tags` | nativ |
| Architekturkarte und Kapselgrenzen | `target/bin/reta-mojo-architecture`, `target/bin/reta-mojo-boundaries` | generierte Metadaten und Abfragen nativ; Python-AST-Scan nur bei Regeneration |
| Architekturverträge und Witnesses | `target/bin/reta-mojo-contracts`, `target/bin/reta-mojo-witnesses` | kommutierende Verträge, Kapselgesetze, Repository-Anker und Nachweisnavigation nativ; Python nur bei Regeneration |
| Kohärenz und Traces | `target/bin/reta-mojo-coherence`, `target/bin/reta-mojo-traces` | Kapsel-/Routenkohärenz und Legacy→Gesetz-Trace-Navigation nativ; Python nur bei Regeneration |
| Impact und Migration | `target/bin/reta-mojo-impact`, `target/bin/reta-mojo-migration` | Impact-Routen, Regression-Gates, geordnete Wellen, Schritte und Invarianten nativ; Python nur bei Regeneration |
| Rehearsal und Aktivierung | `target/bin/reta-mojo-rehearsal`, `target/bin/reta-mojo-activation` | Trockenlauf-Moves, Gate-Suiten, Readiness-Cover, Commit-Gates, Rollbacks und Transaktionen nativ; Python nur bei Regeneration |
| Gesamtvalidierung und Fortschritt | `target/bin/reta-mojo-validation`, `target/bin/reta-mojo-progress` | 51 Architekturchecks, 17 Schichten und Stage-42-Overlay mit Oberflächen-, Schritt-, Wellen- und Arbeitsrestnavigation nativ; Python/AST/Git nur bei Regeneration |
| Persistenz | `target/bin/reta-mojo-persistence` | sechs SQLite-Tabellen, zwölf Morphismen, Python-kompatible SHA-256-Digests, Sections, Garben-Snapshots, Runs, Audit, Cache und Batchpfade vollständig nativ |
| Ausführungsnetz | `target/bin/reta-mojo-execution-network` | FIFO/LIFO/Priorität, Kanäle, Semaphoren, deterministische Reduktion und echte Linux-`fork`-Worker vollständig nativ; statische UTF-8-Operationsgrenze |
| Hybride Tabellen-/Zahlenparallelisierung | `target/bin/reta-mojo-parallel-execution` | `auto`/`threads` über native Mojo-Threads; zehn reine Kerne; explizites `processes`-Backend mit echten Linux-`fork`-Chunks bleibt als Isolationsmodus |
| Typisierte Zeilenvorbereitung | `target/bin/reta-mojo-row-preparation` | besitzender `ParallelRowPreparationContext`, disjunkte Chunkslots, deterministische Reduktion und Python↔seriell↔Thread-Parität ohne `deepcopy` oder Pickle |

Lokale Installation der Launcher:

```bash
./scripts/install_bins.sh
```
