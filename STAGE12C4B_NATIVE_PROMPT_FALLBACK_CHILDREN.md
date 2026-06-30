# Stage 12c4b – Native Kindprozessgrenze für Restfallback und `reta`

Stage 12c4a hatte alle verbliebenen Prompt-Python-Aufrufe in
`prompt_python_bridge.mojo` gekapselt. Zwei der drei Operationen brauchten
jedoch kein eingebettetes CPython: Sie importierten `mojo_bridge.py` nur, damit
dieser anschließend einen weiteren Python-Prozess startet.

## Übertragener Pfad

`prompt_external_commands.mojo` besitzt nun zusätzlich:

- `run_reta_line_native()` für noch nicht vom nativen CLI besessene
  `reta ...`-Zeilen;
- `run_reta_prompt_fallback_native()` für einen atomaren historischen
  Promptfallback mit typisierten Profilargumenten.

Beide Pfade verwenden denselben eng begrenzten, byteerhaltenden
Kindprozessadapter wie `shell`, `python` und `math`. POSIX-`shlex.split`, leere
Argumente, Unicode, Arbeitsverzeichnis, Umgebung, stdin, stdout, stderr und
Rückgabecode bleiben erhalten. Alle Argumente werden einzeln gequotet; die
Shell interpretiert keine Nutzereingabe als freien Befehlstext.

## Verbleibende eingebettete Python-Grenze

`prompt_python_bridge.mojo` exportiert jetzt nur noch
`read_prompt_line_encoded_bridge()`. Damit verbleibt ausschließlich der echte
TTY-Readline-/Vi-/Completion-Editor im eingebetteten CPython. Nicht-TTY-Eingabe
war bereits in Stage 12c2 nativ.

Die historischen Restalgorithmen selbst sind damit noch nicht nativ: Sie laufen
weiter in `retaPrompt.py` beziehungsweise `reta.py`, aber als explizit sichtbare
Kindprozesse statt über einen vorherigen In-Process-Python-Import.

## Prüfung

- Mojo-Shlex-/Quoting-Unit-Tests: **6/6**.
- Neuer nativer Adapterprobe kompiliert.
- Direkter `reta`-Argument-/Unicode-/Leerargumenttest: **1/1**.
- Atomarer Promptfallback mit Profilflags und Shellwörtern: **1/1**.
- Source-/Boundary-Gates für die eine verbleibende eingebettete Operation:
  **9/9**.
- Vier bereits vorhandene externe Byteparitätsfälle liefen in der
  Arbeitsumgebung erneut erfolgreich, bevor der langsame Gesamtlauf getrennt
  wurde.

Der unveränderte kombinierte `std.python`-FFI-Compilerprobe und der monolithische
Promptbuild elaborieren in der Sandbox weiterhin unverhältnismäßig lange. Die
geänderten nativen Module und der neue Integrationsprobe wurden dagegen
kompiliert; der vollständige Zielbuild bleibt `scripts/build.sh` auf dem
Zielsystem.
