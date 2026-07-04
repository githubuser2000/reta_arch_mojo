# Stage 12c5as – runtime-sichere Parallelkonfiguration

## Auslöser

Der vollständige Mojo-Testlauf von Stage 12c5aq brach beim Kompilieren von
`tests/test_legacy_reta_program.mojo` ab. Die Ursache war kein fehlerhafter
`getenv`-Aufruf zur Laufzeit, sondern ein `getenv`-Pfad in einem
Default-Argument:

```text
extract_parallel_config_from_argv(
    argv,
    inherited = parallel_config_from_environment(),
)
```

Mojo 1.0.0b2 versucht Default-Ausdrücke bei der Funktionsinstanziierung
compile-time auszuwerten. Externe C-Funktionen wie `getenv` können dort nicht
interpretiert werden.

## Umsetzung

`parallel_execution.mojo` trennt die Verantwortungen jetzt strikt:

1. `read_parallel_environment()` ist die einzige I/O-Grenze für die sechs
   `RETA_PARALLEL*`-Variablen.
2. `ParallelEnvironmentValues` hält gelesene Werte samt Anwesenheit der beiden
   Modusschalter.
3. `parallel_config_from_environment_values(...)` bildet diese Werte rein und
   deterministisch auf `ParallelExecutionConfig` ab.
4. `extract_parallel_config_from_argv(...)` verlangt seine geerbte
   Konfiguration ausdrücklich.
5. `bootstrap_parallel_execution(...)` verlangt ebenfalls eine explizite
   Konfiguration.
6. `program_workflow.mojo` enthält keinerlei versteckten Umgebungszugriff mehr.
7. `bootstrap_legacy_reta_program_with_parallel_config(...)` ist die
   deterministische Test-/Bibliotheksgrenze; nur
   `bootstrap_legacy_reta_program(...)` liest absichtlich die echte Umgebung.

Die Anwesenheit einer leeren `RETA_PARALLEL_MODE`-Variablen bleibt von einer
nicht gesetzten Variablen unterscheidbar. Damit bleibt auch dieser Randfall der
Python-Referenz erhalten.

## Kompilierung durch den Benutzer

Die Stage wurde bewusst nicht durch ChatGPT kompiliert. Nach dem Entpacken:

```bash
scripts/build-all.sh
scripts/test_current_stage.sh
```

Für die vollständige Testsuite:

```bash
scripts/test_all.sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

`build.sh`, `build-heavy.sh` und `build-all.sh` bauen weiterhin ausschließlich
Produktionsziele. Die Mojo-Dateien unter `tests/` werden nur durch Stage- und
Testsuite-Skripte kompiliert.
