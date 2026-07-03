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

Erzeugt werden neunzehn normale Laufzeitziele:

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


## Stage 12c4m: Installation unter `/usr/local` oder `/usr`

Unveränderliche CSV- und Katalogdaten werden nicht in `bin` oder `lib`
installiert. Das FHS-konforme Standardlayout einer manuellen Installation ist:

```text
/usr/local/bin
/usr/local/lib/reta
/usr/local/share/reta/csv
/usr/local/share/reta/assets
```

Nach dem Build:

```bash
sudo ./scripts/install.sh
```

Ein Distributionspaket verwendet stattdessen ein Staging-Verzeichnis und den
Präfix `/usr`:

```bash
DESTDIR="$pkgdir" PREFIX=/usr ./scripts/install.sh
```

Dann liegen die Tabellen unter `/usr/share/reta/csv`. Die öffentliche
`/usr/bin`-Ebene enthält nur relative Symlinks zu den privaten Launchern unter
`/usr/lib/reta/bin`. Die privaten ELFs werden nicht mehr per Wildcard kopiert,
sondern ausschließlich aus der 36-Ziel-Allowlist
`scripts/install_targets.txt`; dadurch gelangen keine lokalen Alt-/Debugziele
ins Paket. Der Python-Kompatibilitätsbaum behält seinen historischen
Pfad `python_reference/csv` als relativen Symlink auf die kanonischen
Shared-Data-Dateien.

Benutzerinstallation ohne Administratorrechte:

```bash
PREFIX="$HOME/.local" ./scripts/install.sh
```

Fedora-/RPM-konformes privates Programmverzeichnis:

```bash
DESTDIR="$RPM_BUILD_ROOT" PREFIX=/usr LIBEXECDIR=/usr/libexec/reta \
  ./scripts/install.sh
```

Die Daten bleiben unabhängig davon unter `/usr/share/reta`.

Prüfung des vollständigen Staging-Vertrags:

```bash
./scripts/check_resource_paths.sh
./scripts/check_install_layout.sh
./scripts/run_pytest.sh -q tests/test_install_layout.py tests/test_mojo_runtime_path.py
```

Deinstallation verwendet dieselben `PREFIX`, `DESTDIR`, `BINDIR`,
`LIBEXECDIR` und `DATADIR`-Werte:

```bash
sudo ./scripts/uninstall.sh
```

## Portabler ELF-RUNPATH

Mojo 1.0.0b2 ergänzt beim Linken automatisch den absoluten Pfad seiner lokalen
`modular/lib`-Installation. Die Buildskripte rufen deshalb nach jedem Ziel
`tools/sanitize_mojo_runpath.py` auf. Der ELF-Stringtabelleneintrag wird ohne
Verschieben anderer Daten auf den portablen Vertrag gekürzt:

```text
$ORIGIN/../lib/mojo
```

Prüfung eines vorhandenen Binaries:

```bash
python3 tools/sanitize_mojo_runpath.py --check target/bin/reta-native
readelf -d target/bin/reta-native | grep RUNPATH
```

Der Runtime-Starter `bin/mojo-runtime-exec` bleibt für ältere, noch nicht
sanitisierte Binärdateien erhalten.

## Installierbares `generate_html`

Nach `scripts/build.sh` und `scripts/install.sh /usr` liegt der öffentliche
Starter unter `/usr/bin/generate_html`, das private Mojo-ELF unter
`/usr/lib/reta/target/bin/generate-html-native` und die Manpage unter
`/usr/share/man/man1/generate_html.1`.

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

Der reguläre Build erzeugt `target/bin/reta-mojo-table-generation`:

```bash
scripts/build.sh
bin/reta-mojo-table-generation --summary
scripts/test_stage12c5u.sh
```

Damit bestanden in Stage 12c5u 20 reguläre und 18 schwere Compilerziele. Mit dem nachfolgenden Ausgabe-Syntax-Ziel bestehen nun **21 reguläre und 18 schwere, insgesamt 39 installierbare Compilerziele**.


## Native Ausgabe-Semantik und Syntax (Stage 12c5v)

Der reguläre Build erzeugt `target/bin/reta-mojo-output-syntax`. Das Ziel
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
