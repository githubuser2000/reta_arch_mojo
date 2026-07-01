# Stage 12c4h – `keineleereninhalte` vollständig nativ

Stage 12c4h übernimmt die historische Ausgabeoption
`--keineleereninhalte` beziehungsweise den englischen Alias
`--noblankcontents` in den typisierten Mojo-Tabellenplan.

## Referenzsemantik

Die Option ist kein grober Filter für leere CSV-Zeilen. Die Python-Referenz
prüft die **gerade sichtbaren Zellfragmente**:

- ohne Option gilt ein Fragment nur bei Länge null als leer;
- mit Option gilt jedes getrimmte Fragment mit weniger als zwei Unicode-
  Codepoints als leer;
- eine Ausgabezeile entfällt, wenn alle ausgewählten Datenfragmente leer sind.

Damit verschwinden insbesondere historische `?`-Platzhalter. Bei Shell, HTML
und BBCode gilt die Entscheidung getrennt je horizontaler Seite und je
umgebrochener visueller Zeile. CSV, Markdown, Emacs und Plain filtern die
entsprechende logische Tabellenzeile.

## Native Umsetzung

- `NativeRetaPlan.no_blank_contents` besitzt beide Sprachaliasnamen.
- `native_reta_tokens_supported()` akzeptiert die Option nur im vollständig
  besessenen nativen Argumentvektor.
- `table_rendering.mojo` verwendet Unicode-Codepointlängen und erhält die
  seitenspezifische sowie visuelle Filtergrenze.
- Der Emacs-Renderer setzt nun auch die historischen Trenner nach nichtprimen
  Primzahlpotenzen wie 4, 8, 9 und 16.
- HTML entfernt die Nummerierungsausrichtung innerhalb der Markupzelle und
  besitzt für `Manipulation (1)` die semantische Heading-Metadatenbrücke. Damit
  ist der vorher bereits vorhandene physische Katalogindexversatz geschlossen.

## Prüfvertrag

```text
No-blank-Rendererkern:                     3/3
HTML-Metadatenkatalog:                     5/5
nativer CLI-/Ownership-Planer:            25/25
Kompatibilitätslauncher:                   10/10
No-blank Python↔Mojo-Fixtures:            13/13 byteidentisch
bestehende zentrale Markup-Fixtures:       8/8
bestehende Markup-oneTable-Fixtures:      12/12
HTML-Heading-Katalogregeneration:          reproduzierbar
```

Die 13 versionierten Referenzfälle umfassen alle sechs Ausgabearten jeweils
mit und ohne Filter sowie den englischen HTML-Alias. Sie starten direkt
`reta-native`; in diesem Executable existiert kein Python-Fallback. Die
konservative Freigabe des historischen `reta`-Launchers wird sowohl im
Ownership-Test als auch durch einen Lauf mit absichtlich ungültigem
`RETA_PYTHON` geprüft. Der vollständige Launcher-Vertrag besteht 10/10.

## Bewusst nicht in diesen Block gezogen

Bei mehrspaltigen, seitengeteilten Altformaten existieren weitere unabhängige
Rich-/Hyphenations- und Leerzellen-Farbabweichungen. Die neue Filterentscheidung
ist dafür durch synthetische Seiten- und Wraptests abgesichert; diese älteren
Formatdetails werden nicht fälschlich als Teil von `keineleereninhalte`
bezeichnet.
