# reta.arch → Mojo

Dies ist ein inkrementeller, getesteter Port des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2. Das Original umfasst 92 Python-Dateien und 48.831 Zeilen. Wegen der stark dynamischen Architektur werden zusammenhängende Laufzeitpfade typisiert übertragen; die Python-Referenz bleibt sichtbar, bis der jeweilige Pfad vollständig ersetzt ist.

## Fortschritt

```text
Release-Stufen:                    6 von 12 = 50,0 %
vollständig native Originaldateien: 16 von 92 = 17,4 %
mindestens teilweise portiert:      34 von 92 = 37,0 %
gewichteter Quellzeilenstand:        ca. 15,1 %
funktionaler Nutzerumfang:           ca. 40–45 %
```

Die Metriken messen Verschiedenes. Die Stufenquote ist höher, weil die noch offenen Stufen die größten dynamischen Python-Module bündeln. Der vollständige Plan steht in [`ROADMAP.md`](ROADMAP.md).

## Installation mit Python 3.14

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Das Skript erzeugt `.venv`, installiert den Modular-Mojo-Compiler und baut acht reguläre ELF-Programme nach `target/bin/`. Eine Aktivierung mit `source` ist nicht nötig.

```bash
./scripts/check_build_layout.sh
```

`bin/` enthält nur versionierte Shell-Launcher. `.venv/`, `target/`, `build/` und Laufzeitartefakte stehen in `.gitignore`. Die sehr großen generierten Schema- und Architekturkataloge werden optional gebaut:

```bash
./scripts/build-heavy.sh
```

Details: [`BUILD.md`](BUILD.md).

## Stufe 6: erster echter nativer Tabellenpfad

### Native normale Reta-Syntax

```bash
./reta-native \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Oder über den historischen Namen:

```bash
RETA_NATIVE=1 ./reta \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=markdown --breite=40
```

Ohne `RETA_NATIVE=1` bleibt `./reta` auf der vollständigen Kompatibilitätsoberfläche. Das verhindert, dass noch nicht portierte Optionen stillschweigend anders behandelt werden.

Auch die tatsächlichen englischen Namen werden unterstützt:

```bash
./reta-native \
  -language=english \
  -lines --thisrangebefore=1-3 \
  -columns --religions=starpolygon \
  -output --type=csv --width=40
```

### CSV-Kern

Nativ sind:

- Semikolon-CSV
- UTF-8
- Quotes und eingebettete Zeilenumbrüche
- schneller Pfad für die großen einfachen Tabellen
- Zeilen- und Spaltenprojektion
- kompletter Referenzbestand mit 16 CSV-Dateien

```bash
./bin/reta-mojo --mojo-csv-info
```

```text
Zeilen: 1025
Spalten: 746
Zellen: 764650
```

### Zeilenfilter

Vollständig nativ umgesetzt wurden:

- absolute und relative Bereiche
- positive und negative Werte
- Teilererweiterung
- Vergangenheit, Gegenwart und Zukunft
- Zählungsgruppen
- innere und äußere Primzahlklassen
- Mond, Sonne, schwarze Sonne und Planet
- Primvielfache und gewöhnliche Vielfache
- Potenzen
- Invertierung
- nachträgliche Positionsfilter

### Erste Generatorspalten

Deutsch und Englisch sind für vier Familien nativ:

- Gleichheit/Freiheit/Dominieren
- Geist/Emotion/Energie/Materie/Topologie
- Prim-Kreativität
- Gestirnklassifikation

Die restlichen Generator- und Metaspalten bilden Stufe 7.

### Ausgabe

Für den portierten Tabellenpfad sind CSV, Markdown und Emacs bei den geprüften realen Befehlen bytegleich zur projektlokalen Python-Referenz. HTML und BBCode besitzen bereits native Grundstrukturen, aber noch nicht sämtliche dynamischen Klassen und Wrappingregeln.

## Weitere native Bereiche

- Zahlentheorie, Primzahlkreuz und Arithmetik
- Zeilenbereichssprache
- Parameterschema, Aliase und Spalten-Buckets
- Promptcontroller: `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt`
- `prim`, `prim24`, `multis`, `multis3`, `modulo`
- Tabellen-Tag-Schema
- Tabellenzustand und Unicode-Wrapping
- Topologie, Prägarbenanteile, Morphismen und universelle Bucket-Normalisierung
- Grundstrukturen-HTML
- `generate_html`-Orchestrierung
- generierter Kategorien-/Funktorenkatalog

## Öffentliche Programme

```bash
./reta
./reta-native
./retaPrompt
./rp
./rpb prim 60
./multis3 36
./grundStrukHtml.py blank
./generate_html > religionen-tabelle.html
```

Siehe [`BINARIES.md`](BINARIES.md).

## Tests

```bash
./scripts/test_stage6.sh
./scripts/check_native_table_parity.sh
./scripts/check_runtime_alias_catalog.sh
./scripts/check_schema_catalog.sh
./scripts/check_category_catalog.sh
```

Gesamtbestand:

```text
32 native Testdateien
127 native Testfunktionen
122 im aktuellen Stufe-6-Lauf erneut ausgeführt und bestanden
5 unveränderte schwere Katalogtests zuletzt in Stufe 5 bestanden;
  ihre Generatoren wurden in Stufe 6 bytegleich reproduziert
```

Weitere bestehende Prüfungen:

```bash
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
```

Details: [`TEST_RESULTS.md`](TEST_RESULTS.md).

## Nächste Stufe

Stufe 7 portiert den Rest von `generated_columns.py` und `meta_columns.py`, damit wesentlich mehr Spalten ohne Python-Algorithmus entstehen. Danach folgen Kombinations-Joins und gebrochen-rationale CSV-Verkettungen.

## Dokumentation

- [`ROADMAP.md`](ROADMAP.md) – zwölf Stufen und Prozentmetriken
- [`STATUS.md`](STATUS.md) – aktueller Stand
- [`BUILD.md`](BUILD.md) – Compilerprodukte und `.gitignore`
- [`BINARIES.md`](BINARIES.md) – öffentliche Namen und Ziele
- [`TEST_RESULTS.md`](TEST_RESULTS.md) – Testnachweise
- [`PORTING_MATRIX.md`](PORTING_MATRIX.md) – Status jeder Python-Datei
- [`MIGRATION_NOTES.md`](MIGRATION_NOTES.md) – semantische Entscheidungen
