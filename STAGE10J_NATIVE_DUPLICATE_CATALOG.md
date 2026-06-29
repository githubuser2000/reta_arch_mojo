# Stage 10j – wiederholte Katalogauswahl und textwrap-genauer Shellpfad

Stage 10j entfernt die bisherige atomare Python-Grenze für wiederholte numerische Katalogauswahlen. Die Untersuchung der Referenzausgabe zeigte, dass Python keine getrennten Generatorinstanzen mit eigenem Breitenzustand erzeugt: Die wiederholten Aliaswerte bleiben lediglich in der sichtbaren `reta`-Befehlszeile erhalten; die eigentliche Generatoranforderung wird bereits im Tabellenkern semantisch dedupliziert.

## Übernommener Promptpfad

Der repräsentative Legacybefehl

```text
15_ 16_15 15
```

adressiert wegen der historischen Grammatik zweimal Grundstrukturen-Familie 15, Schlüssel 15. Der native Plan bewahrt deshalb beide vollständigen Aliasbündel im Echo:

```text
--Grundstrukturen=<Bündel>,<Bündel>
```

Die erzeugten Tabellenspalten bleiben jedoch wie in Python einfach vorhanden. Die frühere Duplikatsperre in `prompt_table_execution.mojo` ist entfernt; der Befehl läuft vor jedem Python-Import vollständig im Mojo-Prozess.

## Tatsächliche Rendererursache

Die zuvor beobachtete Byteabweichung trat schon bei einem einzigen Aliasbündel auf. Betroffen war die Primzahlkreuz-Zelle:

```text
gegen 6 |  Darin kann sich die 15 am Besten hineinversetzen. | pro 5 |  Darin kann sich die 15 am Besten hineinversetzen.
```

Die alte Mojo-Hilfe ersetzte zwei Leerzeichen durch zwei sichtbare Schutzzeichen. Dadurch wurden sie fälschlich an das folgende Trennzeichen gebunden und der Umbruch erfolgte vor dem letzten `|`. Python `textwrap` behandelt einen Leerzeichenlauf dagegen als eigenen Whitespace-Chunk: Er zählt innerhalb einer Zeile mit, wird an einer Umbruchgrenze jedoch durch `drop_whitespace=True` entfernt.

`_shell_word_wrap_cell` besitzt nun eine eigene ASCII-/Unicode-sichere Chunkzerlegung. Sie

- erhält die genaue Breite interner Leerzeichenläufe,
- verwirft Whitespace-Chunks nur an visuellen Zeilengrenzen,
- behält die vorhandene Bindestrich- und Langwortlogik bei.

Damit bleiben das letzte `|` und die vorangehenden Inhalte auf der ersten Zeile; die Fortsetzungszeile beginnt ohne die zwei am Umbruch liegenden Leerzeichen. Die vollständige ANSI-Ausgabe ist bytegleich zur Python-Referenz.

## Besitz- und Paritätsnachweise

- 23/23 Prompt-Tabellenplanertests bestanden
- 8/8 Renderer-Unit-Tests bestanden
- einzelnes und doppeltes Aliasbündel erzeugen in Python dieselbe semantische Tabelle
- direkte Primzahlkreuz-Shellausgabe: 8.955 Byte bytegleich
- vollständige doppelte Promptausgabe: 9.523 Byte bytegleich
- isolierter doppelter Katalog-One-shot ohne Python-Datei und ohne `reta-native`-Kindprozess bestanden
- numerische Fixturematrix auf 12 vollständige Ausgaben erweitert
- numerischer One-shot-Katalog auf 16 Klassen erweitert
- 5/5 bestehende ANSI-Shell-Fixtures bleiben bytegleich
- vollständiger `scripts/test_stage10.sh`-Lauf mit Exitcode 0
- alle 9/9 regulären Mojo-Executables aus dem finalen Quellstand gebaut

## Weiter offene Besitzgrenze

- echte `v n/m`-Vielfache mit Zähler größer 1, für die die unveränderte Python-Referenz selbst `IndexError` auslöst,
- seltene hintere Promptzweige,
- verbleibende Rich- und kombinierte HTML-Metadatenfälle,
- vollständige i18n-Laufzeit außerhalb des Promptvokabulars.
