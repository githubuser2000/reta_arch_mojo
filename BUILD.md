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
```

Die dreizehn Ziele enthalten sehr große generierte Konstantenstrukturen, Grenzgraphdaten, Architekturverträge, Witness-Matrizen, Kohärenzrouten, Trace-Netze, Impact-Routen, Migrationspläne, Rehearsal-Gates, Aktivierungstransaktionen, Gesamtvalidierungschecks und das Fortschritts-Overlay. Sie sind nicht für jeden normalen Build erforderlich; die Laufzeitpfade verwenden kompakte Katalogdateien.

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
