# Stage 12c5es – Prompt process residual fallback result owner

Diese Etappe zieht die letzte interaktive Residual-Fallback-Result-Rückgabe aus dem
Prompt-Controller in den Prompt-Process-Dispatch-Besitzer.

Neu ist:

- `PromptResidualFallbackProcessResultPlan`
- `plan_prompt_residual_fallback_process_result(...)`
- Snapshot-Marker `residual_fallback_process_result=native-prompt-residual-fallback-result-boundary`

Vorher führte `_run_command` den finalen `retaPrompt.py`-Residual-Fallback
optional aus und gab danach roh `True` zurück. Jetzt erzeugt der
Process-Dispatch-Besitzer einen Result-Plan; der Controller konsumiert nur noch
`residual_result.handled`.

Damit ist der interaktive Residual-Fallback analog zu den externen Process-
Edges in Execution, Boundary und Result aufgeteilt. Reale Prozess-I/O bleibt im
Controller/Adapter; die boolesche Rückgabeprojektion gehört dem reinen Owner.

Zusätzlich wurde der Abschlussmarker von `scripts/test_stage12c5er.sh`
korrigiert: er meldet jetzt `stage12c5er` statt versehentlich `stage12c5eq`.
