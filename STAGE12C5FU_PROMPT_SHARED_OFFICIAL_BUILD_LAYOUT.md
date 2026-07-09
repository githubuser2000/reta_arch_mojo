# Stage 12c5fu: Prompt-Shared-Libraries als offizielles Build-Layout

Diese Stage befördert den in 12c5ft vorbereiteten Prompt-Shared-Pfad in die
offizielle Build- und Installationsstruktur.

## Offizielle Prompt-Artefakte

`scripts/build-all.sh` baut nach den Core-Dünnstarter-Artefakten jetzt auch:

- `target/lib/reta/libreta_prompt_mojo.so`
- `target/lib/reta/libreta_prompt_interactive_mojo.so`
- `target/bin/rpb`
- `target/bin/rp`
- `target/bin/rpl`
- `target/bin/rpe`

`rpb` bleibt ein One-shot-Starter und lädt nur `libreta_prompt_mojo.so`.  `rp`,
`rpl` und `rpe` laden `libreta_prompt_interactive_mojo.so`, die auf der Prompt-
Ausführungsbibliothek aufsetzt.

## Öffentliche Launcher

`bin/rp`, `bin/rpl`, `bin/rpe` und `bin/rpb` sind jetzt dünne öffentliche
Starter.  Sie wählen nur noch den passenden kompilierten Starter in
`target/bin/` und setzen weiterhin `RETA_PYTHON`, damit explizite Python-/Math-
Kompatibilitätsränder atomar funktionieren.

## Installation

`scripts/install.sh` installiert die Prompt-Starter und beide Prompt-Shared-
Libraries mitsamt `.reta-source-id`-Sidecars.  `scripts/check_install_layout.sh`
prüft die installierten Prompt-Artefakte.
