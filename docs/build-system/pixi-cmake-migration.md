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

Nur `reta` und `libreta-core.so` bauen:

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
