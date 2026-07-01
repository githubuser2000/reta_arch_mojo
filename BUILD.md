# Build- und Binärlayout

## Grundsatz

`bin/` enthält kleine, versionierbare POSIX-Launcher. Echte Mojo-Compilerprodukte entstehen ausschließlich unter `target/bin/` und werden durch `.gitignore` ausgeschlossen.

```text
bin/                     versionierte Launcher
target/bin/              reguläre ELF-Executables
target/lib/mojo/         lokale Links auf die Mojo-Laufzeitbibliotheken
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

## Portable Mojo-Laufzeit

Mojo-ELF-Dateien benötigen `libKGENCompilerRTShared.so` und
`libAsyncRTMojoBindings.so`. Das ist unabhängig von den CSV-Dateien. Absolute
Compilerpfade im ELF-`RUNPATH` sind zwischen Rechnern nicht portabel; deshalb
betten alle Builds zusätzlich `$ORIGIN/../lib/mojo` ein und richten den
projektrelativen Ort `target/lib/mojo` ein.

```bash
./scripts/configure_mojo_runtime.sh
```

Die automatische Erkennung kann bei Bedarf überschrieben werden:

```bash
RETA_MOJO_RUNTIME_LIBDIR=/pfad/zu/modular/lib \
  ./scripts/configure_mojo_runtime.sh
```

Die öffentlichen Launcher verwenden zusätzlich `bin/mojo-runtime-exec`. Damit
laufen auch ältere übernommene ELF-Dateien, deren einzig vorhandener `RUNPATH`
noch auf den Rechner zeigt, auf dem sie kompiliert wurden.

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

`reta-prompt-complete` bleibt als persistenter eigenständiger Completion-Arbeiter und Kompatibilitäts-/Testziel erhalten. Der reguläre interaktive Prompt verwendet seit Stage 12c4d Completion direkt im nativen TTY-Editor und benötigt weder diesen Arbeiter noch eingebettetes CPython. `reta-mojo-table` ist bewusst leicht und enthält Tabellenzustand, Wrapping und CSV-Inspektion. Das vollständige Tag-Schema liegt in `reta-mojo-tags`. Diese Trennung vermeidet einen unnötigen Compiler-Monolithen.

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

Die siebzehn Ziele enthalten sehr große generierte Konstantenstrukturen, Grenzgraphdaten, Architekturverträge, Witness-Matrizen, Kohärenzrouten, Trace-Netze, Impact-Routen, Migrationspläne, Rehearsal-Gates, Aktivierungstransaktionen, Gesamtvalidierungschecks, das Fortschritts-Overlay, die native SQLite-Persistenz, das deterministische Thread-Ausführungsnetz, die typisierten Thread-Chunk-Kerne und die typisierte Thread-Zeilenvorbereitung. Sie sind nicht für jeden normalen Build erforderlich; die Laufzeitpfade verwenden kompakte Katalogdateien.

## Aufräumen

```bash
./scripts/clean.sh
```

Das Quellrelease enthält weder `.venv/`, `target/` noch ELF-Dateien. Dadurch entstehen keine fremden absoluten Runtime-Pfade im Git-Repository oder Releasearchiv.

`generate-html-native` lädt Assets, löst den zwölfteiligen `--spalten --alles`-Plan auf, rendert die Mitteltabelle und komponiert die Seite vollständig im Mojo-Prozess. Weder Normal- noch Overridepfad benötigt Python oder einen Kindprozess.


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


## Stage 11h/12a: Ausführungsnetz und gezielter Thread-Build

Der öffentliche Ausführungsnetz-Controller wird mit `--no-optimization -j 4` gebaut. Seit Stage 12a verwendet er ausschließlich Mojos CPU-Workerthreads. Direkte POSIX-Prozessprimitive und das frühere Pipe-Protokoll sind entfernt; die Snapshot- und Reduktionspfade bleiben nativ.

Der gezielte Build-, Integrations- und Paritätslauf lautet:

```bash
./scripts/test_stage11h.sh
```

Der Test koppelt das Ausführungsnetz zusätzlich an SQLite und SHA-256; nur dieses Integrationsziel wird daher mit `-lsqlite3 -lcrypto` gelinkt.


## Stage 11i/12a: Typisierte Thread-Chunk-Kerne

`reta-mojo-parallel-execution` wird gezielt mit `--no-optimization -j 4` gebaut. Alle nativen Tabellen- und Zahlenkerne verwenden Mojos CPU-Threadpool und typisierte Chunkslots. Alte Prozessbezeichnungen werden nur noch als Kompatibilitätsalias auf `threads` normalisiert; `fork`, Pipes, `waitpid` und das String-Transportprotokoll sind entfernt.

Der fokussierte Lauf baut mehrere kleine Testprogramme statt eines großen Testmonolithen:

```bash
./scripts/test_stage11i.sh
```

Das Skript prüft zusätzlich die kompakte Prompt-Zeilengrenze, die Integrität der Goldendateien und Python↔Mojo-Parität. Die langen Gesamtbuilds `scripts/build-heavy.sh` und `scripts/build.sh` sind dafür nicht erforderlich.


## Stage 11j: Getrennter Thread-Prepare-Build

`parallel_execution.mojo` ist durch zehn ältere Kernfamilien bereits compilerseitig groß. Der typisierte Prepare-Pfad liegt deshalb in `table_preparation.mojo` und `parallel_row_preparation.mojo` und wird als eigenes Ziel `reta-mojo-row-preparation` gebaut. Dadurch muss eine Änderung an der Zeilenvorbereitung nicht sämtliche übrigen Zahlen- und Tabellenkerne erneut elaborieren.

```bash
./scripts/test_stage11j.sh
./scripts/benchmark_parallel_row_preparation.sh 20000 8 128
```

Die fokussierten Befehle dürfen mit längeren Zeitlimits ausgeführt werden. Die vollständigen Skripte `scripts/build-heavy.sh` und `scripts/build.sh` werden für das Übergabearchiv nicht erneut benötigt und können auf dem Zielsystem gebaut werden.


## Stage 12b: nativer `--alles`-HTML-Pfad

Der reguläre Build erzeugt `generate-html-native` ohne Python- oder Subprozessimport. Der reproduzierbare Plan- und Loader-Test ist klein und kann getrennt ausgeführt werden:

```bash
./scripts/check_all_columns_plan.sh
./scripts/test_stage12b.sh
```

Nach `scripts/build.sh` vergleicht `scripts/check_html_parity.sh` die native Ein-Zeilen-Mitteltabelle mit dem eingefrorenen CPython-Referenzfixture mit 805 Daten-/Generatorspalten.


## Stage 12c1–12c4f: Terminalbreite, nativer TTY-Editor, native-first Kompatibilität, Ausgabe-, Kindprozess- und Bruchgrenzen

Für die vollständige Kompilierung genügen ausschließlich:

```bash
./scripts/build-heavy.sh
./scripts/build.sh
```

Die `check_*`- und `test_*`-Skripte sind keine Buildvoraussetzung. Sie prüfen
optional die erzeugten Programme gegen Referenzfixtures. Für alle bisherigen
Stage-12c-Prüfungen genügt ein einzelner Aufruf:

```bash
./scripts/test_stage12c.sh
```

`test_stage12c.sh` ruft `check_native_prompt_input.sh`,
`check_prompt_external_commands.sh`, `check_prompt_mixed_reciprocal_parity.sh`, `check_prompt_classic_fraction_parity.sh`, `check_compat_launcher.sh`, die beiden Gruppen von `check_compat_native_first_parity.sh` und `check_prompt_terminal_parity.sh`
bereits selbst auf. Ein zusätzlicher separater Aufruf dieser Stage-Prüfungen wäre
nur eine Wiederholung.

Der Promptcontroller besitzt seit Stage 12c4d keine `std.python`-Brücke mehr. Kleine Editor-, History- und PTY-Probes prüfen UTF-8, verschachtelte Completion, Mehrzeilen-Wrapping, Emacs-/Vi-Kernbindings, Ctrl-C/Ctrl-D und zwei aufeinanderfolgende Rohmodussitzungen. Der öffentliche PTY-Test verwendet unverändert `bin/rpb a1`; es gibt keinen Ersatzbefehl für die Laufzeitsemantik.

Der historische Tabellenlauncher ist seit Stage 12c4e native-first und bindet kein `libpython`. `RETA_FORCE_REFERENCE=1` erzwingt den atomaren Referenzkindprozess; ohne Override entscheidet der strenge Ganzvektor-Ownership-Test. `scripts/check_compat_launcher.sh` prüft Argumente, Binärströme und Exitstatus, während `scripts/check_compat_native_first_parity.sh` zwölf Referenzfälle mit absichtlich ungültigem `RETA_PYTHON` vergleicht. Stage 12c4f ergänzt `scripts/check_native_output_stream_parity.sh` für die vier Shell-Ein-Tabellen-Aliase, `justtext`, englische Syntax und Breite-null-No-wrap. Stage 12c4h ergänzt die formatübergreifende No-blank-Parität; Stage 12c4i prüft mit `scripts/check_paginated_rendering_parity.sh` sechs deutsche/englische Shell-/HTML-/BBCode-Mehrspaltenströme. Stage 12c4j ergänzt `scripts/check_column_widths_parity.sh` für positive individuelle Spaltenbreiten; Stage 12c4k ergänzt explizite Nullbreiten. Stage 12c4l prüft mit `scripts/check_markup_nocolor_parity.sh` den rohen HTML-/BBCode-Serializer in zwölf Bytefällen und mit `tests/test_mojo_runtime_path.py` die portable Laufzeitauflösung.
