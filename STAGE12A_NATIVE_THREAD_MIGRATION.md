# Stage 12a – vollständige native Threadmigration und Boundary-Gates

Stage 12a entfernt die letzten prozessbasierten Parallelpfade aus dem Mojo-
Laufzeitkern. Die Python-Referenz darf weiterhin Multiprocessing verwenden;
der native Port verwendet für unabhängige In-Memory-Arbeit ausschließlich
Mojos CPU-Workerthreads.

## Warum der frühere Prozessmodus entfernt wurde

Der Prozessmodus war zunächst als konservative Übersetzung des PyPy3-
Multiprocessingpfads und als möglicher Isolationsmodus erhalten geblieben. Nach
dem Port der dynamischen Python-Callable-Grenze bestand diese Begründung für
die konkreten Mojo-Kerne nicht mehr:

- alle Operationen sind statisch typisiert und intern bekannt,
- Eingaben liegen bereits im selben Mojo-Prozess,
- Worker lesen unveränderliche Daten,
- jeder Worker schreibt in einen eigenen Ergebnisslot,
- die Reduktion erfolgt erst nach der `parallelize`-Barriere,
- SQLite-Schreibvorgänge und Ausgabe-I/O bleiben seriell.

`fork`, private Pipes, `waitpid`, Copy-on-write-Seiten und Ergebnis-
Deserialisierung erzeugten daher nur noch Kosten und zusätzliche Fehlerpfade.

## Vollständig umgestellte Laufzeitmodule

- `src/reta_mojo/execution_network.mojo`
- `src/reta_mojo/parallel_execution.mojo`
- `src/reta_mojo/parallel_row_preparation.mojo`

In diesen drei Modulen gibt es keine Python-, Subprozess- oder POSIX-
Prozessgrenze mehr.

## Typisierte Thread-Chunks

Die zehn Stage-11i-Kerne verwenden nicht länger das frühere längenpräfixierte
Stringprotokoll. Jeder Kern besitzt nun passende typisierte Chunkslots:

1. Religionszeilen dekodieren
2. Kombizeilen dekodieren
3. Mondzahlen berechnen
4. Primfaktoren berechnen
5. Zahlen filtern
6. Faktorpaare berechnen
7. Tabellenspalten auswählen
8. maximale Zellbreiten bestimmen
9. Spalten-Buckets normalisieren
10. Kombi-Join-Tabellen vorbereiten

Eingaben werden pro Chunk typisiert kopiert oder nur gelesen. Resultate werden
in disjunkte Slots geschrieben und anschließend in der Python-definierten
Reihenfolge reduziert.

## Kompatibilität

Die kanonischen APIs tragen das Suffix `_threaded`. Frühere öffentliche Namen
mit `_in_processes` bleiben als reine Quellkompatibilitätsaliasfunktionen
vorhanden. Ebenso werden die Konfigurationswerte `process`, `processes`,
`multiprocessing` und `mp` auf `threads` normalisiert. Diese Aliaswege erzeugen
keinen Prozess.

Die alten CLI-Optionen `--run-process`, `--prime-factors-processes` und
`--factor-pairs-processes` bleiben vorläufig akzeptiert und leiten auf den
Threadpfad um.

## Maschinenprüfbare Boundary-Inventur

`assets/native_bridge_inventory.tsv` enthält alle aktiven Mojo-Brücken:

| Datei | Grenze | Abschlussziel |
|---|---|---|
| `src/compat_main.mojo` | `std.python` | 12e |
| `src/generate_html_main.mojo` | `std.subprocess` | 12b |
| `src/prompt_main.mojo` | `std.python` | 12c |

`tools/audit_native_boundaries.py` schlägt fehl, wenn:

- eine nicht inventarisierte Python-/Subprozessbrücke hinzukommt,
- eine inventarisierte Brücke verschwindet oder ihren Typ ändert,
- irgendwo in Mojo wieder direkte `fork`-, `pipe`-, `waitpid`- oder `_exit`-
  Aufrufe eingeführt werden,
- ein Parallelmodul `std.python` oder `std.subprocess` importiert,
- eine der zehn kanonischen Thread-APIs fehlt.

## Prüfungen

- Boundary-Audit: **0** native Prozessprimitive, **3** Threadmodule,
  **3** explizite Restbrücken, **10** kanonische Thread-APIs
- Boundary-Pytest: **1/1**
- Ausführungsnetz: **85/85**
- Ausführungsnetz↔SQLite: **15/15**
- Parallelkonfiguration: **36/36**
- generischer Thread-Backendtest: **43/43**
- typisierte Prepare-Zeilenvorbereitung: **40/40**
- Zeilenkerne: **55/55**
- Zahlenkerne: **157/157**
- Tabellenkerne: **26/26**
- Python↔Mojo-Parallelparität: **12/12**
- Thread↔Legacy-Alias-Parität: **1/1**
- Python↔Mojo-Ausführungsnetzparität: **8/8**
- Python↔seriell↔Thread-Prepare-Parität: **2/2**

Der fokussierte Lauf lautet:

```sh
./scripts/test_stage12a.sh
```

Die vollständigen Projektbuilds bleiben weiterhin:

```sh
scripts/build-heavy.sh
scripts/build.sh
```
