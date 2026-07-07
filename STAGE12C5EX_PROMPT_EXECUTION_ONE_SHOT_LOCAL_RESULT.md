# Stage 12c5ex: Prompt-Execution-One-Shot-Local-Result

Dieser Schritt zieht die lokale Rückgabeprojektion in `_run_native_one_shot`
aus dem Prozesscontroller heraus. Die eigentlichen lokalen Dispatch-Owner bleiben
unverändert:

- `prompt_reaction_dispatch.mojo` plant Informationsbefehle, Terminal-Clear,
  stateless One-Shot-Logging und deterministische kleine Ausgaben.
- `prompt_main.mojo` führt die sichtbaren Terminaleffekte weiterhin aus.
- `prompt_execution.mojo` besitzt jetzt mit `PromptExecutionOneShotLocalResultPlan`
  und `plan_prompt_execution_one_shot_local_result(...)` die boolesche
  Ergebnisprojektion nach diesen lokalen Effekten.

Damit gibt `_run_native_one_shot` für `hilfe`, `befehle`, `kurzbefehle`,
`leeren`, `loggen`, `nichtloggen`, `prim`, `multis`, `modulo`, Distanz- und
ABC-Hilfsbefehle nicht mehr direkt `True` aus den lokalen Dispatch-Blöcken
zurück, sondern konsumiert jeweils ein typisiertes Prompt-Execution-Result.

Status 12c5ex:

- keine neue Python-Kompatibilitätsgrenze
- keine Änderung an der historischen Ausgabe
- nur die One-Shot-Result-Algebra wandert in den Prompt-Execution-Owner
