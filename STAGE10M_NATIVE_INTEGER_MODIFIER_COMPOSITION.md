# Stage 10m – native Ganzzahl-Modifikatorkomposition

Stage 10m schließt den stabilen ganzzahligen Mischpfad aus `vielfache` und
`teiler` und korrigiert zwei dabei sichtbar gewordene Python-Verträge:
verschachtelte CPython-Mengenreihenfolge sowie dynamisch angehobene
Tabellenobergrenzen für absolute `vN`-Selektoren.

## Komponierte `vielfache`-/`teiler`-Planung

`prompt_table_execution.mojo` plant nun Befehle wie

```text
vielfache teiler mond 6 10
v w mond 12
vielfache teiler mond 2-4
```

vollständig nativ. Der Python-Pfad bildet zuerst die Vereinigungsmenge aller
Teiler, fügt danach die ursprünglichen rohen Zahlenkomponenten an und hängt
zuletzt deren `v...`-Selektoren an. Anders als beim reinen Vielfachenpfad darf
hier **kein** zusätzliches `--vielfachevonzahlen` ausgegeben werden, weil dieser
Filter die zuvor ergänzten Teiler wieder entfernen würde.

Beispiele der reproduzierten Argumentfolgen:

```text
6 10  -> 2,3,5,6,10,10,6,v10,v6
2-4   -> 2,3,4,2-4,v2-4
24    -> 2,3,4,6,8,24,12,24,v24
```

Echte gebrochen-rationale `v n/m`-Vielfache mit Zähler größer 1 bleiben weiter
an der expliziten Kompatibilitätsgrenze, weil die Python-Referenz dort selbst
mit `IndexError` abbricht.

## Verschachtelte CPython-Set-Semantik

Die Teilerreihenfolge ist weder sortiert noch eine einfache Reihenfolge der
ersten Vorkommen. `arithmetic.divisor_range` verschachtelt:

1. Mengen aus Faktor-Tupeln,
2. eine zweite Tupelmenge,
3. zweielementige Ganzzahlmengen und
4. wiederholtes `set |= source_set`.

`prime_cross_columns.mojo` besitzt nun eine typisierte Nachbildung dieser
CPython-3.13-Operationen einschließlich:

- XXHash-basierter Tupelhashes,
- offenem Set-Probing,
- unterschiedlicher Resize-Regeln für `set.add` und `set_merge`,
- der Tabellenkopie beim Merge in eine leere gleich große Menge,
- Entfernung der `1` nur dann, wenn weitere Teiler existieren.

Damit bleibt auch der nicht intuitive Fall `24 -> 2,3,4,6,8,24,12` exakt
erhalten.

## Dynamische Obergrenze absoluter Vielfachenselektoren

Die Python-Laufzeit bestimmt ihre Tabellenobergrenze bereits aus
`--vorhervonausschnitt`. Ein eingebettetes `vN` wird zunächst mit der
historischen 1028-Grenze expandiert; anschließend wird die Laufzeitgrenze auf
`max(Auswahl) + 1` angehoben. Die eigentliche Zeilenauswahl expandiert danach
noch einmal gegen diese neue Grenze.

Der native CLI-Kern reproduziert diesen zweistufigen Effekt nun vor dem
Tabellenaufbau und erweitert die physische CSV-Tabelle bei Bedarf um typisierte
Leerzeilen, auf denen die generierten Spalten weiterarbeiten. Dadurch sind unter
anderem sichtbar:

- `v6,v10` bis Zeile 1026,
- `v2-4` einschließlich der historischen Folgezeile 1029,
- `v24` weiterhin ohne unnötige Anhebung über 1024.

Der reine Parameter `--vielfachevonzahlen` behält dagegen seine separate kurze
Haupttabellengrenze.

## Verifikation

- `test_prompt_table_execution.mojo`: **25/25** bestanden,
- `test_native_reta_cli.mojo`: **22/22** bestanden,
- `test_row_ranges.mojo`: **7/7** bestanden,
- `test_row_filtering.mojo`: **4/4** bestanden,
- `test_table_preparation.mojo`: **2/2** bestanden,
- normalisierte Python↔Mojo-CSV-Parität:
  - `vielfache teiler mond 6 10`: **243/243 Zeilen**, bytegleich,
  - `vielfache teiler mond 2-4`: **687/687 Zeilen**, bytegleich,
  - `vielfache teiler mond 24`: **49/49 Zeilen**, bytegleich.

Der große Generated-Columns-Test konnte in dieser Umgebung nicht neu kompiliert
werden, weil der Mojo-Compiler das großzügige Build-Zeitlimit überschritt. Die
kleineren direkt betroffenen Suiten und der reale Tabellenstrom sind grün.

Der breite `--alles`-Test wurde in Stage 10m nicht ausgeführt. Er darf gemäß der
Vorgabe nur mit einem Timeout von **90 Minuten** gestartet werden; kein kürzerer
Lauf wurde versucht.
