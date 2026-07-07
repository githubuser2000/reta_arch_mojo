# Stage 12c5fq – Core-Shared-Artefakte im offiziellen Buildlayout

Diese Stage macht den in 12c5fp eingeführten Core-ABI-Pfad zum offiziellen
Build-Artefakt des vollständigen Builds.

## Neu verbindlich

`scripts/build-all.sh` baut jetzt zusätzlich zu den schweren und regulären
nativen Zielen auch die Core-Shared-Zielgruppe:

- `target/lib/reta/libreta-core.so`
- `target/bin/reta`
- `target/bin/grundStrukHtml`

Die beiden Programme sind dünne C-Starter. Sie enthalten nicht die reta-Logik
selbst, sondern laden `libreta-core.so` und rufen die passende C-ABI-Funktion.

## Geprüftes Layout

`scripts/check_build_layout.sh` verlangt nun ausdrücklich:

- `target/bin/reta` existiert als natives ELF-Executable.
- `target/bin/grundStrukHtml` existiert als natives ELF-Executable.
- `target/lib/reta/libreta-core.so` existiert als ELF-Shared-Library.
- alle drei Artefakte besitzen Source-ID-Sidecars.
- beide Starter und `libreta-core.so` stammen aus demselben Quellstand.

Damit wird verhindert, dass ein alter Starter versehentlich mit einer neueren
oder älteren Core-Bibliothek kombiniert wird.

## Bewusst noch nicht geändert

Die historischen direkten Native-Ziele bleiben vorerst erhalten:

- `reta-native`
- `grundStrukHtml-native`

Auch die installierten Shell-Launcher werden in dieser Stage noch nicht hart
umgeschaltet. Diese Stage stabilisiert zuerst den Buildvertrag. Der nächste
Schritt kann dann die Install-/Launcher-Umschaltung sein.

## Prompt-Bibliotheken

Die Zielarchitektur aus 12c5fo bleibt unverändert:

- `libreta-prompt.so` für `rp/rpl/rpe/rpb`
- `libreta-prompt-interactive.so` nur für `rp/rpl/rpe`
- `rpb` verwendet keine interaktive Prompt-Eingabe-Bibliothek

Diese Stage baut noch keine Prompt-Shared-Libraries; sie macht nur den
Core-Pfad offiziell.
