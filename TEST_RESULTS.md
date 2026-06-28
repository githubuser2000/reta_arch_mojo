# Testergebnisse – Stufe-9-Zwischenstand

## Testbestand

```text
43 Mojo-Testdateien
170 Testfunktionen insgesamt
8 reguläre ELF-Compilerziele
2 optionale schwere Katalogtestdateien
```

Der letzte vollständig abgeschlossene normale Stufe-7-Lauf ergab **145/145** Tests. Seitdem wurden 20 Tests für Meta-, Bruch-, Kombi- und Markup-Pfade ergänzt. Ein erneuter monolithischer Kaltlauf stößt in dieser Umgebung bei `test_csv_reference` und weiteren großen Asset-Compilern an das äußere Ausführungslimit. Deshalb wurden die direkt geänderten Programme einzeln gebaut und ausgeführt.

## Aktuell erneut ausgeführte Mojo-Tests

```text
test_table_rendering             3/3
test_html_cell_metadata          4/4
test_meta_columns                3/3
test_fraction_concat_columns     3/3
test_kombi_join_columns          4/4
test_generated_aliases           6/6
test_native_reta_cli             7/7
                               -------
                                30/30 bestanden
```

Es gab keinen Testfehler. Sammelläufe wurden ausschließlich durch die Laufzeitgrenze während eines nachfolgenden Compiler- oder Referenzprozesses beendet.

## Stufe 7: Generator- und Metaspalten

```bash
./scripts/test_stage7.sh
./scripts/check_generated_column_parity.sh
```

Die CLI-Suite enthält **30** reale deutsche und englische Generatorfälle. Abgedeckt sind Klassifikatoren, Modallogik, Primzahlkreuz, Primzahlwirkung, Primuniversum, `PrimCSV`, zwölf Metaachsen, vier Bruch-Prägarben sowie Markdown/Emacs.

Wichtig: Der frühere englische Testname `--universe_meta_concrete` war im Python-Original kein wirksamer Alias und verglich zwei leere Ausgaben. Er wurde durch den realen Alias `--universeMetaConcrete` ersetzt; dessen nichtleere Ausgabe ist bytegleich.

## Stufe 8: Kombinationspfad

```bash
./scripts/test_stage8.sh
./scripts/check_kombi_parity.sh
```

Die Kombi-Suite enthält **9** reale CLI-Fälle für:

- Galaxie und Universum
- Deutsch und Englisch
- Einzel- und Mehrfachauswahl
- Negativauswahl
- gemischte Galaxie-/Universum-Abfragen
- historische leere Segmente und Relationsreihenfolge

Die Laufzeitassets sind reproduzierbar:

```text
4.095 Meta-Anfrageordnungen
173 Kombi-Aliase
151 Kombi-Relationsordnungen
9.593 wirksame Generatoraliase
71.820 geordnete Bruchrelationen
```

## Stufe 9: BBCode und HTML

```bash
./scripts/test_stage9.sh
./scripts/check_markup_parity.sh
RETA_MARKUP_EXTENDED=1 ./scripts/check_markup_parity.sh
```

Die schnelle Release-Suite vergleicht **8** zentrale Ausgaben gegen geprüfte Python-Byte-Fixtures. Insgesamt wurden **16** Fälle einzeln direkt mit `PYTHONHASHSEED=0` gegen die Python-Referenz validiert:

- BBCode Breite 0 und 40
- Deutsch und Englisch
- ohne Nummerierung und ohne Überschriften
- HTML Breite 0 und 40
- physische deutsche und englische Spalten
- Primzahlwirkung
- Meta-Spalten mit echten `<ul>/<li>`-Listen
- gebrochenes Universum mit echten `<br>`-Tags

Die Trennung in schnelle Fixtures und expliziten Refresh ist notwendig, weil wiederholte Kaltstarts der Python-Referenz in einem einzigen Sammellauf sporadisch sehr lange dauern.

```bash
RETA_REFRESH_MARKUP_FIXTURES=1 ./scripts/check_markup_parity_extended.sh
```

## Buildprüfung

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Alle acht regulären ELF-64-Ziele wurden gebaut. Der Sammelbuild erreichte wegen des äußeren Zeitlimits fünf Ziele; die verbleibenden drei sowie das unterbrochene Kompatibilitätsziel wurden anschließend einzeln erfolgreich gebaut. `bin/` enthält nur versionierbare Launcher, `target/bin/` nur ignorierte Compilerprodukte.

## Referenzbaseline

Die unveränderte Python-Referenz hatte beim Eingang bereits drei fehlschlagende und einen übersprungenen Test. Diese Baseline-Abweichungen wurden nicht dem Mojo-Port zugerechnet und nicht verdeckt geändert.
