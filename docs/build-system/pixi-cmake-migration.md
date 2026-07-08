# Pixi/CMake-Migration

Diese Migration ist absichtlich additiv. Die bestehenden Shell-Skripte bleiben
zunächst die Quelle der Wahrheit. Pixi fixiert die Werkzeuge und CMake liefert
benannte Targets darüber. Erst wenn diese Schicht stabil bleibt, werden die
Skripte ausgedünnt.

## Stufe 1: Pixi als Umgebung und Task-Runner

Pixi legt seine Umgebung unter `.pixi/` an. `bin/mojo-real` sucht dort bereits
nach `.pixi/envs/default/bin/mojo`, deshalb ist kein zusätzlicher Mojo-Wrapper
notwendig.

Wichtige Befehle:

```sh
pixi run mojo-version
pixi run build-core-shared
pixi run build-shared
pixi run build-all
pixi run test
pixi run release-check
```

Für den bisherigen uv/.venv-Weg bleibt ein eigener Task erhalten:

```sh
pixi run setup-mojo-venv
```

## Stufe 2: CMake als Orchestrierungsschicht

Konfigurieren:

```sh
pixi run cmake-configure
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
- keine Änderung an `target/`-Layout oder Installpfaden
- keine Änderung an den Mojo-Quellen
- kein direkter CMake-Sprachsupport für Mojo
- kein Wechsel auf CPack/Packaging
