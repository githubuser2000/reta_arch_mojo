# Stage 12c5ai – Mojo-Testeffekte und nativer Schema-Snapshot

## Gemeldeter Compilerabbruch

Der vollständige Lauf aus Stage 12c5ag erreichte
`tests/test_legacy_table_handling.mojo`, konnte das Testmodul aber nicht
parsen. Die Testfunktionen waren nicht mit `raises` markiert, obwohl
`std.testing.assert_*`, geprüfte Listen-/Dict-Zugriffe und mehrere delegierte
Legacy-Funktionen Fehler propagieren können.

Korrigiert wurden alle vier Testfunktionen in
`test_legacy_table_handling.mojo`. Eine systematische Suche fand denselben
latenten Fehler zusätzlich in einer Meta-, einer Output-Semantics- und zwei
Table-Generation-Testfunktionen. Damit tragen insgesamt acht korrigierte
Testfunktionen explizit `raises`. `tests/test_mojo_test_effect_signatures.py`
verhindert künftig neue `test_*`-Funktionen ohne diese Effektannotation.

## Native Fortsetzung

`reta-mojo-domain-probe schema-json` wird nun vollständig nativ ausgegeben.
Der Serializer arbeitet direkt auf `RetaContextSchema` und reproduziert:

- sortierte Sprach-, Ausgabe-, Zeilen-, Kombinations- und Scope-Mappings,
- die geordnete Liste aller 33 Hauptparameter-Aliasgruppen,
- sieben sortierte Tagnamen,
- 431 Einträge der Haupt-Parametermatrix,
- Größen 12 und 14 der beiden Kombinationsmatrizen,
- alle neun Modulsplit-/Kompatibilitätsnamen.

Das 5.611-Byte-Referenz-JSON liegt nur als Testorakel unter
`assets/schema_snapshot_reference.json`. Der produktive Serializer liest
dieses Asset nicht und startet keine Python-Laufzeit.

Der Kataloggenerator verwendet nun wie `RetaArchitecture.bootstrap` die realen
Module `words_context`, `words_matrix` und `words_runtime`, statt die
Kompatibilitätsfassade fälschlich als Besitzer aller drei Schemaschichten zu
melden.

## Verifikation

Der fokussierte lokale Modular-Lauf ist:

```sh
scripts/test_stage12c5ai.sh
```

Er kompiliert und startet zuerst alle vier reparierten Testmodule, dann den
vollständigen nativen Schema-Snapshot-Test und schließlich die Domänenprobe.
Die Probe wird für elf Befehlsfälle bytegenau gegen Python verglichen,
einschließlich `schema-json`.

Der vollständige Ablauf bleibt:

```sh
./do.sh 12c5ai
```

`architecture-json` ist damit der einzige der 16 Referenzbefehle, der noch
nicht vollständig vom nativen Domänenprobe-Executable besessen wird.
