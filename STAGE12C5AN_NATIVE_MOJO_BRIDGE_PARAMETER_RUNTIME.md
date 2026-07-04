# Stage 12c5an – native Mojo-Bridge-Fassade und vollständige Parameter-Runtime

## Ziel

Diese Stage schließt zwei historische Kompatibilitätsgrenzen, ohne einen neuen
Algorithmusbesitzer einzuführen:

1. `python_reference/mojo_bridge.py` wird durch eine typisierte Mojo-Fassade
   ersetzt.
2. `reta_architecture/parameter_runtime.py` wird von „weitgehend nativ“ auf
   vollständig nativ gehoben.

## Native `mojo_bridge.py`-Oberfläche

`tools/generate_legacy_mojo_bridge_catalog.py` erfasst reproduzierbar:

- 15 öffentliche Modulnamen,
- 19 Funktionsdefinitionen einschließlich des verschachtelten Readline-
  Completers.

`src/reta_mojo/legacy_mojo_bridge.mojo` ordnet die historische Oberfläche den
bereits vorhandenen Besitzern zu:

- TTY, History und Vi-/Emacs-Eingabe: `native_prompt_input.mojo`,
- verschachtelte Completion: `completion_nested.mojo`,
- explizite Kindprozesse: `prompt_external_commands.mojo`,
- vollständige HTML-Seite: `html_document.mojo`.

Es wird kein CPython eingebettet. Solange `reta.py` und der hintere
Prompt-Effektblock noch nicht vollständig nativ sind, bleiben genau diese
Kompatibilitätsfälle als sichtbarer Mojo-Kindprozess erhalten.

## Gemeinsamer HTML-Besitzer

Die wiederverwendbare HTML-Orchestrierung wurde aus
`src/generate_html_main.mojo` nach `src/reta_mojo/html_document.mojo`
verschoben. Der Programmeinstieg und die historische Bridge verwenden dadurch
denselben Besitzer für:

- `middle.alx`-Override,
- native `--alles`-Tabellenerzeugung,
- optionale Zwischenablage,
- Kopf-, JavaScript-, Hierarchie- und Footer-Verkettung,
- byteerhaltende stdout-Ausgabe.

## Vollständige Parameter-Runtime

`src/reta_mojo/parameter_runtime.mojo` besitzt nun zusätzlich die drei
historischen Einstiege:

- `produce_all_spalten_numbers`,
- `apply_width_parameter`,
- `parameters_to_commands_and_numbers`.

Die alte Mutation eines beliebigen `Program`-Objekts wird nicht nachgebaut.
Stattdessen liefern alle Pfade explizite Werte:

- `ParameterRuntimePlan`,
- `ParameterRuntimeWidthResult`,
- `UpperLimitArgument`,
- `AppliedUpperLimit`.

Sechs frühere Modulglobale, drei verschachtelte Helfer und Lazy-Importzustand
werden durch `ParameterRuntimeLegacySnapshot` und statische Besitzer ersetzt.
Diagnosen sind geordnete Planwerte statt unmittelbarer Seiteneffekte.

## Prüfung

Portable Prüfungen dieser Stage:

- 211 Source-Vertragstests bestanden,
- 1 begründeter compilerabhängiger Skip,
- 82 fokussierte Bridge-, Parameter-, Domain-, HTML-, Metrik- und Infrastrukturtests bestanden.

Zusätzlich korrigiert diese Stage die beobachtbare Aliasreihenfolge der Domain-Probe: kanonische Gruppen bleiben sortiert, ihre Aliaslisten bewahren jedoch die Python-Einfügereihenfolge.

Der lokale Modular-Test kompiliert zusätzlich:

- `tests/test_legacy_mojo_bridge.mojo`,
- `tests/test_parameter_runtime_complete.mojo`.

Vollständiger lokaler Ablauf:

```sh
./do.sh 12c5an
```
