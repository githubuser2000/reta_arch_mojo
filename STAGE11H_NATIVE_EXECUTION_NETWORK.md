# Stage 11h – natives deterministisches Ausführungsnetz

## Portierter Referenzbereich

`python_reference/reta_architecture/execution_network.py` ist als ausführende Mojo-Laufzeitschicht portiert:

- `src/reta_mojo/execution_network.mojo`
- `src/architecture_execution_network_main.mojo`
- `bin/reta-mojo-execution-network`

Der Port ist kein Metadaten-Snapshot. Warteschlangen, Kanäle, Semaphorzustände, Workerprozesse, Ergebnisreduktion und Snapshotbildung werden zur Laufzeit in Mojo ausgeführt.

## Typisierte Laufzeitobjekte

Die native Schicht enthält:

- `ExecutionNetworkConfig`
- `ExecutionTask`
- `ExecutionResult`
- `ExecutionRunResult`
- `FifoTaskQueue`
- `LifoTaskStack`
- `PriorityTaskQueue`
- `ResourceSemaphore`
- `HalfDuplexChannel`
- `FullDuplexChannel`
- `ExecutionNetworkBundle`

FIFO, LIFO und Prioritätsplanung behalten die Referenzordnung. Prioritätsgleichstände werden über den Taskindex aufgelöst. `deterministic_reduce` kann unabhängig von der tatsächlichen Ausführungsreihenfolge wieder nach Eingabeindex zusammensetzen.

## Prozessausführung

Der Linux-Pfad verwendet echte Prozesse:

1. Für jeden Task wird eine private Pipe erzeugt.
2. `fork()` startet einen nativen Mojo-Kindprozess.
3. Der Kindprozess führt die typisierte Operation aus und schreibt die UTF-8-Nutzlast in die Pipe.
4. Der Supervisor liest vollständig, wartet mit `waitpid()` und propagiert Workerfehler.
5. Tasks werden höchstens bis `max_workers` gleichzeitig gestartet.
6. Die Resultate werden anschließend deterministisch verklebt.

Damit ist `mode="processes"` keine simulierte Schleife und keine Python-Bridge. Der derzeit unterstützte Prozessstart ist Linux `fork`; `spawn` wird explizit abgewiesen, statt still seriell zu laufen.

## Statische Grenze statt Python-`Any`

Die Python-Referenz akzeptiert beliebige Pickle-fähige Nutzlasten und dynamisch importierte Callables. Die Mojo-Grenze ist absichtlich enger:

- Nutzlast und Ergebnis sind besitzende UTF-8-Strings.
- Ausführbare Funktionen werden über eine geprüfte Operationskennung beziehungsweise bekannte `callable_path`-Namen gewählt.
- Enthalten sind `identity`, `double_int`, `square_int`, `uppercase`, `lowercase` und `byte_length`.
- Metadaten werden als kanonischer JSON-Text transportiert.

Diese Grenze verhindert dynamisches `Any`, versteckte Python-Importe und nicht überprüfbare Pickle-Semantik. Weitere Reta-spezifische Workeroperationen können typisiert ergänzt werden, ohne Scheduler und Transport neu zu bauen.

Die Kanal- und Semaphorobjekte sind in Stage 11h deterministische, nichtblockierende Zustandsgrenzen. Volle pthread-/Condition-Variable-Wartekoordination wird erst benötigt, wenn `parallel_execution.py` native Threads oder länger lebende Supervisoren verwendet. Leere beziehungsweise volle Kanäle melden derzeit unmittelbar einen Fehler; ein übergebener Timeout wird nicht aktiv abgewartet. Diese Abweichung ist explizit und verhindert vorgetäuschte Threadsicherheit.

## Persistenzkopplung

`execution_run_snapshot_json()` erzeugt einen stabilen Laufzeitsnapshot. Der Stage-11h-Integrationstest führt zwei echte Workerprozesse aus, persistiert den Run über Stage 11g in SQLite, schreibt ein Auditereignis und liest Zähler sowie Auditnutzlast wieder zurück. Damit sind Ausführungsnetz und Persistenz bereits verbunden; die noch offene `parallel_execution.py` kann auf beiden nativen Schichten aufbauen.

## Öffentliche Abfragen

```bash
./bin/reta-mojo-execution-network --summary
./bin/reta-mojo-execution-network --config 4 priority true fork true 16
./bin/reta-mojo-execution-network --order priority
./bin/reta-mojo-execution-network --run-serial lifo
./bin/reta-mojo-execution-network --run-process fifo
./bin/reta-mojo-execution-network --channels
./bin/reta-mojo-execution-network --task double_int 21
```

## Validierung

```bash
./scripts/test_stage11h.sh
```

Der fokussierte Lauf umfasst:

- **85/85** native Ausführungsnetzprüfungen;
- **15/15** native Ausführungsnetz↔Persistenz-Integrationsprüfungen;
- **8/8** Python↔Mojo-Paritätsfälle;
- echte Fork-Worker, Unicode und Zeilenumbrüche über Pipes;
- Fehlerpropagation aus Workerprozessen;
- FIFO-/LIFO-/Prioritätsordnung und stabile Tie-Breaks;
- bounded Channels, Semaphoren und Snapshotstruktur.

Die langen Gesamtbuilds sind dafür nicht erforderlich. Test und öffentlicher Controller werden gezielt mit `--no-optimization -j 4` gebaut.

## Verbleibender Stage-11-Laufzeitblock

Nach Stage 11h bleibt von den beiden zuvor offenen Laufzeitmodulen nur noch `reta_architecture/parallel_execution.py`. Dessen Chunkplanung, Transformations-/Sheaf-Batches, Prozesspoolstrategien und Persistenzvorbereitung bilden Stage 11i.
