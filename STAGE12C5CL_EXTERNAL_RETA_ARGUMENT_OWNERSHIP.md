# Stage 12c5cl – External-Reta-Argumente im Interaktionsbesitzer

Diese Stufe schließt die kleine Restkante aus Stage 12c5ck: Der Prozesscontroller
erhält für den bewusst externen `reta`-Promptprozess nicht mehr nur den rohen
Befehl, sondern auch die bereits im Interaktionsbesitzer abgetrennten `reta`-
Argumente.

## Änderung

- `PromptExternalProcessDispatchPlan` trägt jetzt zusätzlich `arguments: List[String]`.
- `plan_external_process_dispatch(...)` plant für `KIND_RETA` die Nutzargumente
  aus `command.words[1:]` über `_prompt_command_arguments(...)`.
- `prompt_main.mojo` importiert `KIND_RETA` nicht mehr und prüft nicht mehr
  selbst `command.kind != KIND_RETA`.
- `_run_native_reta_prompt_command(...)` arbeitet nur noch auf geplanten Tokens.
- Der Snapshot enthält `external_reta_arguments=native-prompt-reta-argv-plan`.

Die tatsächlichen OS-/Prozessränder für `shell`, `python`, `math` und nicht
vollständig nativ unterstützte `reta`-Befehle bleiben weiterhin im
Prozesscontroller beziehungsweise im expliziten Fallbackprozess.

## Prüfpfad

Der Stage-Lauf ist `scripts/test_stage12c5cl.sh`. Er baut die Prompt-/Legacy-/
Tabellenadapter-Regressionen und führt die compilerfreien Source-, Ledger-,
Metrik- und Archivverträge aus.
