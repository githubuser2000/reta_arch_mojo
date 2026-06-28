# reta.arch → Mojo

Dies ist ein **arbeitsfähiger inkrementeller Port** des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2.

Er ist absichtlich kein vorgetäuschter 1:1-Syntaxdump. Das Original umfasst ungefähr 49.000 Python-Zeilen und nutzt an vielen Stellen dynamische Python-Semantik (`getattr`, untypisierte Rückgaben, `*args`, `**kwargs`, Laufzeitimporte und frei geformte Dictionaries). Eine mechanische Umschrift würde zwar nach Mojo aussehen, aber weder zuverlässig kompilieren noch die Semantik erhalten.

Deshalb besteht das Ergebnis aus zwei klar getrennten Schichten:

1. **Nativer Mojo-Kern** für bereits sauber übertragene Algorithmen und Architekturbegriffe.
2. **Kompatibilitäts-Launcher** für die vollständige historische CLI, solange deren übrige Subsysteme noch Python sind.

## Was nativ portiert ist

| Bereich | Mojo-Modul | Stand |
|---|---|---|
| Zahlentheorie | `src/reta_mojo/number_theory.mojo` | Primfaktoren, Teiler, Wiederholungen, Prime Creativity, Primzahlkreuz, Mondzahlen |
| Zeilenbereiche | `src/reta_mojo/row_ranges.mojo` | Parser und Expansion einschließlich Ausschlüssen, Mengen, Vielfachen und Offsets |
| Arithmetik | `src/reta_mojo/arithmetic.mojo` | Faktorpaare, Primfaktoren, Modulozeilen, Teilerbereiche, Dictionary-Invertierung |
| Kategorientheorie | `src/reta_mojo/category_theory.mojo` | 26 Kategorien, 77 Funktoren, 42 natürliche Transformationen, 8 Paradigmenbegriffe |
| Topologie | `src/reta_mojo/topology.mojo` | typisierte Kontextdimensionen, Aliasauflösung, offene Auswahlen, Verfeinerung |
| Ausgabe-Modi | `src/reta_mojo/output_modes.mojo` | Modussemantik, Renderer-Konstanten, HTML-/BBCode-Zeilenfarben |
| Prägarben | `src/reta_mojo/presheaves.mojo` | typisierte Lokalsektionen und Restriktion |
| Universelle Konstruktion | `src/reta_mojo/universal.mojo` | Normalisierung positiver/negativer Spalten-Buckets |

Der native Quellbaum hat rund 2.300 Mojo-Zeilen, davon etwa 1.050 generierte, aber vollständig typisierte Architekturdaten.

## Voraussetzungen

- Linux, macOS oder Windows über WSL gemäß den Mojo-Systemvoraussetzungen
- Mojo **1.0.0b2** zum Ausführen oder Bauen
- Python **3.10 bis 3.14** nur für den Kompatibilitätsmodus

Am einfachsten richtest du den offiziellen Compiler projektlokal ein:

```bash
./scripts/setup_mojo.sh
```

Das Skript erzeugt `.venv`, installiert exakt `mojo==1.0.0b2` mit `uv` und prüft anschließend `mojo --version`. Die Wrapper finden `.venv/bin/mojo` automatisch; `source .venv/bin/activate` ist daher nicht nötig.

Manuell entspricht das:

```bash
uv venv --python 3.13 .venv
uv pip install --python .venv/bin/python 'mojo==1.0.0b2' --prerelease allow
```

### Achtung: gleichnamiger Snap

Der Snap `mojo` aus dem Snap Store ist **nicht** die Programmiersprache von Modular, sondern ein Canonical/Juju-Deploymentwerkzeug. Typische Spuren des falschen Programms sind Pfade wie `/snap/mojo/.../site-packages/mojo/juju` und Fehler über ein fehlendes `juju`. Entferne ihn bei Bedarf mit:

```bash
sudo snap remove mojo
```

Die Projekt-Wrapper lehnen `/snap/mojo/...` ausdrücklich ab und bevorzugen immer den projektlokalen offiziellen Compiler.

Für die komplette alte Prompt-Oberfläche können zusätzlich die Abhängigkeiten aus `python_reference/pyproject.toml` nötig sein. Die normalen Tabellenaufrufe funktionieren mit der gebündelten Referenz und den im Projekt enthaltenen Fallback-Modulen.

## Benutzung

### Native Mojo-Befehle

```bash
./bin/reta-mojo --mojo-prime 60
./bin/reta-mojo --mojo-range '1-9,-3' 100
./bin/reta-mojo --mojo-architecture
./bin/reta-mojo --mojo-output html 9
./bin/reta-mojo --mojo-help
```

### Vollständige historische CLI über die Migrationsgrenze

```bash
./bin/reta-mojo-compat \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon --breite=40
```

Der Kompatibilitäts-Launcher ist selbst Mojo. Er startet die gebündelte Python-Referenz als Kindprozess, damit deren globale Zustände, Laufzeitimporte und mögliche Worker-Prozesse nicht in den Mojo-Prozess hineinreichen.

## Bauen

```bash
./scripts/build.sh
```

Erzeugt lokal:

- `build/reta-mojo-native`
- `build/reta-mojo-compat-bin`

Der Architekturkatalog hat wegen seiner Größe einen eigenen Einstiegspunkt und wird nur bei `--mojo-architecture` geladen. Die Wrapper `bin/reta-mojo` und `bin/reta-mojo-compat` verwenden die lokalen Binärdateien, falls sie vorhanden sind; andernfalls starten sie den jeweiligen Mojo-Quelltext direkt. Dadurch enthält das Archiv keine an einen fremden absoluten Runtime-Pfad gebundenen Binärdateien.

## Tests

```bash
./scripts/test_all.sh
./scripts/check_compat_parity.sh
```

Die Tests decken die nativen Module direkt ab. Zusätzlich erzeugt `tools/generate_parity_tests.py` feste Erwartungsvektoren aus der Python-Referenz. Dadurch wird nicht nur geprüft, ob der Mojo-Code intern konsistent ist, sondern ob er bei legitimen Eingaben dasselbe Ergebnis wie Python liefert.

Die geprüften Referenzvektoren umfassen unter anderem:

- 257 Prime-Creativity-Werte
- 86 Primfaktorzerlegungen
- 44 Teilermengen
- 288 Primzahlkreuz-Prädikate
- 10 nichttriviale Bereichsausdrücke

## Wichtige Dateien

- `PORTING_MATRIX.md` – Status jeder Python-Datei
- `MIGRATION_NOTES.md` – bewusste semantische Entscheidungen und offene Grenzen
- `tools/generate_category_theory.py` – erzeugt den typisierten Kategoriekatalog
- `tools/generate_parity_tests.py` – erzeugt Python→Mojo-Paritätstests
- `python_reference/` – unveränderte hochgeladene Referenz plus minimaler Bridge-Adapter

## Ehrlicher Status

Die vollständigen Tabellen-, Prompt-, I18n-, CSV-, Generatorspalten- und Architekturvalidierungsnetze sind noch nicht nativ in Mojo. Sie laufen über `reta-mojo-compat`. Der Port ist dennoch direkt ausführbar, testbar und so strukturiert, dass weitere Module ohne erneute Architekturentscheidung aus der Bridge herausgelöst werden können.
