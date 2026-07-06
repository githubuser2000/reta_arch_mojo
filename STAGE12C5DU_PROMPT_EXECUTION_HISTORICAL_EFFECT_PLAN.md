# Stage 12c5du – Prompt execution historical effect plan

This stage moves the remaining pure companion-effect and logging-transition
membership logic for historical table and `mulpri` prompt execution out of
`src/prompt_main.mojo` and into `src/reta_mojo/prompt_execution.mojo`.

New native owner surface:

- `PromptExecutionHistoricalEffectPlan`
- `plan_prompt_execution_historical_effects(...)`

The controller still performs the visible effects: printing command lists,
help, compound clear lines and mutating the session logging flag. The decision
rules and fixed ordering around `kurzbefehle`, `befehle`, `h/help/hilfe`,
`leeren`, `loggen` and `nichtloggen` now belong to the prompt-execution owner,
so the interactive and one-shot controllers do not wire
`prompt_historical_ownership.mojo` directly.

No `.so`/`.dll` split is implemented in this stage. The change is a pure
ownership/transpilation step inside the existing native executable layout.
