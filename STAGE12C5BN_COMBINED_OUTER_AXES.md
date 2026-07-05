# Stage 12c5bn – kombinierte klassische, Eigenschafts- und Katalogachsen

Stage 12c5bn schließt die letzte in 12c5bm bewusst offen gelassene
Mehrdomänen-Grenze: klassische Ganzzahlfamilien dürfen nun gemeinsam mit
`EIGN…`/`EIGR…` und den numerischen Katalogfamilien 16/15 um korrigierte echte
Bruchvielfachpläne liegen.

## Belegte gemeinsame Außenordnung

Die instrumentierte Python-Referenz beweist unabhängig vom bekannten defekten
gemeinsamen n/m-Rechteck folgende stabile Reihenfolge:

1. Thomas,
2. physische Emotion-/Größe-/Motive-Blöcke,
3. EIGN vor EIGR,
4. physischer Universum-Block,
5. Mond, Alles, Primzahlkreuz und Richtung,
6. numerische Familie 16,
7. numerische Familie 15.

Die klassischen, Eigenschafts- und Katalogaufrufe verwenden dieselbe geordnet
deduplizierte Ganzzahlprojektion. Primzahlkreuz bleibt die Ausnahme: Es übernimmt
nur die explizite gewöhnliche Vielfachenachse und `--oberesmaximum=1029`, aber
keine projizierten Ganzzahlen.

## Native korrigierte Pläne

Die physische Bruchausführung bleibt gegenüber Python absichtlich korrigiert:
Motive und Universum besitzen weiterhin je ihr eigenes Zähler×Nenner-Rechteck.
Nur die äußere Zweigreihenfolge wird aus Python übernommen.

Beispiele:

- `mond motive EIGNgut universum v2/3,5`: 28 Aufrufe;
- `mond motive universum 15_13 16_2 v2/3,5`: 29 Aufrufe;
- vollständige Kombination mit Thomas, vier klassischen Suffixen, EIGN und
  beiden Katalogfamilien: 34 Aufrufe;
- dieselbe Kombination zusätzlich mit EIGR: 35 Aufrufe.

## Implementierungsänderung

Der Planer erzeugte die kombinierte Reihenfolge bereits vollständig in
`_plan_multi_domain_true_fraction_multiples`. Entfernt wurde deshalb nur der
konservative Gate, der bei gleichzeitig vorhandener klassischer und
Eigenschafts-/Katalogachse unnötig `FALLBACK` zurückgab. Der danach unbenutzte
Hilfsprädikatpfad wurde ebenfalls entfernt.

## Prüfung

```sh
PYTHONHASHSEED=0 python3 scripts/check_prompt_combined_outer_order_reference.py
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bn.sh -- -j 4
```

Die Python-Probe prüft ausschließlich Executor-argv und Zweigreihenfolge. Sie
friert nicht das bekannte fehlerhafte historische gemeinsame n/m-Rechteck ein.
