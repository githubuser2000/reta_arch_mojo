# Roadmap – Aktualisierung 12c5bh

`mojo_bridge.py`, `parameter_runtime.py`, `retaPrompt.py`, `generated_columns.py`, der vollständige I18n-Monolith und sämtliche Architekturproben besitzen jetzt native oder reproduzierbar generierte Eigentümer. Die vollständige Testsuite besitzt getrennte Build-/Run-Phasen mit Frischemanifest und kontrollierter Laufzeitparallelität; kommalokale Null-/Ausschlussachsen neben echten Bruchvielfachen sind ebenfalls nativ. Die großen verbleibenden Laufzeitblöcke konzentrieren sich auf `reta.py`, den interaktiven `prompt_execution.py`-Effektblock und die heterogene Laufzeitaggregation der Architektur-Fassade. Der nächste Schwerpunkt ist die weitere Verkleinerung dieses produktiven Kompatibilitätsrands.

Geplanter Umfang: **12 Release-Stufen**. Eine Stufe zählt erst als abgeschlossen, wenn Quellcode, Referenztests, Compilerziele, Dokumentation und ein source-only Archiv gemeinsam geprüft sind.

## Fortschrittsmaße nach Stage 12c5bh

| Maß | Stand | Aussage |
|---|---:|---|
| abgeschlossene Release-Stufen | **9/12 = 75,0 %** | Stufen 1–8 und 11 sind abgeschlossen; Stufe 12 ist mit 12a, 12b, 12c1–12c3 und 12c4a–12c5t zu etwa 74,0 % abgeschlossen, während 9 und 10 noch Restpfade besitzen |
| vollständig native oder generierte Python-Dateien | **89/92 = 96,7 %** | Datei vollständig ersetzt oder als reproduzierbares Laufzeitasset abgebildet |
| mindestens angegriffene Python-Dateien | **92/92 = 100,0 %** | Status direkt aus der autoritativen `NATIVE`-Zuordnung |
| angegriffene Referenzzeilen | **48.831/48.831 = 100,0 %** | maschinenberechnet statt manuell fortgeschrieben |
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

10. **Vollständige Prompt-Sprache und i18n — ca. 95–97 %**
    Klammerbewusstes Tokenisieren, kompakte Kurzbefehle, CPython-Set-Reihenfolge, fünfsprachiger Completion-Katalog und persistenter Mojo-Completion-Arbeiter sind nativ. Stage 12c5az trennt zusätzlich gemischte `v1/n`- und echte `v n/m`-Vielfache in unabhängige 1024er- beziehungsweise physische CSV-Rechteckachsen. Mojo plant 18 Domänenfamilien plus EIGN/EIGR einschließlich Ganzzahl-, Reziprok- und `n/m`-Achsen, ganzzahliger Vielfachen/Teiler, historischer Bruchbereiche, stabiler Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache. Vollständig besessene Einmalbefehle laufen vor jedem Python-Import und rufen den Tabellenkern im selben Mojo-Prozess auf. Eine getrennte Legacy-Präsentationsschicht besitzt sämtliche kompakten Tabellenfamilien und `mulpri`/`p`. Stage 10h ergänzt positive reine Zahlen-, Bereichs-, Listen- und Bruchkompositionen sowie 365 adressierbare Einträge des fünfsprachigen `15`-/`16`-Katalogs. Vorbereitete Fragmentbreiten, Bindestrichumbrüche, Zählungsmarkierungen und der historische nicht-zeilenorientierte Farbausgabestrom sind bytegenau modelliert. Stage 10i–10n ergänzen Null-/Negativ- und Kollisionsalgebra, wiederholte Katalogauswahl, mehrbereichige Abstände, native Datei-/Pipe-I/O, positive Promptbreiten, komponierte ganzzahlige Vielfachen-/Teilerpfade, verschachtelte CPython-Teiler-Setordnung und dynamische Obergrenzen absoluter `vN`-Selektoren. Echte `v n/m`-Vielfache mit Zähler größer 1 sind seit Stage 12c4r nativ. Seit Stage 12c4u besitzen auch Completion-Runtime und verschachtelte Zustandsmaschine eigene native Module. Stage 12c4v übernimmt zusätzlich Prompt-Sitzung und Prompt-Runtime-Vertrag einschließlich fünfsprachiger Präfixe. Stage 12c4w portiert den Prompt-Vorbereitungsvertrag einschließlich Regex/Wildcards und prüft den echten vollständigen `--alles`-Bestand semantisch zellgenau; offen bleibt dort nur die produktive Controller-Aktivierungsnaht. Stage 12c4x übernimmt zusätzlich die fünf aktiven `i18n.words`-Splitmodule mit 34.667 sprachgebundenen Baumknoten vollständig als reproduzierbaren nativen Vertrag. Stage 12c4y trennt anschließend den produktiven Parameterplan aus dem CLI-Monolithen, besitzt Obergrenzen, Breiten, Zeilen und Spalten in einem typisierten Modul und macht den einstündigen Python-`--alles`-Lauf als wiederverwendbares Referenzpaket über mehrere reine Mojo-Stages nutzbar. Stage 12c4z professionalisiert den installierbaren `generate_html`-Einstieg mit atomarer Ausgabe, expliziter Zwischenablage, Manpage und FHS-sicherer Pfadauflösung; die hochgeladene unseeded Python-Vollreferenz wird mit transparentem Header-/Hashordnungsbericht wiederverwendet. Stage 12c5a schließt danach die produktive Prompt-Interaktionsnaht mit einem typisierten Controllerbesitzer. Stage 12c5b übernimmt zusätzlich die vollständige historische PromptLanguageBundle-Oberfläche und stellt alle Referenzpfade auf PyPy3-first. Stage 12c5c schließt danach den Quellbaum-Integritätsbesitzer mit binärem SHA-256, Pflichtpfaden, Runtime-Artefakten und CSV-Verträgen sowie die dynamische Split-i18n-Fassade. Offen bleiben vor allem seltene hintere Ausführungszweige des Promptcontrollers und die vollständige native `reta.py`-Legacy-Oberfläche.

11. **Architektursteuerung und Laufzeitnetze — abgeschlossen (11a–11j)**
    Stage 11a portiert Architekturkarte und realen Modul-/Kapsel-Grenzgraph. Stage 11b ergänzt Verträge und Witnesses. Stage 11c portiert Kohärenz und Traces. Stage 11d ergänzt Impact und Migration. Stage 11e ergänzt Rehearsal und Aktivierung. Stage 11f portiert Gesamtvalidierung und Fortschritts-Overlay. Stage 11g portiert die reale SQLite-Persistenz. Stage 11h portiert das deterministische Ausführungsnetz. Stage 11i portiert Konfiguration, CPU-Erkennung und zehn reine Tabellen-/Zahlenkerne. Stage 11j ersetzt den dynamischen `WorkerPrepare`-/`deepcopy`-Objektgraphen durch einen besitzenden typisierten Zeilenvorbereitungskontext. Stage 12a vereinheitlicht sämtliche nativen Parallelpfade auf typisierte Mojo-Threads und verbietet POSIX-Prozessprimitive per Gate.

12. **Bridge entfernen und Releaseparität — ca. 64 %**
    Stage 12a ist abgeschlossen: Boundary-Inventur, harte No-Python-/No-Subprozess-Gates für Parallelmodule und vollständige native Threadmigration. Stage 12b portiert den zwölfteiligen `--alles`-Spaltenplan und entfernt den Python-Kindprozess aus `generate_html`. Stage 12c1 portiert reale TTY-Geometrie und die exakte Prompt-Befehls-/Tabellengrenze. Stage 12c2 kapselt Linux/macOS-Geometrie und verwendet für Pipes Mojos portablen Eingabekanal mit verzögertem Python-Import. Stage 12c3 führt `shell`, `python` und `math` direkt aus Mojo aus und lässt rohe Unicode-Nutzlasten vor dem Kompaktscanner unangetastet. Stage 12c4a kapselt die verbleibende Python-Grenze in einem einzelnen Adapter und beseitigt die im Gesamtbuild sichtbare FFI-Signaturkollision. Stage 12c4b verlegt nicht-native `reta`-Zeilen und atomare Promptfallbacks aus dem eingebetteten CPython in den expliziten Mojo-Kindprozessadapter. Stage 12c4c holt die stabilen gemischten Reziprok-Modifier `vielfache + teiler + 1/n` aus diesem Fallback zurück und korrigiert deren exakten Argumentvertrag. Stage 12c4d ersetzt auch den TTY-Readline-/Vi-/Completion-Eingang durch einen nativen UTF-8-Editor mit POSIX-`termios`, History und verschachtelter Completion und besitzt klassische Bruch-No-ops sowie gemischte Bruch-/Ganzzahl-Kommatokens. Stage 12c4e entfernt die letzte eingebettete Python-Laufzeit aus `compat_main.mojo`: Der historische `reta`-Launcher führt vollständig besessene Argumentvektoren direkt nativ aus und startet nur für unbekannte oder teilweise portierte Semantik einen atomaren Referenzkindprozess. Stage 12c4f besitzt die Shell-Ausgabegruppe `onetable`/`endless*`/`dontwrap`/`justtext`, Breite-null-No-wrap und den Python-kompatiblen Überlangwortumbruch. Stage 12c4g übernimmt dieselbe Ein-Tabellen-Semantik für HTML und BBCode. Stage 12c4h besitzt die seitenlokale `keineleereninhalte`-Semantik; Stage 12c4i schließt Bindestrichumbruch und Restfarben der paginierten Shell-/HTML-/BBCode-Kernpfade. Stage 12c4r besitzt echte `v n/m` mit Zähler größer eins und einen zentralen Defektkatalog; Stage 12c4s auditiert diesen rückwirkend und übernimmt die Kontroll-Hauptparameter. Stage 12c4t portiert die allgemeine Wortvervollständigung und ihre Legacy-Fassade. Offen bleiben seltene hintere Prompt-Ausführungszweige, gemischte Bruchdomänen sowie 12d–12e.

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
| 12c | 99,95 % | 12c1–12c3 fertig; 12c4a–12c4t verkleinern Prompt-/Tabellenfallbacks und besitzen Renderer-, Kontroll-, Bruch- sowie Wort-Completion-Pfade; 12c4u besitzt Completion-Runtime und verschachtelte Zustandsmaschine; 12c4v besitzt Prompt-Sitzung und Runtimevertrag vollständig nativ; 12c4w ergänzt Prompt-Vorbereitung und vollständige `--alles`-Semantik; 12c4x den aktiven i18n-Split; 12c4y den produktiven Parameter-Runtime-Besitzer; 12c4z den professionellen FHS-`generate_html`-Einstieg; 12c5a die native Prompt-Interaktions- und Controllergrenze |
| 12d | 0 % formal | Befehlsmatrix, Benchmarks und gezielte SIMD-Prüfung |
| 12e | 0 % formal | Packaging und Freigabe |
| **Stufe 12** | **ca. 67,7 %** | 12a–12b, 12c1–12c3 und 12c4a–12c5a abgeschlossen; Restalgorithmen sowie 12d–12e offen |



Stage 12c5ao schließt `setup.py` vollständig als reproduzierbaren nativen Metadaten- und Commandplan, typisiert die historische `reta.py`-Programmoberfläche weiter und repariert die strenge CsvTable-Besitzgrenze der Generated-Columns-Integration.

Stage 12c5an schließt die historische `mojo_bridge.py`-Oberfläche vollständig nativ und hebt `parameter_runtime.py` mit typisierten Planadaptern auf vollständigen Dateibesitz.



## Stage 12c5cf – Bare Terminal-Clear-Dispatch im Interaktionsbesitzer

- [x] `leeren`/`clear` als alleinstehenden Prompt-Terminaleffekt nativ planen.
- [x] Bare `KIND_CLEAR`-Branches aus `_run_command` und `_run_native_one_shot` entfernen.
- [x] Zusammengesetztes `leeren` bei Tabellenplänen weiter in `prompt_historical_ownership.mojo` lassen, weil dort die historische `rows + 1`-Leerzeilenwirkung besitzt.
- [x] Prompt-Interaktionssnapshot um `terminal_clear_dispatch=native-terminal-clear-plan` erweitern.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cf.sh -- -j 8` ausführen.

## Stage 12c5ce – nächster Prompt-Sitzungsrand

- [x] Bare Logging-Dispatch aus dem Prozesscontroller entfernen.
- [x] `PromptLoggingDispatchPlan` im Interaktionsbesitzer ergänzen.
- [x] Prompt-/Legacy-/Tabellenadapterziele im Stage-Lauf frisch bauen.
- [ ] Nächste Restkante: weitere alleinstehende Prompt-Kontrollbefehle oder verbleibende hintere Prompt-Sonderzweige.

## Stage 12c5am – native retaPrompt- und Generated-Columns-Besitzergrenzen

- `retaPrompt.py`: exakter 55-Namen-Katalog und explizites `LegacyRetaPromptBundle`; Terminal-/Prozess-I/O bleibt bei `prompt_main.mojo`.
- `generated_columns.py`: typisierte Request-/Result-Orchestrierung statt heterogenem `Concat`-Objekt; vorhandene Algorithmusbesitzer werden wiederverwendet.
- Architekturassets: kanonische Prozessortopologie verhindert rechnerabhängige `snapshot-json`-/`manifest.tsv`-Abweichungen.

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


## Stage 12a–12b abgeschlossen; Stage 12c bis 12c4t fortgesetzt

- **12a – abgeschlossen:** vollständige Bridge-Inventur, Runtime-Gates, 0 native Prozessprimitive und 10 kanonische Thread-APIs.
- **12b – abgeschlossen:** zwölfteiliger `--alles`-Spaltenplan und `generate_html` ohne Python-/Subprozessbrücke.
- **12c1 – abgeschlossen:** reale TTY-Breite für `--breite=0` und exakte physische Grenze zwischen Prompt-Befehlszeile und Tabelle.
- **12c2 – abgeschlossen:** portable native Eingabe für Pipes/Umleitungen, verzögerter Python-Import und zielabhängige Linux-/macOS-Terminalgeometrie.
- **12c3 – abgeschlossen:** `shell`, `python` und `math` ohne Python-Brücke, byteerhaltender Kindprozessadapter und UTF-8-sicherer Rohbefehl-Bypass.
- **12c4a – abgeschlossen:** eingebettete Python-Grenze gekapselt und FFI-Signaturkollision entfernt.
- **12c4b – abgeschlossen:** nicht-native `reta`-Zeilen und atomare Promptfallbacks direkt über den Mojo-Kindprozessadapter; nur der TTY-Editor bleibt eingebettet.
- **12c4c – abgeschlossen:** `vielfache + teiler + 1/n`, Reziprok-Maximum, Spaltenzählung und reine `teiler 1/n`-Leerseite bytegenau nativ.
- **12c4d – abgeschlossen:** nativer POSIX-TTY-Editor mit UTF-8, History, Completion und Emacs-/Vi-Kernbindings; klassische Bruch-No-ops und gemischte Tokens nativ; keine eingebettete Python-Laufzeit im Prompt.
- **Rest-12c4:** verbleibende dynamische Prompt-Sitzungs-/Speicherbefehle, seltene Rich-/Readline-Komfortgrenzen, vollständige i18n-Laufzeit und atomar zurückfallende Mischdomänen schließen.
- **12d:** vollständige Befehlsmatrix, Leistungsprofile, Thread-/Speicheroptimierung und nur benchmarkgestützte SIMD-Kernel.
- **12e:** reproduzierbares Packaging, Installationspfade, Release-Checks und finale Dokumentation.


## Stage 12c4j – individuelle Spaltenbreiten

- `--breiten` und `--widths` sind für positive Werte in Shell, HTML und BBCode nativ.
- Die Liste adressiert ausgewählte Datenspalten, wird durch spätere Vorkommen ersetzt und fällt für fehlende Einträge auf die globale Breite zurück.
- Nullwerte, CSV/Markdown/Emacs und Raw-Markup bleiben bis zu ihren eigenen visuellen Zeilenports atomarer Referenzfallback.
- Der native-first-Vertrag ist über 12 Bytefixtures, 26 Ownership- und 12 Launchertests abgesichert.


## Stage 12c4k – explizite Nullbreiten

- `0` innerhalb `--breiten`/`--widths` ist für Shell, HTML und BBCode nativ.
- Eine Nullbreite deaktiviert den Wortumbruch nur für die zugehörige ausgewählte Datenspalte; fehlende Listeneinträge verwenden weiterhin die globale Breite.
- Markup misst historische Rohleerzeichen für die Umbruchentscheidung, serialisiert den Zelltext jedoch normalisiert.
- Shell besitzt die Referenzsemantik überbreiter Nullspalten einschließlich einmaligem Überspringen auf der ersten Datenseite und Abbruch späterer horizontaler Seiten.
- CSV/Markdown/Emacs bleiben atomarer Referenzfallback; HTML/BBCode mit `--nocolor` wurden in Stage 12c4l übernommen.
- Der Vertrag ist über 12 Nullbreitenfixtures, 17 Renderertests, 26 Ownership- und 13 Launchertests abgesichert.


## Stage 12c4l – portable Runtime und rohes Markup

- Übernommene Mojo-ELF-Dateien starten ohne identischen absoluten `.venv`-Pfad.
- Builds betten `$ORIGIN/../lib/mojo` ein; `target/lib/mojo` wird lokal auf die zwei Modular-Laufzeitbibliotheken verknüpft.
- Bestehende Binaries werden durch `bin/mojo-runtime-exec` ohne Neukompilierung lauffähig.
- HTML und BBCode mit `--nocolor` besitzen den exakten rohen `print`-Vertrag, einschließlich interner Leerraumläufe und physischer HTML-Zeilenstruktur.
- Zwölf Markupströme, 18 Renderertests, 26 Ownershiptests, 14 Launchertests und vier Runtimepfadtests sichern die Stufe ab.


## Stage 12c4o – Einzelspaltenbreiten in flachen Formaten

- CSV, Markdown und Emacs/Org besitzen `--breiten`/`--widths` nativ.
- Positive, ersetzte und explizit nullhaltige Listen verwenden denselben
  typisierten Breitenplan wie Shell, HTML und BBCode.
- Der gemeinsame Zeilenexpander reproduziert Nummerierungsfortsetzungen,
  Überschriften-/Primzahlpotenztrenner, CSV-Randwhitespace und die unnummerierten leeren `;;`-Strukturfelder bytegenau.
- Dreizehn deutsche/englische Referenzströme und der native-first Launcher laufen
  ohne Python-Kindprozess.

## Stage 12c4p – sichere native Generatorbereiche

- Ein endlicher Mojo-Ausdrucksparser ersetzt den bisher nur scheinbar nativen
  Besitz geklammerter Python-artiger Ganzzahlbereiche.
- Nativ sind Ganzzahlarithmetik, Listen/Mengen/Tupel und einvariable
  Comprehensions über `range` mit ein bis drei Argumenten.
- Additive und subtraktive Zeilenbereiche sowie generatorbasierte
  `--spaltenreihenfolgeundnurdiese` verwenden denselben Parser.
- Beliebiger Python-Code, Gleitkommaausdrücke, Bedingungen und verschachtelte
  Comprehensions bleiben atomarer Referenzfallback.
- Sechs End-to-End-Ströme sind bytegleich; Parser **5/5**, Bereichsplaner
  **8/8** und CLI-/Ownership **29/29** bestehen.

## Stage 12c4q – native Start-, Sprach- und Hilfeoberfläche

- Leerer Aufruf und reine deutsche/englische Sprachwahl werden vor dem
  Tabellenplan bytegenau nativ behandelt.
- `-h`/`-help` lesen reproduzierbar generierte Hilferessourcen und benötigen
  weder Python-Kindprozess noch eingebettetes CPython.
- Mehrfache Hilfe und die historische Regel „erste Sprachwahl gewinnt“ bleiben
  erhalten.
- Hauptparameter ohne Nebenoption werden nicht mehr fälschlich als vollständige
  Standardtabelle besessen.
- Sieben End-to-End-Ströme, fünf Startmodultests und 30 CLI-/Ownership-Tests
  sichern die Grenze ab.

## Stage 12c4r – zentraler Defektkatalog und echte Bruchvielfache

- `KNOWN_DEFECTS.json` ist die maschinenlesbare Quelle für Python-Originalfehler, Mojo-Portfehler, Fehlerkandidaten und bewusst konservierte Altverträge.
- Jeder offene Python-Fehler benötigt Reproduktion, Quellorte, heutigen Mojo-Vertrag und einen konkreten Auftrag für die spätere Python-/PyPy3-Bereinigung.
- `universum v2/3` und die entsprechenden Emotion-, Strukturgrößen- und Motivepfade werden nativ als kartesisches Produkt der Zähler- und Nenner-Vielfachachsen ausgeführt.
- Anders als der abstürzende Python-Altalgorithmus begrenzt Mojo jede Achse an der tatsächlichen Rechteckform ihrer CSV-Domäne.
- Mehrere verschieden große Bruchdomänen sowie gemischte 1024er-Reziprok- und datenbegrenzte Bruchachsen bleiben atomarer Fallback.
- Der Python-Absturz bleibt während der Referenzphase absichtlich reproduzierbar und wird nach Abschluss der Transpilierung anhand desselben Sollvertrags behoben.

## Stage 12c4s – Defektvollständigkeit und native Kontroll-Hauptparameter

- **abgeschlossen:** rückwirkender Audit der bisher verstreuten
  verhaltensrelevanten Python-, Mojo-, Packaging- und Testbefunde;
- **abgeschlossen:** 35 zentral katalogisierte Defekte/Eigenheiten und 12
  konkrete spätere Python-/PyPy3-Arbeitspunkte;
- **abgeschlossen:** reproduzierbare eingefrorene Python-Baseline mit exakt
  67 bestandenen und drei katalogisierten roten Tests;
- **abgeschlossen:** native `-debug`-, `-nichts`- und `-nothing`-Semantik vor
  Start-/Hilfe-/Tabellenownership;
- **abgeschlossen:** automatische Entfernung absoluter Mojo-Compiler-RUNPATHs
  nach regulären und schweren Builds;
- **als Nächstes:** verbleibende dynamische Prompt-Sitzungs-/Speicherbefehle und
  die noch atomar zurückfallenden gemischten Bruchdomänen getrennt portieren;
- **nach funktionalem Portabschluss:** `PYTHON_CLEANUP_BACKLOG.md` Punkt für
  Punkt im Python-/PyPy3-Original abarbeiten und gemeinsame korrigierte
  Sollfixtures für Python und Mojo festlegen.


## Stage 12c4t – native Wortvervollständigung

- `reta_architecture/completion_word.py` und die Legacy-Fassade
  `libs/word_completerAlx.py` besitzen eine typisierte Mojo-Laufzeit.
- UTF-8-Cursor bleiben Bytepositionen des nativen Editors; sichtbare
  `start_position`-Werte werden wie in Python in Unicode-Skalaren gezählt.
- Präfix-, Middle-, `WORD`- und Satzmodus sowie Anzeige-/Metadatenersetzung
  sind ohne Python-Objekte verfügbar.
- Zehn Python↔Mojo-Datensätze sind byteidentisch; fünf native Unit-Tests
  bestehen.
- `PY-CAND-007` hält fest, dass prompt_toolkits Standardregex deutsche Wörter
  an ASCII-/Unicode-Grenzen trennt. Mojo konserviert dies bis zur gemeinsamen
  Python-/Mojo-Bereinigung.

## Stage 12c5d – native Legacy-Fassaden

- `libs/center.py` und `libs/lib4tables.py` wechseln auf vollständigen nativen Besitz.
- 27 Center-Funktionen, sechs nPm-Gruppen und 18 öffentliche Tabellenhilfe-Reexports sind typisiert abgebildet.
- Vier Hilfeassets und 83 Unicode-Ziffernbereiche werden reproduzierbar aus eingefrorenen Quellen erzeugt.
- `MOJO-FIXED-028` korrigiert die bisherige ASCII-only-Ziffernerkennung.
- Der nach Stage 12c5e korrigierte damalige Stand lautet **49/92 vollständig**, **71/92 mindestens teilweise**, **32.641/48.831 angegriffene Referenzzeilen**; die zuvor höheren Angaben waren manuell überzählt (`TEST-FIXED-013`).


## Stage 12c5e – native CSV-/Kombinationsverkettung

- `reta_architecture/concat_csv.py` und `libs/lib4tables_concat.py` wechseln auf vollständigen nativen Besitz.
- Exakte rationale Paargruppen ersetzen die Float-/Rundungsgrenze; fünf historische CSV-Prägarben, Transposition, Überschriften, Primzahlkompaktion, Tabellenanhängung und Metadaten sind typisiert.
- Die Legacy-Fassade bewahrt 34 Nicht-Konstruktormethoden und 13 Zustandssektionen.
- Python↔Mojo-Parität: **20/20 Zeilen byteidentisch**; neue native Tests **12/12**; angrenzende Bruch-/Metaspaltentests **7/7**.
- Sourcearchive werden als XZ ausgeliefert und parallelfähig mit `xz -T0` aufgerufen; beim aktuellen kleinen Tarstrom war ein Block kleiner als erzwungene Mehrblockarchive. Paralleles Brotli ist nicht vorhanden.
- `tools/porting_metrics.py` macht die Fortschrittszahlen reproduzierbar und schließt `TEST-FIXED-013`.
- Stand: **51/92 vollständig**, **73/92 mindestens teilweise**, **33.198/48.831 = 68,0 % angegriffene Referenzzeilen**.


## Stage 12c5f – native Parametersemantik, Spaltenbindung und Universal-Synchronisation

- `semantics_builder.py`, `column_selection.py` und `universal.py` wechseln auf vollständigen nativen beziehungsweise reproduzierbar generierten Besitz.
- Der vollständige Katalog umfasst 431 Familien, 432 Matrixeinträge, 84 Hauptparameter, 4.155 Parameterpaare, 14 typisierte Datenslots und 556 einfache Spalten.
- Normal- und Inversionsmodus stimmen über zwei vollständige UTF-8-Fingerabdrücke und **20/20** kanonische Probezeilen mit Python überein.
- Indexierte `Dict[String, Int]`-Tabellen reduzieren den Vollaufbau samt Fingerabdruck von über 20 Minuten auf ungefähr 0,8 Sekunden.
- Set-basierte Parameternamen und Datensätze werden nur an semantisch ungeordneten Grenzen kanonisiert; Generator und Referenzasset sind unter `PYTHONHASHSEED=0` und `1` byteidentisch (`TEST-FIXED-015`).
- Drei veraltete Python-Testwerte werden ohne Produktivlogikänderung von 554 auf 556 korrigiert (`TEST-FIXED-014`).
- Maschinenberechneter Stand: **54/92 vollständig**, **74/92 mindestens teilweise**, **33.465/48.831 angegriffene Referenzzeilen**.


## Stage 12c5g – nativer Kombinationsjoin und ordnungsunabhängige Volltabellenparität

- `reta_architecture/combi_join.py` besitzt nun einen vollständigen nativen Besitzer für CSV-Dekodierung, Auswahlrelation, vorbereitete Untertabellengruppen, Zellbereinigung und Tabellenjoin.
- Fachlich mengenartige Hauptzeile→CSV-Zeilen-Zuordnungen werden kanonisch sortiert; sichtbare Kombinationsreihenfolgen bleiben separat geordnet.
- Der Volltabellenvergleich kanonisiert physische Spalten- und Klassentokenreihenfolgen, bleibt aber gegenüber Inhalts-, Zeilen-, Attribut- und Markupänderungen empfindlich.
- Stand nach der Stage: **55/92 vollständig**, **75/92 mindestens teilweise**, **34.177/48.831 angegriffene Referenzzeilen**.

## Stage 12c5h – native Paketexporte und deterministische Installation

- Die 598-zeilige Reexportfassade `reta_architecture/__init__.py` ist als reproduzierbarer typisierter Katalog mit **314 Importbindungen**, **232 geordneten öffentlichen Exporten** und **46 Besitzermodulen** portiert.
- `reta-mojo-exports` stellt Symbol-, Modul-, Public- und Gesamtabfragen ohne Python-Import bereit.
- Der `middle.alx`-Vergleich weist Container- und Nutzlastdigests getrennt aus. Das hochgeladene vermeintliche Python3-Artefakt ist ein Tar, dessen einziges Mitglied byteidentisch mit der PyPy3-Datei ist; ein unabhängiger Python3-Ausgabestrom war daher nicht enthalten.
- `scripts/install_targets.txt` begrenzt Installationen auf **31 offizielle Compilerziele**. Unbekannte Alt-/Debugdateien wie `reta-native-o0` werden nicht mehr kopiert.
- Stand: **56/92 vollständig nativ/generiert**, **76/92 mindestens teilweise**, **34.775/48.831 angegriffene Referenzzeilen**.


## Stage 12c5i – native Architektur-Tabellenadapter

- `reta_architecture/table_adapters.py` ist vollständig nativ besessen.
- Vier Modulhelfer, 17 logische `Prepare`-Methoden und 34 `Concat`-Methoden werden in exakter Quellreihenfolge inventarisiert.
- Der heterogene `Prepare`-Objektzustand ist als `PrepareAdapterState` typisiert; die drei Python-Properties besitzen explizite Getter/Setter.
- Die Fassade dupliziert keine Algorithmen, sondern leitet auf `row_filtering`, `table_preparation`, `table_wrapping`, `tag_schema`, `number_theory` und `legacy_lib4tables_concat` weiter.
- Header-/Tagmutation bleibt seriell; Datenzeilen verwenden denselben typisierten Kontext wie die native Thread-Zeilenvorbereitung.
- Maschinenstand: 57/92 vollständig, 77/92 mindestens teilweise, 35.194/48.831 angegriffene Referenzzeilen.


## Stage 12c5j – Ownership-Korrektur und nativer Fassadengraph

- `architecture_exports_for_module` überträgt seine explizite lokale `ArchitectureExportSpec`-Kopie mit `entry^`; der unter Mojo 1.0.0b2 reproduzierte Buildabbruch ist als `MOJO-FIXED-029` dokumentiert.
- `reta_architecture/facade.py` erhält einen reproduzierbaren nativen Strukturvertrag: 45 Felder, 49 Methoden, 45 Bootstrap-Zuweisungen, 44 Rebuild-Einstiege, 98 Abhängigkeitskanten und 48 Snapshot-Einträge.
- Feld- und Bootstrap-Reihenfolge bleiben getrennt, weil die Konstruktion abhängige Komponenten bewusst später erzeugt als ihre Dataclass-Position.
- `reta-mojo-facade` prüft und fragt den Graphen ohne Python-Import ab. Die heterogene Objektaggregation bleibt teilweise nativ, bis alle referenzierten Besitzer vollständig portiert sind.
- `target/tests/concat_csv_probe` bleibt außerhalb der Produktionsbuilds und wird gezielt mit `scripts/build_concat_csv_probe.sh` erzeugt.
- Maschinenstand: 57/92 vollständig, 78/92 mindestens teilweise, 35.903/48.831 angegriffene Referenzzeilen.


## Stage 12c5k – nativer Program-Workflow-Kern und Inhaltsprofile

- `reta_architecture/program_workflow.py` erhält einen reproduzierbaren Vertrag mit 4 Feldern, 11 Methoden, 10 internen Aufrufkanten und 12 Workflow-Schritten.
- CSV-Pfad, Ausgabemodus, Religion-Zelldekodierung, serielle/native Thread-Tabellenladung, Sprachspaltenersatz, Laufzeitflag-Reset und beide Kombi-Zweigpläne sind echte native Mojo-Logik.
- Die heterogene `Program`-Aggregation bleibt teilweise nativ, bis Tabellenlaufzeit, Generierung und Renderer denselben vollständig typisierten Zustandswert teilen.
- `PROJECT_CONTENT_PROFILES.md` definiert das Sourcearchiv, den lokalen Buildbaum und die installierte Laufzeit; `target/`, `.venv/`, `.git/` und Caches werden nicht mehr für Transpilierungsuploads benötigt.
- Maschinenstand: 57/92 vollständig, 79/92 mindestens teilweise, 36.282/48.831 angegriffene Referenzzeilen.


## Stage 12c5l – UTF-8, Compilerresolver und README-Generator

- Selbstreferenzielles `MOJO_BIN` wird defensiv aufgelöst; Stage 12c5e baut den Concat-Probecompiler wieder über die normale Projektauflösung.
- Religion-JSON-Dekodierung scannt UTF-8 sicher als Bytes und besitzt direkte CJK-/vietnamesische Reproducer.
- `libs/generate4readme.py` ist vollständig durch kanonische deutsch/englische Assets und einen nativen Laufzeitbesitzer ersetzt.
- `PY-CAND-012` hält die hashseedabhängige Reihenfolge von vier Python-Bruchparameterlisten für den späteren Cleanup fest.
- Maschinenstand: 58/92 vollständig, 80/92 mindestens teilweise, 36.664/48.831 angegriffene Referenzzeilen.

## Stage 12c5m – Testumgebung, Workflow-Priorität und Domain-Probe-Kern

- [x] `pytest` als explizite Python-Testabhängigkeit der Mojo-Projektumgebung deklarieren und automatisch einrichten.
- [x] Stage-Skripte nur mit einem Python starten, das `pytest` tatsächlich importieren kann.
- [x] Python-kompatible Ausgabemoduspriorität `bbcode > html > plain` unabhängig von der Argumentreihenfolge herstellen.
- [x] Schnelle UTF-8-/JSON-Religion-Fixture für normale Workflow-Regressionsläufe einführen.
- [x] Neun Kernbefehle von `reta_domain_probe_py.py` über den nativen Schema-/Parametersemantikbesitzer bereitstellen.
- [ ] HTML-Metadaten-, Schema- und vollständige Architektur-Snapshotbefehle des Domain-Probe nativ übernehmen.
- Maschinenstand: 58/92 vollständig, 81/92 mindestens teilweise, 37.072/48.831 angegriffene Referenzzeilen.


## Stage 12c5n – CSV-Quoteparität und native HTML-Klassenextraktion

- [x] CSV-Quotes nur am Feldanfang aktivieren und eingebettete JSON-Quotes bytegenau erhalten.
- [x] Workflow-Fixture gegen ASCII, CJK, Vietnamesisch und leere JSON-Schlüssel absichern.
- [x] Versionsabhängigen `prompt_toolkit`-Defektreproducer ohne erzwungenes Altverhalten klassifizieren.
- [x] `reta_extract_html_classes.py` vollständig durch native HTML-Erzeugung, Attributanalyse und JSONL-Ausgabe ersetzen.
- [x] Neues reguläres Compiler- und Installationsziel `reta-extract-html-classes-native` hinzufügen.
- [ ] Vollständige 1.372-Zellen-Produktionsextraktion lokal unter Modular Mojo gegen `htmlclassesPy.jsonl` laufen lassen.
- Maschinenstand: 59/92 vollständig, 82/92 mindestens teilweise, 37.197/48.831 angegriffene Referenzzeilen.


## Stage 12c5o – vollständiger nativer Meta-Spaltenbesitzer

- `reta_architecture/meta_columns.py` wechselt von unportiert zu vollständig nativ.
- Alle 14 öffentlichen Funktionen besitzen typisierte Einstiege; die bereits nativen Meta-Spalten- und Primwirkungsalgorithmen werden durch Bundle, Snapshot, CSV-/Bruchkatalog und historische Aliase vollständig geschlossen.
- `assets/meta_columns_catalog.tsv` bindet 87 Brüche und 884 geordnete Kombinationseinträge reproduzierbar an die beiden Quell-CSVs.
- `PY-CAND-013` hält den kompatibel konservierten Python-Fehler fest, durch den alle vier `stern/div`-Gruppen leer bleiben.
- Maschinenstand: 60/92 vollständig, 83/92 mindestens teilweise, 38.174/48.831 angegriffene und 28.751/48.831 vollständig native Referenzzeilen.


## Stage 12c5p – vollständige Morphismen und einheitliche Testinterpreterwahl

- `reta_architecture/morphisms.py` wechselt von teilweise nativ zu vollständig nativ.
- Alle 13 Methoden der fünf Klassen besitzen typisierte Mojo-Verträge.
- Die bisherige Bereichsimplementation dedupliziert nach der Sortierung nun wirklich wie die Python-Referenz `sorted(set(...))`.
- Der dynamische Shorthand-Callback wird als besitzende `PromptExpansionRequest` an den eigentlichen Expander übergeben, ohne Python-Laufzeit.
- Alle Shell-Pytestpfade verwenden `scripts/run_pytest.sh`; dadurch gewinnt die pytest-fähige Projekt-`.venv` zuverlässig vor einem ungeeigneten System-Python.
- Maschinenstand: **61/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **28.840/48.831 vollständig native Referenzzeilen**.


## Stage 12c5q – UTF-8-sicheres Rendering und vollständige Runtime-Kompatibilität

- Der HTML-, BBCode-, Shell- und Flat-Wortumbruch zerlegt Text über Unicode-Codepoints.
- Rekonstruierte Präfixe werden mit `removeprefix` statt mit Codepointlängen als Byteoffset entfernt.
- Die exakte abstürzende All-Spalten-HTML-Kommandozeile besitzt einen nativen Regressionstest; Umlaute, CJK und Emoji decken weitere Mehrbytegrenzen ab.
- Die tote `pending_space`-Zuweisung im HTML-Klassenextraktor ist entfernt.
- `reta_architecture/runtime_compat.py` wechselt von teilweise zu vollständig nativ: 17 Funktionen, `isZeilenAngabe`, `nPmEnum`, historische Konstanten sowie Bereichs-, Arithmetik-, Hilfe-, Konsolen- und Wrappingadapter.
- Die zentrale Ziffernerkennung verwendet den reproduzierbaren Python-`str.isdigit`-Katalog.
- Maschinenstand: **62/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **29.029/48.831 vollständig native Referenzzeilen**.


## Stage 12c5r – Morphismen-Ownership und vollständiges Table-Wrapping

- Der letzte Teilkonstruktor von `MorphismBundle.from_topology_and_sheaves` verwendet wie die drei vorherigen eine explizite `ContextSelection.copy()`; ein Transfer aus der immutable Eingabereferenz ist ausgeschlossen.
- `table_wrapping.py` wechselt von teilweise zu vollständig nativ: zwölf Funktionen, Runtime-/Bundle-Snapshots, Getter/Setter, Bootstrap, `alxwrap`, Chunks und Breitenberechnung sind typisiert.
- Das mutable Python-Modulglobal wird durch `TextWrapRuntimeState` ersetzt; pyphen/pyhyphen-Objekte werden als Capability-Felder modelliert, ohne dynamische Python-Callables einzubetten.
- Alle nativen Split- und Fallbackpfade arbeiten über Codepoints und bewahren bei fehlendem Backend den historischen Ein-Element-Fallback.
- Maschinenstand: **63/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **29.229/48.831 vollständig native Referenzzeilen**.


## Stage 12c5u – Tabellen-Gluing

- [x] `table_generation.py` vollständig typisiert.
- [x] CSV-, Generator- und Kombi-Reihenfolge als nativer Orchestrator.
- [x] 20 reguläre plus 18 schwere Compilerziele.
- [ ] Lokalen Modular-Compilerlauf `scripts/test_stage12c5u.sh` ausführen.

## Stage 12c5w – Compilerreparatur und vollständiger Input-Vertrag

- [x] Reservierten lokalen Bezeichner `alias` aus dem vollständigen Importgraphen entfernen.
- [x] `src/main.mojo` als erstes Compiler-Gate jeder Stage-12c5w-Prüfung bauen.
- [x] Alle vier öffentlichen Klassen und 18 Felder von `input_semantics.py` typisiert besitzen.
- [x] 17.741 dynamisch erzeugte Vokabulardatensätze reproduzierbar und ohne Python-Laufzeit laden.
- [x] Hashseedabhängigkeit des Generatorimports erkennen und mit kanonischem `PYTHONHASHSEED=0` schließen.
- [x] FHS-Installation des Input-Katalogs und der von `mojo-runtime-exec` benötigten Frischehelfer schließen.
- [x] FHS-Layouttests mit `RETA_TARGET_DIR` von lokalen Buildartefakten entkoppeln.
- [x] Row-Range-Zeichenschnitte und Präfix-Escaping für mehrbyteige Unicode-Präfixe härten.
- [x] `--mojo-input-snapshot` im öffentlichen `reta-mojo`-Launcher verdrahten.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5w.sh` ausführen und etwaige nachfolgende Compilerdiagnose zurückführen.
- Maschinenstand: **69/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **30.672/48.831 vollständig native Referenzzeilen**.

## Stage 12c5y – vollständiger nativer TableOutput-Besitzer

- [x] Historischen `TableOutput`-Zustand als explizite typisierte Konfiguration abbilden.
- [x] Property-, Spaltenprojektions-, Puffer-, Farb- und Bundle-Verträge nativ besitzen.
- [x] Shell, CSV, Markdown, Emacs, HTML, BBCode und Nichts an den vorhandenen nativen Renderer anbinden.
- [x] Diagnoseziel `reta-mojo-table-output`, Modultest und Python/PyPy3-Parität hinzufügen.
- [x] All-Columns-Source-Test auf den einzigen Besitzer `parameter_runtime.mojo` aktualisieren (`TEST-FIXED-027`).
- [x] **60/60** fokussierte Source-Gates, **144 + 1 Skip** portable Source-Suite und **264/264** Importresolver abschließen.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5y.sh` mit einem gefüllten aktuellen `target`-Baum ausführen.
- Maschinenstand: **71/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **31.790/48.831 vollständig native Referenzzeilen**.

## Binärkonsolidierung nach Stage 12c5z

- erledigt: TableGeneration, OutputSyntax, ConsoleIO und TableOutput teilen `libreta-mojo-diagnostics.so` und einen ABI-geprüften Loader;
- nächster sinnvoller Bibliotheksblock: die eng gekoppelten Architekturdiagnosen aus `build-heavy.sh` nach fachlichen Gruppen konsolidieren, nicht alle 18 Ziele blind in eine monolithische DSO werfen;
- Testprogramme bleiben kurzlebige, nicht installierte Prozesse, bis Messungen zeigen, dass deren Buildzeit oder Speicherverbrauch die bessere Fehlerisolation überwiegt;
- portable Binärübergaben müssen über `scripts/export_target.sh` erfolgen, damit keine absoluten `.venv`-Symlinks weitergegeben werden.

## Stage 12c5aa – Build-Besitz und vollständige Prepare-Fassade

- [x] `scripts/build-all.sh` als einzigen vollständigen Produktions-Baueinstieg hinzufügen.
- [x] Gemeinsame Diagnosebibliothek ausschließlich dem regulären Build zuordnen.
- [x] Tiefes Build-/Paritätswerkzeug in `build-and-test-shared-diagnostics.sh` umbenennen.
- [x] Historische Stage-Tests von installierbaren `target/bin`-Artefakten entkoppeln.
- [x] Source-ID-Sidecar im Installationsmanifest separat und korrekt prüfen (`TEST-FIXED-028`).
- [x] `libs/lib4tables_prepare.py` vollständig typisiert über vorhandene native Tabellenkerne besitzen.
- [x] Lokalen fokussierten Modular-Test `scripts/test_stage12c5aa.sh` ausführen; 4/5 Tests bestanden, der fünfte deckte eine falsche Erwartung bei unbegrenzter Terminalbreite auf (`TEST-FIXED-030`).
- Maschinenstand: **72/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **32.103/48.831 vollständig native Referenzzeilen**.
## Stage 12c5ac – vollständige Prompt-Vorbereitungsfassade

- historischer `configure_prompt_preparation`-/Bootstrapvertrag explizit typisiert
- deutsche Legacy-Funktionsnamen und `prepare_grosse_ausgabe` als dünne native Weiterleitungen
- fünfsprachiger frischer Legacy-Snapshot gegen Python
- kein neues installierbares Compilerziel

## Stage 12c5ad – vollständige Tabellenvorbereitung und Laufzeit

- [x] `table_preparation.py` vollständig typisieren.
- [x] Header-/Tag-Gluing, Spaltenbijektion und Haupt-/Kombi-Ergebnisse besitzen.
- [x] `table_runtime.py` samt `Tables`, `Maintable` und Bundle vollständig besitzen.
- [x] `table_state.py` um Factory- und Snapshotoberfläche ergänzen.
- [x] Fortschrittsmetriktest gegen erfolgreiche Inkremente härten.
- [x] `test_all.sh` über den portablen Runtimewrapper ausführen.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5ad.sh` ausführen.
- [ ] Nach mehreren weiteren Stages oder vor einem Release `scripts/test_all.sh` ausführen.
- Maschinenstand: **76/92 vollständig**, **83/92 mindestens teilweise**,
  **38.174/48.831 angegriffene** und **33.430/48.831 vollständig native
  Referenzzeilen**.

## Stage 12c5ai – Mojo-Testeffekte und nativer Schema-Snapshot

- [x] Gemeldeten `cannot call function that may raise`-Fehler im Legacy-Table-Handling-Test beheben.
- [x] Gesamten Mojo-Testbaum auf fehlende `raises`-Annotationen prüfen und fünf Fundstellen korrigieren.
- [x] Dauerhaften Quellvertrag für Testeffekte hinzufügen.
- [x] `schema-json` aus dem typisierten nativen Schema bytegenau serialisieren.
- [x] Schemakataloggenerator auf die echten Splitmodule und Kombinationsgrößen umstellen.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5ai.sh` ausführen.
- [ ] Danach `./do.sh 12c5ai` bis zum vollständigen `test_all.sh`-Abschluss ausführen.
- Offen in der Domänenprobe: nur noch `architecture-json`.



## Stage 12c5aj – kanonische Parametergarbe und Prompt-Execution-Besitz

- [x] Lokal bestätigte 12c5ai-Testeffekt- und Schema-Reparaturen dokumentieren.
- [x] `ParameterAliasGroup` und `PairColumns` zentral in Python-Reihenfolge sortieren.
- [x] Parität um `params`, `pairs` und `main-json` erweitern.
- [x] `PromptExecutionBundle` und exakten Snapshot nativ zusammensetzen.
- [x] Sechs reine Helfer aus `prompt_execution.py` typisiert übertragen.
- [x] Dauerhafte Source- und Mojo-Regressionstests hinzufügen.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5aj.sh` ausführen.
- [ ] Danach `./do.sh 12c5aj` bis zum vollständigen `test_all.sh`-Abschluss ausführen.
- Offen: der große interaktive `PromptGrosseAusgabe`-Effektblock und `architecture-json`.


## Stage 12c5ak – native Architektur- und Domänenproben

- [x] `architecture-json` als letztes Domänenprobe-Kommando nativ bereitstellen.
- [x] 48 Architekturabschnitte reproduzierbar mit `PYTHONHASHSEED=0` einfrieren.
- [x] Absolute Referenzpfade durch einen zur Laufzeit aufgelösten portablen Token ersetzen.
- [x] Sämtliche 63 statischen JSON-/Markdown-Kommandos von `reta_architecture_probe_py.py` nativ laden.
- [x] `package-integrity-json` dynamisch über den nativen Manifestbesitzer ausführen.
- [x] Eigenes reguläres Ziel, Launcher, Installmanifest und vollständige Parität ergänzen.
- [x] Generator gegen Hashseed-, Bytecode- und Cachezustandsabweichungen härten.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5ak.sh` ausführen.
- [ ] Danach `./do.sh 12c5ak` bis zum vollständigen `test_all.sh`-Abschluss ausführen.

Maschinenstand: **79/92 vollständig**, **85/92 mindestens teilweise**, **41.130/48.831 angegriffene Referenzzeilen**.


## Stage 12c5al – vollständiger nativer Legacy-I18n-Monolith

- [x] Historischen Monolithen ohne `__all__` über seine wirksame öffentliche Domänenoberfläche erfassen.
- [x] Alle acht Klassen und vier Funktionen in den fünfsprachigen typisierten Baumkatalog integrieren.
- [x] Debug-, Duplikat- und Klassifikationsverhalten an vorhandene native Besitzer delegieren.
- [x] Katalogformat auf v2 anheben und 68.265 Zeilen bytegenau regenerierbar machen.
- [x] Snapshot-, Source-, Installations- und Portierungsmetriken aktualisieren.
- [ ] Lokalen Modular-Lauf `scripts/test_stage12c5al.sh` ausführen.
- [ ] Danach `./do.sh 12c5al` bis zum vollständigen `test_all.sh`-Abschluss ausführen.

Maschinenstand: **80/92 vollständig**, **86/92 mindestens teilweise**, **46.561/48.831 angegriffene Referenzzeilen**.


## Stage 12c5ax – historische Prompt-Familien ohne unnötigen Fallback

- [x] Historischen Ownership-Entscheid aus `prompt_main.mojo` in ein reines typisiertes Modul extrahieren.
- [x] Alle 33 bereits geplanten Tabellenfamilien gemeinsam klassifizieren.
- [x] Neun konservativ ausgesparte Kompaktfamilien aus dem Python-Fallback holen.
- [x] Shell-, Speicher- und unbekannte Verbundteile weiterhin atomar ablehnen.
- [x] Acht schnelle End-to-End-Ströme isoliert bytegenau prüfen; `alles` planvollständig und im Full-All-Workflow stromvollständig halten.
- [ ] Benutzerseitigen Modular-Lauf `scripts/test_stage12c5ax.sh` ausführen.


## Stage 12c5ay – Legacy-Prozessnamen auf nativen Thread-Backendvertrag ausrichten

- [x] Benutzerlauf bis zum ersten realen Laufzeitabbruch auswerten.
- [x] Vier Number- und zwei Row-Assertions vom entfernten Prozessmodus auf den aufgelösten Threadmodus korrigieren.
- [x] Alle zehn `*_in_processes`-Kompatibilitätsaliase quellseitig an ihre `*_threaded`-Besitzer binden.
- [x] Erneute Einführung von `stats.mode == "processes"` statisch verbieten.
- [x] Stage 12c5ax mit allen historischen Promptfamilien in die aktuelle Kette übernehmen.
- [ ] Benutzerseitigen Modular-Lauf `scripts/test_stage12c5ay.sh` ausführen.

## Stage 12c5ba – eindeutige Buildthreads und negative Bruch-No-ops

- [x] Benutzer-`-j` gegen die drei internen `-j 4`-Defaults deduplizieren.
- [x] Ohne Benutzerwert den konservativen Threaddefault exakt einmal bewahren.
- [x] Mehrere explizite Benutzer-Threadoptionen vor dem Compiler ablehnen.
- [x] Potenziell werfende `Int(String)`-Konvertierung der gemischten Reziprokachse mit `raises` propagieren.
- [x] Drei reihenfolgensensitive negative-first Bruchvielfachen-Zweige ohne Python-Kindprozess besitzen und positive-first Gegenfälle atomar halten.
- [ ] Benutzerseitigen Modular-Lauf `scripts/build-all.sh -- -j 8 && scripts/test_stage12c5ba.sh` ausführen.

## Stage 12c5bb – positive reziproke Vielfache mit ausgeschlossenen echten Brüchen

- [x] Positive-first `v1/n,-a/b`-Referenzpfade instrumentiert erfassen.
- [x] Die enge Signaturklasse ohne positive echte Brüche und ohne ausgeschlossene Reziproke typisiert besitzen.
- [x] Universum-, Emotion- und Teilerprojektionen quell- und laufzeitseitig binden.
- [x] Ausgeschlossene echte Brüche aus der `n/m`-CSV-Materialisierung fernhalten.
- [x] Den dokumentierten `v1/4,-1/8,2/3`-Kollisionsfall atomar lassen.
- [ ] Benutzerseitigen Modular-Lauf `scripts/build-all.sh -- -j 8 && scripts/test_stage12c5bb.sh` ausführen.
## Stage 12c5bc – installierter Launcher ohne optionales Ziel

- [x] Fehlenden optionalen `reta-mojo-table`-Build im FHS-Layout reproduzieren.
- [x] Quellbaum-Fallback nur bei tatsächlich vorhandener Mojo-Quelle zulassen.
- [x] Im Binärlayout deterministischen Exitstatus 127 und konkrete Diagnose liefern.
- [x] Positive-first Bruchvielfachen-Port aus 12c5bb vollständig in der Stage-Kette erhalten.
- [ ] Benutzerseitigen Modular-Lauf `scripts/build-all.sh -- -j 8 && scripts/test_stage12c5bc.sh` ausführen.
## Stage 12c5bd – Prägarbenvererbung und reziproke Bruchkollision

- [x] Positionsabhängige `cn`-Prägarbenannahme durch einen vollständigen 16+16-Vererbungsvertrag ersetzen.
- [x] Sprachneutrale Sektionen nach Verfeinerung mit `cn`-Kontext und unveränderter Nutzlast bewahren.
- [x] `v1/4,-1/8,2/3` in Reziprokdifferenz und echte Bruch-CSV-Achse zerlegen.
- [x] 13-Aufruf-Plan, Zeilenmenge und direkte native Ausführung in die bestehende Paritätskette aufnehmen.
- [ ] Benutzerseitigen Modular-Lauf `scripts/build-all.sh -- -j 8 && scripts/test_stage12c5bd.sh` ausführen.

## Stage 12c5be – Workflow-Root und konsistenter Rich-Output-Modus

- [x] Den `Jungfrau`-gegen-UTF-8-Fixture-Fehler des vollständigen Mojo-Laufs auflösen.
- [x] `ProgramWorkflowBundle.repo_root` bis zu Religion- und Motiv-CSV durchreichen.
- [x] Verstecktes `RETA_DATA_DIR` aus dem fokussierten Workflow-Modultest entfernen.
- [x] Lokalisierte HTML-/BBCode-Erkennung mit dem typisierten Rendererplan synchronisieren.
- [x] Beide Rich-Modi und ihre historische BBCode-Priorität regressionsprüfen.
- [x] Benutzerseitiger 12c5be-Lauf bestätigt: Workflow **5/5**, Hauptprogramm **16 Fälle**, portable Verträge **67 bestanden**.
- [ ] Danach `RETA_TEST_HEAVY=1 scripts/test_all.sh` vollständig fortsetzen.

## Stage 12c5bf – domänenspezifische Mehrfachpläne für echte Bruchvielfache

- [x] Die vier physischen Zähler×Nenner-Rechtecke ausdrücklich typisieren.
- [x] Mehrere ausgewählte Bruchfamilien in unabhängige Projektionen zerlegen.
- [x] Historische Familienreihenfolge Emotion → Größe → Motive → Universum bewahren.
- [x] 26-Aufruf-Zweidomänen- und 44-Aufruf-Vierdomänenvertrag ergänzen.
- [x] Gemischte Reziprokachsen pro Domäne unter der 1024er-Grenze vereinigen.
- [x] Unbewiesene Mischungen mit klassischen Familien, Eigenschaften oder Ganzzahlen atomar halten.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bf.sh` ausführen.
- [ ] Danach `RETA_TEST_HEAVY=1 scripts/test_all.sh` vollständig fortsetzen.

## Stage 12c5bg – deterministische Kommandoassets und positive Ganzzahl-/Bruchachsen

- [x] Den 12c5aq-Abbruch aus dem 12c5bf-Benutzerlauf auf eine ambient Rich-Version zurückführen.
- [x] Die eingefrorene Python-Assetgenerierung mit einem lokalen textuellen Rich-Minimaladapter isolieren.
- [x] Benutzer-Site-Packages ausschließen und Ist-/Soll-SHA-256 bei Abweichungen ausgeben.
- [x] Positive Ganzzahlen und Bereiche neben `v n/m` ohne doppelte Projektion vervielfachen.
- [x] Ein- und Mehrdomänen-, Reziprok-, abgeschnittene und Teilerkompositionen binden.
- [x] Null-, Ausschluss- und separat negative Komponenten bis zu einem eigenen Vertrag atomar halten.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bg.sh` ausführen.
- [ ] Danach `RETA_TEST_HEAVY=1 scripts/test_all.sh` vollständig fortsetzen.

## Stage 12c5bj – stabile Kommando-Paritätsassets

Der historische Assetgate ist jetzt vollständig read-only. Fünf gepinnte SHA-256-Verträge ersetzen die erneute Referenzausführung im normalen Stage-Lauf. Die Python-Referenz bleibt mit `--check-reference` explizit prüfbar, ist aber von der reproduzierbaren nativen Snapshotfreigabe getrennt. Damit ist die durch CPython 3.14 ausgelöste falsche Migrationsverweigerung geschlossen.

- [x] `Set[Int]`/`List[Int]`-Compilergrenze im echten Bruchteilerpfad schließen
  und durch den aktuellen fokussierten Mojo-Probe absichern (12c5bj).

## Stage 12c5bk – hermetische native Parität und klassische Bruchguards

- [x] Geerbte installierte `RETA_*`-Ressourcenpfade aus dem nativen Kommando-Paritätsgate entfernen.
- [x] Den Prüfer unter absichtlich ungültigen Fremdpfaden gegen 4/4 gepinnte Fälle ausführen.
- [x] Die äußere Zeile-1-Sentinel im Bruchteilerpfad wiederherstellen und Wert 1 deduplizieren.
- [x] Klassische Ganzzahlfamilien bei reinen echten Bruchachsen inert behandeln.
- [x] Ein- und Mehrdomänenfälle gegen die eingefrorene `bedingungZahl`-Grenze prüfen.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bk.sh -- -j 4` ausführen.
- [ ] Danach `scripts/build-tests.sh --heavy -- -j 4 && scripts/run-tests.sh --jobs 4` ausführen.

### Stage 12c5bk

- hermetische native Kommando-Parität;
- klassische Ganzzahlfamilien bleiben bei reinen Bruchachsen inert;
- äußere Zeile 1 im Bruchteilervertrag wiederhergestellt;
- konservativ inkrementelle Testkompilierung mit transitiven Importhashes;
- nichtwerfender `hoechsteZeile()`-Zugriff über `Dict.get()`.

## Stage 12c5bl – klassische Ganzzahl-/Mehrdomänen-Bruchkomposition

- [x] Äußere Python-Reihenfolge relativ zum unveränderten Basisplan beweisen.
- [x] Geordnete Vereinigung domänenspezifischer Ganzprojektionen typisieren.
- [x] Thomas vor und Mond/Alles/Primzahlkreuz/Richtung nach den Domänen planen.
- [x] Vielfachen-, Teiler-, Null- und Ausschlussachsen regressionsprüfen.
- [x] Vollständigen 31-Aufruf-Vertrag für alle klassischen Familien ergänzen.
- [x] stdin-TTY und Terminalgeometrie des nativen Paritätsrunners isolieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bl.sh -- -j 4` ausführen.

## Stage 12c5bm – Mehrdomänen-Eigenschafts-/Katalogkomposition

- [x] EIGN/EIGR zwischen Motive- und Universumblock auf der geordneten
  Vereinigung korrigierter Projektionen planen.
- [x] Numerische Familie 16 vor Familie 15 nach allen physischen Bruchblöcken
  ausführen.
- [x] Explizite gewöhnliche Vielfachenachsen genau einmal an Eigenschafts- und
  Katalogaufrufe anhängen.
- [x] Positive-First-Referenzprüfung vom gerenderten stdout auf gesammelte
  Executor-argv umstellen.
- [x] Klassische Ganzzahlfamilien plus neue Eigenschafts-/Katalogachsen bis zu
  einem separaten Reihenfolgebeleg atomar halten.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bm.sh -- -j 4` ausführen.

## Stage 12c5bn – kombinierte klassische, Eigenschafts- und Katalogachsen

- [x] Gemeinsame Python-Außenordnung über Executor-argv unabhängig vom defekten
  historischen n/m-Rechteck einfrieren.
- [x] Thomas → physische Domänen → EIGN/EIGR → Universum →
  Mond/Alles/Primzahlkreuz/Richtung → 16 → 15 als einen Vertrag binden.
- [x] Den konservativen Classic+Property/Numeric-Fallback entfernen.
- [x] 28-, 29-, 34- und 35-Aufrufpläne regressionsprüfen.
- [x] Gemeinsame äußere Ganzzahlprojektion und Primzahlkreuz-Sonderachse prüfen.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bn.sh -- -j 4` ausführen.

## Stage 12c5bo – kanonische Optionsschreibweise im Laufzeitprüfer

- [x] Benutzerfehler nach erfolgreichem Vollbuild auf Probe-Assertion eingrenzen.
- [x] Historische Python-argv-Schreibweise von nativer kanonischer Schreibweise trennen.
- [x] Native Emotionsachse auf `--grundstrukturen=emotion` und Spalten 4,5 binden.
- [x] Prüfstandsdefekt und Sourcevertrag dokumentieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bo.sh -- -j 4` ausführen.

## Stage 12c5bp – korrigierter Zwischenstand

- [x] Die fehlende Trennung lokaler und globaler Vielfachenschreibweisen
  lokalisieren.
- [x] Den zunächst zu weit gefassten Kompakt-v-Vertrag als durch 12c5bq
  korrigiert kennzeichnen.

## Stage 12c5bq – kommalokales Präfix und globales positionsfreies v

- [x] Python-Referenz für `v` an erster, mittlerer und letzter Wortposition
  ausführbar binden.
- [x] Kompakte Präfixe pro Kommakomponente statt pro Gesamttoken auswerten.
- [x] Eigenständiges `v` und `vielfache` global auf alle Bruchpaare anwenden.
- [x] Lokale 2-/4-Aufruf- und globale 13-/19-Aufrufverträge trennen.
- [x] Defekt `MOJO-FIXED-067` auf den tatsächlichen Scope-Overreach korrigieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bq.sh -- -j 4` ausführen.

## Stage 12c5br – vollständige Prompt-Ausgabeparameter

- [x] Alle 13 kanonischen Ausgabeparameter im historischen Eigentumsbeweis freigeben.
- [x] 65 fünfsprachige Katalogaliasnamen an denselben typisierten Besitzer binden.
- [x] `justtext`, `onetable`, `endlessscreen`, `endless`, `dontwrap` und `breiten` aus dem atomaren Fallback entfernen.
- [x] Parameter aus der CPython-kompatiblen Gesamtmengenordnung aller Prompttokens filtern.
- [x] Duplikatentfernung und exakte Executor-argv-Reihenfolge mit 7 Referenzfällen binden.
- [x] Zwei veraltete lokale-v-Assertions aus dem vollständigen Benutzerlauf korrigieren.
- [x] Brotli-Interpreterauflösung und Cachelöschung portabel stabilisieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5br.sh -- -j 8` ausführen.


## Stage 12c5bs – positionsunabhängige Prompt-Begleiteffekte

- [x] `abc`/`abcd` bei genau zwei Wörtern in Präfix- und Suffixposition nativ klassifizieren.
- [x] Rohtext bewahren und nur die typisierte Nutzwortreihenfolge normalisieren.
- [x] `loggen`/`nichtloggen` als positionsfreie Begleiteffekte nativer Tabellen- und `mulpri`-Pläne besitzen.
- [x] Loggingzustand erst nach erfolgreicher Tabellenwirkung anwenden und `loggen`-Priorität erhalten.
- [x] Direkte kompakte Bruchprobe auf den korrekten lokalen Zwei-Aufruf-Vertrag festschreiben.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bs.sh -- -j 8` ausführen.


## Stage 12c5bt – Informations-Begleiteffekte

- [x] `kurzbefehle`, `befehle` und Hilfe über lokalisierte Mengenmitgliedschaft besitzen.
- [x] Historische Ausgabeordnung Kurzbefehle → Befehle → Hilfe vor der Tabelle bewahren.
- [x] Zusammengesetztes `leeren` explizit am terminalabhängigen Kompatibilitätsrand halten.
- [x] Abgewiesene Tabellen-/`mulpri`-Kandidaten vor jedem Einzelbefehlsdispatch atomar zurückgeben.
- [x] Explizite Spaltenwahl gegen interne Richtungs-Standardwahl regressionsprüfen.
- [x] Komponentenlokalen Reziprok-Settail vollständig binden.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bt.sh -- -j 8` ausführen.

## Stage 12c5bu – natives zusammengesetztes `leeren`

- [x] Terminalzeilen nativ über `TIOCGWINSZ`, `LINES` und 24-Fallback bestimmen.
- [x] `leeren`/`clear` positionsunabhängig als Tabellen-/`mulpri`-Begleiteffekt besitzen.
- [x] Historische Reihenfolge Informationsausgaben → Zeilen+1 → Tabelle bewahren.
- [x] Standalone-ANSI-Clear und atomaren Fallback unverändert halten.
- [x] Nicht-`Writable`-Struct im Mojo-Test über `Equatable` vergleichen.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bu.sh -- -j 8` ausführen.

## Stage 12c5bv – Inline-Speicherung und deterministische Tabellentests

- [x] Positionsunabhängige zusammengesetzte `S`-/`s`-Speicherung nativ planen.
- [x] Ambiguitäts-, Duplikat- und `abc`-Grenzen gegen Python einfrieren.
- [x] Englische Compound-Clear-Probe in den Einmalmodus versetzen.
- [x] Mond-/Sonnen- und terminalbreitenabhängige Tabellenverträge korrigieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bv.sh -- -j 8` ausführen.

## Stage 12c5bw – Verlaufseigentum der Inline-Speicherung

- [x] Bereits konsumierte Inline-Speicherzeilen von der Previous-Command-Policy ausschließen.
- [x] Präfix-, Mittel-, Suffix- und lokalisierte Langaliasformen gegen Python binden.
- [x] Verlaufspolitik im typisierten `prompt_interaction.mojo` statt im Prozesseinstieg besitzen.
- [x] `MOJO-FIXED-073` im zentralen Defektledger dokumentieren.
- [x] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bw.sh -- -j 8` erfolgreich ausgeführt.


## Stage 12c5bx – gespeicherte Ausgabezusätze im Interaktionsbesitz

- [x] Python-Referenzdefekt für `o` plus Zusatz reproduzierbar einfrieren.
- [x] Positionsunabhängigen `o`-/`BefehlSpeicherungAusgeben`-Plan nativ typisieren.
- [x] Zusatzpayload als String statt Python-Listenobjekt führen.
- [x] Bereits konsumierte gespeicherte Ausgabezusätze von der Previous-Command-Policy ausschließen.
- [x] `PY-OPEN-007` im zentralen Defektledger und Python-Bereinigungsrückstand dokumentieren.
- [ ] Benutzerseitig `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bx.sh -- -j 8` ausführen.


## Stage 12c5cg – Bare informational dispatch ownership

- Alleinstehende Informationsbefehle `hilfe`/`help`, `befehle`/`commands` und `kurzbefehle`/`shortcommands` werden als `PromptInformationalDispatchPlan` im Interaktionsbesitzer geplant.
- `prompt_main.mojo` rendert nur noch die geplanten Hilfe-/Befehlsausgaben und enthält keine bare `KIND_HELP`-/`KIND_COMMANDS`-/`KIND_SHORT_COMMANDS`-Branches mehr.
- Zusammengesetzte Informations-Begleiteffekte bei Tabellen- und `mulpri`-Plänen bleiben im historischen Tabellenbesitzer, weil dort die Reihenfolge vor der Tabelle maßgeblich ist.
- Benutzerprüfung: `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cg.sh -- -j 8`.

## 12c5ch follow-up

The prompt controller now delegates bare deterministic output commands to the
interaction owner. Remaining controller-owned boundaries are external execution
(shell/python/math/reta), one-shot-only logging status text and the historical
`mulpri` composition helper.
