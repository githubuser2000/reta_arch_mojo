# Stage 12c5bd – Prägarben-Vererbung und reziproke Bruchkollision

## Gemeldeter Testfehler

`tests/test_presheaves_complete.mojo` erwartete bei einer auf `language=cn`
und `scope=csv` eingeschränkten Prägarbe fälschlich bereits in der ersten
Sektion einen Pfad `csv/cn-*`.

Die Python-Referenz und der native Topologiebesitzer verwenden jedoch dieselbe
Meet-/Verfeinerungssemantik: Eine sprachneutrale Sektion ist für eine
sprachspezifische Anfrage weiterhin gültig und erhält im verfeinerten Kontext
die angefragte Sprache. Die sortierte CSV-Discovery beginnt mit einer neutralen
Datei, weshalb die alte Positionsannahme falsch war.

Der neue exakte Vertrag lautet:

- 16 explizite `cn-*`-CSV-Sektionen,
- 16 sprachneutrale CSV-Sektionen,
- insgesamt 32 eingeschränkte Sektionen,
- jede Ergebnis-Sektion besitzt nach der Verfeinerung `cn` im Kontext,
- Nutzlast und `.csv`-Quelle bleiben unverändert erhalten.

## Weiterer nativer Prompt-Port

Der korrigierte Mojo-Pfad besitzt nun auch:

```text
universum v1/4,-1/8,2/3
```

Die eingefrorene Python-Referenz stürzt weiterhin in
`prompt_execution.py:1841` mit `IndexError` ab. Mojo trennt stattdessen:

1. positive Reziprokvielfache `1/4` unterhalb 1024,
2. ausgeschlossene Reziprokvielfache `-1/8`,
3. die echte Bruchvielfachenachse `2/3` innerhalb des realen
   Universum-CSV-Rechtecks.

Die Reziprokachse enthält damit die Vielfachen von vier, aber keine Vielfachen
von acht, vereinigt mit den stabilen Reziprokprojektionen der `2/3`-Achse. Die
echte Bruchachse behält zehn Zählergruppen `2,4,...,20`; insgesamt entstehen
13 native Tabellenaufrufe. Andere unbewiesene Sign-/Reihenfolgen und mehrere
verschiedene Bruch-CSV-Domänen bleiben atomarer Fallback.

## Lokaler Lauf

```bash
scripts/build-all.sh -- -j 8
scripts/test_stage12c5bd.sh
```

Die Kompilierung wird weiterhin ausschließlich lokal durch den Benutzer
ausgeführt.

## Portable Prüfung

- vollständige Source-Suite: 284 bestanden, 1 übersprungen,
- fokussierte Defekt-/Metrik-/Ownership-Gruppe: 57 bestanden,
- Manifest-/Defektprüfung: 15 bestanden,
- Quellarchiv-Roundtrip: 3 bestanden.

