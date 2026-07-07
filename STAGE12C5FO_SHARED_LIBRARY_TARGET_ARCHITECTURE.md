# Stage 12c5fo – Shared-Library-Zielarchitektur

Diese Stage setzt die gewünschte Nach-Portierungsarchitektur als testbare
Quellarchitektur fest.  Sie baut die bestehenden Starter noch nicht riskant um,
sondern friert die Bibliotheksgrenzen, Starter-Abhängigkeiten und Schutzregeln
für die nächsten Umbau-Stages ein.

## Zielbibliotheken

### `libreta-core.so` / `libreta-core.dll`

Gemeinsamer nativer Kern für:

- `reta`
- `grundStrukHtml`
- `rp`
- `rpl`
- `rpe`
- `rpb`

Inhaltlich gehören hierher: Parametersemantik, Tabellenlogik, Spalten- und
Zeilenlogik, Ausgabeformate, Program-Workflow, `reta`-CLI-Planung sowie der
Teil von Grundstrukturen/HTML, der von `grundStrukHtml` wiederverwendet wird.

### `libreta-prompt.so` / `libreta-prompt.dll`

Gemeinsame Prompt-Ausführung für:

- `rp`
- `rpl`
- `rpe`
- `rpb`

Diese Bibliothek darf `libreta-core` verwenden.  `rpb` ist hier als direkter
One-shot-Starter angebunden.

### `libreta-prompt-interactive.so` / `libreta-prompt-interactive.dll`

Interaktive Prompteingabe nur für:

- `rp`
- `rpl`
- `rpe`

`rpb` darf diese Bibliothek nicht laden.  Hierhin gehören interaktive Eingabe,
Session-/History-/Line-Editor-Logik und reine Terminal-Reaktionsgrenzen.

## Dünne Starter

```text
reta           -> libreta-core
grundStrukHtml -> libreta-core
rpb            -> libreta-prompt + libreta-core
rp             -> libreta-prompt-interactive + libreta-prompt + libreta-core
rpl            -> libreta-prompt-interactive + libreta-prompt + libreta-core
rpe            -> libreta-prompt-interactive + libreta-prompt + libreta-core
```

## Harte Regeln

1. `reta` wird nur noch Starter und delegiert an `libreta-core`.
2. `grundStrukHtml` verwendet dieselbe Core-Bibliothek wie `reta`.
3. `rp`, `rpl`, `rpe`, `rpb` teilen sich `libreta-prompt`.
4. `rpb` verwendet keine interaktive Prompteingabe-Bibliothek.
5. Nur `rp`, `rpl`, `rpe` verwenden `libreta-prompt-interactive`.
6. Diese Stage ist absichtlich nicht der produktive ABI-Umbau; sie verhindert
   erst einmal falsche Abhängigkeiten, bevor echte `--emit shared-lib`-Ziele
   für die drei neuen Bibliotheken angeschlossen werden.

## Neue Dateien

- `src/reta_mojo/shared_library_architecture.mojo`
- `tests/test_shared_library_architecture.mojo`
- `tests/test_stage12c5fo_source.py`
- `scripts/build_shared_library_targets.sh`

## Prüfung

Der neue Source-Guard erzwingt, dass `rpb` nicht in der interaktiven Library
auftaucht und dass die sechs Starter genau an die vorgesehenen Bibliotheken
gebunden sind.
