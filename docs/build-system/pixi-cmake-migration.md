# Pixi/CMake-Migration

Diese Migration ist absichtlich additiv. Die bestehenden Shell-Skripte bleiben
zunächst die Quelle der Wahrheit. Pixi fixiert die Werkzeuge und CMake liefert
benannte Targets darüber. Erst wenn diese Schicht stabil bleibt, werden die
Skripte ausgedünnt.

## Stufe 1: Pixi als Umgebung und Task-Runner

Pixi legt seine Umgebung unter `.pixi/` an. `bin/mojo-real` sucht dort bereits
nach `.pixi/envs/default/bin/mojo`, deshalb ist kein zusätzlicher Mojo-Wrapper
notwendig.

Wichtig: Mojo wird nicht als Pixi-PyPI-Abhängigkeit installiert. Der Compiler
bleibt extern über `MOJO_BIN`, `.venv/bin/mojo`, `.pixi/envs/default/bin/mojo`
oder `PATH` auffindbar. Dadurch vermeidet Pixi Resolver-Probleme mit
`mojo==1.0.0b2` und den verfügbaren manylinux-Wheels.

Vor dem ersten Build kann die Umgebung geprüft werden, ohne zu kompilieren:

```sh
pixi run check-toolchain
```

Wichtige Befehle:

```sh
pixi run check-toolchain
pixi run mojo-version
pixi run build-core-shared
pixi run build-shared
pixi run build-all
pixi run test
pixi run release-check
pixi run install
pixi run uninstall
pixi run check-install-layout
```

Für den bisherigen uv/.venv-Weg bleibt ein eigener Task erhalten:

```sh
pixi run setup-mojo-venv
```

## Stufe 2: CMake als Orchestrierungsschicht

Konfigurieren:

```sh
pixi run cmake-configure
pixi run cmake-list-targets
```

Nur `reta` und `libreta_core_mojo.so` bauen:

```sh
pixi run cmake-build-core-shared
```

Alle offiziellen Shared-Library-Ziele bauen:

```sh
pixi run cmake-build-shared
```

Vollbuild:

```sh
pixi run cmake-build-all
```

Installation unter `/usr/local`:

```sh
pixi run cmake-configure
sudo pixi run cmake-install
```

Der CMake-Installationspräfix ist standardmäßig `/usr/local` und kann bei Bedarf bewusst überschrieben werden:

```sh
cmake -S . -B build -G Ninja -DRETA_INSTALL_PREFIX=/usr/local
```

Tests bauen und ausführen:

```sh
pixi run cmake-test
```

Alternativ mit CTest, wenn die Tests vorher gebaut wurden:

```sh
pixi run cmake-ctest
```

## Stufe 3: Späterer Zielzustand

1. Shell-Skripte bleiben zunächst kompatible Wrapper.
2. CMake übernimmt danach Install-Layout, Shared-Library-Gruppen und
   Release-Gates als offizielle Targets.
3. Erst danach werden doppelte Skriptlisten entfernt.
4. Ein echter Mojo-Abhängigkeitsgraph kommt erst, wenn die direkten
   Compilerabhängigkeiten sicher genug modelliert sind.

## Bewusste Nicht-Ziele dieser ersten Stufe

- keine Entfernung funktionierender Shell-Skripte
- keine Änderung an `target/`-Layout; Install-Targets verwenden standardmäßig `/usr/local`
- keine Änderung an den Mojo-Quellen
- kein direkter CMake-Sprachsupport für Mojo
- kein Wechsel auf CPack/Packaging

## Fehlerbild: Pixi versucht Mojo zu lösen

Wenn Pixi meldet, dass `mojo==1.0.0b2` wegen eines manylinux-Tags nicht
auflösbar ist, steht Mojo noch als PyPI-Abhängigkeit in `pixi.toml` oder ein
altes `pixi.lock` hält diesen Zustand fest. Der gewünschte Zustand ist:

```toml
# keine [pypi-dependencies]-Zeile fuer mojo
```

Danach den Lock neu erzeugen lassen:

```sh
rm -f pixi.lock
pixi run check-toolchain
```

## Einheitliche Install-Layout-Defaults

Die Installationspfade werden ab dieser Stufe zentral in
`scripts/reta_install_defaults.sh` gesetzt. Der Default bleibt `/usr/local`.
Shell, Pixi und CMake verwenden dieselben Variablen:

```sh
scripts/print_install_layout.sh
pixi run install-layout
pixi run cmake-install-layout
```

Wichtige Variablen:

```text
PREFIX=/usr/local
BINDIR=$PREFIX/bin
LIBEXECDIR=$PREFIX/lib/reta
DATADIR=$PREFIX/share/reta
MANDIR=$PREFIX/share/man
```

Für Paketbau oder Tests kann weiterhin bewusst überschrieben werden:

```sh
DESTDIR=/tmp/pkgroot PREFIX=/usr/local scripts/install.sh
cmake -S . -B build -G Ninja -DRETA_INSTALL_PREFIX=/usr/local
```

## Zentrales Artefaktmanifest

Die Build- und Install-Artefakte werden schrittweise aus einer gemeinsamen
Shell-Manifestdatei gespeist:

```text
scripts/reta_artifacts.sh
scripts/print_artifact_manifest.sh
```

Ziel ist, dass Shell-Skripte, Pixi-Tasks und CMake-Targets nicht dauerhaft
separate Listen für Executables, schwere Compilerziele und Shared Libraries
pflegen müssen.  Die vorhandenen Build-Skripte bleiben zunächst die ausführende
Instanz; das Manifest ist die zentrale Namensquelle.

Prüfen:

```sh
scripts/print_artifact_manifest.sh
pixi run artifact-manifest
cmake --build build --target reta-artifact-manifest
```

## Artefaktmanifest als Release-Gate

Ab dieser Stufe wird `scripts/install_targets.txt` gegen das zentrale Manifest
geprüft. Dadurch fällt sofort auf, wenn ein neues Executable in einer Liste
steht, aber in der anderen fehlt.

```sh
scripts/check_artifact_manifest_consistency.sh
pixi run check-artifact-manifest
cmake --build build --target reta-check-artifact-manifest
```

`release_check.sh` führt diese Prüfung vor dem nativen Vollbuild aus. Der Plan
lässt sich weiterhin ohne Ausführung anzeigen:

```sh
pixi run release-plan
cmake --build build --target reta-release-plan
```

## Einheitliche Build-Defaults

Ab dieser Stufe verwenden Pixi und CMake denselben zentralen Shell-Wrapper für
Build-Tasks:

```text
scripts/reta_build_defaults.sh
scripts/run_build_task.sh
scripts/print_build_defaults.sh
scripts/configure_cmake_with_defaults.sh
```

Die direkten historischen Skripte bleiben unverändert nutzbar. Der Wrapper ist
nur die gemeinsame Schicht für Pixi/CMake und für Nutzer, die einen einheitlichen
Einstieg wünschen.

Defaults anzeigen:

```sh
scripts/print_build_defaults.sh
pixi run build-defaults
cmake --build build --target reta-build-defaults
```

Standardwerte:

```text
RETA_MOJO_JOBS=8
RETA_TEST_RUN_JOBS=1
RETA_TEST_RUN_PARALLEL_JOBS=4
RETA_TEST_RUN_TIMEOUT=0
RETA_CMAKE_BUILD_DIR=build
RETA_CMAKE_GENERATOR=Ninja
```

Pixi nutzt diese Schicht direkt:

```sh
pixi run build-core-shared
pixi run test-parallel
pixi run release-plan
```

CMake wird ebenfalls über die Defaults konfiguriert:

```sh
pixi run cmake-configure
cmake --build build --target reta-core-shared
```

Wer bewusst andere Werte will, setzt sie vor dem Aufruf:

```sh
RETA_MOJO_JOBS=4 pixi run build-core-shared
RETA_TEST_RUN_PARALLEL_JOBS=6 pixi run test-parallel
RETA_CMAKE_BUILD_DIR=build-debug pixi run cmake-configure
```


### Plan-/Dry-Run-Modus

Für Pixi- und CMake-Einstiege gibt es einen Planmodus.  Er zeigt die effektiv
geplanten Befehle an, ohne Mojo zu kompilieren, Tests auszuführen oder nach
`/usr/local` zu installieren.

```sh
pixi run plan-build-core-shared
pixi run plan-build-all
pixi run plan-test
pixi run plan-install
pixi run cmake-configure
pixi run cmake-plan-build-core-shared
pixi run cmake-plan-install
```

Direkt über die Wrapper geht dasselbe:

```sh
scripts/run_build_task.sh --dry-run build-core-shared
scripts/run_install_task.sh --dry-run install
```

Der Planmodus ist bewusst eine Wrapper-Funktion.  Die historischen
Spezialskripte bleiben ausführbar und werden nicht durch eine zweite
Buildlogik ersetzt.


## Diagnose ohne Build

Der gemeinsame Doctor-Befehl prüft Shell-Syntax, zentrale Defaults,
Install-Layout, Artefaktmanifest, Toolchain und die wichtigsten Plan-Kommandos.
Er kompiliert nichts und installiert nichts.

```sh
scripts/reta_doctor.sh
pixi run doctor
pixi run cmake-configure
pixi run cmake-doctor
```

Wenn CMake noch nicht konfiguriert ist, meldet der Doctor das nur als Hinweis.
Für die CMake-Variante muss zuerst `pixi run cmake-configure` gelaufen sein.


## Punkt 4 Abschlussstatus

Der Buildsystem-Aufräumpunkt ist abgeschlossen, wenn diese nicht-kompilierenden
Prüfungen grün sind:

```sh
scripts/print_buildsystem_cleanup_status.sh
scripts/reta_doctor.sh
pixi run doctor
pixi run cmake-configure
pixi run cmake-doctor
```

Danach beginnt als nächster Hauptpunkt die ABI-/Shared-Library-Stabilisierung.
