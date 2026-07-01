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

## `bin/` gegenüber `target/bin/`

`bin/` enthält die stabilen, versionierten **Startskripte und Symlinks**. Sie
sind selbst keine kompilierten Mojo-Programme: Sie wählen ein Profil, setzen
Pfade oder Umgebungsvariablen und starten das passende Ziel. Die tatsächlichen
kompilierten ELF-Binaries entstehen durch `scripts/build.sh` beziehungsweise
`scripts/build-heavy.sh` unter `target/bin/` und gehören nicht in Git.

Kurzzuordnung:

- `bin/reta`: öffentlicher native-first Tabellenlauncher; vollständig besessene Argumente laufen in Mojo, Restargumente fallen während der Migration atomar auf Python zurück;
- `bin/reta-native`: strikter nativer Entwickler-/Diagnosepfad ohne Ownership-Prüfung und ohne Python-Fallback;
- `bin/reta-mojo-compat`: expliziter Übergangsname für denselben native-first Kompatibilitätskern, den `bin/reta` normalerweise startet;
- `bin/rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*`: Symlinks/Profile desselben nativen Promptprogramms;
- `bin/prim`, `prim24`, `multis`, `multis3`, `modulo`, `math`: Komfortstarter mit vorbereiteten Promptbefehlen;
- `bin/grundStrukHtml`, `generate_html`: HTML-Werkzeuge;
- `bin/reta-mojo-*`: Architektur-, Prüf-, Persistenz- und Parallelisierungswerkzeuge;
- `bin/mojo-real`: Auswahl des echten Modular-Mojo-Compilers.

Fehlt ein Ziel in `target/bin/`, meldet der Launcher den nötigen Buildschritt
oder verwendet bei leichten Zielen den dokumentierten `mojo run`-Fallback.

## Wichtige Tabellenpfade

Native-first historische Oberfläche mit atomarem Python-Fallback für noch nicht besessene Argumentvektoren:

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

`RETA_NATIVE=1` erzwingt den nativen Pfad. Die normale `./reta`-Ausführung entscheidet seit Stage 12c4e konservativ selbst; Stage 12c4f besitzt zusätzlich die Shell-Ein-Tabellen- und Justtext-Ausgabe; Stage 12c4g erweitert die Ein-Tabellen-Aliase auf HTML und BBCode; Stage 12c4h/12c4i besitzen No-blank und die paginierten Kernrenderer; Stage 12c4j besitzt positive individuelle Shell-/HTML-/BBCode-Spaltenbreiten; `RETA_FORCE_REFERENCE=1` erzwingt die vollständige Python-Referenz.

## Zielzustand nach vollständiger Transpilierung

Für die normale Nutzung wird dann nur noch **ein öffentlicher Startname** benötigt:

```text
reta
```

`reta-native` kann als optionaler Diagnosealias erhalten bleiben, um den strikt
nativen Pfad ausdrücklich zu erzwingen. `reta-mojo-compat` ist nach Entfernung
des letzten Python-Fallbacks semantisch überflüssig; Stage 12e kann den Namen
löschen oder nur als rückwärtskompatiblen Symlink auf `reta` behalten. Auch die
zwei heutigen Compilerziele `reta-native` und `reta-mojo-compat-bin` können dann
zu einem einzigen Releasebinary `target/bin/reta` zusammengeführt werden.

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
| normale `reta`-Ausführung | `target/bin/reta-mojo-compat-bin` | native-first bei vollständig besessenen Argumentvektoren; sonst atomarer Python-Kindprozessfallback; kein eingebettetes CPython |
| `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*` | `target/bin/reta-prompt-native` | explizite One-shots, besessene Tabellen, sämtliche kompakte Tabellenfamilien sowie reine Zahlen-/Bruch-, Null-/Negativ-, Ausschluss- und wiederholte 15/16-Katalogkompositionen laufen ohne Python-/`reta-native`-Kindprozess; echte `v n/m`-Vielfache mit Zähler größer 1 und seltene hintere Sonderzweige bleiben an der Bridge |
| eigenständige verschachtelte Completion | `target/bin/reta-prompt-complete` | persistenter Mojo-Arbeiter als Kompatibilitäts-/Testziel; der interaktive TTY-Editor vervollständigt direkt |
| `grundStrukHtml*` | `target/bin/grundStrukHtml-native` | Renderer nativ |
| `generate_html` | `target/bin/generate-html-native` | vollständig nativ einschließlich `--alles`-Mitteltabelle |
| Tabellenzustand/CSV/Wrapping | `target/bin/reta-mojo-table` | nativ |
| Tag-Schema | `target/bin/reta-mojo-tags` | nativ |
| Architekturkarte und Kapselgrenzen | `target/bin/reta-mojo-architecture`, `target/bin/reta-mojo-boundaries` | generierte Metadaten und Abfragen nativ; Python-AST-Scan nur bei Regeneration |
| Architekturverträge und Witnesses | `target/bin/reta-mojo-contracts`, `target/bin/reta-mojo-witnesses` | kommutierende Verträge, Kapselgesetze, Repository-Anker und Nachweisnavigation nativ; Python nur bei Regeneration |
| Kohärenz und Traces | `target/bin/reta-mojo-coherence`, `target/bin/reta-mojo-traces` | Kapsel-/Routenkohärenz und Legacy→Gesetz-Trace-Navigation nativ; Python nur bei Regeneration |
| Impact und Migration | `target/bin/reta-mojo-impact`, `target/bin/reta-mojo-migration` | Impact-Routen, Regression-Gates, geordnete Wellen, Schritte und Invarianten nativ; Python nur bei Regeneration |
| Rehearsal und Aktivierung | `target/bin/reta-mojo-rehearsal`, `target/bin/reta-mojo-activation` | Trockenlauf-Moves, Gate-Suiten, Readiness-Cover, Commit-Gates, Rollbacks und Transaktionen nativ; Python nur bei Regeneration |
| Gesamtvalidierung und Fortschritt | `target/bin/reta-mojo-validation`, `target/bin/reta-mojo-progress` | 51 Architekturchecks, 17 Schichten und Stage-42-Overlay mit Oberflächen-, Schritt-, Wellen- und Arbeitsrestnavigation nativ; Python/AST/Git nur bei Regeneration |
| Persistenz | `target/bin/reta-mojo-persistence` | sechs SQLite-Tabellen, zwölf Morphismen, Python-kompatible SHA-256-Digests, Sections, Garben-Snapshots, Runs, Audit, Cache und Batchpfade vollständig nativ |
| Ausführungsnetz | `target/bin/reta-mojo-execution-network` | FIFO/LIFO/Priorität, Kanäle, Semaphoren, typisierte Mojo-Threads und deterministische Reduktion vollständig nativ; statische UTF-8-Operationsgrenze |
| Tabellen-/Zahlenparallelisierung | `target/bin/reta-mojo-parallel-execution` | zehn reine Kerne über typisierte native Mojo-Thread-Chunks; historische Prozessoptionen sind ausschließlich Kompatibilitätsalias und erzeugen keinen Prozess |
| Typisierte Zeilenvorbereitung | `target/bin/reta-mojo-row-preparation` | besitzender `ParallelRowPreparationContext`, disjunkte Chunkslots, deterministische Reduktion und Python↔seriell↔Thread-Parität ohne `deepcopy` oder Pickle |

Lokale Installation der Launcher:

```bash
./scripts/install_bins.sh
```
