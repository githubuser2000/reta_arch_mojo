# Stage 12c5bx – Native Besitzgrenze für gespeicherte Ausgabezusätze

## Ausgangslage

Stage 12c5bw besitzt die positionsunabhängige Inline-Speicherung und ihre
Verlaufspolitik. Der nächste Rand liegt direkt daneben: `o` beziehungsweise
`BefehlSpeicherungAusgeben` kann im Python-Controller nicht nur alleinstehen,
sondern zusammen mit weiteren Promptwörtern auftreten. Dieser Zusatzpfad wird
historisch über Mengenmitgliedschaft erkannt, ist aber im Python-Original defekt:
`text_state.liste` wird als Liste an `pending_output` übergeben und später mit
einem String konkateniert. Der reproduzierbare Fehler ist ein `TypeError`.

## Native Korrektur

`prompt_interaction.mojo` besitzt jetzt auch diesen gespeicherten
Ausgabezusatz als typisierten Plan:

1. Die physische Zeile wird mit dem balancierten Promptparser zerlegt.
2. Ein lokalisierter Ausgabealias (`o`, `BefehlSpeicherungAusgeben`,
   `CommandSaveOutput`, …) wird an jeder Wortposition erkannt.
3. Der historische Trigger bleibt eng: alleinstehendes `o` wird akzeptiert;
   gemischte Ausgabezusätze benötigen mehr als ein distinktes Nicht-`o`-Token.
4. Der native Plan trägt den Zusatz als `String` statt als heterogene Liste.
5. Genau ein ausgewählter Ausgabealias wird aus dem Zusatz entfernt.
6. Bereits konsumierte Ausgabezusätze aktualisieren den vorherigen Befehl nicht.

`prompt_main.mojo` fragt diesen Plan vor dem gewöhnlichen Einzelbefehlsdispatch
ab. Wenn kein Befehl gespeichert ist, bleibt die beobachtbare Meldung
`Kein Befehl gespeichert.`. Gibt es gespeicherten Text, wird dieser mit dem
getypten Zusatz kombiniert und erneut durch den nativen Promptdispatcher geführt.

## Python-Defekt

- `PY-OPEN-007`: Der historische Python-Zweig für gespeicherte Ausgabe mit
  Zusatz übergibt eine Tokenliste an eine Stringkonkatenation und stürzt mit
  `TypeError` ab. Mojo übernimmt den sinnvollen Vertragskern, aber nicht den
  Absturz.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bx.sh -- -j 8
```
