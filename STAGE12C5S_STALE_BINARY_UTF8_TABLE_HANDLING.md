# Stage 12c5s – stale Binary Guard, UTF-8 HTML und native tableHandling-Fassade

## Auslöser

Nach einer source-only Aktualisierung stürzte `bin/reta-native` weiterhin mit

```text
String slice starts on 17/20 which is not a codepoint boundary
```

ab. Das Archiv enthält absichtlich kein `target/`. Ein vorhandener alter
`target/bin/reta-native` blieb deshalb im Arbeitsbaum liegen und wurde vom
Launcher vor dem neuen Quellcode bevorzugt.

## Build-Frischevertrag

Reguläre und schwere Builds schreiben neben jedes erzeugte ELF eine
`*.reta-source-id`-Datei. Die ID ist der SHA-256-Fingerabdruck von
`SOURCE_MANIFEST.sha256`.

`bin/mojo-runtime-exec` ruft vor einem Source-tree-Binary nun zentral
`scripts/check_mojo_binary_freshness.sh` auf. Abgewiesen werden:

- Binaries ohne Source-ID;
- Binaries aus einem anderen Sourcearchiv;
- Binaries, die älter als eine Datei unter `src/` sind.

Installierte FHS-Bäume ohne Entwicklungsmanifest bleiben davon unberührt.

## UTF-8-Härtung des HTML-Renderers

`table_rendering.mojo` verwendet im HTML-Pfad keine rohe Konstruktion
`StringSlice(text)[byte=...]` mehr. HTML-Escaping iteriert Codepoints. Der
verbleibende Scanner für bewusste Tags rekonstruiert Textspannen ebenfalls aus
vollständigen Codepoints. Selbst ein fehlerhaft nicht ausgerichteter Byteoffset
kann daher keinen Runtime-Assert mehr erzeugen.

Die lokalen Reproducer umfassen:

```bash
bin/reta-native -zeilen --vorhervonausschnitt=1 \
  -spalten --alles -ausgabe --art=html
bin/reta-native -zeilen --alles \
  -spalten --alles -ausgabe --art=html
```

sowie Umlaute, CJK, Emoji und HTML-Sonderzeichen hinter Mehrbytezeichen.

## Vollständiger Besitz von `libs/tableHandling.py`

Die 27 exportierten Namen der historischen Fassade sind nun durch
`src/reta_mojo/legacy_table_handling.mojo` besessen. Das native
`LegacyTableHandlingRuntime` bündelt explizit:

- `TableStateSections`;
- `TextWrapRuntimeState`;
- `OutputRuntimeState`;
- `info_log` und `output_enabled`.

Syntaxklassen, Zahlentheorie, Shell-Zeilenbreite, Textwrap-Capabilities und
Konsolenausgabe delegieren ausschließlich an bestehende native Besitzer. Es
gibt keine Python-, `PythonObject`- oder Subprozessbrücke.

## Tests

```bash
scripts/build.sh
scripts/test_stage12c5s.sh
```

Der Stage-Test baut den exakten All-Spalten-HTML-Reproducer und die native
`tableHandling`-Fassade. Source-Gates prüfen zusätzlich die Build-Sidecars, den
real ausgeführten stale-binary-Reject und das Fehlen roher HTML-String-Slices.

## Metriken

```text
vollständig nativ/generiert:      64/92 = 69,6 %
mindestens teilweise portiert:    83/92 = 90,2 %
angegriffene Referenzzeilen:       38.174/48.831 = 78,2 %
vollständig native Referenzzeilen: 29.297/48.831 = 60,0 %
produktive Mojo-Zeilen in src/:    53.613
produktive Mojo-Zeilen reta_mojo/: 49.581
aktive std.python-Brücken:              0
```
