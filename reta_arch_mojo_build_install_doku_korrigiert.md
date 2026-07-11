# reta_arch_mojo: Build, Installation und Deinstallation

Diese Doku beschreibt den sauberen Weg für Shell-Skripte, Pixi und CMake.

Grundregel:

```sh
pixi nicht mit sudo ausführen
```

Pixi verwaltet die Projektumgebung, `.pixi/`, Lockfiles, Caches und Buildumgebung. Diese Dateien sollen deinem normalen Benutzer gehören. `sudo` wird nur dort benutzt, wo wirklich nach `/usr/local` geschrieben wird.

## Ziel-Layout

Standardmäßig wird nach `/usr/local` installiert:

```text
/usr/local/bin/                 öffentliche Executables: reta, rp, rpl, rpe, rpb, ...
/usr/local/lib/reta/            Shared Libraries und private Runtime-Dateien
/usr/local/share/reta/          Daten, Assets, Python-Referenzmaterial
/usr/local/share/man/man1/      Manpages
```

Nicht gewünscht:

```text
/usr/local/lib/reta/bin/
/usr/local/lib/reta/scripts/
*.reta-source-id in /usr/local
reta/rp/rpl/rpe/rpb in Projektroot
reta/rp/rpl/rpe/rpb in reta_arch_mojo/bin
reta/rp/rpl/rpe/rpb in reta_arch_mojo/run
```

Im Projekt ist `target/bin/` der Build-Ausgabeort. Installierte Programme gehören nach `/usr/local/bin`.

## Variante 1: Shell-Skripte

### Mojo vorbereiten

```sh
cd /home/alex/Eigene-Dateien/myRepos/reta_arch_mojo
scripts/setup_mojo.sh
```

`scripts/setup_mojo.sh` installiert nur Mojo beziehungsweise richtet den Mojo-Zugriff ein. Es soll keine `reta`, `rp`, `rpl`, `rpe` oder `rpb` nach `bin/`, `run/` oder in den Projektroot schreiben.

Prüfen:

```sh
./bin/mojo-real --version
scripts/check_project_launcher_layout.sh
```

### Kompilieren

```sh
scripts/build-all.sh -- -j 8 2>&1 | tee build-all.txt
scripts/build-tests.sh -- -j 8 2>&1 | tee build-tests.txt
```

Optional die Tests ausführen:

```sh
scripts/run-tests.sh 2>&1 | tee run-tests.txt
```

### Layout prüfen

```sh
scripts/check_project_launcher_layout.sh
scripts/check_install_layout.sh
scripts/check_manpages.sh
```

### Installieren nach /usr/local

```sh
sudo ./scripts/install.sh
```

Nicht so:

```sh
sudo pixi run install
```

Das kann funktionieren, ist aber unsauber, weil Pixi dann als root läuft.

### Installieren nach anderem Prefix

Für Benutzerinstallation ohne root:

```sh
PREFIX="$HOME/.local" ./scripts/install.sh
```

Danach sicherstellen, dass der Benutzer-Binpfad im PATH liegt:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Variante 2: Pixi

### Pixi vorbereiten

```sh
cd /home/alex/Eigene-Dateien/myRepos/reta_arch_mojo
pixi install
```

### Mojo vorbereiten

```sh
pixi run setup-mojo
```

Falls der Task anders heißt, verfügbare Tasks anzeigen:

```sh
pixi task list
```

### Kompilieren

```sh
pixi run build-all
pixi run build-tests
```

### Prüfen

```sh
pixi run check-project-launcher-layout
pixi run check-install-layout
pixi run check-manpages
```

### Installieren nach /usr/local

Sauberer Weg:

```sh
sudo ./scripts/install.sh
```

Nicht empfohlen:

```sh
sudo pixi run install
```

Warum: `pixi run install` startet Pixi als root, falls du davor `sudo` setzt. Root kann dann Dateien in `.pixi/`, Cache oder Buildumgebung erzeugen. Das führt später zu unnötigen Rechteproblemen.

### Installieren nach $HOME/.local ohne sudo

```sh
PREFIX="$HOME/.local" pixi run install
```

Das ist okay, weil kein root nötig ist.

## Variante 3: CMake

### Konfigurieren

```sh
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local
```

Oder über Pixi:

```sh
pixi run cmake-configure
```

### Bauen

```sh
cmake --build build -j 8
```

Oder über Pixi:

```sh
pixi run cmake-build
```

### Prüfen

```sh
cmake --build build --target reta-check-project-launcher-layout
cmake --build build --target reta-check-install-layout
cmake --build build --target reta-check-manpages
```

### Installieren nach /usr/local

```sh
sudo cmake --install build
```

Das ist okay: Hier läuft nicht Pixi als root, sondern nur der CMake-Installationsschritt.

### Installieren nach anderem Prefix

```sh
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build -j 8
cmake --install build
```

Für `$HOME/.local` ist kein `sudo` nötig.

## Deinstallation

### Shell-Skript

Standardprefix `/usr/local`:

```sh
sudo ./scripts/uninstall.sh
```

Nur anzeigen, was entfernt würde:

```sh
scripts/run_install_task.sh --dry-run uninstall
```

Anderer Prefix:

```sh
PREFIX="$HOME/.local" ./scripts/uninstall.sh
```

### Pixi

Für Benutzerprefix ohne root:

```sh
PREFIX="$HOME/.local" pixi run uninstall
```

Für Systemprefix `/usr/local` besser nicht `sudo pixi run uninstall`, sondern:

```sh
sudo ./scripts/uninstall.sh
```

Nur Plan anzeigen:

```sh
pixi run plan-uninstall
```

### CMake

```sh
cmake --build build --target reta-uninstall-plan
sudo cmake --build build --target reta-uninstall
```

Bei Benutzerprefix ohne root:

```sh
cmake --build build --target reta-uninstall
```

## Nach der Installation prüfen

```sh
which reta
which rp
which rpl
which rpe
which rpb

reta -h
rp -h
rpb -h
```

Manpages:

```sh
man reta
man rp
man rpl
man rpe
man rpb
```

Layout kontrollieren:

```sh
ls /usr/local/bin/reta /usr/local/bin/rp /usr/local/bin/rpl /usr/local/bin/rpe /usr/local/bin/rpb
ls /usr/local/lib/reta/*_mojo.so
find /usr/local/lib/reta -maxdepth 2 -type d \( -name bin -o -name scripts -o -name python_reference \)
find /usr/local/bin /usr/local/lib/reta -name '*.reta-source-id' -o -name '*.reta-test-source-id'
```

Die beiden `find`-Befehle sollten nichts ausgeben.

## Kurzfassung

Shell:

```sh
scripts/setup_mojo.sh
scripts/build-all.sh -- -j 8
scripts/build-tests.sh -- -j 8
scripts/check_project_launcher_layout.sh
sudo ./scripts/install.sh
```

Pixi:

```sh
pixi install
pixi run setup-mojo
pixi run build-all
pixi run build-tests
pixi run check-project-launcher-layout
sudo ./scripts/install.sh
```

CMake:

```sh
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j 8
sudo cmake --install build
```

Deinstallation:

```sh
sudo ./scripts/uninstall.sh
```
