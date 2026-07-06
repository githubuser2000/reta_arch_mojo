# Stage 12c5ea – Prompt execution branch fallback outcome owner

Diese Etappe zieht die letzte doppelte Nachentscheidung des gemeinsamen
Tabellen-/`mulpri`-Branches in den Prompt-Execution-Owner.

## Neu

- `plan_prompt_execution_native_branch_outcome(...)` entscheidet jetzt auch
  unattempted fallback cases: Ein abgewiesener zusammengesetzter Kandidat wird
  zur Kompatibilitätsgrenze geschickt, obwohl der Controller keinen nativen
  Render-Versuch startet.
- Der interaktive Prompt und `-befehl` benutzen denselben Ablauf:
  `native_handled = False`, optionaler nativer Branch-Versuch, danach genau
  ein `PromptExecutionNativeBranchOutcomePlan`.
- `prompt_main.mojo` besitzt keine getrennte `if native_branch.fallback_required`
  Nachprüfung mehr.

## Risiko

Niedrig: Die Änderung verschiebt Kontrollflussentscheidung, nicht Terminal-I/O
oder Tabellenrendering. Der Controller führt weiterhin nur die geplanten Effekte
aus oder startet den bestehenden Fallback.
