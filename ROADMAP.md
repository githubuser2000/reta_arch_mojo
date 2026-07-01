# Portierungsfahrplan Python → Mojo

Geplanter Umfang: **12 Release-Stufen**. Eine Stufe zählt erst als abgeschlossen, wenn Quellcode, Referenztests, Compilerziele, Dokumentation und ein source-only Archiv gemeinsam geprüft sind.

## Fortschrittsmaße nach Stage 12c4i

| Maß | Stand | Aussage |
|---|---:|---|
| abgeschlossene Release-Stufen | **9/12 = 75,0 %** | Stufen 1–8 und 11 sind abgeschlossen; Stufe 12 ist mit 12a, 12b, 12c1–12c3 und 12c4a–12c4i zu etwa 67 % abgeschlossen, während 9 und 10 noch Restpfade besitzen |
| vollständig native oder generierte Python-Dateien | **33/92 = 35,9 %** | Datei vollständig ersetzt oder als reproduzierbares Laufzeitasset abgebildet |
| mindestens angegriffene Python-Dateien | **61/92 = 66,3 %** | vollständig oder teilweise nativ |
| gewichtete Quellzeilen | **ca. 52 %** | konservative Schätzung unter Berücksichtigung der großen Teilports |
| funktionaler Nutzerumfang | **ca. 96–98 %** | praktisch nutzbarer Reta-Umfang ohne Python-Algorithmus |

Die Stufenquote ist höher als die Quellzeilenquote, weil die letzten Stufen besonders große dynamische Module bündeln: vollständige Ausgabeaufbereitung, Prompt-Sprache, i18n-Matrix, Architekturvalidierung und Parallelisierung.

## Die zwölf Stufen

1. **Grundlage und Zahlentheorie — abgeschlossen**
   Mojo-Projekt, Primfaktoren, Teiler, Primzahlkreuz, Bereichssprache, Basistests.

2. **Schema, Aliase und Eingabesemantik — abgeschlossen**
   Typisierte Parametersemantik, deutsche Aliasauflösung, Spalten-Buckets und CLI-Normalisierung.

3. **Promptprogramme und historische Startnamen — abgeschlossen**
   `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt`, Sitzungszustand und native Arithmetikbefehle.

4. **HTML-Grundstrukturen und `generate_html` — abgeschlossen**
   Nativer Grundstrukturenrenderer und Mojo-Orchestrierung der HTML-Gesamtseite.

5. **Buildlayout, Tag-Schema und Tabellenzustand — abgeschlossen**
   ELF-Buildziele unter `target/`, `.gitignore`, Tabellen-Tags, Wrapping, `multis3`.

6. **CSV, Zeilenfilter und erster nativer Reta-Tabellenpfad — abgeschlossen**
   Semikolon-CSV, vollständige Zeilenfiltermaschine, zweisprachige Laufzeit-Aliase, erste Generatorspalten, CSV/Markdown/Emacs-Ausgabe und `RETA_NATIVE=1`.

7. **Alle Generator- und Metaspalten — abgeschlossen**
   Klassifikatoren, Modallogik, Primzahlkreuz, Primzahlwirkung, Primuniversum, `PrimCSV` sowie zwölf allgemeine Meta-/Konkretachsen einschließlich aller 4.095 Teilmengenordnungen.

8. **Kombinationen und CSV-Verkettung — abgeschlossen**
   Vier gebrochen-rationale CSV-Prägarben, Galaxie-/Universum-Kombi-Join, 173 Aliase, 151 Relationsordnungen, Negativ- und Mehrfachauswahl.

9. **Vollständige Tabellenaufbereitung und Ausgabe — ca. 97–98 %**
   BBCode und der zentrale ANSI-Shellpfad sind für die geprüften deutschen und englischen Ausgaben bytegleich. HTML besitzt physische und semantische Zellmetadaten, tag-erhaltende Zellen, Wrapping und Seitenteilung; die Ein-Tabellen-Aliase sind seit 12c4g auch für HTML und BBCode bytegleich nativ. Seit 12c4i stimmen außerdem vorhandene Bindestrichtrennung und Shell-Restfarben in paginierten deutschen und englischen Kernströmen bytegleich. `--alles` und der vollständige `generate_html`-Pfad sind seit Stage 12b nativ. Dynamische TTY-Breite und Prompt-Zeilengrenzen sind seit 12c1 nativ; offen bleiben wenige Rich-/Terminalsonderfälle außerhalb dieses Pfads.

10. **Vollständige Prompt-Sprache und i18n — ca. 92–95 %**
    Klammerbewusstes Tokenisieren, kompakte Kurzbefehle, CPython-Set-Reihenfolge, fünfsprachiger Completion-Katalog und persistenter Mojo-Completion-Arbeiter sind nativ. Mojo plant 18 Domänenfamilien plus EIGN/EIGR einschließlich Ganzzahl-, Reziprok- und `n/m`-Achsen, ganzzahliger Vielfachen/Teiler, historischer Bruchbereiche, stabiler Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache. Vollständig besessene Einmalbefehle laufen vor jedem Python-Import und rufen den Tabellenkern im selben Mojo-Prozess auf. Eine getrennte Legacy-Präsentationsschicht besitzt sämtliche kompakten Tabellenfamilien und `mulpri`/`p`. Stage 10h ergänzt positive reine Zahlen-, Bereichs-, Listen- und Bruchkompositionen sowie 365 adressierbare Einträge des fünfsprachigen `15`-/`16`-Katalogs. Vorbereitete Fragmentbreiten, Bindestrichumbrüche, Zählungsmarkierungen und der historische nicht-zeilenorientierte Farbausgabestrom sind bytegenau modelliert. Stage 10i–10n ergänzen Null-/Negativ- und Kollisionsalgebra, wiederholte Katalogauswahl, mehrbereichige Abstände, native Datei-/Pipe-I/O, positive Promptbreiten, komponierte ganzzahlige Vielfachen-/Teilerpfade, verschachtelte CPython-Teiler-Setordnung und dynamische Obergrenzen absoluter `vN`-Selektoren. Offen bleiben echte `v n/m`-Vielfache mit Zähler größer 1, weitere hintere Sonderpfade und die vollständige i18n-Laufzeit außerhalb des Promptvokabulars.

11. **Architektursteuerung und Laufzeitnetze — abgeschlossen (11a–11j)**
    Stage 11a portiert Architekturkarte und realen Modul-/Kapsel-Grenzgraph. Stage 11b ergänzt Verträge und Witnesses. Stage 11c portiert Kohärenz und Traces. Stage 11d ergänzt Impact und Migration. Stage 11e ergänzt Rehearsal und Aktivierung. Stage 11f portiert Gesamtvalidierung und Fortschritts-Overlay. Stage 11g portiert die reale SQLite-Persistenz. Stage 11h portiert das deterministische Ausführungsnetz. Stage 11i portiert Konfiguration, CPU-Erkennung und zehn reine Tabellen-/Zahlenkerne. Stage 11j ersetzt den dynamischen `WorkerPrepare`-/`deepcopy`-Objektgraphen durch einen besitzenden typisierten Zeilenvorbereitungskontext. Stage 12a vereinheitlicht sämtliche nativen Parallelpfade auf typisierte Mojo-Threads und verbietet POSIX-Prozessprimitive per Gate.

12. **Bridge entfernen und Releaseparität — ca. 64 %**
    Stage 12a ist abgeschlossen: Boundary-Inventur, harte No-Python-/No-Subprozess-Gates für Parallelmodule und vollständige native Threadmigration. Stage 12b portiert den zwölfteiligen `--alles`-Spaltenplan und entfernt den Python-Kindprozess aus `generate_html`. Stage 12c1 portiert reale TTY-Geometrie und die exakte Prompt-Befehls-/Tabellengrenze. Stage 12c2 kapselt Linux/macOS-Geometrie und verwendet für Pipes Mojos portablen Eingabekanal mit verzögertem Python-Import. Stage 12c3 führt `shell`, `python` und `math` direkt aus Mojo aus und lässt rohe Unicode-Nutzlasten vor dem Kompaktscanner unangetastet. Stage 12c4a kapselt die verbleibende Python-Grenze in einem einzelnen Adapter und beseitigt die im Gesamtbuild sichtbare FFI-Signaturkollision. Stage 12c4b verlegt nicht-native `reta`-Zeilen und atomare Promptfallbacks aus dem eingebetteten CPython in den expliziten Mojo-Kindprozessadapter. Stage 12c4c holt die stabilen gemischten Reziprok-Modifier `vielfache + teiler + 1/n` aus diesem Fallback zurück und korrigiert deren exakten Argumentvertrag. Stage 12c4d ersetzt auch den TTY-Readline-/Vi-/Completion-Eingang durch einen nativen UTF-8-Editor mit POSIX-`termios`, History und verschachtelter Completion und besitzt klassische Bruch-No-ops sowie gemischte Bruch-/Ganzzahl-Kommatokens. Stage 12c4e entfernt die letzte eingebettete Python-Laufzeit aus `compat_main.mojo`: Der historische `reta`-Launcher führt vollständig besessene Argumentvektoren direkt nativ aus und startet nur für unbekannte oder teilweise portierte Semantik einen atomaren Referenzkindprozess. Stage 12c4f besitzt die Shell-Ausgabegruppe `onetable`/`endless*`/`dontwrap`/`justtext`, Breite-null-No-wrap und den Python-kompatiblen Überlangwortumbruch. Stage 12c4g übernimmt dieselbe Ein-Tabellen-Semantik für HTML und BBCode. Stage 12c4h besitzt die seitenlokale `keineleereninhalte`-Semantik; Stage 12c4i schließt Bindestrichumbruch und Restfarben der paginierten Shell-/HTML-/BBCode-Kernpfade. Offen bleiben echte `v n/m` mit Zähler größer eins, weitere Restalgorithmen sowie 12d–12e.

Die Zahl **12** ist die geplante Releasegliederung. Interne Teilpakete oder Fehlerkorrekturen erhöhen diese Zahl nicht automatisch.

### Teilstufenstand 11 und 12

| Teilstufe | Status | Inhalt |
|---|---:|---|
| 11a | 100 % | Architekturkarte und Boundary-Graph |
| 11b | 100 % | Verträge und Witnesses |
| 11c | 100 % | Kohärenz und Traces |
| 11d | 100 % | Impact und Migration |
| 11e | 100 % | Rehearsal und Aktivierung |
| 11f | 100 % | Gesamtvalidierung und Fortschritt |
| 11g | 100 % | SQLite-Persistenz |
| 11h | 100 % | Ausführungsnetz |
| 11i | 100 % | reine Tabellen-/Zahlen-Chunk-Kerne; seit 12a ausschließlich Threads |
| 11j | 100 % | typisierter Prepare-Zeilenkontext und Produktionsoberfläche |
| **Stufe 11** | **10/10 = 100 %** | abgeschlossen |
| 12a | 100 % | Bridge-Inventur, harte Boundary-Gates und vollständige Threadmigration |
| 12b | 100 % | nativer `--alles`-Plan und Python-freies `generate_html` |
| 12c | 99 % | 12c1–12c3 fertig; 12c4a–12c4c kapseln und verkleinern die Promptgrenze; 12c4d entfernt die Prompt-Python-Laufzeit; 12c4e schaltet den historischen Tabellenlauncher native-first; 12c4f besitzt die Shell-Ein-Tabellen- und Justtext-Ausgabegruppe; 12c4g besitzt Markup-oneTable; 12c4h No-blank; 12c4i paginierte Kernparität |
| 12d | 0 % formal | Befehlsmatrix, Benchmarks und gezielte SIMD-Prüfung |
| 12e | 0 % formal | Packaging und Freigabe |
| **Stufe 12** | **ca. 67 %** | 12a–12b, 12c1–12c3 und 12c4a–12c4i abgeschlossen; echte `v n/m`, Restalgorithmen sowie 12d–12e offen |


## Stage 10n – native EIGN/EIGR-Eigenschaftsachsen

- Ein eigener typisierter Planer übernimmt alle 165 deutschen
  `EIGN…`-/`EIGR…`-Katalogbefehle.
- Die Eigenschaftssuffixe werden erst nach CPython-kompatibler Mengenordnung des
  vollständigen Promptbefehls extrahiert.
- EIGN verwendet `--konzept`; EIGR verwendet `--konzept2` und bewahrt bei
  Ganzzahlen die historische zweite `-zeilen`-Sektion.
- Der in der Python-Promptschicht defekte `deepcopy(module)`-Vorlauf von EIGR
  wird nicht imitiert. Maßgeblich ist sein expliziter, direkt über `reta.py`
  ausführbarer Argumentvertrag.
- Vollständig besessene Eigenschaftsbefehle laufen vor jedem Python-Import und
  ohne `reta-native`-Kindprozess.


## Stage 11a – native Architekturkarte und Kapselgrenzen

- `architecture_map.py` ist als vollständiger typisierter Mojo-Snapshot verfügbar.
- `architecture_boundaries.py` ist als typisierter Modulbesitz-, Import- und Kapselgraph verfügbar.
- Die Quellbaum-/AST-Auswertung läuft nur beim expliziten Regenerieren; normale Abfragen und Validierungszugriffe benötigen kein Python.
- `reta-mojo-boundaries` liefert Zusammenfassung, Modulbesitz, Kapselstatistik und Diagramme.
- Generatoren sind über mehrere `PYTHONHASHSEED`-Werte byteidentisch reproduzierbar.


## Stage 11b – native Architekturverträge und Witnesses

- `architecture_contracts.py` ist als typisierter Snapshot mit 33 Diagrammen, 11 Kapselverträgen und 22 Gesetzen verfügbar.
- `architecture_witnesses.py` ist als typisierter Snapshot mit 536 Ankern, 11 Kapselschnitten, 33 Diagramm-, 42 Natürlichkeits-Witnesses und 55 Verpflichtungen verfügbar.
- 351/351 dateiartige Anker sind gegen `python_reference` aufgelöst; 185 symbolische Anker bleiben bewusst symbolisch.
- Beide Generatoren sind über `PYTHONHASHSEED=0`, `1`, `42`, `random` byteidentisch reproduzierbar.
- Verträge und Witnesses bleiben getrennte schwere Ziele, damit Mojo nicht den gesamten Metakatalog in einem Compiler-Monolithen instanziiert.


## Stage 11c – native Kohärenzmatrix und Trace-Navigation

- `architecture_coherence.py` ist als typisierter Snapshot mit 11 Kapseln, 53 Routen, 42 Natürlichkeits- und 22 Gesetzeskohärenzen verfügbar.
- `architecture_traces.py` ist als typisierter Snapshot mit 34 Komponenten-, 11 Kapsel- und 42 Stufentraces sowie 204 Route-Hops verfügbar.
- Beide Validierungen besitzen den Status `passed`; interne Zählungs- und Leerfehlerinvarianten werden nativ geprüft.
- Acht repräsentative CLI-Abfragen sind Python↔Mojo byteidentisch.
- Die Architekturkontrollregeneration umfasst nun sechs byteidentische Generatorziele.
- Kohärenz und Traces bleiben getrennte schwere Compilerziele.


## Stage 11d – nativer Impact-Kalkül und Migrationsplan

- `architecture_impact.py` ist als typisierter Snapshot mit 34 Quellen, 34 Verträgen, 10 Regression-Gates und 34 Migrationskandidaten verfügbar.
- `architecture_migration.py` ist als typisierter Snapshot mit 7 Wellen, 34 Schritten, 34 Gate-Bindungen und 7 Natürlichkeitsinvarianten verfügbar.
- Beide Validierungen besitzen den Status `passed`.
- Acht repräsentative CLI-Abfragen sind Python↔Mojo byteidentisch.
- Die Architekturkontrollregeneration umfasst nun acht byteidentische Generatorziele.
- Impact und Migration bleiben getrennte schwere Compilerziele.


## Stage 11e – native Rehearsal- und Aktivierungsschicht

- `architecture_rehearsal.py` ist als typisierter Snapshot mit 7 Öffnungen, 34 Moves, 34 Gate-Suiten und 7 Readiness-Covern verfügbar.
- `architecture_activation.py` ist als typisierter Snapshot mit 7 Fenstern, 34 Units, 34 Commit-Gates, 34 Rollbacks und 7 Transaktionen verfügbar.
- Beide Bundles besitzen neben dem gespeicherten Referenzstatus eine native Kreuzvalidierung der internen Beziehungen.
- Elf repräsentative CLI-Abfragen sind Python↔Mojo byteidentisch.
- Die Architekturkontrollregeneration umfasst nun zehn byteidentische Generatorziele.
- Die öffentlichen Query-Controller werden gezielt ohne Optimierung gebaut; die Bundletests bleiben normal optimiert.


## Stage 11f – native Gesamtvalidierung und Fortschritts-Overlay

- `architecture_validation.py` ist als typisierter Snapshot mit 51 Checks, 17 Schichten und 3.448 geprüften Einzelobjekten verfügbar.
- `architecture_progress.py` ist als typisierter Snapshot mit 30 Oberflächen, 34 Schritten, 7 Wellen und einem offenen Umweltblock verfügbar.
- Die Validierung besitzt den Status `passed`; das Fortschritts-Overlay ist intern konsistent und bewusst `attention`, weil die externe Command-Parity-Baseline fehlt.
- Beide Bundles besitzen native Kreuzvalidierungen ihrer internen Referenzen und Zählungen.
- Acht repräsentative CLI-Abfragen sind Python↔Mojo byteidentisch.
- Die Architekturkontrollregeneration umfasst nun zwölf byteidentische Generatorziele.
- Die Query-Controller werden ohne Optimierung gebaut; die Bundletests bleiben normal optimiert.


## Stage 11g – native SQLite-Persistenz

- `persistence.py` ist als echte Laufzeitschicht in `src/reta_mojo/persistence.mojo` portiert.
- Sechs Tabellen und zwölf öffentliche Persistenzmorphismen decken Sections, Garben-Snapshots, Ausführungsläufe, Audit und Cache ab.
- Canonical-JSON-Digests sind Python↔Mojo identisch, einschließlich Unicode.
- Python liest von Mojo erzeugte Datenbanken und Mojo liest von Python erzeugte Sections und Garben-Snapshots.
- 47/47 native Prüfungen und 5/5 sprachübergreifende Paritäts-/Interoperabilitätsprüfungen bestehen.
- Batch-Schreibvorgänge bleiben seriell und transaktional; reine Nutzlast- und Zeilenvorbereitung kann seit Stage 11j threadparallel laufen.


## Stage 11h – natives deterministisches Ausführungsnetz

- `execution_network.py` ist als echte Mojo-Laufzeitschicht portiert.
- FIFO-, LIFO- und Prioritätsplanung einschließlich stabiler Prioritätsgleichstände sind nativ.
- Halb- und Vollduplexkanäle sowie CPU-, Datei- und Ausgabesemaphoren besitzen typisierte Zustände und Snapshots.
- Seit Stage 12a verwendet das Ausführungsnetz ausschließlich native Mojo-Threads mit disjunkten Ergebnisslots; direkte Prozessprimitive sind verboten.
- Die statische Nutzlastgrenze besteht aus UTF-8-Text, kanonischem Metadaten-JSON und geprüften Operationskennungen statt Python-`Any`, `pickle` und dynamischem `importlib`.
- Deterministische Reduktion stellt optional die ursprüngliche Taskreihenfolge wieder her.
- 85/85 native Netzprüfungen, 15/15 Persistenzintegrationsprüfungen und 8/8 Python↔Mojo-Paritätsfälle bestehen.
- Stage 11i portiert die reinen `parallel_execution.py`-Kerne; Stage 11j ergänzt den typisierten Prepare-Zeilenkontext und stellt den nativen Standard auf Threads um.


## Stage 11i – native Chunk-Kerne mit Prozessbasis

- `parallel_execution.py` ist für die reinen, deterministischen Operationen als typisierte Mojo-Laufzeit verfügbar.
- Zehn Tabellen-/Zahlenoperationen besitzen serielle Referenz- und typisierte Thread-Chunkpfade; historische Prozessaliasnamen leiten seit Stage 12a ausschließlich auf Threads um.
- Die frühere String-Transportgrenze ist entfernt; jeder Kern verwendet typisierte Chunks und disjunkte Ergebnisslots.
- Ergebnisse werden unabhängig von der Workerreihenfolge in die Python-definierte Zeilen-/Zahlenindexordnung reduziert; Threadfehler werden über dedizierte Fehlerslots propagiert.
- Der native API liefert auch beim seriellen Rückfall einen typisierten Ergebniswert statt `None`.
- 29/29 Konfigurations-, 55/55 Zeilenprozess-, 157/157 Zahlenprozess-, 26/26 Tabellen- und 12/12 Python↔Mojo-Paritätsprüfungen bestehen; zusammen mit Prompt-LF und Fixture-Integrität sind es 286/286 fokussierte Prüfungen.
- Die kompakte Promptankündigung besitzt nun eine explizite LF-Grenze; 6/6 zugehörige Tests bestehen.


## Stage 11j – typisierte Thread-Zeilenvorbereitung und Abschluss von Stufe 11

- `ParallelRowPreparationContext` ersetzt den dynamischen, per `deepcopy` transportierten Python-`Prepare`-Objektgraphen.
- Header-, Religionsnummern-, Kombi-, Breiten- und Wrappingkontext sind besitzende explizite Werte; globale Header-Tag-Mutation bleibt vor dem parallelen Bereich seriell.
- Alle nativen Parallelmodi verwenden Mojos CPU-Workerthreads; alte Prozesswerte sind ausschließlich Kompatibilitätsalias.
- Jeder Thread schreibt ausschließlich in seinen Chunkslot; die Reduktion sortiert danach deterministisch nach der ursprünglichen Python-Zeilennummer.
- Python-Referenz, serielles Mojo und Thread-Mojo liefern für den vollständigen vorbereiteten Fixture-Zeilenstrom identische Bytes.
- 36/36 Konfigurations-, 40/40 Zeilenvorbereitungs- und 2/2 Vollstrom-Paritätsprüfungen bestehen.
- Stufe 11 ist mit 11a–11j vollständig abgeschlossen.


## Stage 12a–12b abgeschlossen; Stage 12c bis 12c4f fortgesetzt

- **12a – abgeschlossen:** vollständige Bridge-Inventur, Runtime-Gates, 0 native Prozessprimitive und 10 kanonische Thread-APIs.
- **12b – abgeschlossen:** zwölfteiliger `--alles`-Spaltenplan und `generate_html` ohne Python-/Subprozessbrücke.
- **12c1 – abgeschlossen:** reale TTY-Breite für `--breite=0` und exakte physische Grenze zwischen Prompt-Befehlszeile und Tabelle.
- **12c2 – abgeschlossen:** portable native Eingabe für Pipes/Umleitungen, verzögerter Python-Import und zielabhängige Linux-/macOS-Terminalgeometrie.
- **12c3 – abgeschlossen:** `shell`, `python` und `math` ohne Python-Brücke, byteerhaltender Kindprozessadapter und UTF-8-sicherer Rohbefehl-Bypass.
- **12c4a – abgeschlossen:** eingebettete Python-Grenze gekapselt und FFI-Signaturkollision entfernt.
- **12c4b – abgeschlossen:** nicht-native `reta`-Zeilen und atomare Promptfallbacks direkt über den Mojo-Kindprozessadapter; nur der TTY-Editor bleibt eingebettet.
- **12c4c – abgeschlossen:** `vielfache + teiler + 1/n`, Reziprok-Maximum, Spaltenzählung und reine `teiler 1/n`-Leerseite bytegenau nativ.
- **12c4d – abgeschlossen:** nativer POSIX-TTY-Editor mit UTF-8, History, Completion und Emacs-/Vi-Kernbindings; klassische Bruch-No-ops und gemischte Tokens nativ; keine eingebettete Python-Laufzeit im Prompt.
- **Rest-12c4:** echte `v n/m` mit Zähler größer eins, seltene fortgeschrittene Readline-Komfortfunktionen und die übrigen Prompt-/i18n-Algorithmen schließen.
- **12d:** vollständige Befehlsmatrix, Leistungsprofile, Thread-/Speicheroptimierung und nur benchmarkgestützte SIMD-Kernel.
- **12e:** reproduzierbares Packaging, Installationspfade, Release-Checks und finale Dokumentation.


## Stage 12c4j – individuelle Spaltenbreiten

- `--breiten` und `--widths` sind für positive Werte in Shell, HTML und BBCode nativ.
- Die Liste adressiert ausgewählte Datenspalten, wird durch spätere Vorkommen ersetzt und fällt für fehlende Einträge auf die globale Breite zurück.
- Nullwerte, CSV/Markdown/Emacs und Raw-Markup bleiben bis zu ihren eigenen visuellen Zeilenports atomarer Referenzfallback.
- Der native-first-Vertrag ist über 12 Bytefixtures, 26 Ownership- und 12 Launchertests abgesichert.
