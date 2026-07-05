# Stage 12c5br – vollständige Prompt-Ausgabeparameter

## Ausgangsfehler

Der native Tabellenplaner leitete bereits alle Ausgabeparameter an den nativen
`reta`-Kern weiter. Der davor liegende atomare Eigentumsbeweis akzeptierte aber
nur sieben kanonische Namen. Dadurch wurden vollständig implementierte
Promptbefehle mit `--justtext`, `--onetable`, `--endlessscreen`, `--endless`,
`--dontwrap` oder `--breiten=...` weiterhin an den Python-Kindprozess gegeben.

Zusätzlich bewahrt Python nicht die Quellreihenfolge mehrerer Parameter. Die
historische Vorbereitung führt zuerst `list(set(...))` über den vollständigen
Tokenvektor aus und filtert anschließend die Parameter. Eine Ordnung nur über
die Parameterteilmenge wäre ebenfalls falsch, weil die übrigen Befehls- und
Datentokens die Hash-Tabellenbelegung beeinflussen.

## Nativer Vertrag

- **13/13** kanonische Ausgabeparameter gehören dem nativen Promptpfad.
- Der generierte fünfsprachige Katalog bindet **65/65** lokalisierte Namen.
- Eigenständige `-ausgabe`- und `-output`-Sektionsmarker bleiben erlaubt.
- Parameter werden aus der CPython-kompatiblen Gesamtmengenordnung gefiltert.
- Duplikate verschwinden wie im Python-`set`; negative Zeilenselektoren werden
  nicht irrtümlich als Ausgabeparameter übernommen.
- Der instrumentierte Referenzvergleich prüft sechs zuvor abgewiesene Optionen
  sowie einen vollständigen 13-Parameter-Vektor: **7/7** exakte Executor-argv.

## Dateien

- `src/reta_mojo/prompt_historical_ownership.mojo`
- `src/reta_mojo/prompt_table_execution.mojo`
- `tests/test_prompt_historical_ownership.mojo`
- `tests/test_prompt_table_execution.mojo`
- `tests/prompt_output_parameter_probe.mojo`
- `scripts/check_prompt_output_parameters.py`
- `scripts/check_prompt_output_parameters.sh`
- `scripts/test_stage12c5br.sh`

Der geschlossene Portierungsdefekt ist als `MOJO-FIXED-068` dokumentiert.

## Im realen Benutzerlauf zusätzlich geschlossene Prüfstandsfehler

Der vollständige Mojo-Lauf von Stage 12c5bq bestand alle vorherigen Testziele
bis `test_prompt_table_execution`. Die dortigen zwei Fehlschläge lagen nicht im
Produktionsplan, sondern in nach der lokalen `v`-Korrektur veralteten
Assertions:

- `--vorhervonausschnitt=5,v5` wurde nur mit einem vorausgehenden Komma gesucht;
- `v1/4,-1/8` erwartete noch die alte Reihenfolge
  `4,516,12,524`, obwohl die lokale literale Ausschließung von Zeile 8 die
  CPython-Set-Reihenfolge `512,4,516,520,12,524,...` ergibt.

Außerdem wurden zwei portable Infrastrukturfehler geschlossen:

- das Brotli-Sourcearchiv wählt nun ausdrücklich ein Python mit installiertem
  `brotli`-Modul und bevorzugt die Projekt-`.venv`;
- die Architekturasset-Bereinigung wiederholt `rmtree` bei `ENOTEMPTY`/`EBUSY`
  und führt vollständige Sweeps aus, falls ein Cache gleichzeitig neu entsteht.

Diese Befunde sind als `TEST-FIXED-064`, `TEST-FIXED-065` und
`TEST-FIXED-066` dokumentiert.

## Compilerfreie Prüfung

- alle 87 Source-Testdateien: **369 bestanden**, **1 begründeter Skip** für den
  nicht kompilierten `concat_csv_probe`;
- Architektur-Referenzaudit: **70/70**, zusätzlich **7 Subtests**;
- fokussierte Ledger-/Stage-/Portierungsverträge: **50/50**;
- Archiv-/Cachevertrag: **14/14**, zusätzlich manueller Brotli-Roundtrip;
- Defektledger: **159 Einträge**, davon **18** spätere Python-Aufgaben;
- Portierung: **89/92 vollständig**, **92/92 mindestens teilweise**.
