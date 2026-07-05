# Stage 12c5bq – positionsunabhängiges globales v und kommalokale Präfixe

## Korrektur der 12c5bp-Annahme

Stage 12c5bp nahm irrtümlich an, ein direkt an den ersten Bruch angeheftetes
`v` gelte für die gesamte kommagetrennte Liste. Der Python-Referenzparser zeigt
zwei verschiedene Sprachformen:

1. **Kompaktes Präfix-v ist kommalokal.**
   `v1/4,-1/8,2/3` markiert nur `1/4` als Vielfaches. Entsprechend markieren
   `1/4,v-1/8,v2/3` nur die jeweils präfigierten Komponenten.
2. **Ein eigenständiges `v` oder `vielfache` ist global.**
   Python prüft diese Wörter in der vollständigen Tokenliste. Sie dürfen daher
   vor, zwischen oder nach den übrigen Wörtern stehen.

Die folgenden Formen sind global und planidentisch:

```text
v universum 1/4,-1/8,2/3
universum v 1/4,-1/8,2/3
universum 1/4,-1/8,2/3 v
universum vielfache 1/4,-1/8,2/3
```

Dagegen ist diese Form absichtlich lokal:

```text
universum v1/4,-1/8,2/3
```

## Native Umsetzung

- `_parse_fraction_token` bestimmt `multiple` für jede Kommakomponente neu.
- `_fraction_pairs_with_multiple_scope` bleibt ausschließlich für das
  eigenständige, positionsunabhängige `v` beziehungsweise `vielfache`
  zuständig.
- Nicht präfigierte echte Brüche werden nicht mehr durch ein früheres
  kompaktes `v` expandiert.
- Beim positiven Reziprokkollisionsplan expandiert nur eine tatsächlich als
  Vielfaches markierte Reziprokkomponente. Ein lokales `-1/8` entfernt deshalb
  nur Zeile 8; `v-1/8` oder ein globales `v` entfernt alle Vielfachen von 8.

## Gebundene Laufzeitverträge

| Ausdruck | Bedeutung | Universum | Emotion + Universum |
|---|---|---:|---:|
| `v1/4,-1/8,2/3` | nur `1/4` mehrfach | 2 Aufrufe | 4 Aufrufe |
| `v 1/4,-1/8,2/3` | alle Komponenten mehrfach | 13 Aufrufe | 19 Aufrufe |
| `vielfache 1/4,-1/8,2/3` | alle Komponenten mehrfach | 13 Aufrufe | 19 Aufrufe |

Eine ausführbare Python-Referenzprobe schützt zusätzlich:

- die kommalokale Bindung eingebetteter Präfixe;
- die Positionsunabhängigkeit eigenständiger `v`-/`vielfache`-Wörter;
- die Gleichheit aller globalen Varianten.

## Archivhinweis

Das veröffentlichte Archiv wird aus einem frischen Checkout erzeugt und enthält
keine getrackte `tests/test_prompt_runtime.mojo.tmp`. Wer einen älteren
Arbeitsbaum überlagert hat, muss den alten Indexeintrag einmal entfernen:

```sh
git rm --cached --ignore-unmatch tests/test_prompt_runtime.mojo.tmp
rm -f tests/test_prompt_runtime.mojo.tmp
```

Bei einer frischen Entpackung ist dieser Schritt nicht erforderlich.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 6
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bq.sh -- -j 4
```

## Breiter compilerfreier Audit

Der anschließende Python-Gesamtaudit fand zwei unabhängige historische
Testfehler, ohne Produktionssemantik zu ändern:

- `TEST-FIXED-062`: Der Architekturfortschrittstest suchte `.git` unter
  `python_reference/` statt im tatsächlichen Projektwurzelverzeichnis.
- `TEST-FIXED-063`: Der Workflow-Snapshottest erwartete den Tippfehler
  `load_/religion_table` statt des realen Schritts `load_religion_table`.

Nach der Korrektur bestehen alle 70 Tests des historischen
Architektur-Refaktor-Monolithen sowie die neu erzeugten 70 AST-Fingerabdrücke.
