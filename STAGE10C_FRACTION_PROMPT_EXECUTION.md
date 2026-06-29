# Stage 10c – Bruchbereiche und Zeilenmodifikatoren im nativen Prompt

Stage 10c schließt die größte zusammenhängende Fallbackgrenze aus Stage 10b: positive Brüche sowie die ganzzahligen Promptoperatoren `vielfache`, `teiler` und `einzeln` werden vor der Fachfamilienauswahl nativ in einen `PromptTablePlan` überführt.

## Datenfluss

```text
Prompt-Tokens
  → lokalisierte kanonische Befehle
  → positive Ganzzahlbereiche
  → _PromptFractionPair-Zwischenwerte
  → ganze / reziproke / echte n/m-Achsen
  → geordnete PromptTableInvocation-Liste
  → reta-native
```

Die bestehende reine Portierung von `bruchSpalt` und `createRangesForBruchLists` wird jetzt tatsächlich von der Tabellenplanung benutzt. Dadurch sind nicht nur Einzelbrüche, sondern auch die historischen Rechteck- und Versatzformen ausführbar.

## Referenzfälle

Die neue Ausführungsparität umfasst:

```text
emotion 2/3
emotion 2/4
universum 3/3
groesse 2/4
teiler mond 12
einzeln mond 2
vielfache mond 512
motive 2/3
universum 1/2-3/3
motive 4/5+2/2
```

Verglichen wird der geordnete CSV-Tokenstrom nach Entfernung ausschließlich präsentationsbedingter Whitespace-Läufe. Das ist absichtlich enger als ein bloßer Rückgabecode, behauptet aber keine Bytegleichheit des noch nicht vollständig identischen Shell-Wrappings.

## Verbleibende Grenze

Die Subtraktions- und Bruchvielfachenalgebra (`-1/2`, `v1/2`, Bruch plus `vielfache`/`teiler`) bleibt atomar bei der Referenz. Sie wird erst übernommen, wenn Mengenbildung, Abzug und Reihenfolge gemeinsam portiert sind.
