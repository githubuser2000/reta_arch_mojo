# Stage 12c5ch – Bare deterministic prompt output dispatch ownership

## Ziel

Die verbleibenden wiederholten Bare-Branches für deterministische Prompt-Ausgaben
lagen noch direkt in `src/prompt_main.mojo`.  `prim`, `multis`, `modulo`,
`abc` und die verwandten Distanz-/Vergleichsbefehle wurden dadurch sowohl im
interaktiven Loop als auch im nativen One-Shot-Pfad als einzelne
`command.kind`-Abfragen offen codiert.

12c5ch verschiebt diese Entscheidung in den nativen Interaktionsbesitzer.
Der Prozesscontroller druckt nur noch die geplanten Zeilen.

## Native Grenze

Neu in `src/reta_mojo/prompt_interaction.mojo`:

- `PromptSimpleOutputDispatchPlan`
- `plan_simple_output_dispatch(command, language)`

Der Plan besitzt die deterministischen, zustandsfreien Prompt-Ausgaben:

- `prim` / `prim24`
- `multis` / `multis3`
- `modulo`
- `primfaktorenvergleich`
- `abstand` / Primabstand
- `abc`

Shell-, Python-, Math- und vollständige `reta`-Ausführung bleiben bewusst im
Prozess-/Betriebssystemrand beziehungsweise im CLI-Besitzer.

## Controller-Folge

`src/prompt_main.mojo` enthält für diese Bare-Kommandos keine wiederholten
`if command.kind == ...`-Ausgabebranches mehr. Beide Pfade delegieren an
`plan_simple_output_dispatch(...)`:

- interaktiver Prompt
- nativer One-Shot-Prompt

`mulpri` bleibt vorerst separat, weil es eine historische Kombination aus
Primvergleich, Primzeilen und `multis`-Zeilen mit eigener Präsentationsregel
bildet.

## Prüfgrenze

Die Stage baut weiterhin frisch:

- `tests/test_prompt_interaction.mojo`
- `tests/test_legacy_reta_prompt.mojo`
- `tests/test_table_adapters.mojo`

Die Source-Verträge prüfen, dass der neue Plan existiert, der Controller die
Bare-Ausgaben delegiert und der Snapshot die neue Besitzgrenze enthält.
