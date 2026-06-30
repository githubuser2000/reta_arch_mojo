# Stage 12c4a – Prompt-Bridge und FFI-Integration

Der vollständige lokale Build von Stage 12c3 deckte einen Integrationsfehler
auf, den der isolierte Modultest nicht sehen konnte: `prompt_main.mojo`
importiert `std.python`, während `prompt_external_commands.mojo` eine eigene
`dlsym`-Deklaration mit abweichendem Mojo-Rückgabetyp erzeugte. Beim gemeinsamen
Lowering entstand deshalb eine konfliktbehaftete C-Signatur.

## Korrektur

Der externe Promptbefehl verwendet nun den standardisierten libc-Aufruf
`system()`. Der bereits vollständig einzelargument-gequotete Befehl wird
synchron über `/bin/sh -c` ausgeführt; stdin, stdout, stderr und Umgebung werden
vom Kind geerbt. `dlopen`, `dlsym`, der manuelle Zugriff auf `environ`,
`posix_spawn` und `waitpid` entfallen aus dem Mojo-Modul.

## Schmale Python-Grenze

`prompt_main.mojo` enthält keine `Python`- oder `PythonObject`-Typen mehr. Die
verbleibenden drei Operationen sind in `prompt_python_bridge.mojo` isoliert:

1. echter TTY-Readline-/Vi-/Completion-Eingang,
2. atomarer historischer Promptfallback,
3. ein noch nicht vom nativen CLI besessener `reta`-Aufruf.

## Build und Tests

Für die vollständige Kompilierung reichen:

```bash
scripts/build-heavy.sh
scripts/build.sh
```

Die Prüfscripte sind optional. `scripts/test_stage12c.sh` ruft die einzelnen
12c-Prüfungen bereits auf; `check_prompt_external_commands.sh` muss daher nicht
zusätzlich separat gestartet werden.

Neu ist `tests/prompt_external_python_ffi_probe.mojo`. Es importiert
`std.python` und den Kindprozessadapter im selben kleinen Compilerziel und
reproduziert damit genau die Integrationsbedingung des gemeldeten Fehlers.
