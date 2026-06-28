# Build- und Binärlayout

## Grundsatz

`bin/` enthält **keine kompilierten Mojo-Dateien**. Dort liegen kleine, versionierbare POSIX-Shell-Launcher mit stabilen öffentlichen Namen. Die echten Compilerprodukte werden nach `target/bin/` geschrieben.

```text
bin/                     versionierte Launcher
src/                     Mojo-Quellen
target/bin/              kompilierte ELF-Executables, nicht versioniert
.venv/                   lokaler Mojo-Compiler und Runtime-Bibliotheken, nicht versioniert
```

Sowohl `target/` als auch `.venv/` stehen in `.gitignore`.

Diese Trennung ist notwendig, weil die von der pip/uv-Installation erzeugten ELF-Dateien zurzeit lokale Runtime-Bibliotheken aus der verwendeten Mojo-Umgebung referenzieren. Sie werden deshalb auf dem Zielrechner kompiliert und nicht als scheinbar portable Git-Artefakte eingecheckt.

## Erstinstallation und Build

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

`setup_mojo.sh` installiert Mojo projektlokal und ruft anschließend automatisch `scripts/build.sh` auf. Nur für eine reine Compilerinstallation ohne Build:

```bash
RETA_SKIP_BUILD=1 ./scripts/setup_mojo.sh
```

Manueller Neuaufbau:

```bash
./scripts/build.sh
```

Aufräumen:

```bash
./scripts/clean.sh
```

Prüfung der Verzeichnisgrenzen und ELF-Dateien:

```bash
./scripts/check_build_layout.sh
```

## Kompilierte Programme

`scripts/build.sh` erzeugt derzeit:

```text
target/bin/reta-mojo-native
target/bin/reta-mojo-schema
target/bin/reta-mojo-table
target/bin/reta-mojo-compat-bin
target/bin/reta-prompt-native
target/bin/grundStrukHtml-native
target/bin/generate-html-native
target/bin/reta-mojo-architecture
```

Die öffentlichen Namen wie `reta`, `rp`, `multis3` oder `generate_html` bleiben Launcher. Sie wählen das passende vorkompilierte Programm und fallen nur bei fehlendem `target/bin` auf `mojo run` zurück.

## Installation öffentlicher Namen

```bash
./scripts/install_bins.sh
```

Das verlinkt die stabilen Launcher nach `~/.local/bin`. Es kopiert keine Compilerprodukte in Git.
