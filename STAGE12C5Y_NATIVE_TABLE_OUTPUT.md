# Stage 12c5y – vollständiger nativer TableOutput-Besitzer

## Ausgangspunkt

`reta_architecture/table_output.py` war in der Portierungsmatrix nur als
„teilweise nativ“ markiert. Die eigentlichen Formatserializer waren bereits in
`src/reta_mojo/table_rendering.mojo` breit vorhanden und durch zahlreiche
Markup-, Breiten-, UTF-8- und CLI-Paritätstests abgesichert. Es fehlte jedoch
der explizite Besitzer der historischen Klasse `TableOutput` selbst:

- mutierbarer Ausgabemodus und Syntaxklasse,
- Farb-, Ein-Tabellen-, Nummerierungs- und Breitenzustand,
- `onlyThatColumns`,
- der durch `cliout2` geführte Ergebnisbuffer,
- die öffentliche ANSI-Farbpolitik,
- `TableOutputBundle.create` und dessen Snapshotvertrag.

Dadurch war die Renderinglogik zwar nativ, die Architekturgrenze aber noch
nicht als eigenständiger typisierter Abschnitt geschlossen.

## Neuer Besitzer

`src/reta_mojo/table_output.mojo` führt ein:

- `TableOutputConfig`
- `TableOutput`
- `TableOutputRenderResult`
- `TableOutputRuntimeSnapshot`
- `TableOutputBundle`
- `TableOutputBundleSnapshot`
- `default_table_output_config()`
- `bootstrap_table_output()`

Der heterogene Python-`Tables`-Objektgraph wird durch einen expliziten
Konfigurationswert ersetzt. Alle tatsächlich vom Renderer konsumierten
Eigenschaften sind benannt und typisiert. `cli_out` delegiert an
`render_table_with_native_context`, behält aber die historische Besitzregel:
Der logische Text wird immer in `resulting_table` aufgenommen; die physische
Ausgabe kann durch `nothing_output` unterdrückt werden.

## Vollständig abgedeckte Oberfläche

Die native Schicht besitzt nun:

1. Outputmodus und Syntaxklassenname,
2. Color-/OneTable-/Nummerierungszustand,
3. globale und spaltenspezifische Breiten,
4. Textbreite und Texthöhe,
5. Heading- und No-blank-Filter,
6. Sprache und HTML-Quellspalten,
7. Zeilennummernobergrenze,
8. geordnete einbasierte Spaltenprojektion mit stiller Auslassung ungültiger
   Indizes,
9. Ausgabeakkumulation und unterdrückte physische Ausgabe,
10. ANSI-Farbgebung für Überschrift, Restzeile, Mondzahlen, Primzahlen und
    gerade/ungerade Normalzeilen,
11. Shell, CSV, Markdown, Emacs, HTML, BBCode und Nichts über die bereits
    vorhandenen nativen Serializer.

Die Farbimplementierung wird nicht dupliziert. `table_rendering.mojo` exponiert
mit `colorize_shell_text` lediglich einen öffentlichen Adapter auf den bereits
produktiven `_shell_colorize`-Kern.

## Diagnose und Build

Neu:

```text
src/table_output_main.mojo
bin/reta-mojo-table-output
scripts/check_table_output_parity.py
scripts/test_stage12c5y.sh
tests/test_table_output_complete.mojo
tests/test_table_output_complete_source.py
```

`scripts/build.sh` baut nun 23 reguläre Ziele. Zusammen mit 18 schweren Zielen
umfasst das Installmanifest 41 Compilerziele.

## Paritätsvertrag

Der Python-Paritätsprüfer vergleicht:

- den exakten `TableOutputBundle.snapshot()`-Vertrag,
- `onlyThatColumns` einschließlich Reihenfolge und ungültiger Indizes,
- die ANSI-Farbpolitik für Überschrift, Restzeile, Prim- und Mondzahl.

Der native Modultest prüft zusätzlich Zustandsübergänge, Modus-Flags,
Ergebnisbuffer, CSV-Delegation und die gekoppelte Entfernung von Überschrift
und Überschriftszeilennummer. Die bestehende vollständige
`test_table_rendering.mojo`-Suite wird im Stage-Test erneut gebaut und
 ausgeführt.

## Native Prüfung

```bash
scripts/test_stage12c5y.sh
```

Der Lauf baut zuerst den vollständigen Paketimportgraph, danach Diagnose-,
Besitzer- und Renderer-Modultest und schließlich die Python-/PyPy3-Parität.

## Compilerunabhängige Abschlussprüfung

```text
fokussierte Stage-Gates:              60/60 bestanden
gesamter portabler Source-Bestand:    144 bestanden, 1 begründeter Skip
relative Mojo-Importe:                264/264 auflösbar
Defektkatalog:                        95/95 konsistent
Python-Bereinigungspunkte:            19
aktive std.python-Brücken:             0
```

Der zusätzliche Audit fand `TEST-FIXED-027`: Der historische
All-Columns-Quelltest erwartete `load_all_column_selection` noch in
`native_reta_cli.mojo`, obwohl Stage 12c4y den einzigen Besitzer bewusst nach
`parameter_runtime.mojo` verschoben hatte. Der Test prüft nun Delegation statt
Duplikation und stimmt mit `test_parameter_runtime_source.py` überein.

Der offizielle Modular-Mojo-Compiler ist in der Erstellungsumgebung nicht
installiert. Ein angekündigter hochgeladener `target`-Ordner war im aktiven
Dateisystem nicht gefüllt sichtbar; deshalb werden Compiler- und Laufzeiterfolge
nicht vorweggenommen. `scripts/test_stage12c5y.sh` bleibt das verbindliche Gate.

## Metrik

`reta_architecture/table_output.py` wechselt von `teilweise nativ` zu `nativ`:

```text
vollständig nativ/generiert:       71/92 = 77,2 %
mindestens teilweise portiert:     83/92 = 90,2 %
vollständig native Referenzzeilen: 31.790/48.831 = 65,1 %
angegriffene Referenzzeilen:        38.174/48.831 = 78,2 %
```
