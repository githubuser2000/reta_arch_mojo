# Stage 12c5q – UTF-8-sicheres Rendering und vollständige Runtime-Kompatibilität

## Anlass

Der produktive Aufruf

```sh
bin/reta -zeilen --vorhervonausschnitt=1 -spalten --alles -ausgabe --art=html
```

brach im nativen Kompatibilitätsprogramm mit

```text
String slice starts on 17 which is not a codepoint boundary
```

ab. Zusätzlich meldete der Compiler in `html_class_extractor.mojo`, dass eine
Zuweisung an `pending_space` vor dem nächsten Überschreiben nie gelesen wurde.

## UTF-8-Reparatur

`table_rendering.mojo` zerlegt Wörter und Whitespace nun konsequent über
`codepoint_slices()`. Rekonstruierte Präfixe werden mit `removeprefix` entfernt,
statt ihre Codepointlänge als Byteoffset für `StringSlice` zu verwenden. Alle
vier Umbruchpfade besitzen zusätzlich einen No-Progress-Fallback auf
`hard_chunks`, damit ein unerwartet nicht exakt passender Präfix weder eine
Endlosschleife noch einen unsicheren Slice erzeugt.

Auch der interne Ganzzahlparser des Renderers liest ASCII-Ziffern aus
Codepoint-Slices. Damit existiert im Wortumbruch kein Pfad mehr, der einen
beliebigen UTF-8-Byteoffset als Stringgrenze verwendet.

Die exakte Benutzerkommandozeile ist in
`tests/test_native_reta_utf8_html.mojo` als kompilierter Regressionstest
enthalten. Weitere Fälle umfassen Umlaute, CJK-Zeichen und Emoji in langen,
mit Bindestrichen getrennten Wörtern.

## Compilerwarnung

Die tote Zwischenzuweisung `pending_space = False` wurde aus
`html_class_extractor.mojo` entfernt. Der Zustandsautomat setzt den Wert erst an
der tatsächlich beobachtbaren Stelle.

## Vollständiger Besitzer für `runtime_compat.py`

`src/reta_mojo/runtime_compat.mojo` besitzt nun die komplette öffentliche
Oberfläche von `python_reference/reta_architecture/runtime_compat.py`:

- 17 definierte Funktionen plus den Alias `isZeilenAngabe`;
- die acht Werte und fünf Gruppierungen von `nPmEnum`;
- die historischen Multiplikations-, Komma- und Primzahlkreuz-Konstanten;
- Bereichs-, Arithmetik-, Konsolen-, Hilfe- und Wrapping-Adapter;
- einen typisierten Snapshot der 18 aufrufbaren Namen und 13 globalen Namen.

Die früher nur von `legacy_center.mojo` verwendete Unicode-Zifferntabelle ist
nun auch der zentrale Besitzer für `arithmetic.has_digit`. Damit entspricht
`textHatZiffer` wieder Python `str.isdigit`, auch für etwa `٢`, `²` und `⑵`.

Es gibt keine `std.python`-, `PythonObject`-, Unterprozess- oder Interpreterbrücke.

## Prüfung

Der lokale Stage-Test kompiliert und startet:

1. `tests/test_runtime_compat_complete.mojo`
2. `tests/test_native_reta_utf8_html.mojo`
3. `tests/test_table_rendering.mojo`

Danach folgen die Source-, Ownership-, Defekt-, Metrik- und Archivverträge über
den gemeinsamen Pytest-Resolver.
