# Stage 12c5bo – kanonische Emotion-Option im nativen Bruchprüfer

## Gefundener Fehler

Der vollständige native Build von Stage 12c5bm war erfolgreich. Anschließend
brach die kombinierte Bruchprobe mit
`emotion positive-first reciprocal axis is missing` ab.

Das war **kein Produktionsfehler** des Mojo-Planers. Der typisierte native Plan
für `emotion v1/4,-2/3` enthält korrekt:

```text
--grundstrukturen=emotion
--spaltenreihenfolgeundnurdiese=4,5
```

Der Python-Prüfer verlangte in seinem nativen Ergebnisblock dagegen irrtümlich
`--Grundstrukturen=emotion`. Diese historische gemischte Schreibweise ist für
die gesammelte Python-Referenz-argv korrekt, aber nicht für den kanonischen
nativen Tabellenparameter.

## Korrektur

- Die Referenzprüfung behält `--Grundstrukturen=emotion` unverändert bei.
- Die native Probe prüft ausschließlich `--grundstrukturen=emotion`.
- Ein Sourcevertrag trennt beide Blöcke ausdrücklich, damit die Schreibweisen
  nicht erneut vermischt werden.
- Der Produktionscode in `prompt_table_execution.mojo` bleibt unverändert.

## Benutzerprüfung

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bo.sh -- -j 4
```

Der Lauf kompiliert nur den fokussierten True-Fraction-Probe neu und führt den
korrigierten Prüfer aus. Ein erneuter vollständiger Produktionsbuild ist für
diese reine Prüfstandsänderung nicht erforderlich.
