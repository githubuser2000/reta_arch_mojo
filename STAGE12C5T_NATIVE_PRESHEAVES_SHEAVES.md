# Stage 12c5t – native Prägarben und Garben

## Ziel

Diese Stage schließt die beiden Architekturmodule

- `python_reference/reta_architecture/presheaves.py`
- `python_reference/reta_architecture/sheaves.py`

als zusammenhängende native Gluing-Schicht. Lokale Repository-, CSV-,
Übersetzungs- und Promptsektionen bleiben als Prägarben getrennt; die global
zusammengeführten Parameter-, Generator-, Tabellen- und HTML-Sichten werden als
typisierte Garben modelliert. Zur Laufzeit werden weder Python-Objekte noch ein
Python-Interpreter oder Hilfsprozesse benötigt.

## Native Prägarben

`src/reta_mojo/presheaves.mojo` besitzt nun alle fünf Python-Klassen und ihre
15 Methoden:

- `LocalSection`
- `Presheaf`
- `FilesystemPresheaf`
- `PromptStatePresheaf`
- `PresheafBundle`

Die dynamische Python-Nutzlast `object` wird als kanonischer JSON-Text
transportiert. Der Kontext bleibt der bereits typisierte `ContextSelection`.
Einschränkungen verwenden dessen echten Meet und verwerfen leere lokale
Sektionen. Prompt-Updates ersetzen wie in Python die vorherige Promptsektion.

Der reproduzierbare Katalog `assets/presheaf_catalog.tsv` enthält exakt:

```text
CSV-Sektionen:            79
Übersetzungssektionen:    27
Assetsektionen:          163
Gesamt:                  269
```

Alle Katalogpfade sind relativ zum Referenzbaum und damit sowohl im
Quellarchiv als auch nach FHS-Installation portabel.

## Native Garben

`src/reta_mojo/sheaves.mojo` und
`src/reta_mojo/parameter_semantics.mojo` besitzen alle fünf Python-Klassen und
22 Methoden:

- `ParameterSemanticsSheaf`
- `GeneratedColumnsSheaf`
- `TableOutputSheaf`
- `HtmlReferenceSheaf`
- `SheafBundle`

Die Parametersemantik umfasst nun zusätzlich die vollständige öffentliche
Methodenoberfläche, den synchronisierten Programmzustand und einen typisierten
Snapshot. Generierte Spalten und Ausgabetabellen werden besitzend kopiert,
sodass spätere Mutationen des Quellzustands keine Garbensektion rückwirkend
ändern.

`assets/html_reference_sheaf.tsv` reproduziert die Python-Last-write-Regel für
Zeile 0 von `htmlclassesPy.jsonl`. Es enthält 669 eindeutige Spalten und pro
Spalte den vollständigen kompakten 15-Feld-JSON-Datensatz.

## Reproduzierbarkeit

Beide Assets werden gemeinsam erzeugt:

```bash
python3 tools/generate_presheaf_sheaf_catalogs.py
```

Die Source-Gates erzeugen sie erneut und vergleichen ihre SHA-256-Werte mit
dem eingecheckten Stand.

## Diagnoseziel

Der reguläre Build besitzt ein neues Ziel:

```text
target/bin/reta-mojo-sheaves
```

Beispiele:

```bash
./bin/reta-mojo-sheaves --summary
./bin/reta-mojo-sheaves --presheaf csv
./bin/reta-mojo-sheaves --html 4
./bin/reta-mojo-sheaves --prompt 'reta -zeilen'
```

Damit umfasst `scripts/build.sh` 19 reguläre Ziele. Zusammen mit 18 schweren
Zielen enthält `scripts/install_targets.txt` 37 offizielle Compilerziele.

## Tests

Vorbereitet sind neun native Mojo-Tests:

```text
tests/test_presheaves_complete.mojo   4
tests/test_sheaves_complete.mojo      5
```

Der lokale Stage-Lauf kompiliert zusätzlich das Diagnoseprogramm und vergleicht

- die vier Prägarbenzählungen,
- 33 Hauptaliasgruppen,
- 428 kanonische Parameterpaare,
- 669 HTML-Referenzen sowie
- die vollständigen JSON-Nutzlasten der Spalten 0, 1, 4 und 669

mit der Python-/PyPy3-Referenz.

```bash
scripts/build.sh
scripts/test_stage12c5t.sh
```

Die archivierbaren Source-, Ownership-, Installations-, Defekt- und
Metrikgates bestanden in der Erstellungsumgebung 41/41. Der tatsächliche
Mojo-Compilerlauf bleibt dem lokalen Modular-Compiler vorbehalten.

## Fortschritt

```text
vollständig nativ/generiert:       66/92 = 71,7 %
mindestens teilweise portiert:     83/92 = 90,2 %
angegriffene Referenzzeilen:        38.174/48.831 = 78,2 %
vollständig native Referenzzeilen:  29.716/48.831 = 60,9 %
produktive Mojo-Zeilen in src/:     54.590
aktive std.python-Brücken:               0
```
