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

## Installationsprofile

Es gibt drei kumulative Installationsprofile:

```text
standard  reta, rp, rpl, rpe, rpb, generate_html, grundStrukHtml
zusatz    standard + reguläre Entwickler-/Diagnosebefehle
all       standard + zusatz + schwere Architektur-/Stage-Diagnosen
```

Shell-Installation:

```sh
sudo ./scripts/install.sh              # standard
sudo ./scripts/install.sh --zusatz
sudo ./scripts/install.sh --all
```

Shell-Deinstallation:

```sh
sudo ./scripts/uninstall.sh --standard
sudo ./scripts/uninstall.sh --zusatz
sudo ./scripts/uninstall.sh --all      # auch Default von uninstall.sh
```

Pixi sollte für `/usr/local` nicht mit `sudo` gestartet werden. Für
Systeminstallation deshalb weiterhin das Shell-Installskript mit `sudo` nutzen:

```sh
pixi run build-all
sudo ./scripts/install.sh --zusatz
```

Für Benutzerinstallation ohne root gehen die Pixi-Tasks direkt:

```sh
PREFIX="$HOME/.local" pixi run install
PREFIX="$HOME/.local" pixi run install-zusatz
PREFIX="$HOME/.local" pixi run install-all
PREFIX="$HOME/.local" pixi run uninstall-all
```

CMake-Profile:

```sh
sudo cmake --install build                         # standard
sudo cmake --build build --target reta-install-zusatz
sudo cmake --build build --target reta-install-all
sudo cmake --build build --target reta-uninstall-standard
sudo cmake --build build --target reta-uninstall-zusatz
sudo cmake --build build --target reta-uninstall-all
```

## Pixi

```sh
pixi run build-all
sudo ./scripts/install.sh
```

Optional vorher prüfen:

```sh
pixi run check-toolchain
```

Deinstallieren:

```sh
sudo ./scripts/uninstall.sh
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
sudo cmake --install build
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

## Library-Layout

Alle installierten Shared Libraries, inklusive Mojo-Runtime-`.so`, liegen flach unter `/usr/local/lib`. Öffentliche ausführbare Dateien liegen nur unter `/usr/local/bin`. Alte private Reste unter `/usr/local/lib/reta` werden von `scripts/uninstall.sh` entfernt.
