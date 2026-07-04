# Stage 12c5at – typisierte native Prompt-Ausführungsgrenze

## Ausgangspunkt

Stage 12c5as beseitigt den von Mojo 1.0.0b2 gemeldeten Compile-Time-`getenv`-
Pfad. Danach blieb `reta_architecture/prompt_execution.py` als eine von nur noch
drei teilweise nativen Referenzdateien markiert, obwohl Parser, Bruchsemantik,
Tabellenplanung und Promptcontroller bereits native Besitzer hatten.

Der fehlende architektonische Schritt war eine eigene Ausführungsgrenze
zwischen dem typisierten `PromptTablePlan` und der beobachtbaren Terminalausgabe.
Bisher lag diese Logik als private Hilfsfunktion in `src/prompt_main.mojo`.

## Umsetzung

`src/reta_mojo/prompt_execution_runtime.mojo` besitzt jetzt:

- `PromptRenderedInvocation`
- `PromptTableExecutionResult`
- `prompt_table_command_echo(...)`
- `render_prompt_table_plan(...)`

Der Renderer führt sämtliche geplanten nativen `reta`-Aufrufe zunächst ohne
Terminal-I/O aus und liefert ein vollständiges typisiertes Ergebnis. Erst
`prompt_main.mojo` gibt die bereits erzeugten Kommandozeilen und Tabellen aus.
Ein leerer ungültiger Teilaufruf kann dadurch keine halb ausgegebene
Mehrfachoperation mehr hinterlassen.

`prompt_execution.mojo` enthält außerdem eine exakte Eigentümertabelle für alle
22 Top-Level-Oberflächen des historischen Python-Moduls. Jede Funktion oder
Klasse verweist auf ein vorhandenes Mojo-Modul und ein dort tatsächlich
vorhandenes Evidenzsymbol. Die Reihenfolge wird direkt gegen den Python-AST
geprüft.

Damit ist die deterministische Tabellen-Ausführungsgrenze des historischen
Moduls nativ. `prompt_execution.py` bleibt bewusst als **teilweise nativ**
markiert, solange noch nicht bewiesene historische Verbundbefehle atomar über
die explizite Kompatibilitätsgrenze laufen.

## Fortschritt

```text
vollständig nativ/generiert:    89/92 = 96,7 %
mindestens teilweise portiert: 92/92 = 100,0 %
angegriffene Referenzzeilen:    48.831/48.831 = 100,0 %
```

## Kompilierung durch den Benutzer

ChatGPT führt weiterhin keine Mojo-Kompilierung aus. Nach dem Entpacken:

```bash
scripts/build-all.sh
scripts/test_current_stage.sh
```

Für die vollständige Suite:

```bash
scripts/test_all.sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

Die Stage kompiliert gezielt den bestehenden Prompt-Bundle-Test und den neuen
Runtime-Grenztest. Die Produktions-Buildskripte kompilieren weiterhin keine
Dateien aus `tests/`.
