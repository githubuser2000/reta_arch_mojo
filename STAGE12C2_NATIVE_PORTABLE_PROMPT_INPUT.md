# Stage 12c2 – portabler nativer Prompt-Eingabekanal

Stage 12c2 trennt portable Mojo-I/O von der verbleibenden historischen
TTY-Line-Editor-Grenze. Die öffentlichen Befehle und Profile bleiben
unverändert.

## Was „nativ über ioctl(TIOCGWINSZ)“ bedeutet

„Nativ“ bedeutet hier nur: Mojo ruft die C-/Betriebssystem-Schnittstelle direkt
auf; es wird weder Python noch ein `stty`-Kindprozess benötigt. `ioctl` bleibt
aber eine Betriebssystem-ABI:

| Ziel | Backend | Request |
|---|---|---:|
| Linux und WSL | `linux-ioctl` | `0x5413` |
| macOS/Darwin | `darwin-ioctl` | `0x40087468` |
| sonstige Ziele | `environment-fallback` | kein `ioctl` |

`terminal_geometry.mojo` fragt das Ziel über `CompilationTarget` ab. Wenn keine
native Geometrie verfügbar ist, werden `COLUMNS` und danach der historische
80-Spalten-Wert verwendet. Die OS-Abhängigkeit ist damit in einem kleinen
Adapter gekapselt; Tabellenrenderer und Promptlogik bleiben davon unabhängig.

## Nativer Eingabekanal

`native_prompt_input.mojo` verwendet Mojos eingebaute `input()`-Funktion für:

- stdin-Pipes;
- umgeleitete Eingabe;
- ausdrücklich mit `RETA_PROMPT_PLAIN_INPUT=1` gewählte schlichte Eingabe.

Der Kanal besitzt:

- dieselben Promptpräfixe (`> `, `speichern> `, `loeschen> `);
- den historischen EOF-Sentinel `\x04`;
- best-effort History-Persistenz nach `~/.ReTaPromptHistory`;
- bewusst erhaltene doppelte History-Einträge;
- keine vorsorgliche Python-Initialisierung.

Python wird in `prompt_main.mojo` nun erst importiert, wenn tatsächlich eine
Kompatibilitätsgrenze benutzt wird.

## Warum der echte TTY-Editor noch nicht blind ersetzt wird

Auf einem realen TTY bleiben GNU Readline, Vi-Modus und die Completion-Callback-
Grenze zunächst unverändert. Mojos schlichtes `input()` liest zwar portabel
eine Zeile, bietet aber nicht automatisch dieselbe Vi-Tastenbelegung,
History-Navigation und Tab-Completion. Eine bedingungslose Umstellung würde
somit das beobachtbare Verhalten der Profile `rp` und `rpl` ändern. Stage 12c2
portiert deshalb den semantisch sicheren Teil; die vollständige TTY-
Line-Editor-Parität folgt in 12c4.

## Tests

- native Eingabe-/History-Tests: 3/3;
- Pipe- und EOF-Proben: 2/2;
- Source-Ownership/Lazy-Python-Tests: 2/2;
- Terminalgeometrie einschließlich Zielbackend: 4/4;
- Boundary-Audit: 1/1;
- POSIX-Prozessprimitive: 0;
- explizite Restbrücken: 2.

Der große Promptcontroller bleibt Bestandteil von `scripts/build.sh`. Seine
monolithische Elaboration überschritt in der Sandbox erneut das verdoppelte
Compilerlimit; alle neuen kleinen Module und Proben wurden mit dem finalen
Quellstand kompiliert und ausgeführt.

## Verbleibender Stage-12c-Umfang

- 12c3: hintere Promptausführungszweige und i18n-Restpfade;
- 12c4: vollständig nativer TTY-Line-Editor mit Vi-, History- und Completion-
  Parität sowie Entfernung der Prompt-`std.python`-Grenze.
