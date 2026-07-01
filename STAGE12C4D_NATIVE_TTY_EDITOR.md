# Stage 12c4d – nativer TTY-Editor und klassische Bruch-No-ops

Stage 12c4d entfernt die letzte eingebettete Python-Grenze aus dem interaktiven
Promptpfad. `prompt_main.mojo` liest reale Terminals nun über einen nativen
POSIX-Adapter und einen getrennt testbaren Mojo-Zeileneditor. Der explizite
Kindprozessfallback für noch nicht portierte Fachalgorithmen bleibt davon
unberührt; er importiert weiterhin kein CPython in den Mojo-Prozess.

## Schichten

### `prompt_line_editor.mojo`

Der reine Editorzustand enthält keine Betriebssystemaufrufe. Er besitzt:

- UTF-8-sichere Cursorgrenzen, Einfügen, Backspace und Delete,
- Anfang/Ende, wortweise Bewegung und Kill-Operationen,
- History vor/zurück mit Wiederherstellung der noch nicht abgeschickten Zeile,
- Root- und verschachtelte Parameter-Completion über den nativen
  `PromptLanguageCatalog`,
- eindeutige Ersetzung, gemeinsamen Präfix und Kandidatenlisten.

Dadurch lassen sich fast alle Eingaberegeln ohne Pseudoterminal prüfen.

### `prompt_terminal_input.mojo`

Die kleine Systemgrenze verwendet direkt:

- `tcgetattr`, `cfmakeraw` und `tcsetattr` für POSIX-Rohmodus,
- Mojos `FileDescriptor` für stdin/stdout,
- Linux-/macOS-spezifisches `FIONREAD`, um Escape von ANSI-Sequenzen zu
  unterscheiden,
- garantierte Terminalwiederherstellung bei Enter, Ctrl-C, Ctrl-D und Fehlern.

Unterstützt sind die üblichen Emacs-Bindings, Cursor-/Home-/End-/Delete-Tasten,
History, Alt-B/Alt-F, Completion, Ctrl-L, deterministisches Mehrzeilen-Wrapping sowie ein kompakter Vi-Insert- und
Normalmodus (`h/l`, `0/$`, `i/a/A/I`, `x/X`, `b/w`, `j/k`). Vollständige GNU-
Readline-Makros, inkrementelle Suche und dessen kompletter Undo-Baum werden
nicht imitiert. Ein PTY-Test erzwingt 16 Spalten, bearbeitet über die Wrapgrenze und öffnet danach in demselben Prozess eine zweite Rohmodussitzung. Schlägt POSIX-Rohmodus fehl, fällt die Eingabe auf Mojos
portables `input()` zurück.

### `native_prompt_input.mojo`

Diese Schicht wählt Pipe/Plain- oder TTY-Eingabe, expandiert den Historypfad,
lädt die persistente History und hängt bei aktiviertem Logging nichtleere
Befehle einschließlich Duplikaten an. Ctrl-C und Ctrl-D werden weiterhin als
die historischen Sentinels `\x03` und `\x04` an den Controller gegeben.

`prompt_python_bridge.mojo` und sein FFI-Compilerprobe sind entfernt. Im
Boundary-Inventar verbleibt damit nur noch `compat_main.mojo` als aktive
`std.python`-Brücke; der Prompt selbst besitzt keine eingebettete Python-
Laufzeit mehr.

## Klassische Tabellenfamilien

Die Python-Referenz definiert echte, nicht auf Ganzzahlen reduzierbare Brüche
bei `mond`, `richtung`, `primzahlkreuz`, `alles` und `thomas` als leeren,
erfolgreich behandelten Plan. Mojo besitzt diesen No-op nun selbst, statt dafür
einen Python-Fallback zu starten.

Zusätzlich wird ein Kommatoken mit gemischten Bruch- und Ganzzahlkomponenten
wie `mond 1/2,3` getrennt verarbeitet: Der echte Bruch bleibt für rationale
Achsen sichtbar, während `3` die gewöhnliche Ganzzahlmengensemantik behält.
Reduzierbare Werte wie `2/2` und `4/2` erzeugen unverändert die Ganzzahlaufrufe.

## Prüfungen

Ausgeführt wurden:

- reiner Mojo-Zeileneditor: **4/4**,
- History-/Plain-Input-Unit-Tests: **4/4**,
- reale PTY-End-to-End-Fälle: **6/6**,
- native Eingabe-/Source-/Boundary-Checks: **12/12**,
- externe Promptadapter- und Source-/Boundary-Checks: **6/6 + 5/5 + 16/16**,
- klassische Python↔Mojo-Bruchpläne: **8/8 byteidentisch**,
- Python-Referenz über `PYTHONHASHSEED=0,1,42`: **3/3 identisch**,
- vollständige native Tabellenplaner-Suite: **28/28**.

Der monolithische `prompt_main.mojo`-Link überschritt in der Sandbox auch mit
`--no-optimization` 40 Minuten, ohne einen Compilerfehler auszugeben. Die neu
geänderten Module, der echte PTY-Probe und die Tabellenprobes wurden dagegen
kompiliert und ausgeführt. Der reguläre lokale Integrationsbuild bleibt deshalb
verbindlich:

```bash
scripts/build-heavy.sh
scripts/build.sh
```

## Verbleibende Grenze

Offen bleiben insbesondere echte `v n/m`-Vielfache mit Zähler größer eins,
für die die Python-Referenz selbst `IndexError` auslöst, weitere atomare
Promptfachfallbacks, die allgemeine `compat_main`-Brücke sowie Stage 12d/12e.
