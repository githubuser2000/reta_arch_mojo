# Testergebnisse – Stufe-9/10/11-Zwischenstand

## Testbestand

```text
94 Mojo-Testdateien und -Probes
17 Python-Testdateien
407 Testfunktionen insgesamt (341 Mojo, 66 Python)
9 reguläre ELF-Compilerziele
16 optionale schwere Metadaten-/Katalog-/Laufzeitziele
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
test_architecture_impact          11/11
test_architecture_migration       13/13
                                -------
                                162/162 bestanden
```

In den oben gezählten Einzelsuiten gab es keinen Testfehler. Zwei breitere Sammelprüfungen werden ausdrücklich **nicht** als bestanden gezählt:

- `scripts/test_prompt_bins.sh` erreichte bei wiederholten Python-Referenzstarts das äußere Laufzeitlimit und lieferte deshalb keinen abgeschlossenen Gesamtlauf.
- `scripts/check_native_table_parity.sh` trifft unter dem lokal verwendeten Python 3.13.5 auf eine Referenzharness-Abweichung: Die direkte Python-CSV-Ausgabe verklebt Zeilen, während der native CSV-Renderer sie mit Zeilenumbrüchen ausgibt. Die Stage-10c-Pfade werden deshalb zusätzlich über feste Byte-Fixtures und normalisierte geordnete CSV-Tokenströme geprüft. Dieser breite Harnessfall ist offen und wird nicht als Paritätserfolg ausgegeben.


## Stage 12c4m/n: Installation und vollständige HTML-Tabelle

```text
Installationslayout /usr:                 bestanden
Installationslayout /usr/local:           bestanden
Installationslayout $HOME/.local:         bestanden
Fedora-LIBEXECDIR=/usr/libexec/reta:      bestanden
Runtime-Pfadtests:                        4/4
Bruchkoordinaten:                         4/4
Generatorreihenfolge und Mond-Markup:     9/9
HTML-Metadaten:                           7/7
Kombi-Join:                               5/5
vollständiges HTML Deutsch:               807 Spalten, bytegleich
vollständiges HTML Englisch:              807 Spalten, bytegleich
Basistabelle CSV/Markdown/Emacs:           4/4 bytegleich
positive Einzelbreiten:                  12/12 bytegleich
explizite Nullbreiten:                    12/12 bytegleich
paginierte Shell/HTML/BBCode:              6/6 bytegleich
keineleereninhalte:                       13/13 bytegleich
rohes HTML/BBCode --nocolor:              12/12 bytegleich
Markup-oneTable:                          12/12 bytegleich
Kombi-CSV:                                 9/9 bytegleich
Source-/Installations-Pytests:            19/19
```

Die CSV-Dateien liegen physisch nur unter `share/reta/csv`; die private
Python-Referenz erreicht dieselben Dateien über einen relativen Symlink. Die
vollständigen HTML-Fixtures enthalten je 807 Überschrifts- und 807 Datenzellen.

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

Der fünfsprachige Katalog wird in ein temporäres Verzeichnis regeneriert und byteweise gegen die eingecheckten Assets verglichen. Abgedeckt sind 25.834 Completion-Werte in 561 Sektionen, 200 Dispatch-Aliase, 95 Kurzersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

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
- `check_native_io_boundaries.sh`: native CSV-/Asset-Datei-I/O, persistentes Completion-Protokoll und HTML-Override ohne `std.python` beziehungsweise `libpython`; seit Stage 12b läuft auch der reale `--alles`-Normalpfad ohne Referenzkindprozess.
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


## Stage 11d: Architektur-Impact und Migrationsplan

Fokussierte native Builds und Läufe:

```text
test_architecture_impact       11/11, Build 11,63 s
test_architecture_migration    13/13, Build 12,24 s
reta-mojo-impact               Build 11,97 s
reta-mojo-migration            Build 12,84 s
                               -----
                               24/24 Bedingungen
```

Zusätzlich bestanden:

- Python↔Mojo-Ausgabeparität: **8/8 byteidentisch**
- Architekturkontrollregeneration: **8/8 byteidentisch**
- Impact- und Migrationsgenerator bei `PYTHONHASHSEED=0`, `1`, `42`, `random`: jeweils byteidentisch
- Impactvalidierung: `passed`, alle fünf Fehlerlisten leer
- Migrationsvalidierung: `passed`, alle sieben Fehlerlisten leer
- beide öffentlichen Launcher mit Zusammenfassungs- und Namensabfragen erfolgreich

Kein Stage-11d-Test und kein Stage-11d-Programmaufruf verwendete `--alles`.


## Stage 11e: Architektur-Rehearsal und Aktivierung

Fokussierte native Builds und Läufe:

```text
test_architecture_rehearsal     14/14, Build 13,92 s
test_architecture_activation    16/16, Build 16,96 s
reta-mojo-rehearsal             Build 14,55 s, --no-optimization
reta-mojo-activation            Build 17,21 s, --no-optimization
                                -----
                                30/30 Bedingungen
```

Zusätzlich bestanden:

- Python↔Mojo-Ausgabeparität: **11/11 byteidentisch**
- Stage-11e-Generatorprüfung: **2/2 byteidentisch**
- Architekturkontrollregeneration: **10/10 byteidentisch**
- Rehearsal- und Aktivierungsgenerator bei `PYTHONHASHSEED=0`, `1`, `42`, `random`: jeweils byteidentisch
- gespeicherte Referenzvalidierungen: beide `passed`
- native Mojo-Kreuzvalidierungen: beide `passed`
- beide öffentlichen Launcher mit Zusammenfassungs- und Namensabfragen erfolgreich

Kein Stage-11e-Test und kein Stage-11e-Programmaufruf verwendete `--alles`.


## Stage 11f: Gesamtvalidierung und Fortschritts-Overlay

```text
test_architecture_validation: 13/13, Build 6,32 s
test_architecture_progress:   16/16, Build 7,78 s
                              -----
                               29/29
```

Zusätzlich bestanden:

- Python↔Mojo-Abfrageparität: **8/8 byteidentisch**
- Stage-11f-Generatorprüfung: **2/2 byteidentisch**
- gesamte Architekturkontrollregeneration: **12/12 byteidentisch**
- Generatoren bei `PYTHONHASHSEED=0`, `1`, `42`, `random`: jeweils byteidentisch
- Paketintegritätszähler unabhängig von `__pycache__`/`.pyc` auf **457** reguläre Referenzdateien normalisiert; Gesamtsumme **3.448**
- native Validierungs-Kreuzprüfung: `passed`
- native Fortschritts-Kreuzprüfung: konsistentes `attention` mit genau `WIP42-01`
- sämtliche früheren Stage-11a–11e-Summaries mit den erwarteten Statuswerten

Kein Stage-11f-Test und kein Stage-11f-Programmaufruf verwendete `--alles`.


## Stage 11g: Native SQLite-Persistenz

```text
test_persistence: 47/47
```

Zusätzlich bestanden:

- deterministische Python↔Mojo-Demoausgabe;
- Python liest Section, Garben-Snapshot, Ausführungslauf, Audit und invalidierten Cache aus einer von Mojo erzeugten SQLite-Datei;
- Mojo liest eine von Python erzeugte Section bytegleich;
- Mojo liest einen von Python erzeugten Garben-Snapshot bytegleich;
- Unicode-Digest Python↔Mojo identisch;
- insgesamt **5/5** Paritäts-/Interoperabilitätsprüfungen;
- Launcher, optimiertes Compilerziel und Buildlayout erfolgreich.

Der fokussierte Lauf verwendet weder den langen Gesamtbuild noch `--alles`:

```bash
./scripts/test_stage11g.sh
```


## Stage 11h: Natives deterministisches Ausführungsnetz (historischer Prozessstand)

```text
test_execution_network:              85/85
test_execution_network_persistence:  15/15
Python↔Mojo parity:                    8/8
                                      -----
                                     108/108
```

Zusätzlich bestanden:

- echte Linux-`fork`-Worker mit privaten Pipes und `waitpid`;
- parallele Workerbegrenzung durch `max_workers`;
- FIFO-, LIFO- und Prioritätsordnung mit stabilem Taskindex-Tie-Break;
- deterministische Eingabereihenfolge trotz abweichender Schedulerreihenfolge;
- Unicode- und Zeilenumbruchnutzlasten über Prozessgrenzen;
- Fehlerpropagation aus dem Workerprozess;
- bounded Halb-/Vollduplexkanäle und Semaphorzustände;
- Snapshotparität für Konfiguration, Tasks, Resultate, Bundle und Runs;
- Persistieren eines echten Prozesslaufs, Audit-Roundtrip und Tabellenzähler über Stage 11g.

Der fokussierte Lauf vermeidet die langen Gesamtbuilds:

```bash
./scripts/test_stage11h.sh
```


## Stage 11i: Native Tabellenparallelisierung (historischer Prozessstand)

```text
test_prompt_legacy_echo:                 6/6
test_prompt_fixture_integrity:           1/1
test_parallel_execution_config:         29/29
test_parallel_row_processes:            55/55
test_parallel_number_processes:        157/157
test_parallel_table_execution:          26/26
Python↔Mojo CLI-/Primfaktorparität:      12/12
                                         -------
                                        286/286
```

Zusätzlich bestätigt:

- echte Linux-`fork`-Worker mit privaten Pipes und `waitpid`;
- serielle und prozessbasierte Ergebnisse für Religion, Kombi, Mondzahlen, Primfaktoren, Zahlenfilter und Faktorpaare in gleicher Python-Referenzordnung einschließlich Filter-Deduplikation;
- Tabellenprojektion, Zellbreiten, Bucket-Normalisierung und Kombi-Join über echte Chunks;
- Unicode, eingebettete Zeilenumbrüche und delimiterhaltige Nutzlasten über das längenpräfixierte Protokoll;
- typisierter serieller Rückfall statt Python-`None`;
- CLI-Demolauf mit zwei Workern sowie 8/8 Demo- und 4/4 Primfaktor-Paritätsausgaben;
- kompakte Promptankündigung endet exakt mit einem LF; alle zehn Goldendateien sind nichtleer und trennen Ankündigung von Nutzlast.

Der fokussierte Lauf vermeidet die langen Gesamtbuilds:

```bash
./scripts/test_stage11i.sh
```


## Stage 11j: Typisierte Thread-Zeilenvorbereitung (vor Stage 12a)

```text
test_parallel_execution_config:             36/36
test_parallel_row_preparation:               40/40
Python↔seriell↔Thread-Vollstromparität:       2/2
                                              -----
                                              78/78
```

Zusätzlich bestätigt:

- `auto` löst auf `threads` auf; `processes` bleibt explizit erhalten;
- unveränderliche Eingaben, disjunkte Chunkslots und serielle indexstabile Reduktion;
- vier absichtlich unsortierte Beispielzeilen werden mit zwei Threads in die Reihenfolge 1, 2, 3, 4 zurückgeführt;
- Unicode-Codepunktbreite, Wrapping, harte Chunks, Religionsnummern und JSON-Snapshots;
- vollständiger Python↔Mojo-Vollstromvergleich für seriellen und Threadpfad;
- vorläufiger Benchmark mit 20.000 Zeilen: 4,12 s seriell, 3,22 s mit acht Threads, identische Prüfsumme.

Der permanente breite Test `test_parallel_thread_backend.mojo` und der aktualisierte große `reta-mojo-parallel-execution`-Controller sind Teil des lokalen Stage-11j-/Gesamtbuilds. In dieser Umgebung überschritt ihre erneute gemeinsame Mojo-Elaboration selbst das verdoppelte Zeitlimit; die kleinen getrennten Stage-11j-Ziele wurden dagegen gebaut und ausgeführt. Ein ThreadSanitizer-Build ließ sich erstellen, sein Start scheiterte in der Sandbox vor Programmbeginn an einer 1-GiB-tcmalloc-Adressraumreservierung. Das ist kein bestandener TSan-Lauf und wird deshalb nicht in 78/78 eingerechnet.

```bash
./scripts/test_stage11j.sh
./scripts/benchmark_parallel_row_preparation.sh 20000 8 128
```


## Stage 12a: Vollständige native Threadmigration und Boundary-Gates

Stage 12a ersetzt die historischen Prozesspfade aus Stage 11h/11i vollständig.
Die älteren Abschnitte bleiben oben als Entwicklungsnachweis erhalten, beschreiben
aber nicht mehr den aktuellen Laufzeitcode.

```text
Boundary-Pytest:                              1/1
test_execution_network:                     85/85
test_execution_network_persistence:         15/15
test_parallel_execution_config:             36/36
test_parallel_thread_backend:               43/43
test_parallel_row_preparation:              40/40
test_parallel_row_threads:                  55/55
test_parallel_number_threads:              157/157
test_parallel_table_execution:              26/26
Python↔Mojo execution-network parity:         8/8
Python↔Mojo parallel parity:                 12/12
Thread↔Legacy-Alias parity:                   1/1
Python↔serial↔thread row parity:              2/2
                                             -------
fokussierte Mojo-/Paritätsprüfungen:       480/480
plus Boundary-Pytest:                         1/1
```

Zusätzlich bestätigt:

- **0** direkte native `fork`-, `pipe`-, `waitpid`- oder `_exit`-Primitive;
- **2** explizit inventarisierte Restbrücken nach Entfernung der `generate_html`-Subprozessgrenze;
- **10** kanonische typisierte `*_threaded`-APIs;
- alle drei Parallelmodule sind frei von `std.python` und `std.subprocess`;
- `auto`, `threads` und historische Prozesswerte führen denselben Threadpfad aus;
- alte `_in_processes`-Funktionsnamen und CLI-Schalter bleiben nur als
  Kompatibilitätsalias erhalten und erzeugen keinen Prozess;
- das frühere längenpräfixierte Prozess-Stringprotokoll ist durch typisierte
  Chunks und disjunkte Ergebnisslots ersetzt;
- FIFO-, LIFO- und Prioritätsplanung, Fehlerpropagation, Unicode und
  deterministische Reduktion bleiben erhalten;
- Python-Referenz, serielles Mojo, Thread-Mojo und Legacy-Alias liefern in den
  geprüften Fällen identische Ergebnisse.

Der fokussierte Lauf lautet:

```bash
./scripts/test_stage12a.sh
```


## Stage 12b: native `--alles`-Mitteltabelle und Entfernung der HTML-Brücke

```text
Plan-/Boundary-Pytests:                     5/5
Mojo-All-Columns-Loader:                    1/1
native POSIX-Prozessprimitive:                0
explizite verbleibende Runtime-Brücken:       2
Quellwerte im zwölfteiligen Alles-Plan:      756
Daten-/Generatorspalten im Referenzfixture:  805
```

Zusätzlich bestätigt:

- `assets/all_columns_plan.tsv` wird mit `PYTHONHASHSEED=0` byteidentisch aus der Python-Referenz reproduziert;
- das Ein-Zeilen-HTML-Fixture besitzt zwei vollständige Zeilen, 1614 öffnende und 1614 schließende Zellen sowie einen vollständigen Tabellenabschluss;
- `generate_html_main.mojo` importiert weder `std.python` noch `std.subprocess`;
- `native_reta_cli.mojo` besitzt `--alles` und `--onetable`;
- der kleine Mojo-Loader wurde mit dem finalen Quellstand kompiliert und ausgeführt;
- der große `generate-html-native`-Build und dessen Bytevergleich bleiben Bestandteil des lokalen `scripts/build.sh`-/`scripts/check_html_parity.sh`-Laufs, weil die monolithische CLI-Elaboration in dieser Sandbox das verdoppelte Compilerlimit überschritt.

Der fokussierte Lauf lautet:

```bash
./scripts/test_stage12b.sh
```


## Stage 12c1: native Terminalgeometrie und Prompt-Zeilengrenzen

```text
test_terminal_geometry:                    3/3
Fixture-Integrität + Boundary-Audit:        2/2
PTY-Probe-Pytest:                            1/1
PTY-Geometrieprobe:             80→73, 120→113, 200→193
kompakte Befehlsfixtures:                 11/11 mit separater reta-Zeile
```

Zusätzlich bestätigt:

- `--breite=0` verwendet `ioctl(TIOCGWINSZ)` statt der früheren Konstanten 80/73;
- stdout, stdin und stderr werden als TTY-Quellen geprüft, danach `COLUMNS` und der historische 80-Spalten-Fallback;
- `bin/rpb a1` behält seinen Namen und seine Argumentsemantik;
- die sichtbare `reta`-Befehlszeile besitzt genau vor dem Tabellenkopf eine physische LF-Grenze;
- der PTY-Paritätstest vergleicht die sichtbaren Python- und Mojo-Zeilen bei 80, 120 und 200 Spalten bytegleich;
- der letzte Ende-zu-Ende-Test benötigt den lokal neu gebauten großen Promptcontroller. Dessen monolithische Elaboration überschritt in der Sandbox auch 32 Minuten, während das getrennte Terminalmodul und 3/3 Geometrietests hier vollständig gebaut und ausgeführt wurden.

```bash
./scripts/build.sh
./scripts/test_stage12c.sh
```


## Stage 12c2: portabler nativer Prompt-Eingabekanal

```text
test_native_prompt_input:                 3/3
Pipe-/EOF-Proben:                          2/2
Source-Ownership/Lazy-Python:              2/2
test_terminal_geometry:                    4/4
Boundary-Audit:                            1/1
native POSIX-Prozessprimitive:               0
explizite Laufzeitbrücken:                    2
```

Zusätzlich bestätigt:

- Linux/WSL und macOS verwenden getrennte `TIOCGWINSZ`-Requestwerte;
- andere Ziele fallen ohne Tabellenlogikänderung auf `COLUMNS`/80 zurück;
- stdin-Pipes und umgeleitete Eingabe verwenden Mojos eingebautes `input()`;
- History schreibt nichtleere Zeilen best effort und behält Duplikate;
- `prompt_main.mojo` importiert Python nicht mehr vorsorglich in `main()`;
- ein echtes TTY behält bis zur vollständigen Vi-/Completion-Parität die
  historische Readline-Grenze;
- der große Promptcontroller überschritt erneut das verdoppelte
  Compilerlimit, während alle neuen kleinen Module und Proben gebaut wurden.

```bash
./scripts/check_native_prompt_input.sh
./scripts/build.sh
./scripts/test_stage12c.sh
```


## Stage 12c3: native rohe Promptbefehle

```text
test_prompt_external_commands.mojo:         6/6
test_prompt_raw_commands.mojo:              5/5
Python↔Mojo Kindprozess-/Byteparität:        7/7
Source-Ownership + Boundary-Audit:           4/4
                                              ----
                                             22/22
```

Zusätzlich bestätigt:

- `shell`, `python` und `math` rufen direkt den nativen Mojo-Adapter statt `mojo_bridge.py` auf;
- Unicode, Quotes, leere Argumente, nachgestellte Leerzeichen und mehrere Newlines bleiben erhalten;
- stdout und stderr bewahren auch NUL- und nicht-UTF-8-Bytes;
- das Kind erbt die vollständige Umgebung und läuft wie die Referenz in `python_reference`;
- die öffentlichen Promptlauncher wählen ohne neue Benutzeroption automatisch den Projektinterpreter `.venv/bin/python`;
- ein früher Rohbefehl-Bypass verhindert UTF-8-Bytegrenzenfehler im Kompaktparser;
- die historische interne Set-Reihenfolge der Planungsstufe bleibt unverändert;
- der Boundary-Audit meldet 0 Parallel-Prozessprimitive, 3 Threadmodule, genau 1 expliziten Kindprozessadapter und 2 verbleibende Python-Brücken.

```bash
./scripts/check_prompt_external_commands.sh
./scripts/test_stage12c.sh
```

## Stage 12c4a: FFI-Integration und gekapselte Promptbrücke

```text
prompt_external_commands parser:              6/6
std.python + child-adapter compiler probe:     1/1
Python↔Mojo external-command byte parity:      7/7
Source-/Boundary-Prüfungen:                    8/8
                                               ----
                                               22/22
```

Der vollständige lokale Stage-12c3-Build hatte eine konfliktierende
`dlsym`-Deklaration gefunden. Der Kindprozessadapter verwendet nun den
gekap­selten libc-`system()`-Aufruf und benötigt weder `dlopen`, `dlsym`,
manuellen `environ`-Zugriff, `posix_spawn` noch `waitpid`. Der kombinierte
Compilerprobe importiert die letzte Python-Brücke und den Kindprozessadapter im
gleichen kleinen Ziel und bestand mit dem finalen Quellstand.

Der optimierte monolithische `prompt_main.mojo`-Build erreichte in der
Arbeitsumgebung erneut das 32-Minuten-Elaborationslimit ohne neue Diagnose. Auf
dem Ryzen-7-Zielsystem wird er regulär durch `scripts/build.sh` gebaut.


## Stage 12c4b: direkte Kindprozessgrenze für Restfallback und `reta`

```text
Mojo-Shlex-/Quoting-Unit-Tests:             6/6
neuer reta-Kindprozess-Argumenttest:        1/1
neuer atomarer Promptfallback-Test:         1/1
Source-/Boundary-Gates:                     9/9
```

`prompt_external_commands_probe.mojo` kompiliert mit den beiden neuen Modi.
Die Tests prüfen insbesondere leere Argumente, Apostrophquotierung, Unicode,
typisierte Profilflags und das Arbeitsverzeichnis. `prompt_python_bridge.mojo`
enthält danach nur noch einen Aufruf in `mojo_bridge.py`: den echten
TTY-Readline-/Vi-/Completion-Eingang.

Vier vorhandene externe Byteparitätsfälle (`shell`, `python`, `math` und
nachgestellte Whitespace-Bytes) liefen im aktuellen Arbeitsstand erneut
erfolgreich. Der kombinierte unveränderte `std.python`-FFI-Probe und der
monolithische Promptcontroller wurden wegen der bekannten extrem langen
Sandbox-Elaboration nicht erneut bis zum Ende gebaut; der vollständige Build
erfolgt weiterhin über `scripts/build.sh` auf dem Zielsystem.


## Stage 12c4c: native gemischte Reziprok-Modifier

Die Python-Referenz wird vor dem Tabellenrenderer instrumentiert und liefert für
sieben Fälle den exakten Argumentplan. Hier bestanden **7/7**
Referenzmessungen: reines `teiler 1/n`, reines Reziprok-Vielfaches, deutsche
Langform, kompaktes `v1/n`, Ausschluss von `-1/n` und zwei echte `v n/m`-
Fallbackgrenzen.

Fokussierte Python-Gates:

```text
prompt mixed reciprocal reference:       7/7
prompt external/source boundary pytest:  7/7
Python-Syntax und Shell-Syntax:           bestanden
```

`check_prompt_mixed_reciprocal_parity.sh` regeneriert die sieben exakten
Python-Argumentpläne, baut die native Tabellenplaner-Suite und extrahiert aus
deren Lauf die vollständigen Mojo-Tokenpläne. Der Vergleich deckte dabei auch
die zuvor falsche Schreibweise `--universum` statt `--Universum` auf. Mit Mojo
1.0.0b2 ergab der fokussierte Lauf:

```text
Python↔Mojo-Argumentpläne:           7/7 byteidentisch
Python-Hash-Seeds 0, 1, 42:          byteidentisch
Mojo-Tabellenplaner:                 28/28 bestanden
prompt external/source boundaries:   7/7 bestanden
```

Der vollständige Python-Testlauf zeigte zusätzlich **86 bestandene**,
**1 übersprungene** und **16 fehlgeschlagene** Tests; die Fehlschläge betreffen
bereits vorhandene veraltete Python-Snapshotzahlen oder in diesem Lauf nicht
neu gebaute beziehungsweise wegen fehlender `libKGENCompilerRTShared.so` nicht
startbare ältere Mojo-Probes, nicht den Stage-12c4c-Quellpfad.


## Stage 12c4d: nativer TTY-Editor und klassische Bruch-No-ops

```text
reiner Mojo-Zeileneditor:                     4/4
History-/Plain-Input-Unit-Tests:               4/4
reale PTY-End-to-End-Fälle:                    6/6
Python-Eingabe-/Source-/Boundary-Gates:       12/12
Promptadapter-Mojo-Suiten:                 6/6 + 5/5
Promptadapter-/Boundary-Pytests:              16/16
klassische Python↔Mojo-Bruchpläne:             8/8 byteidentisch
Hash-Seeds 0, 1, 42:                           3/3 identisch
native Tabellenplaner-Suite:                 28/28
```

Der sechste PTY-Fall erzwingt 16 Terminalspalten, editiert über eine physische Wrapgrenze, schließt die erste Eingabe ab und aktiviert im selben Prozess den Rohmodus für eine zweite Eingabe erneut. Damit werden nicht nur Pufferwerte, sondern Terminalwiederherstellung und mehrzeilige Renderzustände geprüft.

Der Boundary-Audit meldet nach Entfernung von `prompt_python_bridge.mojo` genau **eine** aktive `std.python`-Brücke (`compat_main.mojo`), **einen** expliziten Kindprozessadapter und weiterhin **null** verbotene Prozessprimitive in den Parallelmodulen.

Der vollständige `prompt_main.mojo`-Link überschritt in der Sandbox auch unoptimiert 40 Minuten ohne Compilerdiagnose. Die veränderten Editor-, Terminal-, History- und Tabellenmodule sowie ihre ausführbaren PTY-/Paritätsprobes wurden dagegen mit Mojo 1.0.0b2 kompiliert und ausgeführt. Der verbindliche Zielsystemlauf bleibt:

```bash
scripts/build-heavy.sh
scripts/build.sh
```


## Stage 12c4e: native-first historische `reta`-Oberfläche

```text
Kompatibilitätslauncher-Pytests:             8/8
native-first Python↔Mojo-Vertrag:           12/12 byteidentisch
native CLI Ownership-Tests:                 22/22
Kombi-Parität über den Launcher:              9/9
Markup-Parität über den Launcher:             8/8
Basistabellen-Parität über den Launcher:      4/4
aktive std.python-Brücken:                      0
explizite Kindprozessadapter:                    1
verbotene Parallel-Prozessprimitive:             0
```

Der Launcher-Test prüft unveränderte Argumentvektoren mit Leerargumenten,
Unicode und gemischten Quotes, Binärdaten auf stdout/stderr, das
Referenzarbeitsverzeichnis und den echten Kindprozess-Exitstatus. Die leere
Kommandozeile, `--onetable` und `RETA_FORCE_REFERENCE=1` werden als atomare
Fallbackfälle geprüft.

Die zwölf native-first Referenzfälle setzen `RETA_PYTHON` auf einen absichtlich
nicht vorhandenen Pfad. Erfolgreiche physische, englische, Generator-, Modal-,
Primzahlkreuz-, Primzahlwirkungs-, Meta-, Bruch-, Kombi-, BBCode-, HTML- und
Spaltenreihenfolgefälle können daher nicht aus einem unbemerkten Python-Fallback
stammen. stdout und stderr sind jeweils byteidentisch zur Referenz.

`readelf -d` zeigt am neuen `reta-mojo-compat-bin` nur Mojo-Runtime und libc,
aber kein `libpython`. Der strenge Ownership-Test wurde zugleich korrigiert:
`--onetable` gilt nicht mehr fälschlich als nativ unterstützt und fällt bis zu
seiner echten Rendererimplementierung vollständig zurück.

```bash
scripts/check_compat_launcher.sh
RETA_COMPAT_PARITY_GROUP=1 scripts/check_compat_native_first_parity.sh
RETA_COMPAT_PARITY_GROUP=2 scripts/check_compat_native_first_parity.sh
scripts/test_stage12c.sh
```


## Stage 12c4f: native Ausgabe-Stream- und Ein-Tabellen-Semantik

```text
Ausgabe-Stream Python↔Mojo:                 7/7 byteidentisch
nativer CLI-/Ownership-Planer:             24/24
Tabellenrenderer:                           10/10
Kompatibilitäts-/Boundary-Pytests:          19/19
BBCode-Regressionsfixtures nach Wrap-Fix:    3/3
aktive std.python-Brücken:                     0
```

Die sieben Ausgabe-Stream-Fälle setzen `RETA_PYTHON` auf einen nicht vorhandenen
Pfad und beweisen damit native Ausführung für alle vier Ein-Tabellen-Aliase,
`justtext`, deutsche/englische Syntax sowie den Breite-null-No-wrap-Sonderfall.
HTML und BBCode zusammen mit einem Ein-Tabellen-Alias werden vom Ownership-Test
bewusst abgelehnt und vollständig an die Referenz übergeben.

```bash
scripts/check_native_output_stream_parity.sh
```


## Stage 12c4g: native HTML-/BBCode-Ein-Tabellen-Semantik

```text
Markup-oneTable-Fixtures ohne Python:        12/12
Tabellenrenderer:                            11/11
nativer CLI-/Ownership-Planer:              24/24
gezielte Launcher-/Source-/Boundary-Pytests: 11/11
bestehende zentrale Markup-Fixtures:          8/8
aktive std.python-Brücken:                      0
```

Die zwölf neuen Fälle umfassen HTML und BBCode, sämtliche vier historischen
Ein-Tabellen-Aliase, deutsche und englische Syntax sowie Breite null. Jeder
native-first Lauf setzt `RETA_PYTHON` auf einen absichtlich nicht existierenden
Pfad. Die sechs versionierten Ausgabefixtures wurden zuvor mit
`PYTHONHASHSEED=0` direkt gegen die Python-Referenz verifiziert.

Der normale positive-Breitenpfad erzeugt ohne Alias weiterhin mehrere
`<table>`-/`[table]`-Blöcke. Mit `onetable`, `endlessscreen`, `endless` oder
`dontwrap` enthält genau ein Block sämtliche ausgewählten Spalten, während
Zellumbruch, HTML-Klassen, Symbolmetadaten, Zählungsspalten und Zeilenfarben
bytegleich bleiben.

```bash
scripts/check_native_markup_onetable_parity.sh
RETA_REFRESH_MARKUP_ONETABLE_FIXTURES=1 \
  scripts/check_native_markup_onetable_parity.sh
```


## Stage 12c4h: native `keineleereninhalte`-Semantik

```text
No-blank-Rendererkern:                       3/3
HTML-Metadatenkatalog:                       5/5
nativer CLI-/Ownership-Planer:              25/25
No-blank Python↔Mojo-Fixtures:              13/13 byteidentisch
Kompatibilitätslauncher:                    10/10
bestehende Markup-Fixtures:                  8/8
bestehende Markup-oneTable-Fixtures:        12/12
HTML-Heading-Katalog:                        reproduzierbar
```

Die 13 Fixtures prüfen Shell, HTML, BBCode, CSV, Markdown und Emacs jeweils
vor und nach `--keineleereninhalte` sowie `--noblankcontents` in englischem
HTML. `reta-native` besitzt keinen Python-Fallback. Die gesonderte Ownership-
Suite bestätigt, dass der native-first Launcher dieselben Argumentvektoren
konservativ als vollständig Mojo-besessen erkennt. Der Launcher-Test nutzt
einen explizit konfigurierbaren Referenzinterpreter und besteht 10/10; der
No-blank-Fall setzt `RETA_PYTHON` absichtlich auf einen nicht vorhandenen Pfad.

```bash
scripts/check_no_blank_contents.sh
RETA_REFRESH_NO_BLANK_FIXTURES=1 \
  scripts/check_no_blank_contents_parity.sh
```


## Stage 12c4i: paginierte Rendererparität

```text
Tabellenrenderer:                          13/13
paginierte Shell-/HTML-/BBCode-Fixtures:    6/6 byteidentisch
No-blank-Fixtures:                         13/13 byteidentisch
zentrale HTML-/BBCode-Fixtures:             8/8 byteidentisch
Markup-oneTable ohne Python:               12/12
nativer CLI-/Ownership-Planer:             25/25
Kompatibilitätslauncher:                   10/10
nativer I/O-Boundary-Audit:                bestanden
Source-/Boundary-Gates:                     15/15
```

Die sechs neuen Ströme prüfen Deutsch und Englisch jeweils in Shell, HTML und
BBCode mit positiver Breite, horizontaler Seitenteilung und aktiver No-blank-
Semantik. Die Referenzfixtures wurden mit `PYTHONHASHSEED=0` und dem
projektlokalen Referenzinterpreter erzeugt. Der direkte Mojo-Tabellenkern ist in
allen sechs Fällen byteidentisch.

Zwei zuvor getrennt sichtbare Rich-/Textwrap-Abweichungen sind geschlossen:
Vorhandene ASCII-Bindestriche werden vor hartem Überlangwortschnitt genutzt,
und nur wirklich fehlende Shell-Fortsetzungsfragmente erhalten die neutrale
alternierende Restfarbe. `readelf -d` zeigt am Kompatibilitätslauncher weiterhin
nur `libKGENCompilerRTShared.so` und `libc.so.6`, nicht `libpython`.

```bash
scripts/check_paginated_rendering_parity.sh
RETA_REFRESH_PAGINATED_FIXTURES=1 RETA_REFERENCE_PYTHON=/pfad/zur/referenz-python   scripts/check_paginated_rendering_parity.sh
```


## Stage 12c4j: individuelle positive Spaltenbreiten

```text
Spaltenbreiten Python↔Mojo:              12/12 byteidentisch
Tabellenrenderer:                        15/15
nativer CLI-/Ownership-Planer:           26/26
Kompatibilitätslauncher:                 12/12
paginierte Rendererparität:               6/6
No-blank-Parität:                        13/13
zentrale HTML-/BBCode-Fixtures:           8/8
Markup-oneTable ohne Python:             12/12
Source-/Boundary-Gates:                  14/14
nativer I/O-Boundary-Audit:              bestanden
```

Die zwölf neuen Referenzströme prüfen `--breiten`/`--widths` in deutscher und
englischer Shell-, HTML- und BBCode-Ausgabe, mit globaler Nullbreite und mit
Ersetzen einer früheren Breitenliste. Positive Breiten laufen im
native-first-Launcher bei absichtlich ungültigem `RETA_PYTHON`. In Stage
12c4j blieben Nullwerte in der Einzelbreitenliste noch atomarer
Referenzfallback; Stage 12c4k übernimmt diese Fälle. Flache Ausgabearten und
rohes Markup mit `--nocolor` bleiben weiterhin Referenzfallback.

```bash
scripts/check_column_widths_parity.sh
RETA_REFRESH_COLUMN_WIDTH_FIXTURES=1 \
  scripts/check_column_widths_parity.sh
```


## Stage 12c4k: explizite Nullbreiten

```text
Nullbreiten Python↔Mojo:                 12/12 byteidentisch
positive Breiten Python↔Mojo:            12/12 byteidentisch
Tabellenrenderer:                         17/17
nativer CLI-/Ownership-Planer:            26/26
Kompatibilitätslauncher:                  13/13
paginierte Rendererparität:                6/6
No-blank-Parität:                         13/13
Markup-oneTable ohne Python:              12/12
Source-Gates:                             13/13
nativer I/O-Boundary-Audit:               bestanden
```

Die Nullbreitenmatrix prüft für Shell, HTML und BBCode jeweils `0`, `0,8`,
`5,0` und `0,0`. Sie deckt damit sowohl ungebrochene Einzelspalten als auch
die historische Shell-Seitenabbruchsemantik und die getrennte rohe
Markup-Breitenmessung ab. Der native-first-Launcher wird dabei mit einem
absichtlich nicht vorhandenen `RETA_PYTHON` ausgeführt.

```bash
scripts/check_column_zero_widths_parity.sh
RETA_REFRESH_COLUMN_ZERO_WIDTH_FIXTURES=1 \
  scripts/check_column_zero_widths_parity.sh
```


## Stage 12c4l: portable Runtime und rohes HTML/BBCode

```text
Markup --nocolor Python↔Mojo:             12/12 byteidentisch
Tabellenrenderer:                         18/18
nativer CLI-/Ownership-Planer:            26/26
Kompatibilitätslauncher:                  14/14
portable Runtime-Pfadtests:                4/4
positive Breiten Python↔Mojo:             12/12 byteidentisch
explizite Nullbreiten Python↔Mojo:        12/12 byteidentisch
paginierte Rendererparität:                6/6
No-blank-Parität:                         13/13
Markup-oneTable ohne Python:              12/12
```

Die zwölf neuen Markupfälle umfassen Deutsch und Englisch, globale Breite,
positive Einzelbreiten, explizite Nullbreiten, globale Breite null und
`--keineleereninhalte`. HTML bewahrt den mehrzeiligen Rohserializer; BBCode
bewahrt exakte interne und nachgestellte Padding-Leerzeichen.

```bash
scripts/check_markup_nocolor_parity.sh
python3 -m pytest -q tests/test_mojo_runtime_path.py
```


## Stage 12c4m: FHS-Ressourceninstallation

```text
Ressourcenresolver:                         3/3
Installations-/Runtime-Pytests:             8/8
Kompatibilitätslauncher:                   14/14
FHS-Staging nach /usr:                  bestanden
Start aus fremdem Arbeitsverzeichnis:   bestanden
native installierte CSV-Ausgabe:        bytegleich
installierter Python-Fallback:          bytegleich
Deinstallation:                         bestanden
Basistabellenparität:                       4/4
positive Einzelbreiten:                    12/12
explizite Nullbreiten:                     12/12
rohes HTML/BBCode --nocolor:               12/12
```

Die Paketprobe installiert die kanonischen Daten genau einmal nach
`/usr/share/reta/{csv,assets}`. Private Programme und der verbleibende
Referenzbaum liegen unter `/usr/lib/reta`; relative Symlinks erhalten die
historischen Projektpfade. Die gleiche Probe deckt den manuellen Standard
`/usr/local`, eine Benutzerinstallation mit `$HOME/.local`, `DESTDIR`-Staging
und die symmetrische Deinstallation ab.

```bash
./scripts/check_resource_paths.sh
./scripts/check_install_layout.sh
python3 -m pytest -q tests/test_install_layout.py tests/test_mojo_runtime_path.py
```


## Stage 12c4o: flache individuelle Spaltenbreiten

```text
CSV/Markdown/Emacs Python↔Mojo:          13/13 byteidentisch
zusätzliche kombinierte Randfälle:          4/4 byteidentisch
Tabellenrenderer:                        20/20
nativer CLI-/Ownership-Planer:           26/26
Kompatibilitätslauncher:                 14/14
positive Shell/HTML/BBCode-Breiten:      12/12 byteidentisch
explizite Shell/HTML/BBCode-Nullbreiten: 12/12 byteidentisch
rohes HTML/BBCode --nocolor:             12/12 byteidentisch
paginierte Rendererparität:               6/6 byteidentisch
keineleereninhalte:                      13/13 byteidentisch
aktive std.python-Brücken:                0
```

Die dreizehn neuen Ströme prüfen CSV, Markdown und Emacs mit deutscher und
englischer Syntax, positiven Breiten, `0,8` und dem Ersetzen einer früheren
Liste. Die flachen Formate behalten globale Breite null, expandieren aber jede
logische Zeile entsprechend der ausdrücklich angegebenen Datenspaltenbreiten.
CSV bewahrt zusätzlich die historischen Leerfeld- und exakten
Randwhitespacebytes. Auch `--keinenummerierung` behält die zwei leeren
strukturellen CSV-Felder (`;;`) und behandelt die erste Datenspalte nicht als
Nummerierungsspalte; Markdown und Emacs normalisieren sichtbaren Leerraum und
setzen ihre Trenner nach jedem physischen Überschriftenfragment.

```bash
scripts/check_flat_column_widths_parity.sh
```

## Stage 12c4p: sichere Ganzzahlausdrücke und Generatorbereiche

```text
Ganzzahl-Ausdrucksparser:                 5/5
Zeilenbereichsparser:                     8/8
CLI-/Ownership-Planer:                  29/29
Python↔Mojo-Ausdrucksprobe:               2/2
Generatorbereich-End-to-End:              6/6 byteidentisch
Prompt-/Boundary-Gates:                 10/10
flache Einzelbreiten:                   13/13 byteidentisch
positive Shell/HTML/BBCode-Breiten:     12/12 byteidentisch
explizite Nullbreiten:                  12/12 byteidentisch
keineleereninhalte:                     13/13 byteidentisch
Basistabellen CSV/Markdown/Emacs:         4/4 byteidentisch
```

Die sechs neuen Referenzströme umfassen deutsche und englische
Comprehensions, arithmetische Einzelwerte, subtraktive Mengen, negative
`range`-Schritte und generatorbasierte Spaltenreihenfolge. Nicht besessene
Ausdrücke werden vor dem nativen Start zurückgewiesen und atomar über die
Referenzoberfläche ausgeführt.

## Stage 12c4q: native Start-, Sprach- und Hilfeoberfläche

```text
Native Start-/Hilfe-Parität:              7/7 byteidentisch
Startmodul:                               5/5
CLI-/Ownership-Planer:                  30/30
Kompatibilitätslauncher:                18/18 in zwei Gruppen
Hilferessourcen-Generator:                1/1
Installationslayout-Pytests:              5/5
Prompt-/Eingabe-Source-Gates:             9/9
FHS-Installationsprobe:              bestanden
aktive std.python-Brücken:                 0
libpython-Abhängigkeiten:                  0
```

Die sieben vollständigen Streams prüfen den leeren Aufruf, reine deutsche und
englische Sprachwahl, beide Hilfetexte, doppelte Hilfe und die historische
Regel, dass die erste Sprachwahl gewinnt. Zusätzlich ist abgesichert, dass
`-language=english` und reine Hauptparameter nicht mehr irrtümlich die native
Standardtabelle auslösen.

```bash
python3 tools/generate_native_cli_help_assets.py --check
scripts/check_native_cli_startup_parity.sh
scripts/check_install_layout.sh
```

## Stage 12c4r: zentraler Fehlerkatalog und echte Bruchvielfache

```text
Fehlerkatalog-Einträge:                  14/14 konsistent
Python-Bereinigungsrückstand:                 6 Einträge
Fehlerkatalog-Pytests:                    3/3
Python-PY-OPEN-002-Reproduktion:      IndexError bestätigt
Bruch-CSV-Rechtecke:                      4/4
Echte Bruchvielfachen-Verträge:         12/12
Direkte native Tabellenaufrufe:         13/13
Prompt-Tabellenplaner:                   29/29
Klassische Bruchparität:                18/18 byteidentisch
Prompt-Ausführungsfixtures:               7/7 byteidentisch
Stabile gemischte Reziprokpläne:          5/5 byteidentisch
Source-/Runtime-/Installations-Pytests:  20/20
Native I/O-Boundaries:               bestanden
aktive std.python-Brücken:                 0
```

Die zwölf neuen Vertragsfälle prüfen kompakte und ausgeschriebene Syntax, `teiler`, alle vier Bruchdomänen, die jeweiligen oberen Zählergrenzen sowie zwei weiterhin atomare Mischgrenzen. Der Prüfer reproduziert zunächst den unveränderten Python-`IndexError` und validiert danach den korrigierten Mojo-Vertrag.

```bash
python3 tools/check_known_defects.py
python3 -m pytest -q tests/test_known_defects.py
scripts/check_prompt_true_fraction_multiples.sh
```

## Stage 12c4s: rückwirkender Fehleraudit und native Kontroll-Hauptparameter

```text
zentraler Fehlerkatalog:                 35/35 konsistent
spätere Python-/PyPy3-Arbeitspunkte:        12
Katalog-/Reproduktions-Pytests:            8/8
frozen Python baseline:        67 passed, 3 catalogued failures
native Kontrollmodultests:                 5/5
Start-/Hilfe-/Kontrollparität:           15/15 byteidentisch
Kompatibilitätslauncher:                 20/20, jeder Knoten eigener Prozess
Startmodul:                                5/5
CLI-/Ownership-Planer:                   30/30
Generatorbereiche:                         6/6 byteidentisch
flache Spaltenbreiten:                    13/13 byteidentisch
keineleereninhalte:                       13/13 byteidentisch
Source-/Installations-/Runtime-/Defekt-Pytests: 32/32
RUNPATH-Sanitizer:                          2/2
aktive std.python-Brücken:                    0
libpython-Abhängigkeiten:                     0
Quellmanifest:                           1064/1064
```

Der Rückwärtsaudit nahm zwanzig ältere, bislang nur in Migrationsnotizen,
Stage-Berichten oder Testergebnissen beschriebene Befunde in den zentralen
Katalog auf. `scripts/check_documented_python_baseline.py` akzeptiert exakt die
drei bekannten roten Python-Tests und scheitert bei jeder Veränderung der
Fehlermenge.

`-nichts`/`-nothing` wird nun wie im Python-Hauptparameterparser behandelt: Es
ist allein still, wird in einem echten Tabellenvektor aber ignoriert. Der erste
Mojo-Entwurf hatte es fälschlich in `--art=nichts` übersetzt; der neue
End-to-End-Fall bestätigt die erhaltenen 1.877 Tabellenbytes.

Der Kompatibilitäts-Pytest wurde in vier isolierte Prozesse geteilt, weil der
gemeinsame Pytest-Prozesse nach bereits bestandenen Tests im Teardown hängen
konnte. Die fachlich identischen 20 Knoten bestehen gruppiert vollständig.

`tools/sanitize_mojo_runpath.py` entfernt nach jedem Build den von Mojo selbst
ergänzten absoluten Compilerpfad und lässt ausschließlich
`$ORIGIN/../lib/mojo` im ELF-RUNPATH zurück.


## Stage 12c4t: native Wortvervollständigung

```text
native Completion-Unit-Tests:          5/5
Python↔Mojo-Paritätsdatensätze:       10/10 byteidentisch
Python-Unicode-Defektreproduktion:     1/1
zentraler Fehlerkatalog:              37/37 konsistent
spätere Python-/PyPy3-Arbeitspunkte:     13
aktive std.python-Brücken:                0
Quellmanifest:                       1065/1065
regulärer Build:          3 Ziele gebaut; Sandbox-Timeout beim 4. Ziel
```

Die Paritätsprobe deckt Präfix-, Middle-, Ignore-case-, Unicode-, `WORD`- und
Satzmodus ab. Der Unicode-Fall reproduziert ausdrücklich den heutigen
`prompt_toolkit`-Vertrag: Bei `grö` ist das aktuelle Standardwort nur `ö`;
`größe` wird deshalb nicht vorgeschlagen. Dieser Befund ist als
`PY-CAND-007` katalogisiert und nicht als stiller Mojo-Unterschied kaschiert.

```bash
scripts/check_completion_word.sh
python3 -m pytest -q tests/test_documented_python_defects.py tests/test_known_defects.py
```


Hinweis zu Stage 12c4t: `scripts/build.sh` erzeugte in zwei Läufen die ersten
drei regulären Executables ohne Compilerfehler. Die Sandbox brach anschließend
die Kompilation des unveränderten `reta-native` nach 20 beziehungsweise 40
Minuten ab. Der neue Completion-Baustein wurde unabhängig davon vollständig
kompiliert, getestet und gegen Python verglichen.

Die abschließende Entpackprüfung fand und behob zusätzlich `MOJO-FIXED-018`:
verschachtelte `.pytest_cache`-Dateien werden nicht mehr in das Quellmanifest
aufgenommen. Das cachefreie Archiv verifiziert nun alle 1065 Manifesteinträge.


## Stage 12c4u – native verschachtelte Completion

```text
scripts/check_completion_runtime.sh          3/3 bestanden
scripts/check_completion_nested.sh           5/5 bestanden
test_prompt_language.mojo                   16/16 bestanden
scripts/check_prompt_completion_parity.sh   12/12 Kontexte byteidentisch
scripts/check_completion_nested_parity.sh   67/67 Kontexte byteidentisch
  deutsch                                    33/33
  englisch                                   34/34
```

Die erweiterte Matrix enthält Root-, Hauptparameter-, Nebenparameter- und Wertkontexte, Kommafragmente, Nicht-`reta`-Rekursion, deutsche Umlaute und englische Tippfehlernähe. Sie entdeckte und schloss die bytebasierte Unicode-Reihenfolge sowie den falschen englischen Zeilenwert-Kontext des Kataloggenerators. Der regenerierte fünfsprachige Bestand umfasst 25.834 Werte in 561 Sektionen, 200 Dispatch-Aliase, 95 Kurzersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

Produktiver Completion-Build: `prompt_completion_main.mojo` wurde sauber in **8,64 s** kompiliert und mit dem englischen `--primes=p`-Kontext ausgeführt. Die entfernte Doppelimplementierung in `prompt_language.mojo` wird durch dessen **16/16** Tests abgesichert.

Der Nutzer meldet für sein Zielsystem seit 12c4r ungefähr doppelte Buildgeschwindigkeit. Ein separater sauberer Sandbox-Gesamtbuild erzeugte die ersten drei Standardziele fehlerfrei und lief beim unveränderten `reta-native` in das 60-Minuten-Umgebungslimit; es trat keine Compilerdiagnose auf.

Source-only-Katalogcheck: `check_prompt_language_catalog.sh` regeneriert den fünfsprachigen Bestand nun ohne Projekt-`.venv`; `TEST-FIXED-003` ist geschlossen.


## Stage 12c4v – native Prompt-Sitzung und Prompt-Runtime

```text
Prompt-Runtime-Bestandstests:          30/30 bestanden
Prompt-Sitzungs-Unit-Tests:            10/10 bestanden
Prompt-Runtime-Vertragstests:           5/5 bestanden
Native-Prompt-Input-Tests:              4/4 bestanden
Sitzungsparität Deutsch:               18/18 byteidentisch
Sitzungsparität Englisch:              18/18 byteidentisch
Runtimevertrag Deutsch:                 1/1 byteidentisch
Runtimevertrag Englisch:                1/1 byteidentisch
Runtimevertrag Vietnamesisch:           1/1 byteidentisch
Runtimevertrag Chinesisch:              1/1 byteidentisch
Runtimevertrag Koreanisch:              1/1 byteidentisch
Runtime-Katalogregeneration:        reproduzierbar
Englischer PTY-Speicherpräfix:           1/1 exakt
Source-/Ownership-/Manifest-Pytests:   33/33 im gebauten Baum
entpackte reine Source-Gates:             28/28 bestanden
FHS-Installations-Pytests:                  5/5 im gebauten Baum
zentraler Fehlerkatalog:               42/42 konsistent
spätere Python-/PyPy3-Arbeitspunkte:      13
aktive std.python-Brücken:                 0
Quellmanifest:                           1092/1092
```

Die 36 Sitzungsfälle prüfen Textzustand, wiederholte Leerzeichen,
Klammergruppen, UTF-8, Positions-, Bereichs- und Wertlöschung, die mehrdeutige
dezimale Löschangabe, Speicherausgaben, History-Umschalter und kombinierte
Befehle. Der fünfsprachige Runtimevergleich umfasst Programm- und
Vokabulargrößen, Hauptparameterindizes, Kombinationsabbildungen,
`wahl15`-Validierung sowie die exakten normalen, Speicher- und Löschpräfixe.

```bash
scripts/check_prompt_session_parity.sh
scripts/check_prompt_runtime_catalog.sh
scripts/check_prompt_runtime_parity.sh
scripts/check_prompt_session_pty_prefix.py target/bin/reta-prompt-native
python3 tools/check_known_defects.py
```

Die fokussierten Mojo-Ziele wurden kompiliert und ausgeführt. Der vollständige
produktive `prompt_main`-Controller wurde in **11,98 Sekunden** gebaut. Der
englische native Einmalbefehl `prime 12` liefert anschließend `12: 2^2 3`.
`scripts/build.sh` erzeugte danach alle **9/9** regulären Standardziele
inklusive `reta-native` in **2:24,55 Minuten**. Buildlayout,
FHS-Testinstallation und RUNPATH-Prüfung bestanden. Damit bestätigt nun auch
der vollständige Sandboxbuild die seit Stage 12c4r auf dem Zielrechner
beobachtete deutliche Beschleunigung. Das separat entpackte Source-only-Archiv
bestand **28/28** Tests ohne Binärvoraussetzung; die fünf Installations-Pytests
wurden korrekt nur im gebauten Baum ausgeführt.
