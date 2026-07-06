# Stage 12c5dh – Prompt external shell argv plan

Diese Stage zieht den interaktiven `shell`-Promptpfad eine weitere Schicht
weg vom Prozessadapter. Der Prozessadapter kann weiterhin historische Payload-
Kompatibilitätshelfer bedienen, aber der normale Prompt-Controller verwendet
nun einen bereits vom Interaktions-Owner geplanten argv-Vektor.

## Änderung

Vorher:

```text
prompt_interaction.mojo
  shell -> payload = "echo hi", arguments = []
prompt_main.mojo
  run_shell_prompt_payload_native(external_process.payload)
prompt_external_commands.mojo
  payload -> shell_split(payload) -> system(...)
```

Jetzt:

```text
prompt_interaction.mojo
  shell -> payload = "", arguments = shell_split("echo hi")
prompt_main.mojo
  run_shell_prompt_arguments_native(external_process.arguments)
prompt_external_commands.mojo
  argv -> shell_quote je Element -> system(...)
```

Der historische `run_shell_prompt_payload_native(...)` bleibt als Kompatibilitäts-
Einstieg vorhanden. Er tokenisiert weiterhin über den Runtime-Owner und ruft den
neuen argv-Einstieg auf. Der Produktivpfad des nativen Prompt-Controllers muss
aber keine Shell-Payload mehr an den Prozessadapter übergeben.

## Neuer Snapshotmarker

```text
external_shell_arguments=native-prompt-shell-argv-plan
```

## Bedeutung für spätere `.so` / `.dll`

Diese Stage passt zum geplanten Zielrahmen:

```text
libreta-prompt-reaction.so
  Eingabe, Tastaturreaktion, Prompt-Zeile, History

libreta-prompt-execution.so
  klassifizierte Prompt-Kommandos, Effektpläne, argv-Bau

libreta-process.so
  nur OS-Prozessausführung mit fertigen Payloads oder argv-Vektoren
```

Der normale interaktive `shell`-Pfad liefert jetzt einen fertigen argv-Vektor an
`libreta-process`. Dadurch muss der spätere Prozessadapter weniger Prompt-
Semantik besitzen.

## Nicht geändert

- Keine `.so`-/`.dll`-Umsetzung.
- Keine Änderung an `python`-/`math`-Payloads.
- Keine Entfernung historischer Legacy-Payload-Fassaden.
- Keine Mojo-Kompilation durch den Assistenten.
