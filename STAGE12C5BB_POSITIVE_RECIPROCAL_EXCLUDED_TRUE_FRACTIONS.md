# Stage 12c5bb – positive reziproke Vielfache mit ausgeschlossenen echten Brüchen

## Ausgangspunkt

Stage 12c5ba besitzt bereits die reihenfolgensensitiven negative-first
No-op-Zweige. Der positive-first Gegenfall

```text
universum v1/4,-2/3
```

blieb absichtlich am atomaren Python-Rand, weil die Referenz nicht leer ist.
Eine instrumentierte Referenzausführung zeigt jedoch einen engen und stabilen
Vertrag: Ein führendes positives `v1/n`, gefolgt ausschließlich von
Aussschlüssen `-a/b` mit `a > 1`, erzeugt genau eine reziproke Vielfachenachse.
Die ausgeschlossenen echten Brüche erzeugen weder eine `n/m`-CSV-Achse noch
eine Ganzzahl- oder Gleichheitsachse.

## Nativer Besitz

`prompt_table_execution.mojo` erkennt jetzt ausschließlich diese Klasse:

- mindestens ein positives, ausdrücklich mit `v` markiertes `1/n`,
- mindestens ein ausgeschlossener echter Bruch `-a/b` mit `a > 1`,
- keine positive echte Bruchachse,
- kein ausgeschlossener Reziprokwert `-1/n`,
- genau eine ausgewählte physische Bruchdomäne.

Die bereits vorhandene getrennte Achsenlogik liefert danach automatisch:

- reziproke Vielfache unterhalb 1024,
- keine positive `n/m`-Zählergruppe,
- genau einen Tabellenaufruf pro ausgewählter Tabellenfamilie.

Bewiesene Beispiele:

```text
universum v1/4,-2/3
universum v1/2,-2/3
emotion v1/4,-2/3
universum v1/4,-2/3 teiler
```

Der erste Fall besitzt exakt die Zeilenmenge `{4, 8, ..., 1020}`. Der zweite
besitzt `{2, 4, ..., 1022}`. `teiler` verändert dabei wie in der Referenz nur
die ausgewählte Universum-Spaltenmenge von `1,2` auf `1`.

## Bewusst verbleibender atomarer Fallback

Nicht verallgemeinert wird auf andere Signaturklassen. Insbesondere bleibt

```text
universum v1/4,-1/8,2/3
```

atomarer Fallback, weil der ausgeschlossene Reziprokwert zusammen mit einer
positiven echten Bruchachse weiterhin den dokumentierten Python-Fehlerzweig
erreicht. Auch positive echte Brüche neben dem positiven Reziprok werden nur
über die bereits separat bewiesenen gemischten Achsenverträge besessen.

## Prüfung

Der Stage-Lauf baut weiterhin den vollständigen Prompt-Tabellenvertrag und die
Bruchvielfachenprobe über die Kette 12c5bb → 12c5ba → 12c5az. Die Probe enthält
nun vier zusätzliche Fälle. Der Python-Referenzprüfer bestätigt für Universum
und Emotion jeweils genau einen `reta`-Aufruf, die vollständige reziproke
Zeilenmenge und das Fehlen jeder `--gebrochen-rational_*`-Achse. Anschließend
wird der neue Ein-Achsen-Plan direkt mit `reta-native` ausgeführt; eine
Python-Laufzeit darf dabei nicht verfügbar sein.

Die Mojo-Kompilierung und Laufzeitausführung übernimmt weiterhin der Benutzer:

```sh
scripts/build-all.sh -- -j 8
scripts/test_stage12c5bb.sh
```
