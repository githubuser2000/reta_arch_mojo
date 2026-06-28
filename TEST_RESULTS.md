# Testergebnisse – Stufe-7-Zwischenstand

## Native Testmenge

```text
39 Mojo-Test-/Konstantendateien
150 Testfunktionen insgesamt
145 Testfunktionen im normalen vollständigen Lauf
145 bestanden
0 fehlgeschlagen
0 übersprungen
2 optionale schwere Compilerdateien mit zusammen 5 Testfunktionen nicht kalt gebaut
```

Der vollständige normale Lauf war:

```bash
./scripts/test_all.sh
```

Die optionalen Dateien `test_category_theory.mojo` und `test_schema_catalog_parity.mojo` werden mit `RETA_TEST_HEAVY=1` zugeschaltet. Ihre generierten Kataloge werden unabhängig davon reproduzierbar geprüft:

```bash
./scripts/check_category_catalog.sh
./scripts/check_schema_catalog.sh
```

## Gezielte Stufe-7-Tests

Die erweiterte Stufe-7-Suite enthält 28 Unit-/Integrationstests für:

- skalare Generatorfamilien
- Nichtstandard-Aliasauflösung und Last-write-wins
- Modallogik und Tabellenmutationsreihenfolge
- Primzahlwirkung
- ganzzahlige Primuniversum-Spalten
- gebrochen-rationale Primuniversum-Spalten
- historische Bruchpaarreihenfolge
- `PrimCSV`/`beschrieben`
- Tabellenrenderer und nativen CLI-Plan

```bash
./scripts/test_stage7.sh
```

Die sieben direkt betroffenen Testprogramme wurden im aktuellen Lauf einzeln kompiliert und ergaben **28/28 bestanden**.

## Reale CLI-Byteparität

```bash
./scripts/check_generated_column_parity.sh
```

Ergebnis: **22/22 reale Befehlsfälle bytegleich** zur projektlokalen Python-Referenz mit `PYTHONHASHSEED=0`.

Geprüft werden unter anderem:

- Gestirn, Gleichheit/Freiheit, Geist/Energie und Primvielfache
- Deutsch und Englisch
- Modallogik Liebe/Love
- Primzahlkreuz Pro/Contra
- einzelne und alle sieben Primzahlwirkungsquellen
- einzelne und alle vier ganzzahligen Primuniversum-Familien
- einzelne englische und alle vier deutschen gebrochen-rationalen Primuniversum-Familien
- `PrimCSV`/`beschrieben` in Deutsch und Englisch
- Markdown- und Emacs-Baseline

Die größten Einzelvergleiche umfassten 110.816 Byte für eine gebrochen-rationale Familie und 161.222 Byte für alle vier Familien gemeinsam.

## Reproduzierbare Laufzeitassets

```bash
PYTHONHASHSEED=0 python3 scripts/generate_fraction_pair_catalog.py
python3 scripts/generate_generated_aliases.py
```

Aktueller Bestand:

```text
9.593 wirksame deutsch/englische Nichtstandard-Aliase
71.820 geordnete Bruchrelationen
```

Der Hash-Seed ist beim Bruchkatalog Teil der Referenzdefinition, weil das Python-Original sichtbare Set-Iterationsreihenfolgen verwendet.

## Buildprüfung

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Ergebnis: acht reguläre ELF-64-Programme erfolgreich gebaut; `bin/` enthält ausschließlich versionierbare Shell-Launcher, `target/bin/` ausschließlich ignorierte Compilerprodukte.

Die compilerintensiven generierten Katalogziele bleiben getrennt:

```bash
./scripts/build-heavy.sh
RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh
```

## Weitere bestehende Integrationsprüfungen

```bash
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/check_prompt_catalog.sh
./scripts/check_grundstrukturen_catalog.sh
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
./scripts/check_native_table_parity.sh
./scripts/check_runtime_alias_catalog.sh
```

## Referenzbaseline

Die unveränderte Python-Referenz hatte beim Eingang bereits drei fehlschlagende und einen übersprungenen Test. Diese Baseline-Abweichungen wurden nicht dem Mojo-Port zugerechnet und nicht verdeckt geändert.
