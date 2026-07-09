# Stage 12c5do – prompt reaction storage owner

Diese Stage verschiebt die gemeinsamen Prompt-Speicherentscheidungen aus dem
lokalen Reaktionsdispatch in einen eigenen nativen Owner:

- `src/reta_mojo/prompt_reaction_storage.mojo`

Der neue Owner enthält:

- `PromptInlineStoragePlan`
- `PromptStorageOutputPlan`
- `PromptStoredDefaultPlan`
- `plan_inline_storage_command(...)`
- `plan_inline_storage_output_command(...)`
- `plan_stored_default_command(...)`
- `prompt_reaction_storage_contract_snapshot()`

## Warum

`prompt_reaction_input.mojo` und `prompt_reaction_dispatch.mojo` brauchten beide
dieselben Speicherregeln:

- positionsunabhängiges `S`/`s`-Speichern,
- positionsunabhängiges `o`/`BefehlSpeicherungAusgeben`,
- leeres Enter als gespeicherter Default-Befehl.

Diese Logik ist weder physische Eingabe noch lokaler Effekt-Dispatch. Sie ist
eine gemeinsame Speichersemantik der späteren `libreta_prompt_mojo-reaction`-Grenze.

## Architekturwirkung

Die spätere Zielstruktur bleibt:

```text
libreta_prompt_mojo-reaction
  ├─ prompt_reaction_input
  ├─ prompt_reaction_storage
  └─ prompt_reaction_dispatch

libreta_prompt_mojo-execution
  └─ prompt_process_dispatch

libreta-process
  └─ prompt_external_commands
```

`prompt_reaction_storage` hängt nicht von `libreta_core_mojo`, nicht von
`prompt_process_dispatch` und nicht vom OS-Prozessadapter ab.

## Kompatibilität

Die sichtbare Prompt-Fassade bleibt kompatibel. `PromptScope(...)` wird weiterhin
in historischer Reihenfolge rekonstruiert, aber jetzt aus vier nativen Contracts:

1. `prompt_interaction_contract_snapshot()`
2. `prompt_reaction_input_contract_snapshot()`
3. `prompt_reaction_storage_contract_snapshot()`
4. `prompt_reaction_dispatch_contract_snapshot()`
5. `prompt_process_dispatch_contract_snapshot()`

no `.so`/`.dll` split is implemented in this stage. Die Stage dokumentiert und
festigt nur die spätere Library-Grenze im nativen Mojo-Quellbaum.
