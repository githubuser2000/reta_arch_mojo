# Testergebnisse – Stufe-9/10/11-Zwischenstand

## Testbestand

```text
62 Mojo-Testdateien und -Probes
274 Testfunktionen insgesamt
9 reguläre ELF-Compilerziele
7 optionale schwere Metadaten-/Katalogziele
```

Der letzte vollständig abgeschlossene normale Stufe-7-Lauf ergab **145/145** Tests. Seitdem kamen Meta-, Bruch-, Kombi-, Markup- und Prompttests hinzu. Ein monolithischer Kaltlauf stößt in dieser Umgebung bei `test_csv_reference`, großen Asset-Compilern und wiederholten Python-Referenzstarts an das äußere Ausführungslimit. Deshalb werden die veränderten Programme zusätzlich einzeln gebaut und ausgeführt.

## Aktuell erneut ausgeführte Mojo-Tests

```text
test_csv_table                    3/3
test_prompt_language             16/16
test_prompt_runtime              30/30
test_prompt_legacy_echo           5/5
test_prompt_fraction_execution    8/8
test_prompt_table_execution      23/23
test_meta_columns                 3/3
test_fraction_concat_columns      3/3
test_kombi_join_columns           4/4
test_generated_aliases            6/6
test_native_reta_cli             20/20
test_generated_table_columns      7/7
test_table_rendering              8/8
test_html_cell_metadata           4/4
test_row_filtering_reference      3/3
test_architecture_coherence      10/10
test_architecture_traces           9/9
                                -------
                                162/162 bestanden
```

In den oben gezählten Einzelsuiten gab es keinen Testfehler. Zwei breitere Sammelprüfungen werden ausdrücklich **nicht** als bestanden gezählt:

- `scripts/test_prompt_bins.sh` erreichte bei wiederholten Python-Referenzstarts das äußere Laufzeitlimit und lieferte deshalb keinen abgeschlossenen Gesamtlauf.
- `scripts/check_native_table_parity.sh` trifft unter dem lokal verwendeten Python 3.13.5 auf eine Referenzharness-Abweichung: Die direkte Python-CSV-Ausgabe verklebt Zeilen, während der native CSV-Renderer sie mit Zeilenumbrüchen ausgibt. Die Stage-10c-Pfade werden deshalb zusätzlich über feste Byte-Fixtures und normalisierte geordnete CSV-Tokenströme geprüft. Dieser breite Harnessfall ist offen und wird nicht als Paritätserfolg ausgegeben.

## Stufe 7: Generator- und Metaspalten

```bash
./scripts/test_stage7.sh
./scripts/check_generated_column_parity.sh
```

Die CLI-Suite enthält **30** reale deutsche und englische Generatorfälle. Abgedeckt sind Klassifikatoren, Modallogik, Primzahlkreuz, Primzahlwirkung, Primuniversum, `PrimCSV`, zwölf Metaachsen, vier Bruch-Prägarben sowie Markdown/Emacs.

Der frühere englische Testname `--universe_meta_concrete` war im Python-Original kein wirksamer Alias und verglich zwei leere Ausgaben. Er wurde durch den realen Alias `--universeMetaConcrete` ersetzt; dessen nichtleere Ausgabe ist bytegleich.

## Stufe 8: Kombinationspfad

```bash
./scripts/test_stage8.sh
./scripts/check_kombi_parity.sh
```

Die Kombi-Suite enthält **9** reale CLI-Fälle für Galaxie und Universum, Deutsch und Englisch, Einzel-, Mehrfach- und Negativauswahl sowie gemischte Abfragen. Historische leere Segmente und Relationsreihenfolgen sind Teil des Bytevergleichs.

Die Laufzeitassets sind reproduzierbar:

```text
4.095 Meta-Anfrageordnungen
173 Kombi-Aliase
151 Kombi-Relationsordnungen
9.593 wirksame Generatoraliase
71.820 geordnete Bruchrelationen
```

## Stufe 9: BBCode, HTML und ANSI-Shell

```bash
./scripts/test_stage9.sh
./scripts/check_markup_parity.sh
RETA_MARKUP_EXTENDED=1 ./scripts/check_markup_parity.sh
```

Die schnelle Release-Suite vergleicht **8** zentrale Markupausgaben gegen geprüfte Python-Byte-Fixtures. Insgesamt wurden **16** Markupfälle direkt mit `PYTHONHASHSEED=0` gegen die Python-Referenz validiert. Dazu kommen **5/5** ANSI-Shell-Fixtures für Deutsch und Englisch, Breite 0 und 40, deaktivierte Nummerierung und eine generierte Primzahlwirkungsspalte.

Geprüft werden unter anderem:

- BBCode-Wortumbruch, Seitenteilung, Zählungsfarben und Zellabstände
- physische und dynamische HTML-Zellmetadaten
- echte `<ul>`, `<li>` und `<br>` bei weiterhin maskierten mathematischen Vergleichen
- ANSI-Farben, Fortsetzungszeilen, interne Doppel-Leerzeichen und Auffüllung

`test_html_cell_metadata.mojo` benötigte beim Kaltlauf rund 35 Minuten, bestand aber vollständig mit **4/4** Tests.

## Stufe 10: Prompt-Sprache und Completion

```bash
./scripts/test_stage10.sh
./scripts/check_prompt_language_catalog.sh
./scripts/check_prompt_compact_parity.sh
./scripts/check_prompt_preparation_parity.sh
./scripts/check_prompt_completion_fixtures.sh
./scripts/check_prompt_completion_worker.py
```

Die Promptprüfung umfasst:

```text
27/27 kompakte deutsch/englische Kurzsprachenkontexte bytegleich
23/23 vollständige Promptvorbereitungskontexte bytegleich
12/12 verschachtelte Referenz-Completion-Kontexte bytegleich
12/12 schnelle Completion-Fixtures bytegleich
12/12 Readline-Kontexte an den persistenten Mojo-Arbeiter delegiert
16/16 Prompt-Sprachtests bestanden
30/30 Prompt-Laufzeittests bestanden
```

Zusätzlich ist die fachliche Ausführung jetzt geprüft:

```text
18/18 Bruch-/Bereichsausdrücke bytegleich zu bruchSpalt/createRangesForBruchLists
23/23 Tabellenplanertests bestanden
14/14 reale Bruch-/Modifikatorfälle als normalisierte CSV-Tokenströme identisch
7/7 reale Prompt-Ausführungen als Byte-Fixtures
18 Tabellenfamilien über reta-native statt retaPrompt.py
```

Die Planertests prüfen deutsche und englische Aliase, Mehrfachbefehle, `range`, Invertierung, Ausgabeparameter, das doppelte `groesse`-Routing, die bedingte Universum-Spaltenauswahl, ganzzahlige Vielfachen/Teiler/Einzelauswahl, reduzierte Brüche, echte `n/m`-Spalten, historische Rechteck- und Versatzsyntax, stabile Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache.

Die vierzehn Tabellenreferenzfälle umfassen `emotion`, `universum`, `groesse`, `mond` und `motive`. Neu geprüft sind Bruchteiler, Reziprok- und echte Bruchausschlüsse sowie Reziprok-Vielfache. Verglichen wird der geordnete CSV-Tokenstrom nach Entfernung ausschließlich präsentationsbedingter Whitespace-Läufe; eine Bytegleichheit des noch nicht vollständig identischen Shell-Wrappings wird daraus nicht abgeleitet. Echte `v n/m`-Vielfache mit Zähler größer 1 und kollidierende Legacy-Ausschlussformen bleiben atomar am Fallback.

Die sieben Ausführungsfixtures umfassen Primfaktorenvergleich, einfache und primfaktorisierte Abstände, bidirektionale Bereichsabstände sowie ANSI-Tabellenausgaben. Der Promptcontroller trennt die ausgegebene Befehlszeile nun korrekt von der ersten Tabellenzeile. Der native CLI- und One-shot-Besitztest bestand mit **19/19**, der Renderer mit **4/4** Tests.

Ein Pseudoterminaltest bestätigte die tatsächliche interaktive Ergänzung:

```text
reta -ausgabe --art=htm<Tab>  →  reta -ausgabe --art=html
```

Der fünfsprachige Katalog wird in ein temporäres Verzeichnis regeneriert und byteweise gegen die eingecheckten Assets verglichen. Abgedeckt sind 28.990 Completion-Werte in 549 Sektionen, 200 Dispatch-Aliase, 95 Kurzersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

Der kombinierte `test_stage10.sh`-Kaltlauf wurde einmal nach den bereits bestandenen Sprach-, Laufzeit-, Katalog-, Kurzsprachen- und Fixtureprüfungen vom äußeren Limit beendet. Die noch ausstehende Workerprüfung und die später ergänzten Vorbereitungstests wurden anschließend separat vollständig bestanden. Deshalb wird kein unvollständiger Sammellauf als Gesamterfolg ausgegeben; die obigen Zahlen stammen aus den jeweils abgeschlossenen Einzelprüfungen.

### Stage 10d: obere Zeilengrenzen und Referenzabgrenzung

Ein explizites `--oberesmaximum` hebt nun wie in Python beide historischen Zeilengrenzen an. Zwei fokussierte Tests sichern die Sichtbarkeit nicht-mondartiger Zeilen oberhalb der Standard-Kurzgrenze sowie den korrekten Standardwert 163; gemeinsam mit dem bestehenden Referenzvektor ergibt die Suite **3/3**. Der Reziprok-Vielfachenfall `v1/256,-1/512` prüft praktisch, dass sowohl Zeile 256 als auch Zeile 768 gerendert werden.

Die Fälle `v2/3` und `vielfache 2/3` werden nicht als fehlgeschlagene Mojo-Parität gezählt: Das unveränderte Python-Original bricht dort selbst mit `IndexError` ab. Stage 10d belässt diesen Bereich ausdrücklich an der Bridge, statt eine unbelegte Ersatzsemantik einzuführen.

## Buildprüfung

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Alle neun regulären ELF-64-Ziele wurden gebaut:

```text
reta-mojo-native
reta-mojo-table
reta-mojo-tags
reta-native
reta-mojo-compat-bin
reta-prompt-native
reta-prompt-complete
grundStrukHtml-native
generate-html-native
```

Der Sammelbuild erreichte wegen des äußeren Zeitlimits nur einen Teil der großen Ziele. Die restlichen Ziele wurden einzeln erfolgreich kompiliert; `check_build_layout.sh` bestand danach. `bin/` enthält nur versionierbare Launcher, `target/bin/` nur ignorierte Compilerprodukte.

## Referenzbaseline

Die unveränderte Python-Referenz hatte beim Eingang bereits drei fehlschlagende und einen übersprungenen Test. Diese Baseline-Abweichungen wurden nicht dem Mojo-Port zugerechnet und nicht verdeckt geändert.

## Stage 10e: nativer One-shot- und In-Process-Promptpfad

- `test_native_reta_cli.mojo`: **19/19** bestanden, davon acht neue Besitz-/Ablehnungstests.
- `check_prompt_native_oneshot.sh`: sechs Befehlsarten in einem Verzeichnis ohne `mojo_bridge.py` und ohne `reta-native`-Kindprozess bestanden; zwei Fallbackgrenzen isoliert bestätigt.
- Öffentliche Prompt-Binärtests einschließlich rohem `reta`, interaktivem Prompt, Speicherung und historischem `a 2`-Echo bestanden.
- Die zuvor ausgeführten betroffenen Mojo-Gruppen standen bei **83/83**, die Prompt-Ausführungsfixtures bei **7/7** und die Bruch-/Modifikatormatrix bei **14/14**.
- Der abschließende breite Stage-10-Sammellauf wurde durch einen Neustart der begrenzten Ausführungsumgebung während weiterer Compilerziele beendet. Er wird ausdrücklich nicht als bestanden gezählt; daraus entstand kein konkreter Testfehler.


## Stage 10f: kompakte Legacy-Echos und zusammengesetztes `mulpri`

- `test_prompt_legacy_echo.mojo`: **5/5** bestanden.
- `test_prompt_language.mojo`: **16/16** einschließlich UTF-8-SipHash-Regression bestanden.
- `test_prompt_runtime.mojo`: **21/21** einschließlich korrigierter nichttrivialer Faktorpaare bestanden.
- `check_prompt_compact_execution_parity.sh`: **5/5** vollständige Ausgaben (`a2`, `ap15`, `p12`, `p13`, `G2`) bytegleich zu Python 3.13.5 mit `PYTHONHASHSEED=0`.
- `check_prompt_native_oneshot.sh`: neun native Befehlsklassen ohne `mojo_bridge.py` und ohne `reta-native`-Kindprozess; rendererempfindliche Kurzformen, reine Zahlenkürzel und gemischte Speicher-/Tabellenkürzel bleiben nachweislich atomar am Fallback.
- Die kompakte Sprachvorbereitung bleibt **27/27**, die bestehenden Ausführungsfixtures **7/7**, der Bruchparser **18/18** und die Bruch-/Modifikatormatrix **14/14**. Der ungeteilte 14er-Lauf überschritt das Werkzeugfenster; dieselben Fälle wurden in Gruppen 4+4+3+3 vollständig abgeschlossen.


## Stage 10g: vorbereitete Fragmentbreiten und alle kompakten Tabellenfamilien

- `test_table_rendering.mojo`: **5/5**; der neue Test sichert die Messung an vorbereiteten Wortfragmenten statt an rohen, pauschal gekappten Zellen.
- `check_prompt_compact_execution_parity.sh`: **10/10** vollständige Ausgaben bytegleich zu Python 3.13.5 mit `PYTHONHASHSEED=0`. Neu sind `B2`, `E2`, `T2`, `W2` und `u2`.
- `check_prompt_native_oneshot.sh`: **14** repräsentative Befehlsklassen laufen in einem Verzeichnis ohne `mojo_bridge.py` und ohne `reta-native`-Kindprogramm.
- `check_prompt_execution_fixtures.sh`: **7/7**; die zwei Tabellenfixtures bilden nun auch die tatsächliche Rich-`cliout`-Verklebung von Befehlszeile und Tabellenkopf ab.
- `check_shell_parity.sh`: **5/5** Shell-Fixtures bytegleich.
- `check_markup_parity.sh`: **8/8** zentrale BBCode-/HTML-Fixtures bytegleich.
- Bruchparser **18/18**, Bruch-/Modifikatortabellen **14/14**, kompakte Sprachvorbereitung **27/27**, vollständige Promptvorbereitung **23/23**.
- Alle neun regulären ELF-Ziele wurden seriell aus dem Stage-10g-Quellstand gebaut; `check_build_layout.sh` bestand.


## Stage 10h: native Zahlen- und Katalogkomposition

- Fokussierte Mojo-Suiten: **96/96** (`5 + 21 + 16 + 8 + 21 + 19 + 6`).
- `check_prompt_numeric_execution_parity.sh`: **11/11** vollständige Ausgaben bytegleich zu Python 3.13.5 mit `PYTHONHASHSEED=0`.
- `check_prompt_numeric_oneshot.sh`: **8/8** repräsentative Zahlenklassen laufen in einem Verzeichnis ohne `mojo_bridge.py` und ohne `reta-native`-Kindprozess.
- Der Tabellenplaner prüft alle **365/365 historisch adressierbaren** Einträge des fünfsprachigen numerischen Katalogs. Fünf Multiversum-Einträge mit Schlüssel 15 sind wegen der bereits belegten Legacyform `16_15` grammatisch unerreichbar und werden nicht als fehlgeschlagene Mojo-Abdeckung ausgegeben.
- Kompakte Sprache **27/27**, vollständige Vorbereitung **23/23**, kompakte Ausführung **10/10**, Promptfixtures **7/7**, Bruchparser **18/18**, Completion **12/12**, Shell **5/5** sowie BBCode/HTML **8/8** bleiben grün.
- Die neue Rendererprüfung sichert die historische `█`-Markierung gerader Zählungsgruppen einschließlich umgebrochener visueller Zeilen.


## Stage 10i: native Null-, Negativ- und Ausschlussselektoren

- Fokussierte Mojo-Suiten: **100/100** (`16 + 21 + 5 + 8 + 23 + 20 + 7`).
- `test_prompt_table_execution.mojo`: **23/23**, einschließlich `0`, rein negativer Ganzzahlen, Ganzzahl-/Bruchkollisionen und `teiler`-Subtraktion vor der Divisorbildung.
- `test_native_reta_cli.mojo`: **20/20**; identische positive/negative Zeilenprädikate werden zentral gekürzt und aktivieren bei leerem Rest die All-Zeilen-Semantik.
- `test_table_rendering.mojo`: **7/7**; die Nummernspaltenbreite kann den angeforderten oberen Grenzwert übernehmen, ohne endliche Promptfixtures zu verbreitern.
- `check_prompt_numeric_execution_parity.sh`: **11/11** vollständige numerische Ausgaben bytegleich.
- `check_prompt_numeric_oneshot.sh`: **15/15** nichtleere numerische Klassen laufen isoliert ohne Python-Datei und ohne `reta-native`-Kindprozess.
- `check_prompt_execution_fixtures.sh`: **7/7** allgemeine Promptausgaben bleiben bytegleich.
- Reine leere Pläne wie `-2` und `u teiler 0` sind im Planner exakt geprüft; sie werden nicht als interaktive One-shot-Smokes verwendet, weil ein ausgabeloser Promptprozess sonst in die Eingabeschleife wechseln kann.
- `scripts/test_stage10.sh`: vollständiger Stage-10-Regressionslauf einschließlich Katalog-, Fraction-, Compact-, Preparation- und Completion-Parität mit Exitcode 0.
- `scripts/build.sh`: alle **9/9** vorgesehenen Mojo-Executables erfolgreich kompiliert; `check_build_layout.sh` bestätigt das vollständige Binärlayout.


## Stage 10j: wiederholte Katalogauswahl und Shell-Whitespace-Chunks

- `test_prompt_table_execution.mojo`: **23/23**; der frühere Fallbackfall `15_ 16_15 15` ist jetzt ein besessener Einzelplan mit doppeltem Legacy-Aliasbündel.
- `test_table_rendering.mojo`: **8/8**; der neue Regressionstest sichert Whitespace-Läufe an der 73-Zeichen-Umbruchgrenze der Primzahlkreuz-Zelle.
- Direkter Tabellenvergleich des einfachen Aliasbündels: **8.955/8.955 Byte** und `cmp` ohne Abweichung.
- Vollständige doppelte Promptausgabe: **9.523/9.523 Byte** und `cmp` ohne Abweichung.
- `check_prompt_numeric_execution_parity.sh`: Fixturematrix auf **12/12** erweitert.
- `check_prompt_numeric_oneshot.sh`: Besitzmatrix auf **16/16** erweitert; der neue Fall läuft in einem Verzeichnis ohne Python-Implementierung und ohne `reta-native`-Kindprogramm.
- `scripts/test_stage10.sh`: vollständiger Lauf einschließlich 101/101 fokussierter Mojo-Tests, Katalog-, Compact-, Numeric-, Preparation- und Completion-Parität mit Exitcode 0.
- `scripts/build.sh`: alle **9/9** regulären Mojo-Executables aus dem finalen Stage-10j-Quellstand gebaut; `check_build_layout.sh` bestanden.

## Stage 10k: mehrbereichige `abstand`-/`abstandPrim`-Ausführung

- Fokussierte Stage-10-Mojo-Suiten: **110/110** (`16 + 30 + 5 + 8 + 23 + 20 + 8`).
- `test_prompt_runtime.mojo`: **30/30**; neun neue Regressionen decken Dreifachbereiche, Primfaktorabstände, Duplikate, gemischte Kardinalitäten, äußere Resizes, große Bereiche sowie beide `set.difference`-Strategien ab.
- `check_prompt_distance_execution_parity.sh`: **8/8** vollständige Ausgaben bytegleich zur Python-3.13-Referenz mit `PYTHONHASHSEED=0`.
- `check_prompt_distance_oneshot.sh`: **2/2** Mehrbereichsklassen laufen in einem Verzeichnis ohne Python-Quellen und ohne `reta-native`-Kindprozess.
- Die Referenzreihenfolge wird nicht sortiert angenähert: String-Set, Frozenset-Hash, Singleton-Merge, Difference-Neuaufbau beziehungsweise Copy-and-discard sowie die erste Dict-Schlüsselposition bei späterer Wertüberschreibung sind modelliert.
- `scripts/test_stage10.sh`: vollständiger Lauf mit **110/110** fokussierten Mojo-Tests, Katalog-, Fraction-, allgemeiner Prompt-, Compact-, Numeric-, Distance-, Preparation- und Completion-Parität; Exitcode 0.
- `scripts/build.sh`: alle **9/9** regulären Mojo-Executables aus dem finalen Stage-10k-Quellstand gebaut; `check_build_layout.sh` bestanden.
- Nach dem Vollbuild erneut bestanden: **30/30** Runtime-Tests, **8/8** Mehrbereichs-Bytefixtures und **2/2** isolierte Mehrbereichs-One-shots.



## Stage 10l: native Datei-, Pipe- und HTML-Orchestrierung

- `test_csv_table.mojo`: **3/3** einschließlich vollständiger 1025×746-Referenztabelle über natives Mojo-Datei-I/O.
- Die fokussierten dokumentierten Einzelsuiten stehen damit bei **143/143**.
- `scripts/test_stage10.sh`: **113/113** Stage-10-Mojo-Tests und sämtliche Fraction-, Prompt-, Compact-, Numeric-, Distance-, Preparation- und Completion-Prüfungen mit Exitcode 0.
- `check_prompt_width_oneshot.sh`: **3/3** positive Shell-/HTML-/BBCode-Breiten bytegleich, ohne Python-Quellbaum und ohne `reta-native`-Kindprozess.
- `check_native_io_boundaries.sh`: native CSV-/Asset-Datei-I/O, persistentes Completion-Protokoll und HTML-Override ohne `std.python` beziehungsweise `libpython`; ein fehlgeschlagener Referenzkindprozess wird nicht als Erfolg akzeptiert.
- `check_prompt_completion_worker.py`: **12/12** Readline-Kontexte weiterhin bytegleich.
- `check_html_parity.sh`: Override-, deutscher und englischer Ein-Zeilen-Normalpfad bytegleich; der normale Pfad besitzt genau die dokumentierte `--spalten --alles`-Referenzgrenze.
- `scripts/build.sh`: alle **9/9** regulären Mojo-Executables aus dem finalen Stage-10l-Quellstand gebaut; `check_build_layout.sh` bestanden.
- `check_markup_parity.sh`: **8/8** zentrale BBCode-/HTML-Fixtures bytegleich; `check_shell_parity.sh`: **5/5** Shell-Fixtures bytegleich; `check_compat_parity.sh` bestanden.
- Der breite kalte `test_all.sh`-Lauf schloss die ersten **13** Suiten ohne Fehler ab und wurde während des folgenden Compilerziels bewusst beendet, statt einen unvollständigen Lauf als Gesamterfolg auszugeben.
- `release_check.sh` erreichte nach Vollbuild und mehreren Katalogprüfungen den bereits dokumentierten Python-3.13.5-CSV-Harnessfall: Die Referenz verklebt Zeilen, während der native CSV-Renderer Zeilenumbrüche ausgibt. Dieser bekannte Harnessfall wird nicht als Stage-10l-Regression und auch nicht als Release-Gesamterfolg ausgegeben.

## Stage 10m: komponierte Ganzzahlmodifikatoren und dynamische Selektorgrenzen

- `test_prompt_table_execution.mojo`: **25/25** bestanden. Neu abgedeckt sind Teilervereinigungen für mehrere Werte, Bereiche und die nicht sortierte CPython-Folge `24 -> 2,3,4,6,8,24,12`.
- `test_native_reta_cli.mojo`: **22/22** bestanden. Absolute `vN`-Selektoren heben die Laufzeitgrenze auf 1027 beziehungsweise 1029 an, während `v24` bei 1024 bleibt.
- Angrenzende Kernsuiten: Row-Ranges **7/7**, Row-Filtering **4/4**, Tabellenvorbereitung **2/2**.
- Reale normalisierte CSV-Parität gegen Python 3.13.5 mit `PYTHONHASHSEED=0`:
  - `vielfache teiler mond 6 10`: **243/243** Datenzeilen identisch,
  - `vielfache teiler mond 2-4`: **687/687** Datenzeilen identisch,
  - `vielfache teiler mond 24`: **49/49** Datenzeilen identisch.
- `reta-native` wurde aus dem Stage-10m-Quellstand erfolgreich neu gebaut.
- Der große `test_generated_columns.mojo` überschritt beim erneuten Kompilieren das großzügige Compilerlimit; es kam zu keinem ausgeführten und fehlgeschlagenen Test.
- Der breite `--alles`-Test wurde **nicht** gestartet. Gemäß Vorgabe darf er ausschließlich mit **90 Minuten Timeout** laufen; ein 30-Minuten-Lauf wurde weder angesetzt noch versucht.

## Stage 10n: native EIGN/EIGR-Eigenschaften

```bash
./scripts/check_prompt_property_planning.sh
./scripts/check_prompt_property_execution_parity.sh
./scripts/check_prompt_property_oneshot.sh
```

Ergebnisse:

```text
6/6 fokussierte Eigenschaftsplanertests bestanden
23/23 Integrationsverträge bestanden
165/165 katalogisierte EIGN/EIGR-Befehle besitzen einen nativen Plan
5/5 Python↔Mojo-CSV-Zellströme semantisch identisch
2/2 EIGN-Promptnutzlasten semantisch identisch
6/6 isolierte One-shot-Besitzfälle ohne Python-Module und Kindprozess
```

EIGN wird zusätzlich gegen den funktionsfähigen Python-Prompt geprüft. Für EIGR
ist der direkte `reta.py`-Argumentvertrag die Referenz, weil der Python-Prompt
vorher in `deepcopy(module)` abbricht. Die CSV-Parität normalisiert ausschließlich
präsentationsbedingte Whitespace-Läufe und Leerzeilen; Rohbyte-Parität wird für
diese Fälle nicht behauptet.

In dieser Stage wurde **kein** Befehl und kein Test mit `--alles` ausgeführt.

Der funktional integrierte Prompt-Controller war für die Ausführungsprüfungen
erfolgreich gebaut. Ein erneuter vollständiger Monolithbuild nach der
verhaltensneutralen Ein-Set-Reihenfolge-Optimierung überschritt 30 Minuten
Compilerzeit ohne Diagnose; Unit- und Integrationsziele des endgültigen
Quellstands kompilierten und bestanden.


## Stage 11a: Architekturkarte und Boundary-Graph

```text
test_architecture_map           3/3
test_architecture_boundaries    4/4
                              -----
                               7/7 bestanden
```

Zusätzlich bestanden:

- `scripts/check_architecture_control_generation.sh`: beide generierten Mojo-Dateien byteidentisch zur aktuellen Python-Referenz
- Architekturmap-Generator bei `PYTHONHASHSEED=0`, `1`, `42`, `random`: identischer SHA-256 `610f4b743a8bbd09316de46d46d341361c5e1561831c6818929b83d098466e45`
- Boundary-Generator bei denselben vier Seeds: identischer SHA-256 `574d829d47ca1bdd57e75ee61177c3a188db50a99c123b27d529b32f6ed59338`
- `reta-mojo-boundaries` als ELF gebaut; `--summary`, `--module reta.py` und `--capsule InputPromptCapsule` erfolgreich
- `RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh` erfolgreich mit drei schweren Zielen

Kein Stage-11a-Test und kein Stage-11a-Programmaufruf verwendete `--alles`.


## Stage 11b: Architekturverträge und Witness-Matrix

Fokussierte native Builds und Läufe:

```text
probe_architecture_contracts   20/20 Bedingungen, Build 11,28 s
reta-mojo-contracts            Summary/Diagramm/Kapsel/Gesetz, Build 12,17 s
probe_architecture_witnesses   24/24 Bedingungen, Build 23,20 s
reta-mojo-witnesses            Summary/Anker/Kapsel/Diagramm/Transformation/Verpflichtung, Build 23,75 s
```

Generatorprüfungen:

- `architecture_contracts.mojo` bei Hash-Seeds `0`, `1`, `42`, `random` byteidentisch, SHA-256 `14f0459c85ac0513381ba92de9fde1fc42231d404a92d6be7385a6a93daf1416`
- `architecture_witnesses.mojo` bei denselben Seeds byteidentisch, SHA-256 `26ba36ae176cc07e5031d03a3cee9d93315e8d36a59ea5b35de4c53a9ba593d3`
- `scripts/check_architecture_control_generation.sh`: Karte, Boundaries, Verträge und Witnesses **4/4** byteidentisch
- Vertragsvalidierung: `passed`, keine fehlenden Kapseln, Kategorien, Funktoren oder Transformationen
- Witness-Validierung: `passed`, 351/351 dateiartige Anker aufgelöst und keine unbedeckten Kapseln, Diagramme, Gesetze oder Transformationen
- `RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh` erwartet nun fünf schwere Ziele

Kein Stage-11b-Test und kein Stage-11b-Programmaufruf verwendete `--alles`.


## Stage 11c: Architektur-Kohärenz und Trace-Navigation

Fokussierte native Builds und Läufe:

```text
test_architecture_coherence   10/10, Build 9,11 s
test_architecture_traces        9/9, Build 12,12 s
reta-mojo-coherence           Build 10,23 s
reta-mojo-traces              Build 12,66 s
                             -----
                              19/19 Bedingungen
```

Zusätzlich bestanden:

- Python↔Mojo-Ausgabeparität: **8/8 byteidentisch**
- Architekturkontrollregeneration: **6/6 byteidentisch**
- Kohärenz- und Trace-Generatoren bei `PYTHONHASHSEED=0`, `1`, `42`, `random`: jeweils byteidentisch
- Kohärenzvalidierung: `passed`, alle zehn Fehlerlisten leer
- Tracevalidierung: `passed`, alle sieben Fehlerlisten leer, 34 Komponenten und 204 Route-Hops intern bestätigt
- `RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh`: erfolgreich mit sieben schweren Zielen

Kein Stage-11c-Test und kein Stage-11c-Programmaufruf verwendete `--alles`.
