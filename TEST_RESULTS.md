# Testergebnisse – Stufe 6

## Native Testmenge

```text
32 Testdateien
127 Testfunktionen insgesamt
122 Testfunktionen im aktuellen Stufe-6-Lauf erneut ausgeführt
122 bestanden
0 fehlgeschlagen
0 übersprungen
```

Die fünf nicht erneut kalt kompilierten Funktionen liegen in den unveränderten, sehr großen Katalogtests `test_category_theory.mojo` und `test_schema_catalog_parity.mojo`. Beide bestanden in Stufe 5. In Stufe 6 wurden ihre Generatoren erneut ausgeführt und die generierten Mojo-Dateien bytegleich bestätigt:

```bash
./scripts/check_category_catalog.sh
./scripts/check_schema_catalog.sh
```

## Neue Stufe-6-Prüfungen

- 36 automatisch aus Python erzeugte Zeilenfiltervektoren
- 16 vollständige Original-CSV-Dateien
- `religion.csv`: 1.025 Zeilen, 746 Spalten, 764.650 Zellen
- vier Generatorfamilien für 0–512 in Deutsch und Englisch
- positive und negative Zeilenselektion
- Tabellenprojektion und Headerbehandlung
- deutsche CSV-, Markdown- und Emacs-Ausgabe bytegleich
- englische CSV-Ausgabe bytegleich
- `RETA_NATIVE=1`-Umschaltung bytegleich
- deutscher/englischer Laufzeit-Aliaskatalog reproduzierbar

```bash
./scripts/test_stage6.sh
./scripts/check_runtime_alias_catalog.sh
./scripts/check_native_table_parity.sh
```

## Buildprüfung

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Der normale Build erzeugt acht ELF-64-Programme. Die compilerintensiven, generierten Katalogziele sind absichtlich getrennt:

```bash
./scripts/build-heavy.sh
RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh
```

## Bestehende Integrationsprüfungen

```bash
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/check_prompt_catalog.sh
./scripts/check_grundstrukturen_catalog.sh
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
```

## Referenzbaseline

Die unveränderte Python-Referenz hatte beim Eingang bereits drei fehlschlagende und einen übersprungenen Test. Diese Baseline-Abweichungen wurden nicht dem Mojo-Port zugerechnet und nicht verdeckt geändert.
