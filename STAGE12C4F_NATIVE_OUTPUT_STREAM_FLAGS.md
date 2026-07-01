# Stage 12c4f – Native Ausgabe-Stream- und Ein-Tabellen-Semantik

Stage 12c4f übernimmt die historische Terminal-Ausgabegruppe
`--onetable`, `--endlessscreen`, `--endless`, `--dontwrap` und `--justtext`
in den nativen Tabellenplaner und Shellrenderer.

## Semantik

Die vier Ein-Tabellen-Aliase setzen dasselbe typisierte Planfeld
`NativeRetaPlan.one_table`. Im Shellmodus wird damit die horizontale
Seitenteilung vollständig deaktiviert; alle ausgewählten Spalten werden in
einem einzigen Tabellenstrom ausgegeben. `--justtext` ist das historische Alias
von `--nocolor` und unterdrückt ANSI-Farbsequenzen.

`--breite=0` besitzt zusammen mit `--onetable` eine besondere Legacy-Semantik:
Die Zellen werden überhaupt nicht umgebrochen. Der native Renderer bestimmt
dafür die längste vollständige Zelle statt die automatische Terminalbreite zu
verwenden. Positive Breiten beginnen wie in Python bei mindestens 21 Zeichen;
sobald im Argumentvektor `--breite=0` vorkam, bleibt die Breite für nachfolgende
Breitenparameter auf null gesperrt.

## Konservative Formatgrenze

Die neue Ownership-Freigabe gilt für den Shell-/Terminalrenderer. HTML und
BBCode verwenden weiterhin einen separaten Legacy-Formatter, dessen komplette
Whitespace- und Metadatenparität noch nicht für `oneTable` bewiesen ist.
Kombinationen aus HTML/BBCode und einem Ein-Tabellen-Alias fallen deshalb
weiterhin atomar auf die Python-Referenz zurück. Es gibt keine teilweise native
Ausführung.

## Zusätzliche Paritätskorrektur

Der native Wortumbruch füllt bei überlangen Wörtern nun wie
`textwrap.TextWrapper` zunächst den noch freien Rest der aktuellen Zeile und
setzt erst danach auf der nächsten Zeile fort. Die Implementierung arbeitet
über Unicode-Codepunkte und trennt daher keine UTF-8-Sequenzen.

## Reproduzierbarer Vertrag

```text
Ausgabe-Stream-Parität:             7/7 byteidentisch ohne Python
nativer CLI-/Ownership-Planer:     24/24
Tabellenrenderer:                  10/10
Kompatibilitäts-/Boundary-Pytests: 19/19
BBCode-Regressionsfixtures:          3/3
aktive std.python-Brücken:             0
```

Die sieben Referenzfälle decken alle vier Ein-Tabellen-Aliase, `justtext`,
deutsche und englische Syntax sowie `--breite=0` mit nachfolgendem
Breitenparameter ab. Der native Lauf setzt `RETA_PYTHON` absichtlich auf einen
nicht existierenden Pfad.

## Prüfung

```bash
scripts/check_compat_launcher.sh
scripts/check_native_output_stream_parity.sh
scripts/test_stage12c.sh
```
