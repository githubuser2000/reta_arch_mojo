# Stage 12c5dj – Prompt-Runtime besitzt die externen Kommando-argv-Builder

Diese Stage zieht die letzten lokalen argv-Hilfsfunktionen aus dem nativen
Prompt-Interaktions-Owner heraus und legt sie in den Prompt-Runtime-Owner.

## Änderung

Vorher lagen in `src/reta_mojo/prompt_interaction.mojo` noch lokale Helfer:

- `_prompt_command_arguments(...)`
- `_prompt_command_payload(...)`
- `_prompt_command_payload_arguments(...)`

Diese Helfer bauten die Argumentvektoren für die externen Prompt-Prozesse.
Damit enthielt der Interaktions-Owner noch argv-Bau-Semantik, obwohl er
hauptsächlich Effektentscheidungen liefern soll.

Jetzt liegen die entsprechenden Builder in `src/reta_mojo/prompt_runtime.mojo`:

- `command_argument_tail(...)`
- `command_raw_payload(...)`
- `command_raw_payload_arguments(...)`
- `command_shell_arguments(...)`

`prompt_interaction.mojo` verwendet diese Runtime-Funktionen nur noch im
`PromptExternalProcessDispatchPlan`.

## Neue Grenze

```text
prompt_runtime:
  PromptCommand
  raw payload slicing
  shell argv tokenization
  python/math payload argument vectors
  reta argv tail builder

prompt_interaction:
  command kind routing
  external process effect flags
  typed dispatch plan

prompt_external_commands:
  OS-/Child-Prozess-Ausführung
```

Damit wird der spätere `.so`-/`.dll`-Split sauberer: Die spätere
`libreta_prompt_mojo-runtime` besitzt die Umwandlung von klassifizierten
Prompt-Kommandos in argv-Vektoren. Die Interaktions-Library muss nur noch
entscheiden, welcher Effekt ausgeführt werden soll.

## Snapshotmarker

```text
external_command_arguments=runtime-owned-command-argv-builders
```

## Keine Verhaltensänderung

Die beobachtbare Semantik bleibt erhalten:

- `shell` verwendet weiterhin die genaue Raw-Payload-Semantik und danach
  `shell_split(...)`.
- `python` und `math` behalten den exakten Raw-Payload als ein Argument.
- `reta` erhält weiterhin die Wörter nach dem Kommando-Token als argv-Tail.
- Legacy-Payload-Fassaden im Prozessadapter bleiben unverändert erhalten.

## Bezug zur geplanten Shared-Library-Zielarchitektur

Diese Stage bereitet die spätere Trennung vor:

```text
libreta_prompt_mojo-runtime.so/.dll
  besitzt PromptCommand -> argv-Bau

libreta_prompt_mojo-execution.so/.dll
  besitzt Dispatch-Pläne und Effektentscheidungen

libreta-process.so/.dll
  führt nur fertige argv/Payload-Prozesse aus
```

Die technische `.so`-/`.dll`-Umstellung wird noch nicht durchgeführt.
