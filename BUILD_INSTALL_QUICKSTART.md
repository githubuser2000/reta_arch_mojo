# Build- und Install-Quickstart

Kurze Befehle, um `reta` zu bauen und nach `/usr/local` zu installieren.

Die kurzen Standardbefehle sind absichtlich gültig: `cmake --build build`
baut den vollständigen Produktionssatz, und `cmake --install build` ruft den
Projekt-Installer mit demselben Prefix auf.

## Shellskripte

```sh
scripts/build-all.sh -- -j 8
sudo ./scripts/install.sh
```

Mit Aufräumen vorher:

```sh
scripts/clean.sh
scripts/build-all.sh -- -j 8
sudo ./scripts/install.sh
```

Deinstallieren:

```sh
sudo ./scripts/uninstall.sh
```

## Pixi

```sh
pixi run build-all
sudo env PATH="$PATH" pixi run install
```

Optional vorher prüfen:

```sh
pixi run check-toolchain
```

Deinstallieren:

```sh
sudo env PATH="$PATH" pixi run uninstall
```

## CMake

Minimal mit CMake-Standardbefehlen:

```sh
rm -rf build
cmake -S . -B build
cmake --build build
sudo cmake --install build
```

Explizit mit Prefix, falls du nicht `/usr/local` willst:

```sh
rm -rf build
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build
cmake --install build
```

Die alten expliziten Targets bleiben gültig:

```sh
cmake --build build --target reta-all
sudo cmake --build build --target reta-install
```

CMake über Pixi:

```sh
pixi run cmake-configure
pixi run cmake-build
sudo cmake --install build
```

Deinstallieren bleibt ein Projekt-Target:

```sh
sudo cmake --build build --target reta-uninstall
```

## Installation prüfen

```sh
/usr/local/bin/reta --version
/usr/local/bin/reta-native --version
man reta
```

Falls die Manpage nicht sofort gefunden wird:

```sh
sudo mandb
man reta
```

Installationslayout anzeigen:

```sh
scripts/print_install_layout.sh
pixi run install-layout
cmake --build build --target reta-install-layout
```

## Benutzerinstallation ohne sudo

```sh
scripts/build-all.sh -- -j 8
PREFIX="$HOME/.local" ./scripts/install.sh
```

Dann muss `$HOME/.local/bin` im `PATH` liegen.
