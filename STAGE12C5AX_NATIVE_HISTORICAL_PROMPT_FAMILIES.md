# Stage 12c5ax – native historische Prompt-Tabellenfamilien

Stage 12c5ax verkleinert die atomare Python-Kompatibilitätsgrenze im großen
`PromptGrosseAusgabe`-Pfad. Die eigentlichen Tabellenpläne waren bereits nativ,
aber ein zweiter, konservativer Allowlist-Test ließ neun Familien bei
Ein-Zeichen- oder kompakten Verbundbefehlen weiterhin vollständig an
`retaPrompt.py` fallen.

## Geschlossene Lücke

Betroffen waren die bereits durch `prompt_table_execution.mojo` besessenen
Familien:

- `mond`,
- `primzahlkreuz`,
- `alles`,
- `freiheit` und `gleichheit`,
- `kugeln` und `kreise`,
- `netzwerk`,
- `komplex`.

Ein Langbefehl wie `mond 2` lief schon nativ. Dagegen aktivierte beispielsweise
`r mond 2` die historische Ein-Zeichen-Präsentation und wurde trotz vollständig
typisiertem Plan atomar an Python weitergereicht. Diese Inkonsistenz ist
entfernt.

## Reiner Besitzentscheid

Die Entscheidung liegt nicht mehr als 190-Zeilen-Block in
`src/prompt_main.mojo`, sondern in:

```text
src/reta_mojo/prompt_historical_ownership.mojo
```

Der neue Besitzer enthält:

- den exakten historischen Zahlen-/Bereichs-Syntaxtest,
- den 33 Einträge umfassenden kanonischen Tabellenfamilienkatalog, der auch
  direkt vom Tabellenplaner importiert wird,
- lokalisierte Kommandoauflösung,
- die erlaubten historischen Kontrollwörter,
- die erlaubten Ausgabeparameter,
- die atomare Gesamtentscheidung für einen expandierten Verbundbefehl.

Der Tabellenplaner besitzt keine zweite 33er-Liste mehr; klassische Ganzzahl-
und Bruchfamilien werden aus demselben Katalog abgeleitet. Das Modul besitzt
keinerlei Terminal-, Datei-, Umgebungs-, Python- oder Kindprozesseffekte. Ein Verbund wird weiterhin nur dann nativ ausgeführt, wenn
**jedes** nichtnumerische Token nachweislich einem nativen Tabellen-, Kontroll-
oder Ausgabeparameterbesitzer gehört. Shell-, Speicher- und unbekannte
Parameterzweige bleiben vollständig am atomaren Fallback; Teil-Ausführung ist
weiterhin ausgeschlossen.

## Prüfvertrag

`tests/test_prompt_historical_ownership.mojo` prüft:

1. den exakten 33-Familien-Katalog,
2. die neun zuvor ausgesparten Familien,
3. einen realen typisierten Tabellenplan für jede dieser Familien,
4. englische Alias- und Ausgabeparameterauflösung,
5. atomare Ablehnung von Shell-, Speicher- und unbekannten Zweigen,
6. die historische Zahlen-/Bruch-/Bereichssyntax.

`scripts/check_prompt_historical_families_parity.sh` vergleicht acht kompakte
End-to-End-Ströme bytegenau mit `python_reference/rpb`. Der native Prozess läuft
in einem isolierten Arbeitsverzeichnis, das nur `assets/` und
`python_reference/csv/` enthält. Ein versehentlicher Python-Fallback findet dort
kein `retaPrompt.py`, erzeugt stderr beziehungsweise einen leeren Strom und
lässt den Test sicher scheitern.

`alles` wird im schnellen Stage-Gate bis zum vollständigen nativen Plan geprüft,
aber nicht jedes Mal durch den sehr teuren Python-Allspalten-Generator geschickt.
Die vollständige `--alles`-Referenz bleibt ausdrücklich Teil des vorhandenen
Full-All-/Release-Workflows und darf nach Benutzerfreigabe ausgeführt werden.

## Benutzerlauf

Alle Mojo- und Produktionskompilierungen bleiben beim Benutzer:

```bash
scripts/build-all.sh -- --optimization-level 2 -j 8
scripts/test_stage12c5ax.sh
```

Vor Releases oder nach mehreren Stages:

```bash
scripts/test_all.sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

Der Erstellungsassistent führt keine Mojo-/Native-Kompilierung aus.
