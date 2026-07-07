# Stage 12c5ey: Prompt-Execution-One-Shot-Native-Completion-Result

Dieser Schritt zieht die Rückgabeprojektion direkt nach der nativen
One-Shot-Branch-Completion aus `_run_native_one_shot` heraus.

Vorher entschied der Controller nach
`plan_prompt_execution_native_branch_completion(...)` selbst mit einem direkten
`return True`, ob ein nativ behandelter Tabellen-/Mulpri-/Logging-Zweig die
One-Shot-Probe beendet. Jetzt besitzt `prompt_execution.mojo` diese Algebra mit:

- `PromptExecutionOneShotNativeCompletionResultPlan`
- `plan_prompt_execution_one_shot_native_completion_result(...)`

Damit wird die erste One-Shot-Ergebnisprojektion einheitlich typisiert:

- behandelte native Branch-Completion -> Probe erfolgreich beenden
- nicht behandelte Branch-Completion -> weiter zu Kompatibilitäts- und lokalen
  One-Shot-Dispatchern

Status 12c5ey:

- keine neue Python-Kompatibilitätsgrenze
- keine Änderung an sichtbarer Ausgabe
- nur die One-Shot-Return-Algebra nach nativer Branch-Completion wandert in den
  Prompt-Execution-Owner
