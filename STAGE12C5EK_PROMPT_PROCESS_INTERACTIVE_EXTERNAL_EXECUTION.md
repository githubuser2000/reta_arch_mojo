# Stage 12c5ek – Prompt process interactive external execution owner

Diese Etappe repariert zuerst den durch die Process-Scope-Erweiterung sichtbar
gewordenen Legacy-Snapshot-Zählvertrag: `PromptScope` enthält nun die neuen
Process-Dispatch-Grenzen und der Test erwartet die erweiterte native Oberfläche.

Zusätzlich wird die Interactive-External-Execution / interaktive External-Process-Ausführung weiter aus dem
Controller herausgezogen.  `prompt_process_dispatch.mojo` besitzt nun
`PromptInteractiveExternalExecutionPlan` und
`plan_interactive_external_process_execution`.  Der Controller führt weiterhin
die realen Shell-/Python-/Math-/reta-Kindprozesse aus, konsumiert vor der I/O-
Grenze aber nicht mehr direkt die rohen Dispatch-Flags.

Damit sind die drei interaktiven External-Process-Schichten explizit getrennt:

1. `plan_external_process_dispatch` baut den argv-/Effektplan.
2. `plan_interactive_external_process_execution` entscheidet die konkrete
   interaktive Kindprozess-Ausführung.
3. `plan_interactive_external_process_completion` entscheidet den Abschluss und
   den optionalen Referenz-reta-Kindprozess.

Es wird keine `.so`/`.dll` erzeugt.  Die Änderung bereitet nur die spätere
Shared-Library-Grenze vor, weil die pure Process-Dispatch-Bibliothek weniger
Controller-Algebra enthält.
