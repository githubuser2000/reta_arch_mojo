# Zielarchitektur für spätere `.so` / `.dll`-Aufteilung von `reta_arch_mojo`

Stand: 2026-07-06  
Planungsbasis: aktueller Transpilierungsstand um `12c5dg`  
Status: **Zielrahmen, noch nicht technisch umgesetzt**

Dieses Dokument legt fest, welche späteren Shared Libraries (`.so` unter Linux, `.dll` unter Windows) für `reta_arch_mojo` sinnvoll sind. Es ist absichtlich als Architekturplan geschrieben, damit die weitere Transpilierung diese Grenzen bereits berücksichtigt, ohne den aktuellen Build sofort auf Shared Libraries umzubauen.

---

## 1. Grundentscheidung

Die Executable Binaries sollen später möglichst dünn werden. Die eigentliche Logik soll in Libraries liegen.

Wichtig ist die Abhängigkeitsrichtung:

```text
rp / rpl / rpe / rpb
  -> Prompt-Libraries
      -> reta-Core-Library
```

Nicht umgekehrt:

```text
reta-Core-Library
  -> rp/rpl/rpe/rpb-Libraries
```

Der Kern von `reta` darf die Prompt-Programme nicht kennen. Prompt-Programme dürfen den `reta`-Kern benutzen.

---

## 2. Zentrale Regel

```text
libreta_core_mojo
  kennt keine Prompt-Aufforderung
  kennt keine History
  kennt keine interaktive Tastaturreaktion
  kennt keine rp/rpl/rpe/rpb-Spezial-UI
```

Prompt-Libraries dürfen `libreta_core_mojo` benutzen, wenn sie echte `reta`-Kommandos ausführen müssen.

Die reine Eingabe-/Reaktionsschicht von `rp/rpl/rpe` soll `libreta_core_mojo` aber **nicht** brauchen.

---

## 3. Zielgraph der Executables

```text
bin/reta
  -> libreta-cli
      -> libreta_core_mojo

bin/rp
bin/rpl
bin/rpe
  -> libreta_prompt_interactive_mojo
      -> libreta_prompt_mojo-reaction
      -> libreta_prompt_mojo-execution
          -> libreta_core_mojo
      -> libreta-process

bin/rpb
  -> libreta_prompt_mojo-batch
      -> libreta_prompt_mojo-execution
          -> libreta_core_mojo
      -> libreta-process

bin/grundStrukHtml
bin/generate4readme
  -> libreta-docs
      -> libreta_core_mojo
```

Optional können `libreta-cli`, `libreta-docs` oder `libreta-process` später zusammengelegt werden, falls der Build dadurch einfacher bleibt. Die konzeptionellen Grenzen sollten trotzdem erhalten bleiben.

---

## 4. Ziel-Libraries im Überblick

| Library | Zweck | Darf von `reta-core` abhängen? | Darf Prompt enthalten? | Späterer Nutzen |
|---|---:|---:|---:|---|
| `libreta_core_mojo` | eigentliche reta-Tabellen-/Parameter-/Ausgabelogik | nein, ist der Kern | nein | wichtigste große Core-Library |
| `libreta-cli` | CLI-Schicht für `reta` | ja | nein | dünner `reta`-Starter |
| `libreta_prompt_mojo-reaction` | Eingabe, Prompt-Aufforderung, History, Zeileneditor | nein | ja, aber nur UI/Reaktion | trennt interaktive Eingabe von Ausführung |
| `libreta_prompt_mojo-execution` | fertige Prompt-Kommandos ausführen | ja | ja | gemeinsame Ausführung für `rp/rpl/rpe/rpb` |
| `libreta_prompt_interactive_mojo` | interaktive Schleife für `rp/rpl/rpe` | indirekt über execution | ja | dünne Starter für `rp/rpl/rpe` |
| `libreta_prompt_mojo-batch` | nicht-interaktive Ausführung für `rpb` | indirekt über execution | nur Batch | dünner Starter für `rpb` |
| `libreta-process` | OS-nahe Child-Process-Ausführung | optional | nein | isoliert Shell/Python/Math/Fallback-Prozesse |
| `libreta-docs` | README/HTML/Grundstruktur-Dokumentation | ja | nein | Tools wie `generate4readme`, `grundStrukHtml` |

---

## 5. `libreta_core_mojo`

### Kurze Erklärung

`libreta_core_mojo` ist der eigentliche native `reta`-Kern.

### Lange Erklärung

Diese Library enthält alles, was `reta` unabhängig von Prompt-Bedienung leisten muss: Parametersemantik, Zeilen- und Spaltenauswahl, Tabellenzustand, CSV-Laden, generierte Spalten, Kombinationslogik, Metaspalten, Bruch-/Rational-Logik, Ausgabemodi und Renderer.

Sie soll keine interaktive Prompt-Logik enthalten. Dadurch bleibt der Kern wiederverwendbar für:

```text
reta
rp/rpl/rpe/rpb
readme/html-tools
test-/diagnose-tools
```

`libreta_core_mojo` ist die Library, auf die spätere Tools und Prompt-Ausführung aufbauen.

### Enthalten

```text
Parametersemantik
Zeilenfilter
Spaltenfilter
Tabellenzustand
CSV-Datenzugriff
generierte Spalten
Kombi-/Meta-/Fraction-Logik
Ausgabeformate
HTML / BBCode / Markdown / CSV / Emacs / Shell-Rendering
native reta-Planung
UTF-8-sichere Ausgabe
```

### Nicht enthalten

```text
Prompt-Aufforderung
Readline/Zeileneditor
History-Navigation
interaktive Terminalsteuerung
rp/rpl/rpe/rpb-Profil-UI
Shell/Python/Math-Promptbefehle als UI
```

---

## 6. `libreta-cli`

### Kurze Erklärung

`libreta-cli` ist die dünne CLI-Schicht für `bin/reta`.

### Lange Erklärung

`bin/reta` soll später möglichst nur noch `argv`, Umgebung und Standardströme aufnehmen und an `libreta-cli` weiterreichen. `libreta-cli` übersetzt den Prozessstart in einen `reta`-Plan und ruft `libreta_core_mojo` auf.

Diese Library kann klein bleiben. Sie dient vor allem dazu, dass das eigentliche Executable `reta` nicht mehr den kompletten nativen Kern direkt enthält.

### Abhängigkeiten

```text
libreta-cli
  -> libreta_core_mojo
```

### Benutzt von

```text
bin/reta
```

---

## 7. `libreta_prompt_mojo-reaction`

### Kurze Erklärung

`libreta_prompt_mojo-reaction` enthält nur die interaktive Eingabe- und Reaktionslogik von `rp/rpl/rpe`.

### Lange Erklärung

Diese Library ist für alles zuständig, was mit dem interaktiven Prompt-Verhalten zu tun hat, aber noch keine echte `reta`-Ausführung braucht.

Dazu gehören Prompt-Aufforderung, Tastaturreaktion, Zeileneditor, History, Session-Navigation, Cursor-/Terminalreaktionen und Eingabezustand.

Diese Library soll **nicht** von `libreta_core_mojo` abhängen. Sie soll nicht wissen müssen, wie Tabellen gebaut oder `reta`-Kommandos ausgeführt werden. Sie erzeugt oder sammelt nur fertige Eingaben und Reaktionsereignisse.

Das ist die Trennung, die der Benutzer ausdrücklich bevorzugt: Die Befehlseingabe-/Reaktions-Library von `rp/rpl/rpe` braucht die `reta`-Library nicht.

### Enthalten

```text
Prompt-Aufforderung
interaktive Eingabe
Line-Editor
History
Cursor-/Tastenreaktion
Session-Navigation
Terminal-Reaktion
Eingabezustand
```

### Nicht enthalten

```text
reta-Kernausführung
Tabellenbau
Spalten-/Zeilenlogik
native reta CLI
Shell/Python/Math-Prozessausführung
```

### Abhängigkeiten

```text
libreta_prompt_mojo-reaction
  -> keine Abhängigkeit auf libreta_core_mojo
```

---

## 8. `libreta_prompt_mojo-execution`

### Kurze Erklärung

`libreta_prompt_mojo-execution` führt fertige Prompt-Kommandos aus und darf dafür `libreta_core_mojo` benutzen.

### Lange Erklärung

Diese Library ist die gemeinsame Ausführungsschicht für `rp`, `rpl`, `rpe` und `rpb`. Sie bekommt bereits vorbereitete Kommandos, klassifiziert sie und entscheidet, ob ein Kommando nativ über `libreta_core_mojo`, über Shell, Python, Math oder über einen Fallback-Prozess ausgeführt werden muss.

Diese Library darf und soll von `libreta_core_mojo` abhängen, weil hier echte `reta`-Ausführung passiert.

Sie ist bewusst getrennt von `libreta_prompt_mojo-reaction`, damit interaktive Eingabe nicht automatisch den gesamten `reta`-Kern einbindet.

### Enthalten

```text
Prompt-Kommando-Klassifikation
Prompt-Dispatch-Pläne
native reta-Ausführung aus Prompt-Kommandos
Shell-/Python-/Math-Dispatch-Entscheidung
Fallback-Entscheidung
Storage-/Logging-Ausführungspläne
Prompt-Profile, soweit für Ausführung nötig
```

### Abhängigkeiten

```text
libreta_prompt_mojo-execution
  -> libreta_core_mojo
  -> libreta-process optional
```

### Benutzt von

```text
libreta_prompt_interactive_mojo
libreta_prompt_mojo-batch
```

---

## 9. `libreta_prompt_interactive_mojo`

### Kurze Erklärung

`libreta_prompt_interactive_mojo` ist die interaktive Prompt-Schleife für `rp`, `rpl` und `rpe`.

### Lange Erklärung

Diese Library verbindet die reine Eingabe-/Reaktionsschicht mit der Prompt-Ausführungsschicht. Sie ist der eigentliche interaktive Prompt-Modus.

`rp`, `rpl` und `rpe` sollen später nur dünne Starter sein, die ein Profil auswählen und diese Library starten.

Die Library selbst darf indirekt `libreta_core_mojo` erreichen, aber nur über `libreta_prompt_mojo-execution`. Die reine Eingabereaktion bleibt weiterhin getrennt.

### Enthalten

```text
interaktive Hauptschleife
Profilstart für rp/rpl/rpe
Zusammenspiel von Eingabe und Ausführung
Prompt-Session-Lebenszyklus
```

### Nicht enthalten

```text
vollständiger reta-Kern direkt
Batch-only rpb-Logik
Dokumentationsgeneratoren
```

### Abhängigkeiten

```text
libreta_prompt_interactive_mojo
  -> libreta_prompt_mojo-reaction
  -> libreta_prompt_mojo-execution
      -> libreta_core_mojo
```

### Benutzt von

```text
bin/rp
bin/rpl
bin/rpe
```

---

## 10. `libreta_prompt_mojo-batch`

### Kurze Erklärung

`libreta_prompt_mojo-batch` ist die nicht-interaktive Prompt-Ausführung für `rpb`.

### Lange Erklärung

`rpb` braucht keine Prompt-Aufforderung, keinen interaktiven Line-Editor und keine History-Navigation. Es soll fertige Befehle aus `argv`, stdin oder einer anderen Batch-Quelle nehmen und ausführen.

Darum soll `rpb` nicht `libreta_prompt_interactive_mojo` benutzen. Es soll nur `libreta_prompt_mojo-batch` starten, und diese verwendet dann `libreta_prompt_mojo-execution`.

### Enthalten

```text
Batch-Befehlseingabe
Ausführung einer oder mehrerer Prompt-Zeilen
einfache Ein-/Ausgabe
optional Logging
kein interaktiver Prompt
```

### Nicht enthalten

```text
Prompt-Aufforderung
Readline
History-Navigation
interaktive Tastaturreaktion
```

### Abhängigkeiten

```text
libreta_prompt_mojo-batch
  -> libreta_prompt_mojo-execution
      -> libreta_core_mojo
```

### Benutzt von

```text
bin/rpb
```

---

## 11. `libreta-process`

### Kurze Erklärung

`libreta-process` isoliert OS-nahe Child-Process-Ausführung.

### Lange Erklärung

Diese Library kapselt alle Stellen, an denen externe Prozesse gestartet werden: Shell-Kommandos, Python-Code, Math-Ausführung, historische Fallback-Prozesse und eventuell `retaPrompt.py`-Kompatibilität.

Sie ist bewusst klein zu halten, weil `.so` und `.dll` hier plattformspezifisch werden können. Linux, Windows und Termux unterscheiden sich genau an dieser Stelle stark.

### Enthalten

```text
Child-Prozess-Ausführung
Shell-Aufruf
Python-Aufruf
Math-Aufruf
Fallback-Prozessstart
Exit-Code / stdout / stderr-Verträge
Quoting für Prozessgrenzen
```

### Nicht enthalten

```text
Prompt-UI
Tabellenlogik
reta-Kernsemantik
Dokumentationsgeneratoren
```

### Abhängigkeiten

```text
libreta-process
  -> möglichst wenig
  -> OS-/Runtime-nahe Hilfsfunktionen
```

---

## 12. `libreta-docs`

### Kurze Erklärung

`libreta-docs` enthält Dokumentations- und HTML-Generatorlogik.

### Lange Erklärung

Tools wie `grundStrukHtml` und `generate4readme` brauchen wahrscheinlich keine Prompt-Libraries. Sie brauchen eher `libreta_core_mojo`, eventuell i18n-Daten, HTML-/README-Assets und Dokumentationsgeneratoren.

Darum sollten sie nicht über `libreta_prompt_mojo-*` laufen.

### Enthalten

```text
README-Generator
Grundstruktur-HTML-Generator
i18n-Dokumentationsassets
statische Markdown-/HTML-Ausgabe
```

### Abhängigkeiten

```text
libreta-docs
  -> libreta_core_mojo
```

### Benutzt von

```text
generate4readme
grundStrukHtml
```

---

## 13. Dünne Executable Binaries

### `reta`

```text
reta
  -> libreta-cli
      -> libreta_core_mojo
```

`reta` soll später nur noch ein dünner Starter sein. Es liest `argv`, ruft die CLI-Library auf und gibt Exit-Code und Ausgabe weiter.

### `rp`

```text
rp
  -> libreta_prompt_interactive_mojo
```

Interaktiver Prompt mit Standardprofil.

### `rpl`

```text
rpl
  -> libreta_prompt_interactive_mojo
```

Interaktiver Prompt mit Logging-/Listenprofil, je nach historischer Bedeutung im Projekt.

### `rpe`

```text
rpe
  -> libreta_prompt_interactive_mojo
```

Interaktiver oder one-shot-naher Prompt mit `-e`-/Emacs-/Ausgabeprofil gemäß historischem Profil.

### `rpb`

```text
rpb
  -> libreta_prompt_mojo-batch
```

Nicht-interaktive Befehlseingabe. Keine Prompt-Aufforderung, kein interaktives Readline.

### `grundStrukHtml`

```text
grundStrukHtml
  -> libreta-docs
      -> libreta_core_mojo
```

HTML-/Grundstruktur-Ausgabe ohne Prompt-Abhängigkeit.

### `generate4readme`

```text
generate4readme
  -> libreta-docs
      -> libreta_core_mojo
```

README-/Dokumentationsgenerator ohne Prompt-Abhängigkeit.

---

## 14. ABI-Regeln für spätere `.so` / `.dll`

Damit die Libraries später robust bleiben, sollten über `.so`/`.dll`-Grenzen möglichst einfache Daten gehen.

### Bevorzugt

```text
argc/argv
UTF-8-Strings
Bytes/Puffer
Exit-Code
stdout/stderr-artige Textausgabe
JSON-artige einfache Serialisierung
Dateipfade
```

### Vermeiden

```text
komplexe Mojo-Structs direkt über ABI-Grenzen
interne Listen/Dicts als ABI-Vertrag
Mojo-spezifische generische Typen als öffentliches ABI
interne Enums ohne stabile Repräsentation
zyklische Library-Abhängigkeiten
```

### Grundsatz

```text
Interne Mojo-Typen innerhalb einer Library sind gut.
Über Shared-Library-Grenzen lieber einfache C-/String-/Bytes-Verträge.
```

---

## 15. Abhängigkeitsregeln

### Erlaubt

```text
libreta-cli -> libreta_core_mojo
libreta_prompt_mojo-execution -> libreta_core_mojo
libreta_prompt_interactive_mojo -> libreta_prompt_mojo-reaction
libreta_prompt_interactive_mojo -> libreta_prompt_mojo-execution
libreta_prompt_mojo-batch -> libreta_prompt_mojo-execution
libreta-docs -> libreta_core_mojo
```

### Verboten oder zu vermeiden

```text
libreta_core_mojo -> libreta_prompt_interactive_mojo
libreta_core_mojo -> libreta_prompt_mojo-batch
libreta_core_mojo -> libreta_prompt_mojo-reaction
libreta_core_mojo -> libreta-process, falls nicht zwingend nötig
libreta-docs -> libreta_prompt_mojo-*
libreta_prompt_mojo-reaction -> libreta_core_mojo
```

Die wichtigste harte Regel:

```text
Der reta-Kern hängt nicht vom Prompt ab.
Die reine Prompt-Reaktion hängt nicht vom reta-Kern ab.
Nur Prompt-Ausführung hängt vom reta-Kern ab.
```

---

## 16. Empfohlene Reihenfolge der späteren Umsetzung

Noch nicht sofort umsetzen. Erst weiter sauber transpilieren. Danach in dieser Reihenfolge splitten:

### Phase 1: Planung während der Transpilierung

```text
Grenzen dokumentieren
Imports in Richtung Zielarchitektur bereinigen
Prompt-Reaktion und Prompt-Ausführung weiter trennen
Prozessadapter rein halten
keine ABI-Arbeit erzwingen
```

### Phase 2: Erste stabile Libraries

```text
libreta_core_mojo
libreta-cli
libreta-docs oder libreta-process als kleiner Testsplit
```

### Phase 3: Prompt sauber teilen

```text
libreta_prompt_mojo-reaction
libreta_prompt_mojo-execution
libreta_prompt_interactive_mojo
libreta_prompt_mojo-batch
```

### Phase 4: Windows `.dll`

```text
DLL-Exportregeln festlegen
Pfad-/RPATH-/PATH-Logik prüfen
C-ABI oder einfache String-ABI stabilisieren
```

---

## 17. Konsequenz für die weitere Transpilierung

Ab jetzt sollten neue Stages darauf achten, dass folgende Trennung stärker wird:

```text
Prompt-Runtime-Semantik
  getrennt von
Prozessausführung

Prompt-Reaktion/Eingabe
  getrennt von
Prompt-Ausführung

reta-Core
  getrennt von
Prompt-Facades
```

Die bisherigen Stages `12c5df` und `12c5dg` passen bereits zu dieser Richtung, weil sie Prompt-argv- und Tokenizer-Semantik aus dem externen Prozessadapter herausgezogen haben.

---

## 18. Kurzfassung

```text
reta wird dünn.
libreta_core_mojo wird der Kern.
rp/rpl/rpe werden dünne interaktive Starter.
rpb wird ein dünner Batch-Starter.
Prompt-Reaktion braucht reta-core nicht.
Prompt-Ausführung braucht reta-core.
Docs/HTML-Tools brauchen core, aber keinen Prompt.
Der Core hängt niemals von Prompt-Libraries ab.
```

