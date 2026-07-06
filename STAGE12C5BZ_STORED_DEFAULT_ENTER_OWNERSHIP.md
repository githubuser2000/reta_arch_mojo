# Stage 12c5bz – Gespeicherten Prompt per leerem Enter nativ ausführen

## Ausgangslage

Der fokussierte 12c5by-Build bestätigt, dass die Legacy-Prompt-Fassade dem
nativen Interaktions-Snapshot folgt. Der ältere breite Fehler mit einer festen
`9` war damit ein stale- oder Alt-Binary-Befund, nicht der aktuelle Stand.

Als nächster Prompt-Rand blieb die dokumentierte Bedienung offen: Ein
vorhandener gespeicherter Befehl soll auch durch eine leere Eingabe, also durch
bloßes Enter, ausgeführt werden. Im historischen Python-Prompt kommt das über
den Placeholder des Line-Editors zustande. Im nativen Controller war eine leere
physische Zeile bisher nur `KIND_EMPTY` und damit ein No-op.

## Native Korrektur

- Neuer typisierter Plan `PromptStoredDefaultPlan` in
  `src/reta_mojo/prompt_interaction.mojo`.
- Neue Funktion `plan_stored_default_command(...)`:
  - nichtleere Eingaben bleiben unverändert,
  - leere Eingaben ohne Speicher bleiben unverändert,
  - leere Eingaben mit Speicher liefern die gespeicherte Befehlszeile als
    `INTERACTION_EXECUTE`.
- `accept_prompt_input(...)` plant diesen Fall nach Store-/Delete-Modus und vor
  der normalen Ausführung.
- Der Snapshot enthält jetzt
  `stored_default=native-empty-enter-placeholder-policy`.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bz.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
