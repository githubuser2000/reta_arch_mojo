# Stage 12c5cm – External process payload ownership

## Ziel

Der Prozesscontroller soll nicht mehr selbst die Payloads von `shell`, `python`
und `math` aus der Rohzeile ableiten. Die Entscheidung, welcher externe
Prompt-Prozessrand gemeint ist, lag bereits bei `prompt_interaction.mojo`; nun
liegt dort auch der trennscharfe Nutzlastanteil nach dem ersten Promptwort.

## Änderungen

- `PromptExternalProcessDispatchPlan` enthält jetzt zusätzlich `payload`.
- `plan_external_process_dispatch(...)` füllt `payload` für `shell`, `python`
  und `math` bytegenau aus `command.raw`.
- `reta` behält den geplanten `arguments`-Vektor aus Stage 12c5cl; der
  Fallbackpfad behält weiterhin die Rohzeile, weil der historische `reta`-Child
  dort noch das vollständige shlex-Verhalten besitzt.
- `prompt_main.mojo` ruft für `shell`, `python` und `math` nur noch die
  Payload-Adapter auf und liest nicht mehr selbst aus `external_process.raw`.
- Die alten Line-Wrapper bleiben in `prompt_external_commands.mojo`, damit
  bestehende Tests und direkte Adapterbenutzung stabil bleiben.

## Prüfung

`scripts/test_stage12c5cm.sh` baut bei lokaler Mojo-Verfügbarkeit die
Prompt-/Legacy-/Tabellenadapterziele neu und führt zusätzlich die
compilerfreien Source-, Ledger-, Metrik- und Archivverträge aus.
