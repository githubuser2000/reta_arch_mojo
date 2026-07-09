#!/usr/bin/env sh
set -eu

cat <<'STATUS'
Punkt 4: Aufräumarbeiten in Skripten / Buildsystem
Status: abgeschlossen

Erledigt:
  - Pixi/CMake-Einstieg ist additiv vorhanden.
  - Mojo bleibt extern über bin/mojo-real; Pixi installiert Mojo nicht als PyPI-Abhängigkeit.
  - /usr/local ist der gemeinsame Install-Prefix-Default.
  - lib/reta enthält keine installierte python_reference-Kopie; diese liegt unter share/reta/python_reference.
  - Install-Layout-Defaults liegen zentral in scripts/reta_install_defaults.sh.
  - Build-Defaults liegen zentral in scripts/reta_build_defaults.sh.
  - Artefaktlisten liegen zentral in scripts/reta_artifacts.sh.
  - Build-/Install-/Release-Checks verwenden das zentrale Manifest.
  - Plan-/Dry-Run-Modus ist für Shell, Pixi und CMake vorhanden.
  - Doctor-Befehl prüft Buildsystem, Layout, Manifest, Toolchain und Plan-Kommandos ohne Build.

Wichtige Einstiege:
  scripts/reta_doctor.sh
  pixi run doctor
  pixi run cmake-configure && pixi run cmake-doctor

Nächster Hauptpunkt:
  Punkt 5: ABI-/Shared-Library-Stabilisierung
STATUS
