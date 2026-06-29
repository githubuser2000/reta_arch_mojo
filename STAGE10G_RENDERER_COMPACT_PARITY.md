# Stage 10g – vorbereitete Shellbreiten und vollständige kompakte Tabellenfamilien

Stage 10g schließt die in Stage 10f bewusst zurückgehaltenen kompakten
Tabellenfamilien. Die Ursache lag nicht in deren Promptplanung, sondern in der
Reihenfolge des historischen Renderers: Python umbricht ausgewählte Zellen
zuerst mit der festen Vorbereitungsbreite 73 und bestimmt erst danach die
sichtbare Spaltenbreite aus den entstandenen Fragmenten. Mojo hatte dagegen
die rohe Zelllänge direkt auf 73 gekappt.

## Allgemeine Rendererreparatur

`table_rendering.mojo` misst Shellspalten nun an den tatsächlich vorbereiteten
Fragmenten. Dadurch werden schmalere natürliche Maximalbreiten wie 64, 67, 69,
71 oder 72 erhalten, statt jede längere Rohzelle künstlich auf 73 zu ziehen.
Ein fokussierter Test mit `aaaa bbbb cccc` verhindert die Rückkehr zur alten
Rohzellenmessung.

Die Referenzumgebung besitzt kein `textwrap2` und verwendet deshalb Python
`textwrap` mit `break_on_hyphens=True`. Mojo übernimmt jetzt dieselbe allgemeine
Regel: Passt ein vorhandener Bindestrichpräfix noch auf die aktuelle Zeile,
bleibt er dort, während der Rest auf der Folgezeile beginnt. Das reproduziert
unter anderem `Meta-` / `Paradigmen`, ohne den konkreten Begriff zu codieren.

## Historischer Ausgabestrom

Rich-basiertes `cliout` hängt in der Python-Referenz keinen Zeilenumbruch an.
Deshalb bilden bei farbiger Ausgabe

1. die kompakte Expansionsankündigung,
2. der sichtbare `reta`-Befehl und
3. die erste Tabellenzeile

einen einzigen physischen Ausgabestrom. Dasselbe gilt für ausgeschriebene
Prompt-Tabellenbefehle. Mojo bildet diese Form jetzt bytegenau ab. Mit
`--nocolor` bleibt die normale zeilenorientierte `print`-Semantik erhalten.

## Neu vollständig native Kompaktfamilien

Zusätzlich zu Stage 10f laufen jetzt ohne Python-Import und ohne
`reta-native`-Kindprozess:

- `B` / `bewusstsein`
- `E` / `emotion`
- `T` / `triebe`
- `W` / `wirklichkeit`
- `u` / `universum`

Damit sind alle bislang als rendererempfindlich markierten kompakten
Tabellenfamilien im nativen One-shot-Pfad. Zehn vollständige Ausgaben (`a2`,
`ap15`, `p12`, `p13`, `G2`, `B2`, `E2`, `T2`, `W2`, `u2`) sind gegen die
unveränderte Python-3.13.5-Referenz mit `PYTHONHASHSEED=0` bytegleich.

## Verbleibende kompakte Grenze

Reine Zahlenkürzel wie `15` bleiben atomar an der Bridge. Sie sind keine
Einzeltabelle, sondern komponieren mehrere historische Ausgaben samt eigenen
Zeilenmarkierungen. Diese Komposition wird in einer folgenden Stage als eigener
typisierter Plan portiert; Stage 10g leitet daraus keine vereinfachte
Ersatzsemantik ab.
