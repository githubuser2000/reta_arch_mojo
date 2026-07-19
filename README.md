# reta.arch → Mojo

`reta_arch_mojo` is the Mojo port of the historical `reta` / `reta.arch`
Python project. The goal is to provide the public `reta` command family as
native Linux executables with shared libraries, while keeping the old Python
code only as an explicit reference for parity and debugging.

This repository is not a progress log. The old stage-by-stage project log has
been moved to [`PROJECT_STATUS_LOG.md`](PROJECT_STATUS_LOG.md).

## What is this?

`reta` is a command-line table, prompt and output-generation tool. It works with
the project's data catalogues and can produce terminal, CSV, HTML and related
outputs. The original implementation was Python/PyPy based. This repository
moves the runtime step by step to Mojo and native shared libraries.

The main user commands are:

| Command | Purpose |
| --- | --- |
| `reta` | Main table/output command. |
| `rp` | Interactive prompt frontend. |
| `rpl` | Prompt/logging variant. |
| `rpe` | Prompt editor variant. |
| `rpb` | One-shot/direct prompt command. |
| `generate_html` | Generate HTML output/assets. |
| `grundStrukHtml` | Generate or inspect basic HTML structure output. |

Most `reta-mojo-*` binaries are developer diagnostics. They are not installed by
default.

## Installation profiles

The installer has four explicit profiles:

| Profile | What it installs |
| --- | --- |
| `standard` | Only normal user commands: `reta`, `rp`, `rpl`, `rpe`, `rpb`, `generate_html`, `grundStrukHtml`. |
| `zusatz` | `standard` plus regular developer and diagnostic commands. |
| `all` | `standard` plus `zusatz` plus heavy architecture/stage diagnostics. |
| `reference` | Only the old Python reference tree under `share/reta/python_reference`. |

`standard`, `zusatz` and `all` do not install the Python reference tree. Install
it only when you explicitly need parity or debug material:

```sh
sudo ./scripts/install.sh --reference
```

## Build with shell scripts

The shell scripts are the most direct build path:

```sh
scripts/setup_mojo.sh
scripts/build-all.sh -- -j 8
scripts/build-tests.sh -- -j 8
sudo ./scripts/install.sh
```

The last command installs the `standard` profile. Other profiles:

```sh
sudo ./scripts/install.sh --zusatz
sudo ./scripts/install.sh --all
sudo ./scripts/install.sh --reference
```

Uninstall profiles:

```sh
sudo ./scripts/uninstall.sh --standard
sudo ./scripts/uninstall.sh --zusatz
sudo ./scripts/uninstall.sh --all
sudo ./scripts/uninstall.sh --reference
```

Without an option, `uninstall.sh` performs the safe full cleanup, equivalent to
`--all`.

## Build with Pixi

Pixi can drive the project tasks, but do not run Pixi itself with `sudo` for a
system installation. Build with Pixi as your user, then install through the
shell installer:

```sh
pixi install
pixi run setup-mojo
pixi run build-all
pixi run build-tests
sudo ./scripts/install.sh
```

For a user-local installation, Pixi tasks can call the installer directly:

```sh
PREFIX="$HOME/.local" pixi run install
PREFIX="$HOME/.local" pixi run install-zusatz
PREFIX="$HOME/.local" pixi run install-all
PREFIX="$HOME/.local" pixi run install-reference
```

User-local uninstall:

```sh
PREFIX="$HOME/.local" pixi run uninstall-standard
PREFIX="$HOME/.local" pixi run uninstall-zusatz
PREFIX="$HOME/.local" pixi run uninstall-all
PREFIX="$HOME/.local" pixi run uninstall-reference
```

## Build with CMake

A normal CMake build installs the `standard` profile:

```sh
rm -rf build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -- -j 8
sudo cmake --install build
```

Additional install profiles are available as CMake targets:

```sh
sudo cmake --build build --target reta-install-zusatz
sudo cmake --build build --target reta-install-all
sudo cmake --build build --target reta-install-reference
```

Uninstall targets:

```sh
sudo cmake --build build --target reta-uninstall-standard
sudo cmake --build build --target reta-uninstall-zusatz
sudo cmake --build build --target reta-uninstall-all
sudo cmake --build build --target reta-uninstall-reference
```

`reta-uninstall` is an alias for the full cleanup.

## Installed layout

Default prefix is `/usr/local`:

| Path | Content |
| --- | --- |
| `/usr/local/bin` | Public commands and optional diagnostic executables. |
| `/usr/local/lib` | Native shared libraries and Mojo runtime libraries. |
| `/usr/local/share/reta` | Runtime data/assets. |
| `/usr/local/share/reta/python_reference` | Only when installed with `--reference`. |
| `/usr/local/share/man/man1` | Man pages. |

The installer intentionally avoids hidden executable copies under
`/usr/local/share/reta/python_reference`. The reference tree is data/debug
material, not a second runtime installation.

## Build options

Extra Mojo compiler options can be passed after `--`:

```sh
scripts/build-all.sh -- --optimization-level 2 --target-cpu native -j 8
```

Heavy targets use conservative defaults. To remove the default no-optimization
setting for heavy targets, pass `--optimize-heavy`:

```sh
scripts/build-all.sh --optimize-heavy -- --optimization-level 2 --target-cpu native -j 8
```

Internally these options are forwarded through `MOJO_BUILD_OPTION` handling so
that script, Pixi and CMake entry points stay consistent.

## Check the installation

```sh
reta --version
rp --help
man reta
scripts/check_install_layout.sh
```

Release hardening gates:

```sh
scripts/check_install_profile_matrix.sh
scripts/check_release_bridge_policy.sh
scripts/release_check.sh --dry-run
scripts/release_check.sh --jobs 4 --child-workers 2 -- -j 8
scripts/check_architecture_diagnostics.sh --jobs 4
```

These checks verify that shell scripts, Pixi and CMake use the same install
profiles, that `standard` does not install Python fallback/reference material,
and that the public commands stay separated from diagnostic binaries.

If man pages were installed but are not found immediately, refresh the man-page
index:

```sh
sudo mandb
```

## Development notes

The normal user installation is intentionally small. Diagnostic and architecture
binaries are still useful while porting, testing and comparing native Mojo output
against historical Python behavior, but they should not confuse normal users.

Useful developer documents:

- [`BUILD.md`](BUILD.md) — detailed build notes.
- [`BUILD_INSTALL_QUICKSTART.md`](BUILD_INSTALL_QUICKSTART.md) — compact install commands.
- [`BINARIES.md`](BINARIES.md) — binary and command classification.
- [`PROJECT_STATUS_LOG.md`](PROJECT_STATUS_LOG.md) — old progress log and stage history.
- [`KNOWN_DEFECTS.md`](KNOWN_DEFECTS.md) — known defects and open parity items.

---

# reta.arch → Mojo

`reta_arch_mojo` ist die Mojo-Portierung des historischen Python-Projekts
`reta` / `reta.arch`. Ziel ist, die öffentliche `reta`-Befehlsfamilie als native
Linux-Executables mit Shared Libraries bereitzustellen. Der alte Python-Code
bleibt nur noch als ausdrücklich installierbare Referenz für Paritäts- und
Debugzwecke erhalten.

Diese Datei ist kein Fortschrittsprotokoll. Das alte Stage-Protokoll wurde nach
[`PROJECT_STATUS_LOG.md`](PROJECT_STATUS_LOG.md) verschoben.

## Was ist das?

`reta` ist ein Kommandozeilenwerkzeug für Tabellen, Prompt-Bedienung und
Ausgabeerzeugung. Es arbeitet mit den Datenkatalogen des Projekts und erzeugt
Terminal-, CSV-, HTML- und verwandte Ausgaben. Die ursprüngliche Implementierung
war Python/PyPy-basiert. Dieses Repository verlegt die Laufzeit schrittweise nach
Mojo und native Shared Libraries.

Die normalen Nutzerbefehle sind:

| Befehl | Zweck |
| --- | --- |
| `reta` | Hauptbefehl für Tabellen und Ausgaben. |
| `rp` | Interaktives Prompt-Frontend. |
| `rpl` | Prompt-/Logging-Variante. |
| `rpe` | Prompt-Editor-Variante. |
| `rpb` | Einmaliger/direkter Prompt-Befehl. |
| `generate_html` | Erzeugt HTML-Ausgaben/Assets. |
| `grundStrukHtml` | Erzeugt oder prüft Grundstruktur-HTML. |

Die meisten `reta-mojo-*`-Programme sind Entwicklerdiagnosen. Sie werden nicht
standardmäßig installiert.

## Installationsprofile

Der Installer hat vier klare Profile:

| Profil | Inhalt |
| --- | --- |
| `standard` | Nur normale Nutzerbefehle: `reta`, `rp`, `rpl`, `rpe`, `rpb`, `generate_html`, `grundStrukHtml`. |
| `zusatz` | `standard` plus reguläre Entwickler- und Diagnosebefehle. |
| `all` | `standard` plus `zusatz` plus schwere Architektur-/Stage-Diagnosen. |
| `reference` | Nur der alte Python-Referenzbaum unter `share/reta/python_reference`. |

`standard`, `zusatz` und `all` installieren den Python-Referenzbaum nicht. Er
wird nur installiert, wenn du ihn ausdrücklich brauchst:

```sh
sudo ./scripts/install.sh --reference
```

## Bauen mit Shellskripten

Die Shellskripte sind der direkteste Weg:

```sh
scripts/setup_mojo.sh
scripts/build-all.sh -- -j 8
scripts/build-tests.sh -- -j 8
sudo ./scripts/install.sh
```

Der letzte Befehl installiert das Profil `standard`. Weitere Profile:

```sh
sudo ./scripts/install.sh --zusatz
sudo ./scripts/install.sh --all
sudo ./scripts/install.sh --reference
```

Deinstallation:

```sh
sudo ./scripts/uninstall.sh --standard
sudo ./scripts/uninstall.sh --zusatz
sudo ./scripts/uninstall.sh --all
sudo ./scripts/uninstall.sh --reference
```

Ohne Option führt `uninstall.sh` den sicheren vollständigen Cleanup aus,
entsprechend `--all`.

## Bauen mit Pixi

Pixi kann die Projekt-Tasks ausführen. Für eine Systeminstallation sollte Pixi
aber nicht selbst mit `sudo` gestartet werden. Baue mit Pixi als normaler Nutzer
und installiere dann mit dem Shell-Installer:

```sh
pixi install
pixi run setup-mojo
pixi run build-all
pixi run build-tests
sudo ./scripts/install.sh
```

Für eine Benutzerinstallation kann Pixi den Installer direkt aufrufen:

```sh
PREFIX="$HOME/.local" pixi run install
PREFIX="$HOME/.local" pixi run install-zusatz
PREFIX="$HOME/.local" pixi run install-all
PREFIX="$HOME/.local" pixi run install-reference
```

Benutzerlokale Deinstallation:

```sh
PREFIX="$HOME/.local" pixi run uninstall-standard
PREFIX="$HOME/.local" pixi run uninstall-zusatz
PREFIX="$HOME/.local" pixi run uninstall-all
PREFIX="$HOME/.local" pixi run uninstall-reference
```

## Bauen mit CMake

Ein normaler CMake-Build installiert das Profil `standard`:

```sh
rm -rf build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -- -j 8
sudo cmake --install build
```

Weitere Installationsprofile gibt es als CMake-Targets:

```sh
sudo cmake --build build --target reta-install-zusatz
sudo cmake --build build --target reta-install-all
sudo cmake --build build --target reta-install-reference
```

Deinstallations-Targets:

```sh
sudo cmake --build build --target reta-uninstall-standard
sudo cmake --build build --target reta-uninstall-zusatz
sudo cmake --build build --target reta-uninstall-all
sudo cmake --build build --target reta-uninstall-reference
```

`reta-uninstall` ist ein Alias für den vollständigen Cleanup.

## Installiertes Layout

Standardprefix ist `/usr/local`:

| Pfad | Inhalt |
| --- | --- |
| `/usr/local/bin` | Öffentliche Befehle und optional Diagnose-Executables. |
| `/usr/local/lib` | Native Shared Libraries und Mojo-Runtime-Libraries. |
| `/usr/local/share/reta` | Runtime-Daten/Assets. |
| `/usr/local/share/reta/python_reference` | Nur bei Installation mit `--reference`. |
| `/usr/local/share/man/man1` | Manpages. |

Der Installer vermeidet absichtlich versteckte ausführbare Kopien unter
`/usr/local/share/reta/python_reference`. Der Referenzbaum ist Daten- und
Debugmaterial, keine zweite Runtime-Installation.

## Build-Optionen

Zusätzliche Mojo-Compileroptionen können nach `--` übergeben werden:

```sh
scripts/build-all.sh -- --optimization-level 2 --target-cpu native -j 8
```

Schwere Ziele verwenden konservative Defaults. Mit `--optimize-heavy` kann die
standardmäßige No-Optimization-Vorgabe für schwere Ziele entfernt werden:

```sh
scripts/build-all.sh --optimize-heavy -- --optimization-level 2 --target-cpu native -j 8
```

Intern werden diese Optionen über die `MOJO_BUILD_OPTION`-Logik weitergereicht,
damit Shell-, Pixi- und CMake-Einstiege konsistent bleiben.

## Installation prüfen

```sh
reta --version
rp --help
man reta
scripts/check_install_layout.sh
```

Release-Härtungsprüfungen:

```sh
scripts/check_install_profile_matrix.sh
scripts/check_release_bridge_policy.sh
scripts/release_check.sh --dry-run
```

Diese Prüfungen erzwingen, dass Shellskripte, Pixi und CMake dieselben
Installationsprofile benutzen, dass `standard` kein Python-Fallback-/
Referenzmaterial installiert und dass öffentliche Befehle von Diagnose-Binaries
getrennt bleiben.

Falls Manpages nicht sofort gefunden werden:

```sh
sudo mandb
```

## Entwicklungshinweise

Die normale Nutzerinstallation ist absichtlich klein. Diagnose- und
Architekturprogramme bleiben beim Portieren, Testen und Vergleichen der nativen
Mojo-Ausgabe mit dem historischen Python-Verhalten nützlich. Sie sollen normale
Nutzer aber nicht verwirren.

Nützliche Entwicklerdokumente:

- [`BUILD.md`](BUILD.md) — ausführliche Build-Hinweise.
- [`BUILD_INSTALL_QUICKSTART.md`](BUILD_INSTALL_QUICKSTART.md) — kurze Installationsbefehle.
- [`BINARIES.md`](BINARIES.md) — Klassifikation der Binaries/Befehle.
- [`PROJECT_STATUS_LOG.md`](PROJECT_STATUS_LOG.md) — altes Fortschritts- und Stage-Protokoll.
- [`KNOWN_DEFECTS.md`](KNOWN_DEFECTS.md) — bekannte Defekte und offene Paritätspunkte.
