# Stage 12c5dk – Prompt process dispatch owner

Diese Stage verschiebt die externe Prompt-Prozessplanung aus dem
Interaktions-Owner in einen eigenen Prompt-Execution-Owner.

## Ziel

Die spätere `.so`/`.dll`-Zielarchitektur trennt drei Rollen:

- `libreta_prompt_mojo-runtime`: Prompt-Kommandos, Profile und argv-Bausteine.
- `libreta_prompt_mojo-execution`: Effektentscheidung und Dispatch-Pläne.
- `libreta-process`: Ausführung bereits gebauter argv-/Payload-Prozesse.

Vor dieser Stage lagen die Prozess-Dispatch-Strukturen und Planer noch in
`prompt_interaction.mojo`, obwohl sie nicht zur Eingabe-/History-/Session-Reaktion
gehören.

## Änderung

Neu:

```text
src/reta_mojo/prompt_process_dispatch.mojo
```

Dorthin verschoben wurden:

```mojo
PromptExternalProcessDispatchPlan
PromptFallbackProcessDispatchPlan
plan_external_process_dispatch(...)
plan_prompt_fallback_process_dispatch(...)
prompt_process_dispatch_contract_snapshot()
```

`prompt_interaction.mojo` behält die interaktive Lebenszykluslogik:

```text
Startup → Session
physische Eingabe
History/previous-command
Store/Delete-Zustände
Inline-Speicherlogik
Info-/Logging-/Simple-Output-Pläne
```

`prompt_process_dispatch.mojo` besitzt jetzt die Prozess-Effektplanung:

```text
shell  -> argv + run_shell
python -> argv + run_python
math   -> argv + run_math
reta   -> argv + run_reta
fallback -> retaPrompt.py argv + run_reta_prompt
```

`prompt_main.mojo` importiert die externen Prozessplaner nun aus dem neuen Owner:

```mojo
from reta_mojo.prompt_process_dispatch import (
    plan_external_process_dispatch,
    plan_prompt_fallback_process_dispatch,
)
```

## Warum das eine echte Grenzreduktion ist

Der Interaktions-Owner hatte noch Wissen über externe Prozess-Effekte. Das ist
für eine spätere Library-Grenze schlecht, weil `prompt-reaction` dann indirekt
`process`-Semantik enthält.

Nach dieser Stage gilt:

```text
prompt_interaction:
  Eingabe-/Session-Reaktion

prompt_process_dispatch:
  Prompt-Execution-Prozesspläne

prompt_external_commands:
  reine OS-/Child-Prozessausführung
```

Damit passt der Code besser zum geplanten Split:

```text
rp/rpl/rpe:
  prompt-interactive
    -> prompt-reaction
    -> prompt-execution
      -> reta-core
      -> process

rpb:
  prompt-batch
    -> prompt-execution
      -> reta-core
      -> process
```

Die reine Eingabe-/Reaktionsschicht muss dadurch keine externe Prozessplanung
mehr besitzen.

## Kompatibilität

Die Funktionsnamen und Plan-Strukturen bleiben gleich. Nur der Modul-Owner
ändert sich. Dadurch bleiben die produktiven Kontrollflüsse stabil:

```text
prompt_main.mojo
  -> prompt_interaction für interaktive Zustände
  -> prompt_process_dispatch für externe Effektpläne
  -> prompt_external_commands für Kindprozess-Ausführung
```

Es wird keine `.so` oder `.dll` erzeugt. Diese Stage bereitet nur die spätere
Grenze vor.
