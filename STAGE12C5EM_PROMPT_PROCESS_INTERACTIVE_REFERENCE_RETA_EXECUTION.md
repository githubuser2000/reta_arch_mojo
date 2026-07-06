# Stage 12c5em – Prompt process interactive reference reta execution owner

Diese Etappe zieht die letzte reine Entscheidungsgrenze nach einem interaktiven
externen `reta`-Aufruf in den Prompt-Process-Dispatch-Owner.

Vorher las `prompt_main.mojo` nach dem nativen `reta`-Kindprozessversuch noch
direkt `external_completion.run_reference_reta` und reichte die Argumentliste aus
der externen Ausführung an `run_reta_arguments_native` weiter.

Jetzt erzeugt `plan_interactive_reference_reta_process_execution(...)` einen
kleinen, controller-facing Plan:

- `should_run_reference_reta` entscheidet, ob der historische Reference-reta
  Kindprozess benötigt wird;
- `arguments` enthält die kopierte argv-Liste für den Prozessadapter.

Damit bleibt echte Prozess-I/O im Controller/Adapter, aber die pure
Fallback-Entscheidung für interaktives direktes `reta` liegt nicht mehr als rohe
Boolesche Algebra in `prompt_main.mojo`.

Diese Etappe ist bewusst klein, damit die Prompt-Shared-Library-Grenze stabil
bleibt: Process-Dispatch plant, Process-Adapter führt aus.
