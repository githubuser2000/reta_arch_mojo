# Stage 12c5di – Python-/Math-Promptprozesse als argv-Pläne

## Ziel

Nach `12c5dh` plante der native Interaktions-Owner den normalen `shell`-Promptpfad
bereits als argv-Vektor.  `python` und `math` trugen dagegen im gemeinsamen
`PromptExternalProcessDispatchPlan` noch eine separate Payload-Spalte.  Das war
für die spätere `.so`/`.dll`-Zielarchitektur eine unsaubere Restgrenze: der
Prozessadapter musste für einige normale Promptpfade noch die semantische
Sonderform `external_process.payload` kennen.

Diese Stage zieht die Grenze weiter in Richtung des gewünschten Zielrahmens:
Prompt-Execution baut fertige Prozessargumente, Process führt sie aus.

## Änderung

`PromptExternalProcessDispatchPlan` enthält für normale externe Promptprozesse
keine separate Payload mehr.

Vorher:

```mojo
struct PromptExternalProcessDispatchPlan:
    handled
    payload
    arguments
    run_shell
    run_python
    run_math
    run_reta
```

Jetzt:

```mojo
struct PromptExternalProcessDispatchPlan:
    handled
    arguments
    run_shell
    run_python
    run_math
    run_reta
```

Der Interaktions-Owner baut jetzt auch für `python` und `math` einen
argv-kompatiblen Einargument-Vektor:

```text
python print(1) -> arguments = ["print(1)"]
math 1+1       -> arguments = ["1+1"]
```

Die historische Rohtext-Erhaltung bleibt erhalten: der String nach dem ersten
Promptwort wird weiterhin bytegenau über `_prompt_command_payload(command)`
gewonnen.  Neu ist nur, dass dieser Payload sofort im Interaktions-Owner in den
Argumentvektor gelegt wird.

## Prozessadapter

Neue normale argv-Einstiege:

```mojo
run_python_prompt_arguments_native(arguments, reference_root)
run_math_prompt_arguments_native(arguments, reference_root)
```

Die alten Payload-Helfer bleiben als Kompatibilitätsfassaden erhalten:

```mojo
run_python_prompt_payload_native(payload, reference_root)
run_math_prompt_payload_native(payload, reference_root)
```

Sie verpacken den Payload nur noch lokal in einen Einargument-Vektor und rufen
den neuen argv-Einstieg.  Dadurch können alte Legacy-Fassaden weiter existieren,
während der produktive Promptcontroller keine Payload-Spalte mehr braucht.

## Controller

`prompt_main.mojo` dispatcht jetzt alle normalen externen Promptarten per
`external_process.arguments`:

```text
shell  -> run_shell_prompt_arguments_native(arguments)
python -> run_python_prompt_arguments_native(arguments)
math   -> run_math_prompt_arguments_native(arguments)
reta   -> run_reta_arguments_native(arguments)
```

## Bedeutung für die spätere Library-Aufteilung

Das passt zum festgelegten Zielrahmen:

```text
prompt-reaction:
  Eingabe, Promptzeile, History, Tastaturreaktion

prompt-execution:
  Klassifikation, Effektentscheidung, argv-Bau

process:
  OS-/Child-Prozessausführung mit fertigen Argumenten
```

Die Prozessadapter- `.so`/`.dll` muss damit für normale Promptpfade keine
`PromptExternalProcessDispatchPlan.payload`-Sonderform mehr kennen.  Die
Payload-Helfer sind nur noch Legacy-Eingänge.

## Neuer Snapshotmarker

```text
external_python_math_arguments=native-prompt-python-math-argv-plan
```

Der ältere Payload-Marker wurde präzisiert zu:

```text
external_process_arguments=native-prompt-process-argv-plan
```

## Nicht geändert

- Keine technische `.so`/`.dll`-Umsetzung.
- Keine Mojo-Kompilation durch ChatGPT.
- Keine Änderung an den historischen Legacy-Payload-Fassaden.
- Keine Änderung an der Python-Referenz.
