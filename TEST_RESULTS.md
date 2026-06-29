# Testergebnisse – Stufe-9/10-Zwischenstand

## Testbestand

```text
50 Mojo-Testdateien
198 Testfunktionen insgesamt
9 reguläre ELF-Compilerziele
2 optionale schwere Katalogtestdateien
```

Der letzte vollständig abgeschlossene normale Stufe-7-Lauf ergab **145/145** Tests. Seitdem kamen Meta-, Bruch-, Kombi-, Markup- und Prompttests hinzu. Ein monolithischer Kaltlauf stößt in dieser Umgebung bei `test_csv_reference`, großen Asset-Compilern und wiederholten Python-Referenzstarts an das äußere Ausführungslimit. Deshalb werden die veränderten Programme zusätzlich einzeln gebaut und ausgeführt.

## Aktuell erneut ausgeführte Mojo-Tests

```text
test_prompt_language             15/15
test_prompt_runtime              21/21
test_prompt_fraction_execution    8/8
test_meta_columns                 3/3
test_fraction_concat_columns      3/3
test_kombi_join_columns           4/4
test_generated_aliases            6/6
test_native_reta_cli              9/9
test_generated_table_columns      7/7
test_table_rendering              3/3
test_html_cell_metadata           4/4
                                -------
                                 83/83 bestanden
```

Es gab keinen Testfehler. Abgebrochene Sammelläufe endeten ausschließlich während eines nachfolgenden Compiler- oder Referenzprozesses durch die äußere Laufzeitgrenze.

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
15/15 Prompt-Sprachtests bestanden
18/18 Prompt-Laufzeittests bestanden
```

Zusätzlich ist die vordere fachliche Ausführung jetzt geprüft:

```text
18/18 Bruch-/Bereichsausdrücke bytegleich zu bruchSpalt/createRangesForBruchLists
7/7 reale Prompt-Ausführungen als Byte-Fixtures
2/2 Tabellenbefehle (mond, richtung) über reta-native statt retaPrompt.py
```

Die sieben Ausführungsfixtures umfassen Primfaktorenvergleich, einfache und primfaktorisierte Abstände, bidirektionale Bereichsabstände sowie ANSI-Tabellenausgaben. Der vollständige native CLI-Plantest benötigt kalt rund 51 Minuten und bestand mit **9/9** Tests.

Ein Pseudoterminaltest bestätigte die tatsächliche interaktive Ergänzung:

```text
reta -ausgabe --art=htm<Tab>  →  reta -ausgabe --art=html
```

Der fünfsprachige Katalog wird in ein temporäres Verzeichnis regeneriert und byteweise gegen die eingecheckten Assets verglichen. Abgedeckt sind 28.990 Completion-Werte in 549 Sektionen, 200 Dispatch-Aliase, 95 Kurzersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

Der kombinierte `test_stage10.sh`-Kaltlauf wurde einmal nach den bereits bestandenen Sprach-, Laufzeit-, Katalog-, Kurzsprachen- und Fixtureprüfungen vom äußeren Limit beendet. Die noch ausstehende Workerprüfung und die später ergänzten Vorbereitungstests wurden anschließend separat vollständig bestanden. Deshalb wird kein unvollständiger Sammellauf als Gesamterfolg ausgegeben; die obigen Zahlen stammen aus den jeweils abgeschlossenen Einzelprüfungen.

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
