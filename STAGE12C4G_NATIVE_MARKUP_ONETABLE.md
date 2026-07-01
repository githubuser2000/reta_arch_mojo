# Stage 12c4g – Native Markup-oneTable-Semantik

Stage 12c4g übernimmt die Ein-Tabellen-Semantik von `--onetable`,
`--endlessscreen`, `--endless` und `--dontwrap` nun auch für HTML und BBCode.
Damit besitzt der native Tabellenrenderer die vollständige formatübergreifende
Seitenteilungsentscheidung dieser vier historischen Aliasnamen.

## Semantik

Bei positiver Breite bleibt der normale HTML-/BBCode-Pfad seitenweise: Die
sichtbaren Spalten werden entsprechend der historischen 80-Zeichen-Grenze auf
mehrere `<table>`- beziehungsweise `[table]`-Blöcke verteilt. Sobald einer der
vier Ein-Tabellen-Aliase gesetzt ist, umfasst der erste und einzige Block alle
ausgewählten Spalten. Zellumbruch, HTML-Klassen, Symbolmetadaten,
Zählungsspalten und Zeilenfarben bleiben unverändert.

Bei `--breite=0` befanden sich bereits alle Spalten in einem Block. Der neue
Vertrag bewahrt diese Ausgabe bytegenau und sorgt zugleich dafür, dass der
native Ownership-Prüfer auch diese Kombination ausdrücklich besitzt.

## Native-first-Grenze

`native_reta_tokens_supported()` weist HTML/BBCode plus Ein-Tabellen-Alias
nicht mehr an Python zurück. Der historische `reta`-Launcher führt diese
Argumentvektoren daher direkt im Mojo-Prozess aus. Die Tests setzen
`RETA_PYTHON=/definitely/not/available`; ein unbemerkter Referenzfallback ist
somit ausgeschlossen.

## Reproduzierbarer Vertrag

```text
Markup-oneTable:             12/12 fixture-bytegleich ohne Python
Tabellenrenderer:            11/11
nativer CLI-/Ownership-Test: 24/24
gezielte Launcher/Boundary:  11/11
aktive std.python-Brücken:       0
```

Die zwölf Fälle umfassen HTML und BBCode, alle vier deutschen Aliasnamen,
englische Syntax sowie `--breite=0`. Die sechs versionierten Fixtures wurden
mit `PYTHONHASHSEED=0` gegen die Projekt-Referenz validiert. Eine bewusste
Neugenerierung ist möglich über:

```bash
RETA_REFRESH_MARKUP_ONETABLE_FIXTURES=1 \
  scripts/check_native_markup_onetable_parity.sh
```

## Launcher-Zielbild

Während der Migration bleiben drei Startnamen absichtlich sichtbar:

- `reta`: öffentliche native-first Oberfläche;
- `reta-native`: strikter Entwicklerpfad ohne Python-Rückfall;
- `reta-mojo-compat`: expliziter Name der Übergangs-/Fallbackoberfläche.

Nach vollständiger Transpilierung benötigt die öffentliche Installation nur
noch `reta`. `reta-native` kann als Diagnosealias erhalten bleiben;
`reta-mojo-compat` ist dann semantisch überflüssig und kann in Stage 12e entfernt
oder als rückwärtskompatibler Symlink auf `reta` belassen werden.
