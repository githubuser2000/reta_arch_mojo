# Stage 12c5fo – Shared-Library-Zielarchitektur

Diese Stage setzt die gewünschte Nach-Portierungsarchitektur als testbare
Quellarchitektur fest.  Sie baut die bestehenden Starter noch nicht riskant um,
sondern friert die Bibliotheksgrenzen, Starter-Abhängigkeiten und Schutzregeln
für die nächsten Umbau-Stages ein.

## Zielbibliotheken

### `libreta_core_mojo.so` / `libreta_core_mojo.dll`

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

### `libreta_prompt_mojo.so` / `libreta_prompt_mojo.dll`

Gemeinsame Prompt-Ausführung für:

- `rp`
- `rpl`
- `rpe`
- `rpb`

Diese Bibliothek darf `libreta_core_mojo` verwenden.  `rpb` ist hier als direkter
One-shot-Starter angebunden.

### `libreta_prompt_interactive_mojo.so` / `libreta_prompt_interactive_mojo.dll`

Interaktive Prompteingabe nur für:

- `rp`
- `rpl`
- `rpe`

`rpb` darf diese Bibliothek nicht laden.  Hierhin gehören interaktive Eingabe,
Session-/History-/Line-Editor-Logik und reine Terminal-Reaktionsgrenzen.

## Dünne Starter

```text
reta           -> libreta_core_mojo
grundStrukHtml -> libreta_core_mojo
rpb            -> libreta_prompt_mojo + libreta_core_mojo
rp             -> libreta_prompt_interactive_mojo + libreta_prompt_mojo + libreta_core_mojo
rpl            -> libreta_prompt_interactive_mojo + libreta_prompt_mojo + libreta_core_mojo
rpe            -> libreta_prompt_interactive_mojo + libreta_prompt_mojo + libreta_core_mojo
```

## Harte Regeln

1. `reta` wird nur noch Starter und delegiert an `libreta_core_mojo`.
2. `grundStrukHtml` verwendet dieselbe Core-Bibliothek wie `reta`.
3. `rp`, `rpl`, `rpe`, `rpb` teilen sich `libreta_prompt_mojo`.
4. `rpb` verwendet keine interaktive Prompteingabe-Bibliothek.
5. Nur `rp`, `rpl`, `rpe` verwenden `libreta_prompt_interactive_mojo`.
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
