# Build- und Binärlayout

## Grundsatz

`bin/` enthält kleine, versionierbare POSIX-Launcher. Echte Mojo-Compilerprodukte entstehen ausschließlich unter `target/bin/` und werden durch `.gitignore` ausgeschlossen.

```text
bin/                     versionierte Launcher
target/bin/              reguläre ELF-Executables
target/tests*/           kompilierte Testprogramme
.venv/                   lokaler Mojo-Compiler und Runtime
src/                     Mojo-Quellen
```

## Installation mit Python 3.14

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Nur Compiler installieren:

```bash
RETA_SKIP_BUILD=1 RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

## Regulärer Build

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Erzeugt werden neun normale Laufzeitziele:

```text
target/bin/reta-mojo-native
target/bin/reta-mojo-table
target/bin/reta-mojo-tags
target/bin/reta-native
target/bin/reta-mojo-compat-bin
target/bin/reta-prompt-native
target/bin/reta-prompt-complete
target/bin/grundStrukHtml-native
target/bin/generate-html-native
```

`reta-prompt-complete` ist der persistente native Completion-Arbeiter für die interaktive Readline-Grenze und besitzt seine stdin/stdout-Dateideskriptoren ohne eingebettetes CPython. `reta-mojo-table` ist bewusst leicht und enthält Tabellenzustand, Wrapping und CSV-Inspektion. Das vollständige Tag-Schema liegt in `reta-mojo-tags`. Diese Trennung vermeidet einen unnötigen Compiler-Monolithen.

## Schwere generierte Ziele

```bash
./scripts/build-heavy.sh
RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh
```

Das erzeugt zusätzlich:

```text
target/bin/reta-mojo-schema
target/bin/reta-mojo-architecture
target/bin/reta-mojo-boundaries
target/bin/reta-mojo-contracts
target/bin/reta-mojo-witnesses
target/bin/reta-mojo-coherence
target/bin/reta-mojo-traces
target/bin/reta-mojo-impact
target/bin/reta-mojo-migration
target/bin/reta-mojo-rehearsal
target/bin/reta-mojo-activation
target/bin/reta-mojo-validation
target/bin/reta-mojo-progress
target/bin/reta-mojo-persistence
target/bin/reta-mojo-execution-network
target/bin/reta-mojo-parallel-execution
target/bin/reta-mojo-row-preparation
```

Die siebzehn Ziele enthalten sehr große generierte Konstantenstrukturen, Grenzgraphdaten, Architekturverträge, Witness-Matrizen, Kohärenzrouten, Trace-Netze, Impact-Routen, Migrationspläne, Rehearsal-Gates, Aktivierungstransaktionen, Gesamtvalidierungschecks, das Fortschritts-Overlay, die native SQLite-Persistenz, das deterministische Ausführungsnetz, die hybriden Thread-/Prozess-Chunk-Kerne und die typisierte Thread-Zeilenvorbereitung. Sie sind nicht für jeden normalen Build erforderlich; die Laufzeitpfade verwenden kompakte Katalogdateien.

## Aufräumen

```bash
./scripts/clean.sh
```

Das Quellrelease enthält weder `.venv/`, `target/` noch ELF-Dateien. Dadurch entstehen keine fremden absoluten Runtime-Pfade im Git-Repository oder Releasearchiv.

`generate-html-native` lädt und komponiert Assets nativ. Nur die noch nicht portierte große `--spalten --alles`-Mitteltabelle wird im normalen Generatorpfad über einen expliziten Referenzkindprozess erzeugt; der Overridepfad benötigt Python nicht.


## Stage 11e: gezielt unoptimierte Metadaten-Controller

Die vollständigen Rehearsal- und Aktivierungsbundles werden in den fokussierten Tests mit Mojos Standardoptimierung kompiliert. Nur die beiden öffentlichen Query-Controller verwendet `scripts/build-heavy.sh` mit `--no-optimization`, weil O3 für diese großen Konstantenbäume unverhältnismäßig lange elaboriert. Die Programme sind Metadateninspektoren; ihre Laufzeit ist nicht performancekritisch.


## Stage 11f: Validierungs- und Fortschrittscontroller

`architecture_validation.mojo` und `architecture_progress.mojo` werden in den fokussierten Tests normal optimiert kompiliert. Die beiden öffentlichen Query-Controller verwendet `scripts/build-heavy.sh` mit `--no-optimization`, damit die großen String-/Listen-Snapshots ohne unnötige O3-Elaboration schnell gebaut werden.


## Stage 11g: SQLite- und SHA-256-Linkgrenze

`reta-mojo-persistence` wird zusätzlich mit `-lsqlite3 -lcrypto` gelinkt. Benötigt werden die Systembibliotheken SQLite 3 und OpenSSL/libcrypto einschließlich der Linker-Symlinks der jeweiligen Entwicklungs-/Devel-Pakete. Der Laufzeitpfad enthält keinen Python-Import.

Der gezielte Build und Test lautet:

```bash
./scripts/test_stage11g.sh
```


## Stage 11h: Ausführungsnetz und gezielter Fork-Build

Der öffentliche Ausführungsnetz-Controller wird mit `--no-optimization -j 4` gebaut. Das vermeidet unnötige O3-Elaboration der C-ABI-, Pipe- und Snapshotpfade; die Worker selbst bleiben echte native Linux-`fork`-Prozesse. Es werden keine zusätzlichen Laufzeitbibliotheken außer libc benötigt.

Der gezielte Build-, Integrations- und Paritätslauf lautet:

```bash
./scripts/test_stage11h.sh
```

Der Test koppelt das Ausführungsnetz zusätzlich an SQLite und SHA-256; nur dieses Integrationsziel wird daher mit `-lsqlite3 -lcrypto` gelinkt.


## Stage 11i: Hybride Thread-/Prozess-Chunk-Kerne

`reta-mojo-parallel-execution` wird gezielt mit `--no-optimization -j 4` gebaut. `auto` und `threads` verwenden Mojos CPU-Threadpool; `processes` behält Linux `fork`, private Pipes und `waitpid` als expliziten Isolationsmodus. Es wird keine Python-Laufzeit gelinkt. Der Prozessmodus verwendet längenpräfixierte UTF-8-Felder.

Der fokussierte Lauf baut mehrere kleine Testprogramme statt eines großen Testmonolithen:

```bash
./scripts/test_stage11i.sh
```

Das Skript prüft zusätzlich die kompakte Prompt-Zeilengrenze, die Integrität der Goldendateien und Python↔Mojo-Parität. Die langen Gesamtbuilds `scripts/build-heavy.sh` und `scripts/build.sh` sind dafür nicht erforderlich.


## Stage 11j: Getrennter Thread-Prepare-Build

`parallel_execution.mojo` ist durch zehn ältere Kernfamilien bereits compilerseitig groß. Der typisierte Prepare-Pfad liegt deshalb in `table_preparation.mojo` und `parallel_row_preparation.mojo` und wird als eigenes Ziel `reta-mojo-row-preparation` gebaut. Dadurch muss eine Änderung an der Zeilenvorbereitung nicht sämtliche Prozessprotokolle und Zahlenkerne erneut elaborieren.

```bash
./scripts/test_stage11j.sh
./scripts/benchmark_parallel_row_preparation.sh 20000 8 128
```

Die fokussierten Befehle dürfen mit längeren Zeitlimits ausgeführt werden. Die vollständigen Skripte `scripts/build-heavy.sh` und `scripts/build.sh` werden für das Übergabearchiv nicht erneut benötigt und können auf dem Zielsystem gebaut werden.
