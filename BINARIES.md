# Öffentliche Programme und Compilerziele

## Produktions-Baubefehl

```bash
scripts/build-all.sh
```

Dieser Aufruf baut schwere und reguläre Ziele. `scripts/build.sh` erzeugt dabei
auch `libreta_diagnostics_mojo.so`; Stage-Tests sind für installierbare
Artefakte nicht erforderlich. `scripts/build-and-test-shared-diagnostics.sh`
ist nur ein optionales Paritätswerkzeug und trägt deshalb ausdrücklich
`build-and-test` im Namen.


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
reta-mojo-i18n          reta-mojo-semantics
reta-mojo-exports       reta-mojo-facade
reta-mojo-workflow      reta-mojo-sheaves      reta-mojo-diagnostics
reta-mojo-table-generation
reta-mojo-output-syntax  reta-mojo-console-io
reta-mojo-table-output   reta-mojo-domain-probe
reta-extract-html-classes generate4readme
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
- `bin/grundStrukHtml`, `generate_html`, `generate4readme`, `reta-extract-html-classes`: HTML-/README-/Metadatenwerkzeuge;
- `bin/reta-mojo-*`: Architektur-, Prüf-, Persistenz- und Parallelisierungswerkzeuge;
- `bin/mojo-real`: Auswahl des echten Modular-Mojo-Compilers;
- `bin/mojo-runtime-exec`: startet kompilierte Mojo-ELF-Dateien mit der lokal erkannten Runtime, auch wenn ihr älterer absoluter `RUNPATH` von einem anderen Rechner stammt.

Fehlt ein Ziel in `target/bin/`, meldet der Launcher den nötigen Buildschritt
oder verwendet bei leichten Zielen den dokumentierten `mojo run`-Fallback.


## Portable Binärübergabe zwischen Rechnern

Die kompilierten Programme hängen nicht an einem einkompilierten CSV-Ort. Sie
benötigen vor dem Start die private Modular-Laufzeitclosure (derzeit fünf
`.so`-Dateien).
Der gemeinsame portable Ort ist `target/lib/mojo`, relativ zum Projekt, nicht
ein identischer absoluter Home-Pfad.

```bash
./scripts/configure_mojo_runtime.sh
./reta --help
```

`scripts/build.sh` und `scripts/build-heavy.sh` betten zusätzlich
`$ORIGIN/../lib/mojo` als relativen `RUNPATH` ein. Die Diagnosebibliothek unter `target/lib/reta` verwendet passend `$ORIGIN/../mojo`. Für die Rechnerübergabe erzeugt `scripts/export_target.sh target target-portable.tar.xz` echte Runtime-Dateien statt der lokalen absoluten Symlinks. Die Launcher verwenden
`mojo-runtime-exec` als Abwärtskompatibilität für bereits vorhandene Binaries.

Bei einer manuellen Installation liegen die unveränderlichen Daten unter
`/usr/local/share/reta/{csv,assets}` und die privaten Programme unter
`/usr/local/lib/reta`. Ein Distributionspaket mit `PREFIX=/usr` verwendet
entsprechend `/usr/share/reta` und `/usr/lib/reta`; Fedora-/RPM-Pakete können
private Programme mit `LIBEXECDIR=/usr/libexec/reta` ablegen. `/usr/bin`
enthält nur die öffentlichen relativen Launcher-Symlinks.

## Exakte Installationsmenge bei `PREFIX=/usr`

Die **kompilierten ELF-Dateien** werden nicht direkt nach `/usr/bin`, sondern
nach `/usr/lib/reta/target/bin` installiert. Autoritativ ist
`scripts/install_targets.txt`. Sind beide Buildskripte vollständig gelaufen,
sind es **39 Executables plus eine Shared Library**:

```text
generate-html-native              generate-readme-native
reta-extract-html-classes-native   grundStrukHtml-native
reta-mojo-combi-join              reta-mojo-domain-probe
reta-mojo-architecture-probe      reta-mojo-compat-bin
reta-mojo-exports                 reta-mojo-facade
reta-mojo-workflow                reta-mojo-sheaves
reta-mojo-diagnostics             reta-mojo-i18n
reta-mojo-native                  reta-mojo-package-integrity
reta-mojo-table                   reta-mojo-tags
reta-native                       reta-prompt-complete
reta-prompt-native

reta-mojo-activation              reta-mojo-architecture
reta-mojo-boundaries              reta-mojo-coherence
reta-mojo-contracts               reta-mojo-execution-network
reta-mojo-impact                  reta-mojo-migration
reta-mojo-parallel-execution      reta-mojo-persistence
reta-mojo-progress                reta-mojo-rehearsal
reta-mojo-row-preparation         reta-mojo-schema
reta-mojo-semantics               reta-mojo-traces
reta-mojo-validation              reta-mojo-witnesses
```

Die ersten 21 Executables und `libreta_diagnostics_mojo.so` stammen aus `scripts/build.sh`; die letzten 18 Executables sind optionale
schwere Ziele aus `scripts/build-heavy.sh`. Nicht gebaute optionale Ziele werden
übersprungen. Andere Dateien in `target/bin`, insbesondere lokale Debug- oder
Altvarianten wie `reta-native-o0`, werden ausdrücklich **nicht** installiert.

`/usr/bin` enthält demgegenüber **56 öffentliche Namen als relative Symlinks**
auf Launcher unter `/usr/lib/reta/bin`; darunter sind Komfortnamen und Profile,
also nicht 54 verschiedene ELFs. Die zwei internen Helfer `mojo-real` und
`mojo-runtime-exec` bleiben nur privat unter `/usr/lib/reta/bin`. Standardmäßig
installiert `scripts/install.sh` nach `/usr/local`; `/usr` wird erst mit
`PREFIX=/usr` gewählt.

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

`RETA_NATIVE=1` erzwingt den nativen Pfad. Die normale `./reta`-Ausführung entscheidet seit Stage 12c4e konservativ selbst; Stage 12c4f besitzt zusätzlich die Shell-Ein-Tabellen- und Justtext-Ausgabe; Stage 12c4g erweitert die Ein-Tabellen-Aliase auf HTML und BBCode; Stage 12c4h/12c4i besitzen No-blank und die paginierten Kernrenderer; Stage 12c4j/12c4k besitzen positive und explizite Nullbreiten; Stage 12c4l besitzt zusätzlich rohes HTML/BBCode mit `--nocolor` und eine rechnerübergreifende Mojo-Runtimeauflösung; `RETA_FORCE_REFERENCE=1` erzwingt die vollständige Python-Referenz.

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
./bin/reta-mojo-i18n --summary english
./bin/reta-mojo-i18n --classify deutsch 3
./bin/reta-mojo-exports --summary
./bin/reta-mojo-exports --symbol RetaArchitecture
./bin/reta-mojo-exports --module prompt_session --public
./bin/reta-mojo-facade --summary
./bin/reta-mojo-facade --dependencies bootstrap
./bin/reta-mojo-workflow --summary
./bin/reta-mojo-workflow --load-religion plain 1024
./bin/reta-mojo-sheaves --summary
./bin/reta-mojo-sheaves --html 4
./bin/reta-mojo-table-generation --summary
./bin/reta-mojo-output-syntax --summary
./bin/reta-mojo-console-io --summary
./bin/reta-mojo-domain-probe pair religionen sternpolygon
./bin/reta-mojo-domain-probe reverse 4
./bin/reta-extract-html-classes htmlclassesPy.jsonl
./bin/reta-mojo-package-integrity --summary python_reference
./bin/reta-mojo-package-integrity --json-files python_reference
./bin/reta-mojo-semantics --normal
./bin/reta-mojo-semantics --invert
```

## Zuordnung

| Oberfläche | Compilerziel | Grenze |
|---|---|---|
| `reta-native`, `RETA_NATIVE=1 ./reta` | `target/bin/reta-native` | erster nativer Tabellenpfad |
| normale `reta`-Ausführung | `target/bin/reta-mojo-compat-bin` | native-first bei vollständig besessenen Argumentvektoren; sonst atomarer Python-Kindprozessfallback; kein eingebettetes CPython |
| `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*` | `target/bin/reta-prompt-native` | der native Interaktionsbesitzer steuert Sitzung, One-shots, Speicher-/Löschmodi und Previous-Command-Policy; besessene Tabellen sowie reine Zahlen-/Bruch- und Katalogkompositionen laufen ohne Python-/`reta-native`-Kindprozess, nur seltene ausdrücklich unbesessene hintere Sonderzweige bleiben am atomaren Referenzrand |
| eigenständige verschachtelte Completion | `target/bin/reta-prompt-complete` | persistenter Mojo-Arbeiter als Kompatibilitäts-/Testziel; der interaktive TTY-Editor vervollständigt direkt |
| `grundStrukHtml*` | `target/bin/grundStrukHtml-native` | Renderer nativ |
| `generate_html` | `target/bin/generate-html-native` | vollständig nativ einschließlich `--alles`-Mitteltabelle |
| Tabellenzustand/CSV/Wrapping | `target/bin/reta-mojo-table` | nativ |
| Tag-Schema | `target/bin/reta-mojo-tags` | nativ |
| Fünfsprachiger i18n-Wortbaum | `target/bin/reta-mojo-i18n` | 34.667 reproduzierbare Baumknoten, native Abfrage und verlustfreie Rückserialisierung |
| Paket-Reexportfassade | `target/bin/reta-mojo-exports` | 314 Importbindungen, 232 geordnete `__all__`-Exporte und 46 Besitzermodule reproduzierbar typisiert; Python nur bei expliziter Regeneration |
| Architektur-Kompositionsfassade | `target/bin/reta-mojo-facade` | 45 Felder, 49 Methoden, 45 Bootstrap-Schritte, 44 Rebuild-Einstiege, 98 Abhängigkeitskanten und 48 Snapshot-Einträge als reproduzierbarer nativer Graph; heterogene Laufzeitobjekte bleiben bis zur Portierung ihrer Besitzer teilweise nativ |
| Program-Workflow-Kern | `target/bin/reta-mojo-workflow` | geordneter 4-Felder-/11-Methoden-/12-Schritte-Vertrag; Religion-CSV, Zellendekodierung, native Threadzeilen, Sprachspaltenersatz, Flag-Reset und Kombi-Zweigplanung nativ; heterogene Legacy-Program-Aggregation noch teilweise nativ |
| Prägarben-/Garbendiagnose | `target/bin/reta-mojo-sheaves` | 269 lokale CSV-/i18n-/Assetsektionen, Promptzustand, Parametersemantik, Generator-/Ausgabesektionen und 669 vollständige HTML-Referenzen vollständig nativ |
| Tabellen-Gluing | `bin/reta-mojo-table-generation` → gemeinsame Diagnosebibliothek | typisierter Plan für CSV-Anfügung, Last-Line-Capture, zwölf Generatorfamilien und Galaxie-/Universum-Kombi-Join |
| Ausgabesemantik/-syntax | `bin/reta-mojo-output-syntax` → gemeinsame Diagnosebibliothek | sieben Modi, Aliase, Flags, Syntaxdeskriptoren, Bundle/Snapshot sowie typisierte HTML-/BBCode-/Textzellen |
| Gemeinsame Diagnose-ABI | `target/bin/reta-mojo-diagnostics` + `target/lib/reta/libreta_diagnostics_mojo.so` | vier kompatible Befehlsoberflächen für TableGeneration, OutputSyntax, ConsoleIO und TableOutput; versionierte C-ABI und Source-ID-Paarprüfung |
| Console-/Help-/Utility-Semantik | `bin/reta-mojo-console-io` → gemeinsame Diagnosebibliothek | Chunking, geordnete Eindeutigkeit, Ausgabe-/Debug-Effektplanung, beide Hilfetexte, Terminalkontext und geordneter Default-Container vollständig nativ |
| Domain-Probe-Kern | `target/bin/reta-mojo-domain-probe` | alle 16 Referenzbefehle nativ: Alias-/Paar-/Spaltenabfragen, HTML-, Schema- und vollständiger Architektursnapshot ohne Python-Laufzeit |
| Architektur-Gesamtprobe | `target/bin/reta-mojo-architecture-probe` | 63 reproduzierbare JSON-/Markdown-Oberflächen aus installierten Assets plus dynamische native Paketintegrität; portable Referenzpfadauflösung |
| HTML-Klassenextraktion | `target/bin/reta-extract-html-classes-native` | erzeugt die einzeilige All-Spalten-HTML-Tabelle nativ, analysiert doppelte Attribute/Klassen und schreibt 15-Feld-JSONL ohne Python, Regex oder Unterprozess |
| Quellbaum-Integrität | `target/bin/reta-mojo-package-integrity` | reguläre Dateien und Dateisymlinks, Runtime-Filter, 74 Pflichtpfade, CSV-Zeilen und binärer SHA-256-Gesamtdigest vollständig nativ; native Linux/POSIX-Verzeichnis-FFI und OpenSSL als Systemgrenzen |
| Parametersemantik | `target/bin/reta-mojo-semantics` | 431-Familien-Katalog, 4.155 Parameterpaare, 14 Datenslots, Normal-/Inversionsmodus und vollständiger UTF-8-Inhaltsfingerabdruck nativ; Python nur zur reproduzierbaren Katalogregeneration |
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

### `generate_html` als Systemkommando

`generate_html` ist das öffentliche POSIX-Frontend. Es löst den realen
Installationspfad auf, startet das private Mojo-Ziel und bietet atomare
Dateiausgabe, Sprachwahl, explizite Mitteltabellen, Ressourcenüberschreibungen,
`--no-clobber`, Hilfe und Version. Es wechselt nicht das Arbeitsverzeichnis und
schreibt standardmäßig nur nach stdout. Siehe `man generate_html`.

## Source-ID-Sidecars

Lokale Programme unter `target/bin/` besitzen nach dem Build eine gleichnamige
Datei mit Endung `.reta-source-id`. Diese Dateien sind keine Executables und
werden nicht als öffentliche Befehle installiert. Sie verhindern im
Entwicklungsbaum, dass ein Launcher nach einem source-only Update versehentlich
ein altes Binary startet.

## Bibliotheksfassade ohne neues Programm

`legacy_libreta_prompt.mojo` ist absichtlich kein weiteres installierbares
Diagnoseprogramm. Die historische Python-Datei war eine Importzeit-Fassade;
der native Ersatz wird von bestehenden Prompt-Einstiegen importiert. Nur
`scripts/test_stage12c5ab.sh` erzeugt kurzlebige Testprogramme unter
`target/tests`.
## Stage 12c5ac

Es kommt kein installierbares Programm hinzu. `scripts/test_stage12c5ac.sh` erzeugt lediglich `target/tests/test_prompt_preparation_12c5ac` und eine Snapshotprobe; beide sind kurzlebige Testartefakte.

## Stage 12c5ad

Die vollständigen Besitzer für TablePreparation, TableRuntime und TableState
erzeugen **keine neue installierbare Executable**. Ihre Modul- und
Snapshotprüfungen werden ausschließlich als kurzlebige Testprogramme unter
`target/tests` durch `scripts/test_stage12c5ad.sh` gebaut. `scripts/test_all.sh`
baut die gesamte native Testsuite unter `target/tests-all` und startet jedes
Programm über `bin/mojo-runtime-exec`.

## `reta-mojo-architecture-probe`

Vollständiger nativer Ersatz für `reta_architecture_probe_py.py`:

```sh
./bin/reta-mojo-architecture-probe snapshot-json
./bin/reta-mojo-architecture-probe architecture-map-json
./bin/reta-mojo-architecture-probe architecture-diagram-md
./bin/reta-mojo-architecture-probe package-integrity-json
```

63 statische Oberflächen stammen aus reproduzierbaren installierten Assets;
Paketintegrität wird gegen den aktuellen Referenzbaum berechnet.
