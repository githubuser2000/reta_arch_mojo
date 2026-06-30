> **Seit Stage 12a:** Der hier noch beschriebene explizite Prozessmodus ist entfernt.
> Alle nativen Parallelpfade verwenden Threads; historische Prozessoptionen sind
> nur noch Aliasnamen und erzeugen keinen Prozess.

# Stage 11j – typisierte Thread-Zeilenvorbereitung

Stage 11j schließt die native Laufzeitstufe 11 ab. Der letzte dynamische
`WorkerPrepare`-/`deepcopy`-Pfad aus
`reta_architecture/parallel_execution.py` ist durch besitzende Mojo-Typen und
echte CPU-Workerthreads ersetzt.

## Architekturentscheidung

Für die reinen Tabellen- und Zahlenkerne ist der native Standard nun:

- `auto` → Mojo-Threads,
- `threads` → Mojo-Threads,
- `processes` → seit Stage 12a Kompatibilitätsalias für Mojo-Threads,
- `off` → serieller Referenzpfad.

Mojo besitzt keinen Python-GIL. Threads dürfen daher CPU-Arbeit wirklich auf
mehrere Kerne verteilen und zugleich die bereits geladenen Tabellen lesen,
ohne sie über Pipes zu serialisieren oder durch Copy-on-write-Prozessräume zu
vervielfachen. Stage 12a hat den damaligen Prozesspfad entfernt, weil die portierten Kerne keine nicht-thread-sichere Fremdgrenze mehr enthalten.

SQLite-Schreibvorgänge, globale Header-Tag-Mutation und finale Terminal-/Datei-
Ausgabe bleiben seriell. Parallelisiert werden nur unabhängige, reine
Datenzeilen und Chunk-Kerne.

## Neue native Typen

`src/reta_mojo/table_preparation.mojo`:

- `ParallelRowPreparationContext`
- `PreparedIndexedRow`
- `PreparedRowsSerialResult`
- `prepare_cell_fragments`
- `prepare_indexed_row`
- `prepare_rows_serial`

`src/reta_mojo/parallel_row_preparation.mojo`:

- `PreparationInputRow`
- `ParallelRowPreparationConfig`
- `ParallelRowPreparationStats`
- `ParallelRowsResult`
- `prepare_rows_threaded`

Der Kontext übernimmt nur die Werte, die Datenzeilen tatsächlich lesen. Er
enthält keine Referenz auf die mutable Legacy-`Prepare`-Fassade. Header-Tags
werden vor dem Threadabschnitt seriell geklebt.

## Thread-Sicherheitsmodell

1. Eingabezeilen und Kontext sind während der parallelen Phase nur lesbar.
2. Jeder Chunk schreibt ausschließlich in seinen vorab zugeordneten
   Ergebnisslot.
3. Es gibt keine parallel veränderte globale Tabelle.
4. Nach der von `parallelize` gesetzten Barriere werden alle Slots seriell
   eingesammelt.
5. Die Endreduktion sortiert nach dem ursprünglichen Python-Zeilenindex.

Damit benötigt der Zeilenpfad weder Locks noch atomare Zähler. Das reduziert
nicht nur Laufzeitkosten, sondern auch die Zahl möglicher Race- und
Deadlockzustände.

## Umstellung der vorhandenen Chunk-Kerne

`src/reta_mojo/parallel_execution.mojo` besitzt nun einen gemeinsamen Backend-
Dispatcher. Alle zehn in Stage 11i portierten Tabellen-/Zahlenkerne laufen seit Stage 12a ausschließlich über typisierte Thread-Chunks.

Der alte Funktionsnamensbestand mit Suffix `_in_processes` bleibt zunächst als
Kompatibilitätsoberfläche erhalten. Das ausgewählte Backend steht in
`ParallelOperationStats.mode`; im Standardmodus ist es `threads`.

## Ausführbare Oberflächen

```sh
./bin/reta-mojo-parallel-execution --summary
./bin/reta-mojo-parallel-execution --demo-threads 2 2
./bin/reta-mojo-parallel-execution --demo 2 2
./bin/reta-mojo-parallel-execution --prime-factors 49 6 18 6
./bin/reta-mojo-parallel-execution --prime-factors-processes 49 6 18 6

./bin/reta-mojo-row-preparation --summary 8 128 128
./bin/reta-mojo-row-preparation --demo 2 1
./bin/reta-mojo-row-preparation --parity-fixture threads
```

## Parität

Die vollständige Fixture-Ausgabe vergleicht nicht nur Zähler, sondern alle
Zellenfragmente und ihre physischen Grenzen:

```text
1:hi|終終終~終
2:xy|uvw
3:1234~5678|z
4:abcd~ef|xyz~q
```

Python-Referenz, serielles Mojo und threadbasiertes Mojo liefern denselben
Bytestrom.

## Vorläufiger Laufzeitbefund

Ein reproduzierbarer synthetischer Probeweg mit 20.000 dreispaltigen Zeilen,
acht angeforderten Workern und Chunkgröße 128 ergab in der aktuellen
Containerumgebung:

| Backend | Laufzeit | Prüfsumme |
|---|---:|---:|
| seriell | 4,12 s | 1.846.670 |
| Threads | 3,22 s | 1.846.670 |

Das entspricht hier ungefähr 22 % weniger Wandzeit. Dies ist kein allgemeines
Ryzen-Benchmarkversprechen: Stringallokation, Speicherbandbreite, Zeilenbreite
und Chunkgröße bestimmen den Nutzen. Der Schwellwert bleibt deshalb Teil der
Konfiguration. Der Benchmark kann lokal wiederholt werden:

```sh
scripts/benchmark_parallel_row_preparation.sh 20000 8 128
```

## Prüfungen

- Parallelkonfiguration und Backendauflösung: **36/36**
- typisierte serielle/threadbasierte Zeilenvorbereitung: **40/40**
- Python↔serielles Mojo↔Thread-Mojo Vollstromparität: **2/2**
- repräsentativer generischer Thread-Chunkpfad: Primfaktoren mit unsortierten
  Duplikaten, deterministisch `6, 6, 18, 49`
- Shellsyntax der Build-, Installations-, Paritäts- und Testskripte: bestanden

Ein ThreadSanitizer-Build wurde erzeugt; seine Ausführung ist in der aktuellen
Sandbox an der vom Sanitizer verlangten großen virtuellen Adressraumabbildung
gescheitert, bevor das Programm startete. Der normale Threadtest läuft ohne
Fehler. Auf einem lokalen System kann der Sanitizer zusätzlich mit
`--sanitize thread` ausgeführt werden.

## Compilerstruktur

Der erste Versuch, die Zeilenvorbereitung direkt in das bereits über 1.800
Zeilen große `parallel_execution.mojo` einzubauen, überschritt selbst das auf
acht Minuten verdoppelte fokussierte Kompilierlimit. Deshalb ist der
Zeilenpfad als separates Modul gekapselt. Diese Trennung:

- verkürzt inkrementelle Builds,
- verhindert erneute Elaborierung aller Prozessprotokolle,
- hält Besitz- und Threadgrenzen sichtbar,
- erlaubt kleine, isolierte Tests.

Die vollständigen `build.sh`- und `build-heavy.sh`-Läufe werden weiterhin auf
dem Zielrechner ausgeführt.
