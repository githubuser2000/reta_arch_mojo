# Stage 12c5cg – Bare informational dispatch ownership

## Ausgangspunkt

Die vom Benutzer hochgeladenen Läufe bestätigen den 12c5ce-Ausgangsstand:
der breite Mojo-Lauf endet erfolgreich, und der fokussierte 12c5ce-Stage-Lauf
baut Prompt-, Legacy-Prompt- und Tabellenadapterziele frisch. 12c5cf verschob
den alleinstehenden Terminal-Clear-Dispatch bereits in den Interaktionsbesitzer.

Die nächste noch direkt im Prozesscontroller liegende Prompt-Sessionentscheidung
waren die alleinstehenden Informationsbefehle.

## Native Änderung

`src/reta_mojo/prompt_interaction.mojo` besitzt jetzt:

- `PromptInformationalDispatchPlan`
- `plan_informational_dispatch(command)`
- Snapshot-Eintrag `informational_dispatch=native-prompt-information-plan`

Damit entscheidet der Interaktionsbesitzer die alleinstehenden Befehle:

- `hilfe` / `help`
- `befehle` / `commands`
- `kurzbefehle` / `shortcommands`

Der Prozesscontroller rendert nur noch die geplanten Ausgaben. Die
zusammengesetzten Informations-Begleiteffekte bei Tabellen- und `mulpri`-Plänen
bleiben weiterhin in `prompt_historical_ownership.mojo`, weil sie dort in der
historischen Reihenfolge vor der Tabelle komponieren.

## Vertragsgrenzen

- `tests/test_prompt_interaction.mojo` enthält einen direkten Regressionstest
  für Hilfe-, Befehle- und Kurzbefehle-Pläne.
- `tests/test_stage12c5cg_source.py` verbietet, dass `prompt_main.mojo` wieder
  bare `KIND_HELP`-/`KIND_COMMANDS`-/`KIND_SHORT_COMMANDS`-Branches enthält.
- Der Stage-Lauf baut Prompt-, Legacy-Prompt- und Tabellenadapterziele frisch.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cg.sh -- -j 8

scripts/build-tests.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
