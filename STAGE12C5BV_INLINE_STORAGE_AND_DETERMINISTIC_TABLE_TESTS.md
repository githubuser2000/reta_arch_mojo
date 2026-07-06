# Stage 12c5bv – positionsunabhängige Speicherung und deterministische Tabellentests

## Native Erweiterung

Ein einzelner lokalisierter `S`-/`s`-Speicherbefehl darf zusammen mit mindestens
einem weiteren Token an jeder Wortposition stehen. Der übrige Prompt wird
gespeichert und nicht ausgeführt. Die historische Mengenregel bleibt erhalten:
mehrere verschiedene Speicheraliase, reine Speicherwortfolgen und `abc`/`abcd`
bleiben am atomaren Kompatibilitätsrand. Doppelte identische Aliase entfernen
wie Python nur das erste Vorkommen.

## Laufzeit- und Testkorrekturen

- Die englische Compound-Clear-Probe startet `retaPrompt.english` korrekt mit
  `-befehl`.
- Der Tabellenadaptertest bindet die Python-Referenz: `1` ist Sonne, `4` ist
  Mondzahl.
- Terminalbreitenabhängige Shell-Renderer-Verträge verwenden einen optionalen
  Test-Override von 80 Spalten. Der Produktionspfad ohne Override fragt weiter
  die echte Terminalgeometrie ab.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bv.sh -- -j 8
```
