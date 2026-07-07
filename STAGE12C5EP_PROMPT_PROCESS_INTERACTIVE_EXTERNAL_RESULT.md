# Stage 12c5ep – Prompt process interactive external result owner

Diese Etappe verschiebt die letzte reine Rückgabeentscheidung nach interaktiven
`shell`-/`python`-/`math`-/direkten `reta`-Kindprozessen in den
Prompt-Process-Dispatch-Owner.

Neu ist diese Interactive-External-Result-Grenze:

- `PromptInteractiveExternalResultPlan`
- `plan_interactive_external_process_result(...)`
- Contract-Marker `interactive_external_result=native-prompt-process-result-boundary`

Vorher gab der Controller nach der optionalen Reference-`reta`-Ausführung direkt
`external_completion.handled` zurück. Jetzt konsumiert der Controller ein
geplantes Resultat und gibt `external_result.handled` zurück. Damit liegen
Execution, Completion, optionaler Reference-`reta`-Kindprozess und finale
Handled-Projektion alle im Process-Owner; echte Prozess-I/O bleibt im Controller.
