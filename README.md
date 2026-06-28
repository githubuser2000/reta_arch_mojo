# reta.arch → Mojo

Dies ist ein **inkrementeller, testbarer Port** des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2. Das Original umfasst rund 49.000 Python-Zeilen und verwendet stark dynamische Semantik. Deshalb werden zusammenhängende Laufzeitpfade typisiert übertragen, statt Python nur syntaktisch umzuschreiben.

## Installation mit Python 3.14

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Das Skript:

1. legt `.venv` an,
2. installiert den Modular-Mojo-Compiler,
3. kompiliert acht native Programme nach `target/bin/`.

Eine Aktivierung mit `source` ist nicht nötig. Nur den Build überspringen:

```bash
RETA_SKIP_BUILD=1 ./scripts/setup_mojo.sh
```

Der gleichnamige Snap `/snap/mojo/...` gehört zum Juju-Ökosystem und ist nicht der Modular-Compiler. `bin/mojo-real` erkennt diesen Konflikt.

## Executables und Git

Ja: Mojo-Programme werden kompiliert. Das Projekt trennt jetzt strikt:

```text
bin/          versionierte Shell-Launcher
target/bin/   kompilierte ELF-Executables
```

`target/`, `build/` und `.venv/` stehen in `.gitignore`. Der Quellbaum enthält keine maschinenspezifischen Compilerprodukte. `setup_mojo.sh` baut sie lokal auf dem Zielrechner.

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
./scripts/clean.sh
```

Details: [`BUILD.md`](BUILD.md).

## Öffentliche Programme

```bash
./reta
./retaPrompt
./rp
./rpl
./rpb prim 60
./rpe reta -h
./prim 60
./prim24 29
./multis 12
./multis3 36
./modulo 5
./grundStrukHtml.py blank
./generate_html > religionen-tabelle.html
```

Die historischen Namen existieren auch unter `bin/` und `run/`. Details: [`BINARIES.md`](BINARIES.md).

## Neu in Stufe 5

### Tabellen-Tag-Schema

Nativ und generiert sind nun:

- sieben Tagarten,
- 19 Primärgruppen,
- 478 Primär-Rückabbildungen,
- 483 Primärverknüpfungen,
- beide Kombinations-Tag-Schemata,
- Abbildung Spalte → Tags,
- Abbildung exakte Tagmenge → Spalten.

Beispiele:

```bash
./bin/reta-mojo --mojo-tags 216
./bin/reta-mojo --mojo-tag-columns sternPolygon,universum
```

### Tabellenzustand, Umbruch und Ausgabe

Portiert sind:

- typisierter Tabellenzustand,
- Standard- und explizite höchste Zeilen,
- Unicode-sicheres hartes Wrapping,
- Zeilen- und Tabellenbreitenlogik,
- Anwendung aller sieben Ausgabe-Modi,
- reine Teile von `console_io.py` und `runtime_compat.py`,
- Identitäts-Fallbacks aus `bbcode.py` und `html2text.py`.

```bash
./bin/reta-mojo --mojo-table-state 42
./bin/reta-mojo --mojo-wrap 2 'äöü漢字'
```

### `multis3`

Die historische Dreifach-Faktorisierung läuft nun nativ:

```bash
./multis3 36
```

Ausgabe:

```text
36: [(2, 2, 9), (2, 3, 6), (3, 3, 4)]
```

Die Python-Version gab ein `set` aus und exponierte dadurch eine nicht garantierte Reihenfolge. Mojo liefert dieselbe mathematische Menge bewusst lexikographisch sortiert.

## Bereits native Kernbereiche

| Bereich | Mojo-Module |
|---|---|
| Zahlentheorie und Arithmetik | `number_theory.mojo`, `arithmetic.mojo` |
| Zeilenbereichssprache | `row_ranges.mojo` |
| Parameter- und Eingabesemantik | `schema*.mojo`, `parameter_semantics.mojo`, `input_semantics.mojo` |
| Prompt | `prompt_runtime.mojo`, `prompt_catalog.mojo`, `prompt_main.mojo` |
| Tabellenzustand und Umbruch | `table_state.mojo`, `table_wrapping.mojo` |
| Tabellen-Tags | `tag_schema.mojo`, `tag_schema_catalog.mojo` |
| Ausgabe | `output_modes.mojo`, `console_io.mojo` |
| Topologie, Prägarben, Morphismen | `topology.mojo`, `presheaves.mojo`, `morphisms.mojo` |
| Universelle Bucket-Normalisierung | `universal.mojo`, `column_selection.mojo` |
| Kategoriekatalog | `category_theory.mojo` |
| Grundstrukturen-HTML | `grundstrukturen_html.mojo`, `grundstrukturen_catalog.mojo` |
| HTML-Orchestrierung | `generate_html_main.mojo` |

## Promptcontroller

`retaPrompt`, `rp`, `rpl`, `rpb` und `rpe` teilen denselben nativen Mojo-Controller. Nativ sind Profile, Startargumente, interaktive Schleife, Sitzungszustand, Befehlsspeicher, Completion-Katalog und die Befehle:

```text
prim prim24 multis multis3 modulo abc
```

Noch nicht portierte komplexe Kurzbefehle überschreiten nur für den jeweiligen Befehl die Python-Grenze. Der Promptprozess selbst bleibt Mojo.

## HTML

`grundStrukHtml.py` ist vollständig als Mojo-Renderer umgesetzt und für Deutsch/Englisch bytegleich geprüft. `generate_html` orchestriert das Gesamtdokument nativ. Die große Berechnung des Tabellenmittelteils `middle.alx` bleibt derzeit hinter der expliziten Kompatibilitätsgrenze.

## Tests

```bash
./scripts/test_all.sh
./scripts/test_prompt_bins.sh
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/check_prompt_catalog.sh
./scripts/check_grundstrukturen_catalog.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
```

Aktueller Stand:

```text
7.243 Mojo-Zeilen unter src/
6.451 Mojo-Zeilen im Paket reta_mojo
24 native Testdateien
111 native Testfälle
111 bestanden
8 kompilierte ELF-Executables
```

## Noch nicht vollständig nativ

Die große Tabellen-/CSV-Pipeline, Generatorspalten, Kombinations-Joins, alle komplexen historischen Kurzbefehle, Wörterbuch-Silbentrennung sowie dynamische Validierungs-/Persistenznetze sind noch nicht vollständig portiert. Diese Bereiche bleiben sichtbar hinter der Python-Referenz und werden nicht als fertig ausgegeben.

## Dokumentation

- [`BUILD.md`](BUILD.md) – Compilerprodukte, `.gitignore`, Build und Installation
- [`BINARIES.md`](BINARIES.md) – öffentliche Namen und Zielprogramme
- [`STATUS.md`](STATUS.md) – aktueller Portierungsstand
- [`TEST_RESULTS.md`](TEST_RESULTS.md) – Testnachweise
- [`PORTING_MATRIX.md`](PORTING_MATRIX.md) – Status jeder Python-Datei
- [`MIGRATION_NOTES.md`](MIGRATION_NOTES.md) – semantische Entscheidungen
