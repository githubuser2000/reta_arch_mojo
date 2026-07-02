# Stage 12c5n – CSV-Quoteparität und native HTML-Klassenextraktion

## Lokale Fehlerbefunde

Der schnelle ProgramWorkflow-Test scheiterte bei einer gültigen Religion-Zelle
wie `|{"":"plain",...}|`. Der native CSV-Parser behandelte jedes doppelte
Anführungszeichen als Beginn oder Ende eines quoted Feldes, auch wenn das
Zeichen mitten in einem unquoted Feld stand. Dadurch wurden die JSON-Schlüssel
beim CSV-Lesen entfernt; der nachfolgende JSON-Parser meldete folgerichtig
einen fehlenden leeren Schlüssel.

Ein zweiter Source-Test verlangte, dass eine ältere `prompt_toolkit`-Version das
Wort `grö` weiterhin fälschlich in `gr` und `ö` trennt. Neuere Versionen liefern
korrekt `grö` und den Kandidaten `größe`. Ein Defektreproducer darf eine bereits
upstream behobene Abhängigkeit nicht künstlich als Fehler erzwingen.

## Korrekturen

- CSV-Quotes starten nur noch am Anfang eines Feldes. Doppelte Anführungszeichen
  innerhalb unquoted Felder bleiben normale Nutzdaten, exakt wie bei
  `csv.reader(delimiter=';')`.
- Echte quoted Felder, eingebettete Semikolons, Mehrzeilenfelder und verdoppelte
  Quotezeichen bleiben unverändert unterstützt.
- Die ProgramWorkflow-Fixture prüft damit tatsächlich CSV → JSON → UTF-8 statt
  ein ungültig verstümmeltes Zwischenformat.
- Der `prompt_toolkit`-Reproducer klassifiziert nun sowohl das historische als
  auch das upstream korrigierte Verhalten und hält `PY-CAND-007` weiterhin als
  versionsabhängige Vertragsentscheidung fest.

## Weiterer Portierungsblock

`python_reference/reta_extract_html_classes.py` ist vollständig durch
`src/reta_mojo/html_class_extractor.mojo` und
`src/extract_html_classes_main.mojo` ersetzt.

Der native Pfad:

1. erzeugt die einzeilige All-Spalten-HTML-Tabelle direkt über
   `run_native_reta`,
2. findet die erste Tabellenzeile ohne reguläre Ausdrücke,
3. analysiert alle `td`-Öffnungstags einschließlich mehrfacher Attribute,
4. bewahrt primäre und zusätzliche Klassen, `data-*`, Attributreihenfolge,
   Roh-HTML und Unicode-Text,
5. schreibt dieselben 15 JSON-Felder in kompakter UTF-8-JSONL-Reihenfolge.

Es werden weder Python, `std.python`, `PythonObject`, Regex noch ein
Unterprozess verwendet. Für Tests kann HTML über `RETA_HTML_CLASSES_INPUT`
zugeführt werden; der normale Lauf erzeugt es nativ aus `religion.csv`.

Reguläres Compilerziel:

```text
target/bin/reta-extract-html-classes-native
```

Launcher:

```text
bin/reta-extract-html-classes
```

## Prüfung

`scripts/test_stage12c5n.sh` kompiliert und prüft den CSV-Parser, den
ProgramWorkflow, den HTML-Extraktor und dessen Python↔Mojo-JSONL-Parität. Die
Sourcegates prüfen zusätzlich Besitzgrenzen, Installationsmanifest,
Portierungsmatrix, Defektkatalog und Sourcearchivvertrag.

## Maschinenstand

```text
vollständig nativ/generiert:    59/92 = 64,1 %
mindestens teilweise portiert:  82/92 = 89,1 %
angegriffene Referenzzeilen:     37.197/48.831 = 76,2 %
vollständig native Zeilen:       27.774/48.831 = 56,9 %
Mojo-Zeilen unter src/:          52.397
installierbare Compilerziele:    36
Defektkatalog:                   75/75
Python-Bereinigungspunkte:       18
```

Die reine Source-, Ownership-, Defekt-, Metrik-, Installations- und
Archivvertragssuite besteht aus **63/63** bestandenen Python-Tests. Der lokale
Mojo-Lauf prüft zusätzlich drei Module und **1.616** Python↔Mojo-JSONL-Sätze:
zwei synthetische Zellen sowie 1.614 Zellen der vollständigen vorhandenen
All-Spalten-HTML-Fixture.
