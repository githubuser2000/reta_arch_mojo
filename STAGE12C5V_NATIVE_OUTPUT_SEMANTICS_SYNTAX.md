# Stage 12c5v – Native Output Semantics and Syntax

## Ziel

`reta_architecture/output_semantics.py` war funktional nativ, besaß aber noch
keinen vollständigen typisierten Klassen-, Alias- und Snapshotvertrag.
`reta_architecture/output_syntax.py` war nur teilweise durch statische
Konstanten und Zeilenfarben ersetzt. Stage 12c5v schließt beide Oberflächen.

## Vollständige Ausgabesemantik

`src/reta_mojo/output_modes.mojo` besitzt nun:

- `OutputModeSpec` einschließlich Aliasliste und Snapshot;
- `OutputModeApplication` einschließlich Snapshot;
- `RetaOutputSemantics` mit `canonicalize`, `spec_for`, `create_syntax`,
  `mode_for_output_syntax`, `mode_for_tables`, `is_mode`,
  `apply_mode_to_tables` und `snapshot`;
- den expliziten `OutputModeApplyResult`, der unbekannte Modi ohne Mutation
  darstellt;
- die Python-Semantik des optionalen Zero-Width-Callbacks: CSV, Markdown und
  Emacs setzen die Breite nur dann auf null, wenn diese Grenze vorhanden ist;
- die sortierte Snapshotreihenfolge und die ursprüngliche Einfügereihenfolge
  von `i18n.words_context.ausgabeArt`.

Die vorhandenen produktiven Funktionen `apply_output_mode`,
`canonicalize_output_mode`, `colored_row_begin` und `generate_simple_cell`
bleiben kompatibel und delegieren an denselben Besitzer.

## Vollständige Syntaxoberfläche

`src/reta_mojo/output_syntax.mojo` ersetzt die dynamische Python-Klassenmap
durch sieben immutable Syntaxdeskriptoren:

- `OutputSyntax`
- `NichtsSyntax`
- `csvSyntax`
- `bbCodeSyntax`
- `htmlSyntax`
- `emacsSyntax`
- `markdownSyntax`

`OutputSyntaxBundle` besitzt `class_for`, Zeilenanfänge, typisierte
Zellenanforderungen und den vollständigen Snapshot. HTML-Zellen delegieren an
den bereits reproduzierbaren `HtmlCellCatalog`; BBCode- und einfache
Textsyntax verwenden die zentralen nativen Modusfunktionen. Damit werden
`OrderedDict`, dynamische Klassen, `getattr`, untypisierte Tabellenobjekte und
Python-Ausnahmen nicht in den nativen Kern übernommen.

## Diagnose und Parität

Der reguläre Build erzeugt das 21. reguläre Compilerziel:

```bash
scripts/build.sh
bin/reta-mojo-output-syntax --summary
bin/reta-mojo-output-syntax --canonical html
bin/reta-mojo-output-syntax --apply csv 33 false true
```

Der Stage-Test kompiliert den Mojo-Modultest und das Diagnoseprogramm und
vergleicht anschließend Modusbestand, Klassennamen, Flags, Aliase,
Bundlebesitzer und vier Anwendungsfälle mit Python beziehungsweise PyPy3:

```bash
scripts/test_stage12c5v.sh
```

In der Erstellungsumgebung ohne installierten Modular-Mojo-Compiler wurden die
Source-, Installations-, Matrix-, Metrik-, Defekt-, Archiv- und Boundary-Gates
ausgeführt: **43/43 bestanden**. Zusätzlich besteht der gesamte portable
Source-Testbestand mit **128/128** Tests und einem begründeten Skip für das im
Source-Archiv nicht enthaltene compilerabhängige Concat-Probe-Binary. Die beiden
compilerabhängigen Programme sind
vollständig vorbereitet und werden durch das Stage-Skript lokal geprüft.

## Behobene Port- und Testfehler

- `MOJO-FIXED-039`: `OutputModeSpec` beanspruchte zunächst `Writable`, obwohl
  kein `write_to`-Vertrag existierte. Der unbegründete Protocol-Conformance-
  Anspruch ist entfernt; Diagnoseausgaben schreiben Felder explizit.
- `TEST-FIXED-022`: Der portable Source-Testbestand verlangte ein absichtlich
  nicht archiviertes Concat-Probe-Binary und prüfte zwei veraltete Details der
  Interpreterwahl. Compilerabhängige Parität wird nun begründet übersprungen,
  während die Prompttests den zentralen Resolververtrag prüfen.
- Zentraler Fehlerkatalog: **85/85 konsistent**, davon weiterhin **19** spätere
  Python-/PyPy3-Bereinigungspunkte.

## Metriken

```text
vollständig nativ/generiert:      68/92 = 73,9 %
mindestens teilweise portiert:    83/92 = 90,2 %
angegriffene Referenzzeilen:       38.174/48.831 = 78,2 %
vollständig native Referenzzeilen: 30.423/48.831 = 62,3 %
produktive Mojo-Zeilen in src/:    55.639
produktive Mojo-Zeilen reta_mojo/: 51.402
aktive std.python-Brücken:              0
```
