# Stage 12c5bp – vollständiger Geltungsbereich von Bruchvielfachen

## Gefundene Produktionslücke

Der in Stage 12c5bd eingeführte korrigierte Kollisionsplan für

```text
universum v1/4,-1/8,2/3
```

war im typisierten Parser faktisch nicht erreichbar. Der äußere Parser zerlegt
den kommagetrennten Ausdruck vor der Bruchanalyse. Dabei erhielt nur der erste
Teil `v1/4` das Merkmal `multiple=True`; `-1/8` und `2/3` verloren den durch das
führende `v` gesetzten Geltungsbereich. Der anschließende, bewusst enge
Kollisionswächter verlangt dagegen für alle drei Bruchteile denselben
Vielfachenmodus und gab deshalb trotz vorhandener Planlogik `FALLBACK` zurück.

Dieser Fehler blieb hinter der zuvor früher abbrechenden Emotionsassertion
verborgen.

## Korrektur

- `_parse_fraction_token` erhält den expliziten Parameter
  `inherited_multiple`.
- Beginnt ein kommagetrennter Bruchtoken mit `v`, wird dieser Modus an sämtliche
  Bruchkomponenten desselben Tokens vererbt.
- Die ausgeschriebene Form `vielfache 1/4,-1/8,2/3` normalisiert alle bereits
  geparsten Paare auf denselben Vielfachenmodus und ist damit semantisch
  identisch zur Kompaktform.
- Gemischte Ganzzahlteile wie `v2/3,5` bleiben gewöhnliche äußere Ganzzahlachsen;
  nur Bruchkomponenten erben den Bruchvielfachenmodus.

## Erweiterte native Verträge

Der bisher nur beabsichtigte 13-Aufruf-Plan ist nun tatsächlich erreichbar:

```text
universum v1/4,-1/8,2/3
universum vielfache 1/4,-1/8,2/3
```

Beide Formen erzeugen denselben serialisierten Plan. Die Reziprokachse enthält
Vielfache von vier unterhalb 1024, entfernt Vielfache von acht und vereinigt
damit unabhängig die korrigierte echte `2/3`-Bruchprojektion.

Zusätzlich wird die bereits vorhandene Mehrdomänenlogik für

```text
emotion universum v1/4,-1/8,2/3
```

aktiviert. Der Plan besitzt 19 Aufrufe: sechs für die Emotionsdomäne und dreizehn
für die Universumsdomäne. Beide Domänen behalten ihr eigenes n/m-Rechteck und
ihre eigene Reziprokprojektion.

## Python-Referenz

Die drei Kollisionsformen reproduzieren weiterhin `PY-OPEN-002` mit
`IndexError: string index out of range` in `prompt_execution.py`. Mojo übernimmt
nicht den Absturz, sondern den bereits dokumentierten korrigierten Vertrag aus
getrennter 1024er-Reziprokachse und datenbegrenzten physischen Bruchrechtecken.

## Benutzerprüfung

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bp.sh -- -j 4
```

Der Stage-Test kompiliert nur den fokussierten Bruchplan-Probe neu und führt die
Einzel-/Mehrdomänenpläne anschließend direkt über das vorhandene
`bin/reta-native` aus. Ein vollständiger Produktionsbuild ist wegen der
Änderung in `prompt_table_execution.mojo` dennoch vor dem Stage-Test sinnvoll.
