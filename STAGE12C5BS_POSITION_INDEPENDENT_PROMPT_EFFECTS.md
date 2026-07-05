# Stage 12c5bs – positionsunabhängige Prompt-Begleiteffekte

## Ausgangslage

Der native Promptcontroller besaß `abc`/`abcd` sowie `loggen` und
`nichtloggen` bereits als Einzelbefehle. Zwei historische Kombinationsformen
blieben dennoch an der Python-Grenze:

- `abc` wird in `PromptGrosseAusgabe` bei genau zwei Wörtern über
  Mengenmitgliedschaft erkannt und darf deshalb vor oder nach dem Nutzwort
  stehen (`abc Haus` und `Haus abc`).
- `loggen` und `nichtloggen` werden im hinteren Sonderbefehlblock ebenfalls
  über Mitgliedschaft erkannt. Sie dürfen vor, zwischen oder nach den Tokens
  eines Tabellenkommandos stehen und verändern den Sitzungszustand erst nach
  dessen Ausgabe.

## Native Umsetzung

`prompt_runtime.mojo` normalisiert den zweigliedrigen Suffixfall intern auf
`[abc, Nutzwort]`, bewahrt aber `PromptCommand.raw` unverändert. Dadurch bleibt
`abc_line` ein einziger typisierter Besitzer.

`prompt_historical_ownership.mojo` akzeptiert beide Loggingbefehle als reine
Begleiteffekte und liefert mit `historical_prompt_logging_update` einen
expliziten Dreizustandsplan:

- `PROMPT_LOG_UNCHANGED = -1`
- `PROMPT_LOG_DISABLED = 0`
- `PROMPT_LOG_ENABLED = 1`

Die Python-Priorität ist festgeschrieben: Enthält ein Vektor sowohl
`nichtloggen` als auch `loggen`, gewinnt `loggen`, unabhängig von der
Wortreihenfolge.

`prompt_main.mojo` führt Tabellen- und `mulpri`-Pläne zuerst aus und wendet den
Loggingzustand nur nach erfolgreicher nativer Ausführung an. Reine
Einzelbefehle behalten ihre bisherige sichtbare Mojo-Rückmeldung.

## Referenz- und Regressionsevidenz

- `abc Haus` und `Haus abc`: **2/2** byteidentisch (`8 1 21 19\n`).
- Python-Loggingmitgliedschaft: Aktivieren, Deaktivieren, keine Änderung und
  `loggen`-Vorrang: **4/4**.
- Deutsche und englische Begleittokens werden über den generierten
  Promptkatalog kanonisiert.
- Shell-, Speicher- und unbekannte Parameter bleiben weiterhin atomar am
  Kompatibilitätsrand.

## Defekt

`MOJO-FIXED-069` dokumentiert die unnötige positionsabhängige
Prompt-Effektgrenze.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bs.sh -- -j 8
```
