# Build und Tests – Stage 12c5bh

Der vollständige Produktionsbuild bleibt absichtlich ein Vollbuild:

```sh
scripts/build-all.sh
```

Eine inkrementelle Zielauswahl ist nicht aktiviert. Ohne compilergetreuen
Abhängigkeitsgraphen wäre sie nicht zuverlässig genug. Einzelne Ausgaben werden
jedoch atomar veröffentlicht: Der Compiler schreibt in eine temporäre Datei;
erst nach ELF-Prüfung, RUNPATH-Bereinigung und Inhaltsmarkierung ersetzt sie das
vorherige Ziel. `build-all.sh` prüft abschließend sämtliche regulären und
schweren Ziele.

## Compileroptionen für alle Produktionsziele

Alle drei Produktions-Baueinstiege akzeptieren zusätzliche Optionen für
`mojo build`. Der empfohlene Trenner `--` hält Skriptoptionen und
Compileroptionen eindeutig auseinander:

```sh
scripts/build.sh -- [MOJO_BUILD_OPTION ...]
scripts/build-heavy.sh [--optimize-heavy] -- [MOJO_BUILD_OPTION ...]
scripts/build-all.sh [--optimize-heavy] -- [MOJO_BUILD_OPTION ...]
```

Beispiele:

```sh
# Reguläre Ziele mit Optimierungsstufe 2
scripts/build.sh -- --optimization-level 2

# Vollbuild mit explizitem CPU-Modell und acht Compilerjobs
scripts/build-all.sh -- --target-cpu <CPU-NAME> -j 8

# Optimierungsstufe 2 auch für die sonst absichtlich mit O0 gebauten Schwerziele
scripts/build-all.sh --optimize-heavy -- --optimization-level 2 -j 8
```

`--optimization-level` akzeptiert 0 bis 3; Mojos Standard ist 3 und
`--no-optimization` entspricht 0. Einige sehr große Metadatenziele bleiben
standardmäßig bewusst bei O0, selbst wenn für den übrigen Build ein anderer
Grad angegeben wurde. `--optimize-heavy` entfernt diese lokale
Sicherheitsvorgabe. Alternativ kann `RETA_HEAVY_DEFAULT_NO_OPT=0` gesetzt
werden.

Die Optionen werden bytegetreu, also auch mit getrennten Werten und
Leerzeichen, an jedes reguläre und schwere Mojo-Ziel sowie an die gemeinsame
Mojo-Diagnosebibliothek weitergereicht. Der kleine C-Diagnoseloader behält
seine getrennten C-Optionen. Quellpfad, Ausgabeart, Ausgabedatei, RUNPATH und
atomare Veröffentlichung bleiben Eigentum der Skripte.

Eine Compiler-Threadoption darf nur einmal vorkommen. Bei `-j 8`, `--jobs=8`
oder `--threads 8` unterdrückt der Benutzerwert das lokale `-j 4` der drei
besonders großen Threadziele. Ohne Benutzerwert bleibt dieser konservative
Default erhalten. Zwei explizite Threadoptionen werden vor dem ersten
Compileraufruf mit Exitstatus 2 abgelehnt, statt Mojos spätere Meldung
`Number of threads can only be specified once` zu provozieren.

Die jeweilige Hilfe zeigt die Schnittstelle direkt:

```sh
scripts/build.sh --help
scripts/build-heavy.sh --help
scripts/build-all.sh --help
```

Der aktuelle fokussierte Compilerlauf durchläuft die vollständige Stage-Kette,
prüft die nativen Legacy-Startpfade und den monotonen Obergrenzenvertrag sowie
die compilerunabhängige Argumentweitergabe der Build-Skripte:

```sh
scripts/test_stage12c5ba.sh
```

Die vollständige Testsuite erkennt drei systemnahe Linkerklassen automatisch: Persistenztests verwenden `-lsqlite3 -lcrypto`, Paketintegrität verwendet `-lcrypto`, alle übrigen Tests erhalten keine zusätzlichen Linkerflags. Kompilierung und Ausführung sind getrennt wiederverwendbar:

```sh
scripts/build-tests.sh -- -j 4
scripts/run-tests.sh --jobs 4
```

Der bisherige Gesamteinstieg bleibt kompatibel:

```sh
scripts/test_all.sh
```

`run-tests.sh --jobs N` parallelisiert ausschließlich als sicher klassifizierte Laufzeittests. Tests mit festen temporären Dateien und besonders ressourcenintensive Ziele bilden serielle Barrieren. Mehrere eigenständige Mojo-Compilerprozesse bleiben standardmäßig sequenziell; kontrollierte interne Compilerthreads können über `scripts/build-tests.sh -- -j N` gesetzt werden. Der kombinierte Einstieg trennt beide Regler ausdrücklich: `scripts/test_all.sh --heavy --run-jobs 4 -- -j 4`.

## Grundsatz

`bin/` enthält kleine, versionierbare POSIX-Launcher. Echte Mojo-Compilerprodukte entstehen ausschließlich unter `target/bin/` und werden durch `.gitignore` ausgeschlossen.

```text
bin/                     versionierte Launcher
target/bin/              reguläre ELF-Executables
target/lib/mojo/         lokale Links oder portable Kopien der Mojo-Laufzeit
target/lib/reta/         projektinterne Shared Libraries
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

`setup_mojo.sh` führt standardmäßig `scripts/build-all.sh` aus. Für einen
bewusst nur regulären Erstbuild kann `RETA_BUILD_SCOPE=regular` gesetzt werden.

`setup_mojo.sh` installiert auch die Python-Testabhängigkeiten. Bei einer bereits vorhandenen Mojo-`.venv` werden sie separat ergänzt:

```bash
./scripts/setup_test_dependencies.sh
# oder direkt mit uv:
uv pip install --python .venv/bin/python3 -r requirements-test.txt
```

`pytest` wird von den Python-Source- und Paritätsprüfungen verwendet; es ist keine Mojo-Bibliothek. Shelltests starten Pytest ausschließlich über `scripts/run_pytest.sh`, das einen Interpreter mit importierbarem `pytest` auswählt.

Die Meldung `Failed to initialize Crashpad` wird vom Modular-Werkzeug ausgegeben, wenn dessen optionaler Crash-Reporter fehlt. Solange der folgende Mojo-Prozess normal weiterläuft und sein Exitstatus erfolgreich ist, ist dies keine reta-Testniederlage. Die Projektwrapper filtern stderr absichtlich nicht global.

## Referenzinterpreter

Die Compiler-`.venv` ist nicht der bevorzugte Interpreter für die eingefrorene
Python-Referenz. `scripts/select_reference_python.sh` wählt explizite
`RETA_REFERENCE_PYTHON`-/`RETA_PYTHON`-Vorgaben, danach `pypy3`, dann
`python3`; `.venv/bin/python` bleibt nur ein letzter Fallback.

## Portable Mojo-Laufzeit

Mojo-ELF-Dateien benötigen `libKGENCompilerRTShared.so` und
`libAsyncRTMojoBindings.so`. Das ist unabhängig von den CSV-Dateien. Absolute
Compilerpfade im ELF-`RUNPATH` sind zwischen Rechnern nicht portabel; deshalb
betten alle Builds zusätzlich `$ORIGIN/../lib:$ORIGIN/../lib/mojo` ein und richten den
projektrelativen Ort `target/lib/mojo` ein.

```bash
./scripts/configure_mojo_runtime.sh
# für einen übertragbaren Target-Baum:
RETA_MOJO_RUNTIME_MODE=copy ./scripts/configure_mojo_runtime.sh
./scripts/export_target.sh target target-portable.tar.xz
```

Die automatische Erkennung kann bei Bedarf überschrieben werden:

```bash
RETA_MOJO_RUNTIME_LIBDIR=/pfad/zu/modular/lib \
  ./scripts/configure_mojo_runtime.sh
```

Die öffentlichen Launcher verwenden zusätzlich `bin/mojo-runtime-exec`. Damit
laufen auch ältere übernommene ELF-Dateien, deren einzig vorhandener `RUNPATH`
noch auf den Rechner zeigt, auf dem sie kompiliert wurden.

## Vollständiger Build

```bash
./scripts/build-all.sh
```

Dies ist der einzige vollständige Produktions-Baueinstieg. Er führt zuerst
`scripts/build-heavy.sh` und danach `scripts/build.sh` aus. Die gemeinsame
Diagnosebibliothek `libreta_diagnostics_mojo.so` gehört bereits zum regulären
`scripts/build.sh`; kein `test_stage*.sh` muss nach einem erfolgreichen Build
zusätzlich aufgerufen werden.

Stage-Skripte prüfen Verhalten und dürfen höchstens isolierte Programme unter
`target/tests*` erzeugen. Das einzige kombinierte Build-/Testwerkzeug heißt
absichtlich `scripts/build-and-test-shared-diagnostics.sh`: Es ist optional und
baut vier frühere Einzelprogramme nur als temporäre Paritätsorakel.

## Regulärer Build

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Erzeugt werden zwanzig reguläre Executables und eine Shared Library:

```text
target/bin/reta-mojo-native
target/bin/reta-mojo-table
target/bin/reta-mojo-tags
target/bin/reta-mojo-i18n
target/bin/reta-mojo-package-integrity
target/bin/reta-mojo-exports
target/bin/reta-mojo-facade
target/bin/reta-mojo-workflow
target/bin/reta-mojo-sheaves
target/bin/reta-mojo-diagnostics
target/lib/reta/libreta_diagnostics_mojo.so
target/bin/reta-mojo-domain-probe
target/bin/reta-mojo-combi-join
target/bin/reta-native
target/bin/reta-mojo-compat-bin
target/bin/reta-prompt-native
target/bin/reta-prompt-complete
target/bin/grundStrukHtml-native
target/bin/generate-html-native
target/bin/generate-readme-native
target/bin/reta-extract-html-classes-native
```

`reta-prompt-complete` bleibt als persistenter eigenständiger Completion-Arbeiter und Kompatibilitäts-/Testziel erhalten. Der reguläre interaktive Prompt verwendet seit Stage 12c4d Completion direkt im nativen TTY-Editor und benötigt weder diesen Arbeiter noch eingebettetes CPython. `reta-mojo-table` ist bewusst leicht und enthält Tabellenzustand, Wrapping und CSV-Inspektion. Das vollständige Tag-Schema liegt in `reta-mojo-tags`; der fünfsprachige `i18n.words`-Baum ist über `reta-mojo-i18n` separat prüfbar. Diese Trennung vermeidet einen unnötigen Compiler-Monolithen.

## Schwere generierte Ziele

```bash
./scripts/build-heavy.sh
RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh
```

Das erzeugt zusätzlich:

```text
target/bin/reta-mojo-semantics
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

Die achtzehn Ziele enthalten sehr große generierte Konstantenstrukturen, Grenzgraphdaten, Architekturverträge, Witness-Matrizen, Kohärenzrouten, Trace-Netze, Impact-Routen, Migrationspläne, Rehearsal-Gates, Aktivierungstransaktionen, Gesamtvalidierungschecks, das Fortschritts-Overlay, die native SQLite-Persistenz, das deterministische Thread-Ausführungsnetz, die typisierten Thread-Chunk-Kerne und die typisierte Thread-Zeilenvorbereitung. Sie sind nicht für jeden normalen Build erforderlich; die Laufzeitpfade verwenden kompakte Katalogdateien.

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

### Adaptive Laufzeitparallelität der Tabellenpipeline

Der native `reta`-Pfad verwendet pro Phase genau **eine** Parallelitätsachse:

- mehrere unabhängige Generatoraufträge: Spalten/Aufträge parallel, Zeilen innerhalb des Auftrags seriell;
- genau ein großer, zeilenunabhängiger Generatorauftrag: Zeilen-Chunks parallel;
- Shell, BBCode, CSV, Markdown, Emacs und einfaches HTML: Zeilenblöcke in privaten Puffern parallel;
- Seitenplanung, Spaltenbreiten, endgültige Tabellenmutation und Ausgabe-Writer: seriell;
- zustandsabhängige Primzahlwirkungs-Zeilen: innerhalb einer Spalte seriell, mehrere Wirkungsspalten jedoch parallel.

Es werden keine verschachtelten Worker-Pools erzeugt. Chunk-Ergebnisse liegen in indexierten Slots und werden immer in Quellreihenfolge zusammengefügt. Die Laufzeitsteuerung erfolgt beispielsweise so:

```bash
reta --parallel --parallel-workers=8 --parallel-chunk-size=64 \
  --parallel-threshold=128 -spalten --alles -ausgabe --art=shell

RETA_PARALLEL=threads RETA_PARALLEL_WORKERS=8 \
RETA_PARALLEL_CHUNK_SIZE=64 RETA_PARALLEL_THRESHOLD=128 reta ...
```

`--no-parallel` erzwingt den seriellen Referenzpfad. `scripts/run-tests.sh --jobs N` besitzt weiterhin ein eigenes globales Limit; Tests, die intern Workerthreads verwenden, werden im Manifest als exklusive Barrieren markiert.


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

### Prompt-Interaktionsgate (Stage 12c5a)

```bash
scripts/test_stage12c5a.sh
RETA_BUILD_PROMPT=1 scripts/test_stage12c5a.sh
```

Der erste Befehl baut und prüft das kleine native Interaktionsmodul sowie die
Paritäts- und Source-Gates. Die Variable aktiviert zusätzlich den großen
produktiven Promptlink, der auf schwächeren oder begrenzten Buildumgebungen
deutlich länger als die Modulprüfung dauern kann.


## Stage 12c4m: Installation unter `/usr/local`

Unveränderliche CSV- und Katalogdaten werden nicht in `bin` oder `lib`
installiert. Das FHS-konforme Standardlayout einer manuellen Installation ist:

```text
/usr/local/bin
/usr/local/lib
/usr/local/share/reta/csv
/usr/local/share/reta/assets
```

Nach dem Build, Shell-Variante:

```bash
sudo ./scripts/install.sh
```

Pixi-Variante:

```bash
pixi run build-all
sudo ./scripts/install.sh
```

`sudo pixi run install` wird vermieden, damit Pixi-Umgebung und Cache nicht als root laufen.

CMake-Variante:

```bash
pixi run cmake-configure
pixi run cmake-build
sudo cmake --install build
```

Ein Staging-Verzeichnis für lokale Pakete verwendet ebenfalls standardmäßig
den Präfix `/usr/local`:

```bash
DESTDIR="$pkgdir" PREFIX=/usr/local ./scripts/install.sh
```

Dann liegen die Tabellen unter `/usr/local/share/reta/csv`. Der alte
Python-Referenz-/Kompatibilitätsbaum wird in den nativen Profilen nicht mehr
mitinstalliert; `python_reference` bleibt standardmäßig Quell-, Test- und
Portierungsmaterial im Projektbaum. Nur der explizite Sonderfall
`scripts/install.sh --reference` kopiert ihn nach
`/usr/local/share/reta/python_reference`. Im alten privaten Library-Ordner
`/usr/local/lib/reta` wird nichts Neues mehr abgelegt; `python_reference`,
private `bin/`- und `scripts/`-Verzeichnisse werden dort entfernt.
Öffentliche Befehle und Wrapper liegen direkt unter `/usr/local/bin`; echte
Shared Libraries und die optionale Mojo-Laufzeit liegen flach unter
`/usr/local/lib`. Die privaten ELFs werden nicht mehr per Wildcard kopiert,
sondern ausschließlich aus der Ziel-Allowlist `scripts/install_targets.txt`;
dadurch gelangen keine lokalen Alt-/Debugziele ins Paket. Installierte
Symlink-Depots werden vermieden.

Benutzerinstallation ohne Administratorrechte:

```bash
PREFIX="$HOME/.local" ./scripts/install.sh
```

Optionales Fedora-/RPM-Override, nur wenn ein Distributionspaket ausdrücklich `/usr` verlangt:

```bash
DESTDIR="$RPM_BUILD_ROOT" PREFIX=/usr LIBEXECDIR=/usr/libexec/reta \
  ./scripts/install.sh
```

Der normale manuelle Projektweg bleibt `/usr/local`.

Prüfung des vollständigen Staging-Vertrags:

```bash
./scripts/check_resource_paths.sh
./scripts/check_install_layout.sh
./scripts/run_pytest.sh -q tests/test_install_layout.py tests/test_mojo_runtime_path.py
```

Deinstallation verwendet dieselben `PREFIX`, `DESTDIR`, `BINDIR`,
`LIBDIR`, `LIBEXECDIR` und `DATADIR`-Werte. `LIBEXECDIR` ist nur noch ein Legacy-Cleanup-Pfad; neue Shared Libraries liegen in `LIBDIR`:

```bash
sudo ./scripts/uninstall.sh
```

## Portabler ELF-RUNPATH

Mojo 1.0.0b2 ergänzt beim Linken automatisch den absoluten Pfad seiner lokalen
`modular/lib`-Installation. Die Buildskripte rufen deshalb nach jedem Ziel
`tools/sanitize_mojo_runpath.py` auf. Der ELF-Stringtabelleneintrag wird ohne
Verschieben anderer Daten auf den portablen Vertrag gekürzt:

```text
$ORIGIN/../lib:$ORIGIN/../lib/mojo
```

Prüfung eines vorhandenen Binaries:

```bash
python3 tools/sanitize_mojo_runpath.py --check target/bin/reta-native
readelf -d target/bin/reta-native | grep RUNPATH
```

Der Runtime-Starter `mojo-runtime-exec` bleibt für ältere, noch nicht
sanitisierte Binärdateien erhalten.

## Installierbares `generate_html`

Nach `scripts/build.sh` und `scripts/install.sh` liegt der öffentliche
Starter unter `/usr/local/bin/generate_html`, das native Mojo-ELF unter
`/usr/local/bin/generate-html-native` und die Manpage unter
`/usr/local/share/man/man1/generate_html.1`.

```sh
generate_html --help
generate_html --output reta.html --language english
generate_html --middle-file middle.alx --output reta.html
```

Das Kommando arbeitet aus jedem Verzeichnis, schreibt ohne Option nach stdout
und erzeugt keine implizite `middle.alx`.

## Native Quellbaum-Integrität

Der normale Build erzeugt zusätzlich `target/bin/reta-mojo-package-integrity`:

```sh
./scripts/build.sh
./bin/reta-mojo-package-integrity --summary python_reference
./bin/reta-mojo-package-integrity --json-files python_reference
```

Dieses Ziel wird mit OpenSSL/libcrypto (`-lcrypto`) gelinkt. Auf Fedora/Gentoo
muss deshalb der jeweilige OpenSSL-Entwicklungsumfang mit dem Linker-Symlink
für `libcrypto.so` installiert sein. Die Dateibaumgrenze verwendet direkt
`realpath`, `opendir`, `readdir`, `readlink` und `closedir`; Filterung,
Sortierung, Dateilesen, CSV-Zählung, SHA-256-Gesamtdigest und JSON-Ausgabe
laufen nativ in Mojo. Es wird kein Hilfsprozess gestartet. Die fokussierte
Prüfung lautet:

```sh
MOJO_BIN="$(pwd)/.venv/bin/mojo" ./scripts/test_stage12c5c.sh
```



## Native Parametersemantik

Der schwere Build erzeugt `target/bin/reta-mojo-semantics`:

```sh
./scripts/build-heavy.sh
./bin/reta-mojo-semantics --normal
./bin/reta-mojo-semantics --invert
```

Der Katalog wird reproduzierbar aus der Python-Referenz erzeugt, aber das
installierte Programm baut und prüft die vollständige Semantik ohne Python.
Das fokussierte Gate kompiliert Normal- und Inversionsprobe getrennt, um eine
doppelte Materialisierung des 431-Familien-Katalogs im Compiler zu vermeiden:

```sh
MOJO_BIN="$(pwd)/.venv/bin/mojo" ./scripts/test_stage12c5f.sh
```

## Sourcearchiv für weitere Transpilierungsrunden

Nicht den lokalen Buildbaum mitsenden, sondern:

```bash
./scripts/create_source_archive.sh ../reta_arch_mojo_source.tar.xz
```

Das Archiv enthält Quellen, Referenzimplementierung, Daten, Tests und Generatoren, aber kein `target/`, `.venv/`, `.git/`, Buildverzeichnis oder Cache. Die genaue Einteilung steht in `PROJECT_CONTENT_PROFILES.md`.

## Build-Frische nach source-only Aktualisierungen

Quellarchive enthalten kein `target/`. Ein altes lokales ELF kann daher beim
Entpacken bestehen bleiben. `scripts/build.sh` und `scripts/build-heavy.sh`
schreiben ab Stage 12c5s neben jedes neu erzeugte Programm eine
`*.reta-source-id`-Datei. `bin/mojo-runtime-exec` vergleicht sie mit dem
aktuellen `SOURCE_MANIFEST.sha256` und mit den Änderungszeiten unter `src/`.

Nach dem Einspielen eines neuen Archivs ist deshalb einmal auszuführen:

```bash
scripts/build.sh
# nur für die optionalen schweren Ziele zusätzlich:
scripts/build-heavy.sh
```

Ein veraltetes Binary wird nicht gestartet, sondern mit Exitcode 78 und einer
Neubau-Anweisung abgewiesen.

## Native Prägarben und Garben

Der reguläre Build erzeugt `target/bin/reta-mojo-sheaves`. Das Programm lädt
die reproduzierbaren lokalen Sektionen und die globale HTML-/Parametergarbe:

```bash
./scripts/build.sh
./bin/reta-mojo-sheaves --summary
./bin/reta-mojo-sheaves --presheaf csv
./bin/reta-mojo-sheaves --html 4
```

Das fokussierte Build-/Paritätsgate lautet `scripts/test_stage12c5t.sh`.


## Native Tabellen-Gluing-Diagnose

Der reguläre Build stellt `bin/reta-mojo-table-generation` über den gemeinsamen Diagnose-Loader bereit:

```bash
scripts/build.sh
bin/reta-mojo-table-generation --summary
scripts/test_stage12c5u.sh
```

Bis Stage 12c5y bestanden 23 reguläre und 18 schwere Einzel-Executables. Stage 12c5z ersetzt vier Diagnose-Executables durch einen Loader und eine Shared Library. Mit Stage 12c5ak entstehen standardmäßig **21 reguläre plus 18 schwere Executables sowie eine gemeinsame Bibliothek**. Die vier alten Einzelziele bleiben mit `RETA_BUILD_STANDALONE_DIAGNOSTICS=1` als optionale Paritätsorakel baubar.


## Native Ausgabe-Semantik und Syntax (Stage 12c5v)

Der reguläre Build stellt `bin/reta-mojo-output-syntax` über den gemeinsamen Diagnose-Loader bereit. Die Oberfläche
prüft die vollständigen Besitzer von `output_semantics.py` und
`output_syntax.py`:

```bash
bin/reta-mojo-output-syntax --summary
bin/reta-mojo-output-syntax --canonical markdown
bin/reta-mojo-output-syntax --apply csv 33 false true
scripts/test_stage12c5v.sh
```

Der Stage-Test vergleicht die sieben Modi, Syntaxklassennamen, Flags, Aliase,
Snapshotbesitzer und die optionale Breiten-Callbacksemantik mit der
Python-/PyPy3-Referenz.

## Vollständige Eingabesemantik (Stage 12c5w)

Nach einem neuen Source-Archiv prüft das Stage-Gate zuerst denselben vollständigen Importgraphen wie `scripts/build.sh` und danach die Eingabesemantik:

```bash
scripts/test_stage12c5w.sh
```

Die wiederholte Modular-Meldung `Failed to initialize Crashpad` ist nicht der Buildabbruch; erfolgreich erzeugte Ziele bleiben gültig. Maßgeblich ist die erste nachfolgende `error:`-Diagnose. Stage 12c5w schließt den gemeldeten reservierten Bezeichner `alias` und vergleicht anschließend den 18-Felder-Vokabularsnapshot mit Python beziehungsweise PyPy3. Für Paketierungs- oder Layoutprüfungen kann die Quelle obligatorischer Binaries mit `RETA_TARGET_DIR=/pfad/zu/target/bin scripts/install.sh` explizit gesetzt werden.

Der FHS-Installer installiert im Standardprofil keine privaten Skriptbäume mehr. `mojo-runtime-exec` gehört nur zu den Zusatzprofilen; normale Nutzerbefehle liegen direkt unter `PREFIX/bin`.

## Vollständiges Console-IO und Modulimportprüfung (Stage 12c5x)

Der reguläre Build stellt `bin/reta-mojo-console-io` über den gemeinsamen Diagnose-Loader bereit. Die Oberfläche
deckt Chunking, geordnete Eindeutigkeit, Console-Effektplanung, beide Hilfetexte,
Terminalkontext und den geordneten Default-Container ab:

```bash
scripts/build.sh
bin/reta-mojo-console-io --summary
bin/reta-mojo-console-io --chunks 2 a b c d e
scripts/test_stage12c5x.sh
```

Der Stage-Test kompiliert zuerst `src/main.mojo` und danach ausdrücklich
`src/table_generation_main.mojo`. Zusätzlich prüft ein compilerunabhängiger
Resolver alle 260 relativen Importe in `src/reta_mojo`; dadurch wird eine
Abweichung wie `.kombi_join` gegenüber der vorhandenen Datei
`combi_join.mojo` vor dem Modular-Parserlauf erkannt.



## Vollständiger TableOutput-Besitzer (Stage 12c5y)

```bash
scripts/test_stage12c5y.sh
```

Der Test baut den vollständigen Paketimportgraph, `table_output_main.mojo`, den vollständigen TableOutput-Modultest und erneut die zugrunde liegende Renderer-Suite. Anschließend vergleicht er Bundle-Snapshot, Spaltenprojektion und ANSI-Farbpolitik mit Python beziehungsweise PyPy3. Der öffentliche Name `reta-mojo-table-output` bleibt bestehen; seit Stage 12c5z wird er durch den gemeinsamen Diagnose-Loader und die Shared Library umgesetzt.


## Gemeinsame Diagnosebibliothek (Stage 12c5z)

Der produktive Build erfolgt bereits mit:

```bash
scripts/build.sh
# oder vollständig einschließlich schwerer Ziele:
scripts/build-all.sh
```

Die optionale tiefe Alt-vs.-Shared-Library-Parität lautet:

```bash
scripts/build-and-test-shared-diagnostics.sh
```

Der Standardbuild erzeugt `target/bin/reta-mojo-diagnostics` und `target/lib/reta/libreta_diagnostics_mojo.so`. Die vier bisherigen Launcher für TableGeneration, OutputSyntax, ConsoleIO und TableOutput bleiben unverändert öffentlich, leiten aber auf den gemeinsamen Loader weiter. Die Shared Library trägt `$ORIGIN:$ORIGIN/mojo:$ORIGIN/../mojo`, während Executables `$ORIGIN/../lib:$ORIGIN/../lib/mojo` verwenden. Für direkte Alt-vs.-Bibliothek-Parität können die vier Einzelprogramme mit `RETA_BUILD_STANDALONE_DIAGNOSTICS=1` zusätzlich gebaut werden. Ein transferierbarer Binärbaum wird mit `scripts/export_target.sh` erzeugt.

## Fokussierter Stage-12c5ab-Compilerlauf

Nach `scripts/build-all.sh` ist für die neue Legacy-Prompt-Fassade keine
weitere Produktionsdatei zu bauen. Die optionale Prüfung erzeugt nur
Testartefakte unter `target/tests`:

```bash
scripts/test_stage12c5ab.sh
```

Sie prüft zugleich den korrigierten Prepare-Wrappingvertrag und die
Python-/Mojo-Parität der 48-Namen-Fassade.
## Fokussierte Stage-12c5ac-Prüfung

Nach dem normalen Produktionsbuild kann die vollständige Prompt-Preparation-Fassade gezielt geprüft werden:

```bash
./scripts/test_stage12c5ac.sh
```

Das Skript baut ausschließlich Modultest und Snapshotprobe unter `target/tests`; es erzeugt keine installierbaren Programme oder Shared Libraries.

## Stage 12c5ad: fokussierter Build-/Testzyklus

Der normale Entwicklungszyklus nach dieser Stage ist:

```bash
scripts/build-all.sh
scripts/test_stage12c5ad.sh
```

`test_stage12c5ad.sh` baut nur kurzlebige Testprogramme unter `target/tests`.
Die vollständige native Mojo-Testprogrammsuite ist nicht nach jedem kleinen
Patch nötig, sondern vor Releases oder nach mehreren Stages. Kompilierung und
Ausführung können getrennt wiederverwendet werden:

```bash
scripts/build-tests.sh
scripts/run-tests.sh
```

Die beiden besonders schweren Compilerziele werden nur explizit ergänzt:

```bash
scripts/build-tests.sh --heavy
# oder weiterhin als kombinierter Aufruf:
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

Die Ausführung bleibt standardmäßig sequenziell. Kontrollierte Parallelität
gilt nur für die als sicher klassifizierten Laufzeittests:

```bash
scripts/run-tests.sh --jobs 2
RETA_TEST_RUN_JOBS=2 scripts/test_all.sh
```

`run-tests.sh` führt jedes Testbinary über `bin/mojo-runtime-exec` aus und
prüft vorher das von `build-tests.sh` erzeugte Inhaltsmanifest. Tests mit
festen `/tmp`-Namen und bekannte sehr lange oder speicherintensive Ziele
bilden serielle Barrieren.

## Stage 12c5bi: Testcompileroptionen und korrigierte Promptachsen

Compilerthreadzahl und Laufzeitparallelität sind getrennte Parameter:

```bash
scripts/build-tests.sh --heavy -- -j 4
scripts/run-tests.sh --jobs 4
# kombiniert:
scripts/test_all.sh --heavy --run-jobs 4 -- -j 4
```

Optionen hinter `--` gehen unverändert an jeden einzelnen sequenziellen
`mojo build`-Aufruf. `--run-jobs` betrifft nur fertige Testprogramme. Der
fokussierte Stage-Lauf akzeptiert denselben Compilervektor:

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bi.sh -- -j 4
```

## Architekturprobe

Der reguläre Vollbuild erzeugt zusätzlich:

```text
target/bin/reta-mojo-architecture-probe
```

Die Probe lädt 63 reproduzierbare JSON-/Markdown-Assets und berechnet
`package-integrity-json` dynamisch nativ. Prüfung:

```sh
scripts/test_stage12c5ak.sh
```


## Stage 12c5al – Legacy-I18n-Katalog prüfen

```sh
scripts/test_stage12c5al.sh
```

Der Test regeneriert 68.265 Katalogzeilen, kompiliert den gemeinsamen nativen
I18n-Besitzer und vergleicht alle fünf Sprachdateien bytegenau.

## Stage 12c5ao – Besitz- und Kompatibilitätsprüfung

```sh
./do.sh 12c5ao
```

Der Stage-Test führt die komplette 12c5an-Kette als Voraussetzung aus. Damit
wird insbesondere der früher beim `CsvTable`-Kopieren abgebrochene
Generated-Columns-Test erneut mit dem Modular-Compiler gebaut. Anschließend
werden `test_legacy_reta_program.mojo` und `test_setup_metadata.mojo` gebaut.
Die neuen Fassaden erzeugen keine zusätzlichen installierbaren Executables.

## Stage 12c5bj: gepinnter, read-only Kommando-Paritätsgate

Der reguläre Stage-Lauf prüft ausschließlich die versionierten Assethashes:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bj.sh -- -j 4
```

Der aktuelle Python-Renderer kann separat untersucht werden, ohne Assets zu verändern:

```sh
TEST_PYTHON=$(scripts/find_test_python.sh)
"$TEST_PYTHON" tools/generate_command_parity_assets.py --check-reference
```

`--check-reference` ist bewusst kein Releasegate, da beiläufige CPython-Minorversionsunterschiede die HTML-Serialisierung beeinflussen können. Eine echte Assetaktualisierung muss als eigener überprüfter Commit erfolgen.

### Stage 12c5bj: typisierte Teilerprojektion

Der True-Fraction-Teilerpfad materialisiert `Set[Int]` vor dem Aufruf des
`List[Int]`-Divisorreihenfolgehelfers. Der aktuelle Stage-Test kompiliert den
zugehörigen Probe auch mit `RETA_STAGE_SKIP_PREVIOUS=1`; Compileroptionen werden
weiter hinter `--` durchgereicht.

## Stage 12c5bk: hermetische Parität und Bruchguards

Nach dem Vollbuild:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bk.sh -- -j 4
```

Der Stage-Test überschreibt für die native Kommando-Parität absichtlich alle `RETA_*`-Ressourcenpfade mit ungültigen Werten. Der Prüfer muss sie intern auf den aktuellen Source-Tree normalisieren und 4/4 Fälle bestehen. Anschließend wird der True-Fraction-Probe mit denselben Compileroptionen gebaut und ausgeführt.

## Inkrementelle Testkompilierung ab Stage 12c5bk

Ein unveränderter Test wird nicht erneut kompiliert, wenn sein konservativer
Buildfingerabdruck identisch ist:

```sh
scripts/build-tests.sh --heavy -- -j 4
scripts/run-tests.sh --jobs 4
```

Der Fingerabdruck umfasst die Testdatei, transitiv importierte lokale
Mojo-Module, Compiler/Version, Plattform, Linkprofil, Buildoptionen und
buildrelevante Umgebungswerte. Das ist absichtlich strenger als ein
Zeitstempelvergleich. Ein vollständiger Neubau bleibt verfügbar:

```sh
scripts/build-tests.sh --rebuild-all --heavy -- -j 4
scripts/test_all.sh --rebuild-all --heavy --run-jobs 4 -- -j 4
```

## Stage 12c5bl prüfen

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bl.sh -- -j 4
```

Der Stage-Test prüft zuerst die native Kommando-Parität mit vollständig
abgetrenntem stdin und fester 80×24-Terminalgeometrie. Danach führt er den
gebündelten Python-Referenzprobe für die äußere klassische
Präfix-/Suffixordnung aus und kompiliert den vollständigen True-Fraction-Probe.
Die Python-Referenz wird nicht als Sollwert für ihr bekannt defektes inneres
Bruchrechteck verwendet.


## Pixi/CMake-Einstieg

Die neue Pixi/CMake-Schicht ist additiv. Die bewährten Shell-Skripte bleiben
zunächst die Quelle der Wahrheit; Pixi stellt die Umgebung und CMake benannte
Targets bereit. Details stehen in `docs/build-system/pixi-cmake-migration.md`.

Kurzeinstieg:

```sh
pixi run build-core-shared
pixi run test
pixi run cmake-configure
pixi run cmake-build-core-shared
```

Für nur `reta` und `libreta_core_mojo.so` bleibt der direkte alte Einstieg gültig:

```sh
scripts/build_core_shared.sh -- -j 8
```


### Pixi/CMake ohne Mojo-PyPI-Abhängigkeit

Mojo wird nicht von Pixi als PyPI-Abhängigkeit installiert. Pixi/CMake dienen
hier nur als reproduzierbare Task- und Orchestrierungsschicht über den
bestehenden Skripten. Vor einem Build kann die Toolchain ohne Kompilierung
geprüft werden:

```sh
pixi run check-toolchain
```

Falls noch ein alter Lockfile-Zustand vorhanden ist:

```sh
rm -f pixi.lock
pixi run check-toolchain
```

### Einheitliches Install-Layout

Die Shell-, Pixi- und CMake-Einstiege verwenden denselben Default-Prefix:
`/usr/local`. Die effektiven Pfade können ohne Installation angezeigt werden:

```sh
scripts/print_install_layout.sh
pixi run install-layout
pixi run cmake-install-layout
```

Die zentrale Vorgabe liegt in `scripts/reta_install_defaults.sh`.

## Zentrales Artefaktmanifest

Shell, Pixi und CMake teilen sich schrittweise eine zentrale Artefaktliste:

```sh
scripts/print_artifact_manifest.sh
pixi run artifact-manifest
cmake --build build --target reta-artifact-manifest
```

Die Datei `scripts/reta_artifacts.sh` ist die Namensquelle für öffentliche
Dünnstarter, reguläre native Ziele, schwere native Ziele und Shared Libraries.

### Release-Härtung: Installprofile und Bridge-Policy

Die letzten Release-Gates trennen normale Runtime, Diagnosewerkzeuge und die
alte Python-Referenz hart voneinander:

```sh
scripts/check_install_profile_matrix.sh
scripts/check_release_bridge_policy.sh
```

`check_install_profile_matrix.sh` prüft die kumulativen Profile `standard`,
`zusatz`, `all` und das getrennte Profil `reference` gegen Shell-, Pixi- und
CMake-Tasks. `check_release_bridge_policy.sh` verhindert, dass die native
Standardinstallation wieder versteckte Python-Referenzpfade, Diagnosebefehle
oder zusätzliche Shared Libraries bekommt. Beide Checks sind Teil von
`scripts/release_check.sh`.

### Artefaktmanifest als Release-Gate

`scripts/install_targets.txt` wird jetzt gegen `scripts/reta_artifacts.sh`
geprüft, damit Shell, Pixi und CMake dieselben Build-/Install-Zielnamen
verwenden:

```sh
scripts/check_artifact_manifest_consistency.sh
pixi run check-artifact-manifest
cmake --build build --target reta-check-artifact-manifest
```

Der Release-Plan kann ohne Ausführung angezeigt werden:

```sh
pixi run release-plan
cmake --build build --target reta-release-plan
```

## Einheitliche Build-Defaults

Shell, Pixi und CMake bekommen jetzt eine gemeinsame Default-Schicht für die
häufigsten Build-Parameter. Die direkten historischen Skripte bleiben gültig;
Pixi und CMake gehen über den zentralen Wrapper `scripts/run_build_task.sh`.

Defaults anzeigen:

```sh
scripts/print_build_defaults.sh
pixi run build-defaults
cmake --build build --target reta-build-defaults
```

Zentrale Datei:

```text
scripts/reta_build_defaults.sh
```

Wichtige Defaults:

```text
RETA_MOJO_JOBS=8
RETA_TEST_RUN_JOBS=1
RETA_TEST_RUN_PARALLEL_JOBS=4
RETA_TEST_RUN_TIMEOUT=0
RETA_CMAKE_BUILD_DIR=build
RETA_CMAKE_GENERATOR=Ninja
```

Der Wrapper ergänzt `-j $RETA_MOJO_JOBS` nur dann, wenn der Aufruf noch keine
Mojo-Threadoption enthält. Explizite lokale Aufrufe bleiben also möglich:

```sh
scripts/run_build_task.sh build-core-shared --target-cpu native
scripts/run_build_task.sh build-core-shared -j 4
```

## Planmodus ohne Build oder Installation

Die Pixi- und CMake-Einstiege besitzen einen Dry-Run/Planmodus.  Er zeigt die
effektiven Wrapper-Kommandos an, führt aber keinen Mojo-Build, keine Tests und
keine Installation aus.

```sh
pixi run plan-build-core-shared
pixi run plan-build-all
pixi run plan-test
pixi run plan-install
pixi run cmake-configure
pixi run cmake-plan-build-core-shared
pixi run cmake-plan-install
```

Direkt über die zentralen Wrapper:

```sh
scripts/run_build_task.sh --dry-run build-core-shared
scripts/run_install_task.sh --dry-run install
```

### Buildsystem-Diagnose ohne Kompilierung

```sh
scripts/reta_doctor.sh
pixi run doctor
pixi run cmake-configure
pixi run cmake-doctor
```

Der Doctor prüft Shell/Pixi/CMake-Defaults, `/usr/local`-Install-Layout,
das zentrale Artefaktmanifest, Toolchain und Plan-Kommandos. Er baut nichts
und installiert nichts.


### Punkt 4 Abschlussstatus

```sh
scripts/print_buildsystem_cleanup_status.sh
pixi run script-cleanup-status
pixi run cmake-configure
pixi run cmake-script-cleanup-status
```

Wenn diese Anzeige und der Doctor grün sind, ist Punkt 4 abgeschlossen und der
nächste Hauptschritt ist die ABI-/Shared-Library-Stabilisierung.


### Installationsprofile standard, zusatz, all und reference

Der Installer besitzt drei native Profile plus einen getrennten
Referenz-Sonderfall. Ohne Option gilt `standard`:

```text
standard   reta, rp, rpl, rpe, rpb, generate_html, grundStrukHtml
zusatz     standard + reguläre Entwickler-/Diagnosebefehle
all        standard + zusatz + schwere Architektur-/Stage-Diagnosen
reference  nur alter Python-Referenzbaum für Paritäts-/Debugarbeit
```

`standard`, `zusatz` und `all` installieren `python_reference` bewusst nicht.
Wer die alte Referenz zusätzlich braucht, installiert sie getrennt mit
`--reference` nach dem gewünschten nativen Profil.

Shell:

```bash
sudo ./scripts/install.sh              # standard
sudo ./scripts/install.sh --zusatz
sudo ./scripts/install.sh --all
sudo ./scripts/install.sh --reference  # optional, nur alte Python-Referenz
sudo ./scripts/uninstall.sh --standard
sudo ./scripts/uninstall.sh --zusatz
sudo ./scripts/uninstall.sh --all      # auch Default, entfernt auch Referenz
sudo ./scripts/uninstall.sh --reference
```

Pixi bleibt für Build/Tasksteuerung Benutzerprozess. Für `/usr/local` wird nicht
`sudo pixi run install`, sondern das Installskript direkt mit sudo verwendet:

```bash
pixi run build-all
sudo ./scripts/install.sh --all
```

Für Benutzerprefix ohne root sind die Pixi-Profile direkt nutzbar:

```bash
PREFIX="$HOME/.local" pixi run install
PREFIX="$HOME/.local" pixi run install-zusatz
PREFIX="$HOME/.local" pixi run install-all
PREFIX="$HOME/.local" pixi run install-reference
PREFIX="$HOME/.local" pixi run uninstall-all
PREFIX="$HOME/.local" pixi run uninstall-reference
```

CMake:

```bash
sudo cmake --install build                         # standard
sudo cmake --build build --target reta-install-zusatz
sudo cmake --build build --target reta-install-all
sudo cmake --build build --target reta-install-reference
sudo cmake --build build --target reta-uninstall-all
sudo cmake --build build --target reta-uninstall-reference
```

Alle Shared Libraries liegen flach unter `PREFIX/lib`; ausführbare Dateien liegen
nur unter `PREFIX/bin`. `lib/reta` ist nur noch Legacy-Cleanup.
`python_reference` ist kein Bestandteil der nativen Installation mehr und wird
nur bei `install-reference` als nicht ausführbares Datenmaterial kopiert.
