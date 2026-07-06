# Stage 12c5bw – Verlaufseigentum der Inline-Speicherung

## Ausgangslage

Stage 12c5bv erkennt einen einzelnen lokalisierten `S`-/`s`-Alias an jeder
Wortposition und speichert den übrigen Prompt nativ. Die anschließende
Verlaufspflege klassifizierte dieselbe physische Zeile jedoch erneut nur über
das erste Wort. Bei `emotion S 1` oder `emotion 1 s` entstand deshalb
`KIND_FALLBACK`, und die bereits konsumierte Speicherzeile ersetzte
fälschlicherweise den vorherigen Befehl. Ein späteres alleinstehendes `s` konnte
damit den Speicherbefehl selbst statt des letzten ausführbaren Kommandos
übernehmen.

## Native Korrektur

`prompt_interaction.mojo` besitzt nun auch die vollständige Zeilenentscheidung
für den Verlauf:

1. Die physische Zeile wird mit dem balancierten Promptparser zerlegt.
2. Der reine positionsunabhängige Speicherplan wird erneut ohne Seiteneffekt
   geprüft.
3. Eine bereits als Inline-Speicherung konsumierte Zeile aktualisiert den
   vorherigen Befehl nicht.
4. Alle übrigen Befehle behalten die bestehende kindbasierte Verlaufspolitik.

`prompt_main.mojo` ruft nur noch `record_prompt_line(...)` auf. Damit liegen
Speicherung und Verlauf wieder beim typisierten Interaktionsbesitzer, während
der Prozesseinstieg keine zweite, widersprüchliche Zustandsentscheidung trifft.

## Referenzvertrag

Die Python-Schleife kehrt nach einem erfolgreichen `_storage_command` mit
`continue` vor `_execute` zurück. Vier Präfix-/Mittel-/Suffix-/Langaliasfälle
frieren ein, dass die Speicherzeile konsumiert wird, den Nutztext `emotion 1`
speichert und nicht zum vorherigen ausführbaren Befehl wird.

## Defekt

- `MOJO-FIXED-073`: positionsfreie Inline-Speicherung konnte bei nichtführendem
  Alias den vorherigen Befehl überschreiben.
- `TEST-FIXED-070`: Der Source-Archivvertrag prüft in Git-Arbeitsbäumen den
  Index und in absichtlich `.git`-freien Archiven die ausgelieferten Datei- und
  Symlinkmanifeste.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bw.sh -- -j 8
```
