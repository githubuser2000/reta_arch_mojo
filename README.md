# reta.arch → Mojo

Dies ist ein **arbeitsfähiger inkrementeller Port** des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2. Das Original umfasst ungefähr 49.000 Python-Zeilen und nutzt stark dynamische Python-Semantik. Der Port überträgt deshalb zusammenhängende Laufzeitpfade typisiert und testbar, statt Python-Syntax mechanisch umzuschreiben.

## Architektur des Übergangs

1. **Nativer Mojo-Kern** für bereits portierte Algorithmen, Parametersemantik und Promptsteuerung.
2. **Explizite Betriebssystem-/Kompatibilitätsgrenze** für noch nicht portierte Tabellenpfade, Terminaldienste und historische Kurzbefehle.
3. **Unveränderte Python-Referenz** zur Paritätsprüfung und als vorübergehender Fallback.

Der native Quellbaum umfasst **5.327 Mojo-Zeilen**, davon **4.769 Zeilen im Paket `reta_mojo`**.

## Neu: historische Startprogramme

Die wichtigsten alten Startnamen fehlen nicht mehr:

```bash
./reta
./retaPrompt
./retaPrompt.english
./rp
./rpl
./rpb prim 60
./rpe reta -h
./prim 60
./prim24 29
./multis 12
./modulo 5
./math '2**20'
```

Dieselben Namen existieren zusätzlich unter `bin/` und `run/`. Die Aliasnamen `reta.sh`, `rp.sh` und `rpl.sh` sind ebenfalls vorhanden. Einzelheiten stehen in [`BINARIES.md`](BINARIES.md).

## Nativer Mojo-Prompt

`retaPrompt`, `rp`, `rpl`, `rpb` und `rpe` verwenden jetzt einen gemeinsamen Mojo-Controller in:

- `src/prompt_main.mojo`
- `src/reta_mojo/prompt_runtime.mojo`
- `src/reta_mojo/prompt_catalog.mojo`

Nativ sind Profile, Startargumente, Schleife, Sitzung, Dispatch, Loggingzustand, Befehlsspeicher, Completion-Katalog und die Befehle `prim`, `prim24`, `multis`, `modulo` und `abc`. Der Katalog enthält 388 aus der Referenz erzeugte Promptwörter.

Beispiele:

```bash
./rp
./retaPrompt -befehl multis 12
./rpb prim '1-20'
printf 'prim 29\nq\n' | ./rp
```

Noch nicht portierte komplexe Kurzbefehle werden pro Befehl in einem isolierten Python-Prozess ausgeführt. Der Promptprozess selbst, sein Zustand und die weitere Sitzung bleiben Mojo. GNU-readline, Historydatei und Kindprozesserzeugung bilden eine ausdrücklich markierte Betriebssystemgrenze.

## Weitere native Bereiche

| Bereich | Mojo-Modul | Stand |
|---|---|---|
| Zahlentheorie | `number_theory.mojo` | Primfaktoren, Teiler, Wiederholungen, Prime Creativity, Primzahlkreuz, Mondzahlen |
| Zeilenbereiche | `row_ranges.mojo` | Parser und Expansion einschließlich Ausschlüssen, Mengen, Vielfachen und Offsets |
| Arithmetik | `arithmetic.mojo` | Faktorpaare, Modulo-Tabelle, Teilerbereiche und Hilfsalgorithmen |
| Kategorientheorie | `category_theory.mojo` | 26 Kategorien, 77 Funktoren, 42 natürliche Transformationen, 8 Paradigmenbegriffe |
| Topologie | `topology.mojo` | typisierte Kontextdimensionen, Aliasauflösung, offene Auswahlen, Verfeinerung |
| Ausgabe-Modi | `output_modes.mojo` | Modussemantik, Renderer-Konstanten, HTML-/BBCode-Zeilenfarben |
| Prägarben | `presheaves.mojo` | typisierte Lokalsektionen und Restriktion |
| Universelle Konstruktion | `universal.mojo` | Normalisierung positiver/negativer Spalten-Buckets |
| Kontextschema | `schema.mojo`, `schema_catalog.mojo` | 33 Hauptgruppen, 431 Parametereinträge und Kontext-Mappings |
| Parametersemantik | `parameter_semantics.mojo` | 86 Hauptaliase, 1.355 Unterparameter-Aliase, 428 kanonische Paare, 838 Spaltenverknüpfungen |
| Eingabesemantik | `input_semantics.mojo` | besitzende CLI-Tokens, Abschnitte, Top-Level-Kommas, Polarität und kanonische Spaltenauswahl |
| Prompt | `prompt_runtime.mojo`, `prompt_catalog.mojo` | Profile, Sitzung, Dispatch, Speicherzustand, native Kurzbefehle, 388 Completion-Wörter |

## Installation mit Python 3.14

```bash
./scripts/setup_mojo.sh
```

Das Skript bevorzugt `python3.14`, akzeptiert Python 3.10 bis 3.14 und installiert `mojo==1.0.0b2` in `.venv`. Eine Aktivierung der Umgebung ist nicht nötig. Explizite Auswahl:

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Der gleichnamige Snap `/snap/mojo/...` ist ein Canonical/Juju-Werkzeug und **nicht** der Modular-Mojo-Compiler. `bin/mojo-real` erkennt und verwirft ihn.

## Native Fach-CLI

```bash
./bin/reta-mojo --mojo-prime 60
./bin/reta-mojo --mojo-range '1-9,-3' 100
./bin/reta-mojo --mojo-architecture
./bin/reta-mojo --mojo-schema
./bin/reta-mojo --mojo-columns religionen sternpolygon
./bin/reta-mojo --mojo-alias religion gleichfoermigespolygon
./bin/reta-mojo --mojo-vocabulary
./bin/reta-mojo --mojo-parse-cli \
  -spalten '--religionen=sternpolygon,-gleichfoermigespolygon'
```

## Historische Tabellen-CLI

```bash
./reta \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon --breite=40
```

`reta` ist bereits ein Mojo-Launcher, startet für den noch nicht portierten Gesamtworkflow aber die gebündelte Python-Referenz als isolierten Kindprozess.

## Bauen und installieren

```bash
./scripts/build.sh
./scripts/install_bins.sh
```

Der Build erzeugt:

- `build/reta-mojo-native`
- `build/reta-mojo-schema`
- `build/reta-mojo-compat-bin`
- `build/reta-prompt-native`

Das Quellarchiv enthält bewusst keine vorgebauten Binärdateien mit fremden Runtime-Pfaden.

## Tests

```bash
./scripts/test_all.sh
./scripts/test_prompt_bins.sh
./scripts/check_prompt_catalog.sh
./scripts/check_compat_parity.sh
```

Aktueller Stand: **76/76 native Tests in 15 Testdateien**. Die Prozessintegration prüft zusätzlich `rpb`, `prim24`, `multis`, `modulo`, ein per Pipe gesteuertes `rp`, Promptspeicher, direkte `reta`-Weitergabe und die bytegleiche Fallback-Ausgabe eines historischen Kurzbefehls.

## Wichtige Dateien

- `BINARIES.md` – alle Laufzeit-Startnamen und ihre native Grenze
- `PORTING_MATRIX.md` – Status jeder Python-Datei
- `MIGRATION_NOTES.md` – bewusste semantische Entscheidungen
- `TEST_RESULTS.md` – Test- und Integrationsnachweise
- `python_reference/` – unveränderte Referenz plus schmaler Bridge-Adapter

## Ehrlicher Status

Der Promptcontroller und seine öffentlichen Profile sind jetzt Mojo. Nicht vollständig nativ sind weiterhin die große Tabellenpipeline, CSV-/Generatorspalten, das Architekturvalidierungsnetz und die Übersetzung aller historischen Kurzbefehle. Auch Terminal-readline und Prozessstart liegen noch an der Python-Betriebssystembrücke. Diese Grenzen sind im Code sichtbar und werden nicht als vollständige Transpilierung ausgegeben.
