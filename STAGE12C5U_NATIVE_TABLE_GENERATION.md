# Stage 12c5u – Native Table Generation Gluing

## Ziel

`reta_architecture/table_generation.py` besaß bislang nur indirekte native
Teilpfade. Stage 12c5u macht die Reihenfolge des Tabellenbaus zu einem eigenen
typisierten Mojo-Besitzer.

## Native Typen

- `TableGenerationPlan`
- `TableGenerationResult`
- `TableGenerationResultSnapshot`
- `TableGenerationBundle`
- `TableGenerationBundleSnapshot`
- `TableGenerationConcatResult`
- `TableGenerationKombiResult`

Der heterogene, zur Laufzeit durch Attribute erweiterte Python-`Program`-Graph
wird nicht nachgebildet. Alle Eingaben stehen explizit im Plan, alle mutierten
Tabellen- und Relationswerte werden besitzend zurückgegeben.

## Erhaltene Orchestrierungsreihenfolge

1. Prim- und Bruch-CSV-Prägarben werden über die gesamte physische Quelltabelle angefügt.
2. Erst danach wird die angeforderte letzte Tabellenzeile erfasst und auf die physische Tabelle begrenzt.
3. Generatorfamilien werden in der historischen Reihenfolge angewandt.
4. Galaxie- und Universum-Kombi-Spalten werden verbunden.
5. Spaltenauswahl, generierte Namen, Bruchschlüssel und Kombi-Relationen werden
   im Ergebnis zusammengeführt.

## Öffentliche Python-Oberfläche

Vollständig besessen sind `TableGenerationResult.snapshot`, alle sechs Methoden
von `TableGenerationBundle` und `bootstrap_table_generation`.

## Diagnose und Tests

Der reguläre Build erzeugt `target/bin/reta-mojo-table-generation`.

```bash
bin/reta-mojo-table-generation --summary
bin/reta-mojo-table-generation --last-line 99 3
scripts/test_stage12c5u.sh
```

Der Paritätstest vergleicht den Bundle-Snapshot mit Python/PyPy3 und prüft vier
Grenzfälle der Last-Line-Normalisierung. Vier native Mojo-Tests prüfen Snapshot,
Clamping, leeren Pipelinebau und Legacy-Ergebnisfelder.
