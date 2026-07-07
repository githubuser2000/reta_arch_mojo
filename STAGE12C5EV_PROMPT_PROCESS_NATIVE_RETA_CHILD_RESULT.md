# Stage 12c5ev – Prompt process native reta child result owner

## Ziel

`_run_native_reta_prompt_command` soll die finale handled-/Print-Projektion
für direkte native `reta`-Kindprozessversuche nicht mehr direkt aus
`startup.owned` und `native_reta_tokens_supported(...)` ableiten. Diese reine
Entscheidung gehört zum Prompt-Process-Dispatch-Owner.

## Änderung

Neu in `src/reta_mojo/prompt_process_dispatch.mojo`:

- `PromptNativeRetaChildResultPlan`
- `plan_prompt_native_reta_child_result(...)`
- Contract-Marker
  `native_reta_child_result=native-prompt-reta-child-result-boundary`

`src/prompt_main.mojo` fragt weiterhin die echten nativen Startup- und
Tabellenfähigkeiten ab und druckt weiterhin die reale Ausgabe. Die reine
Zuordnung

- Startup wurde nativ gehandhabt → Startup-Ausgabe drucken, handled
- native reta-CLI akzeptiert Token → native reta-Ausgabe drucken, handled
- sonst → nicht handled, Referenz-/Kompatibilitätsgrenze bleibt offen

liegt nun aber als typed result plan im Process-Owner.

## Warum klein und sicher

Die Stage verschiebt keine I/O-Seite und verändert keine Ausgabe. Sie ersetzt
nur die boolesche Rückgabeprojektion im Controller durch einen typisierten Plan.
Die reale Ausgabe bleibt an derselben Stelle.

## Prüfungen

Source-Guards prüfen:

- neuen Struct und Planner im Process-Owner
- Import und Nutzung in `prompt_main.mojo`
- aktualisierten Process-Contract und Legacy-`PromptScope`
- neuen Mojo-Contract-Test in `tests/test_prompt_interaction.mojo`
