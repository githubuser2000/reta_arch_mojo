# Stage 12c5bt – positionsunabhängige Informations-Begleiteffekte

## Ausgangslage

Die historische Funktion `PromptGrosseAusgabe` wertet `kurzbefehle`,
`befehle` und `hilfe` nicht als ausschließlich alleinstehende Befehle aus.
Sie prüft die vollständige Promptwortmenge und gibt diese Informationen in
einer festen Reihenfolge aus, bevor anschließend der Zahlen-/Tabellenplan
läuft:

1. Kurzbefehle,
2. Befehle,
3. Hilfe,
4. Tabellenwirkung.

Der native Controller besaß die drei Einzelbefehle bereits, behandelte sie in
Kombination mit einer Tabelle aber als unbesessene Tokens und fiel atomar an
den Pythonpfad zurück.

## Native Umsetzung

`PromptHistoricalCompanionEffects` bildet die drei Effekte als typisierten
Bool-Vertrag ab. Die Erkennung verwendet den vollständigen lokalisierten
Promptkatalog und ist unabhängig von der Wortposition.

`prompt_main.mojo` gibt Informationswirkungen erst aus, nachdem der gesamte
Tabellen-/`mulpri`-Vektor als nativ besessen bewiesen wurde, aber noch vor dem
eigentlichen Tabellenplan. Dadurch bleibt die historische Wirkungsreihenfolge
erhalten, ohne bei einem teilweise unbesessenen Kommando sichtbare
Teilausgaben zu erzeugen.

Das terminalabhängige `leeren` bleibt für zusammengesetzte Kommandos weiterhin
am Kompatibilitätsrand. Im Python-Original steht es erst nach der
Zahlen-/Bruchvorbereitung und benötigt die reale Terminalzeilenzahl.

Ein zusätzlicher atomarer Ablehnungswächter steht nun vor dem Einzelbefehlsdispatch:
Erkennt der Planer zwar eine Tabelle oder `mulpri`, lehnt der vollständige
Eigentumsbeweis den Vektor aber ab, wird der interaktive Pfad sofort als Ganzes
an Python übergeben; der Einmalpfad meldet unbesessen. Dadurch können führendes
`leeren`, Logging oder Informationswörter nicht mehr als sichtbare Teilwirkung
vor dem Fallback ausgeführt werden.

## Zusätzlich geschlossene Testregressionen

Der vollständige Benutzerlauf von 12c5bs zeigte zwei veraltete Erwartungen im
großen Tabellenplanertest:

- Eine explizite Spaltenreihenfolge `0,1` ersetzt die interne Standardauswahl
  `3-6`; sie darf nicht zusätzlich serialisiert werden.
- Der komponentenlokale Plan `universum v1/4,-1/8` endet in der
  CPython-Integer-Setfolge
  `...,492,1004,496,1008,500,1012,504,508`.

Ein kleiner eigener Mojo-Test bindet beide Verträge, ohne erneut den gesamten
langlaufenden Tabellenplanertest auszuführen.

## Defekte

- `MOJO-FIXED-070`: Informations-Begleiteffekte fielen unnötig zurück.
- `TEST-FIXED-067`: Explizite Spaltenwahl wurde im Soll zusätzlich zur
  internen Standardwahl erwartet.
- `TEST-FIXED-068`: Lokale Reziprokachse band einen verkürzten veralteten
  Set-Teilstring.
- `MOJO-FIXED-071`: Abgewiesene zusammengesetzte Promptvektoren konnten einen
  führenden Einzelbefehls-Effekt teilweise ausführen.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bt.sh -- -j 8
```
