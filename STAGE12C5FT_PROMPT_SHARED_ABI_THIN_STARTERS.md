# Stage 12c5ft – Prompt-Shared-ABI und dünne Prompt-Starter vorbereitet

Diese Stage setzt den nächsten Schritt der gewünschten Shared-Library-Struktur
um, ohne den vollständigen Build schon riskant umzuhängen.

## Neue ABI-Spur

- `libreta-prompt.so` / später `libreta-prompt.dll`
  - gemeinsamer Prompt-Ausführungskern für `rp`, `rpl`, `rpe`, `rpb`
  - enthält den One-shot-Pfad für `rpb`
  - wird über `src/reta_prompt_abi.mojo` exportiert

- `libreta-prompt-interactive.so` / später `libreta-prompt-interactive.dll`
  - interaktive Eingabe-, Session-, History- und Line-Editor-Spur
  - nur für `rp`, `rpl`, `rpe` vorgesehen
  - wird über `src/reta_prompt_interactive_abi.mojo` exportiert

## Starter-Verhalten

`tools/reta_prompt_loader.c` entscheidet nach dem aufgerufenen Programmnamen:

- `rpb` lädt nur `libreta-prompt.so`
- `rp`, `rpl`, `rpe` laden `libreta-prompt-interactive.so`
- `retaPrompt` und `retaPrompt.english` bleiben als interaktive Profile vorgesehen

Damit ist die harte Architekturregel testbar: `rpb` zieht die interaktive
Prompt-Eingabe-Bibliothek nicht in den One-shot-Pfad.

## Neuer Build-Pfad

`scripts/build_prompt_shared.sh` baut optional:

- `target/lib/reta/libreta-prompt.so`
- `target/lib/reta/libreta-prompt-interactive.so`
- `target/bin/rp`
- `target/bin/rpl`
- `target/bin/rpe`
- `target/bin/rpb`

Diese Ziele sind noch nicht Teil von `scripts/build-all.sh`.  Das ist
absichtlich so: erst lokal grün bekommen, dann offiziell einhängen.

## Controller-Faktorierung

`src/prompt_main.mojo` enthält jetzt `run_prompt_profile_from_args(...)`.  Das
bestehende `main()` ruft diese Funktion weiterhin auf, während die neuen ABI
Wrapper denselben nativen Controller ohne Shell-/Python-Umweg verwenden können.
