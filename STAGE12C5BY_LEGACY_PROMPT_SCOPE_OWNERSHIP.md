# Stage 12c5by – Legacy-Prompt-Scope folgt dem Interaktionsbesitzer

## Ausgangslage

Der lokale 12c5bx-Build bestätigte den neuen Besitz für gespeicherte Ausgabe:
`test_prompt_interaction.mojo` bestand mit 13/13 Tests und die fokussierten
Source-Verträge bestanden mit 61/61. Der breite Benutzerlauf fand danach eine
alte Assertion in `test_legacy_reta_prompt.mojo`: `PromptScope(facade)` lieferte
mehr native Interaktionszeilen als der Legacy-Test erwartete.

Das ist kein Rückfall in der Promptlaufzeit. Die Legacy-Fassade delegiert
`PromptScope(...)` bereits an `prompt_interaction_contract_snapshot()`. Der Test
hatte aber noch die alte Anzahl fest verdrahtet und brach deshalb ab, sobald der
Interaktionsbesitzer einen weiteren nativen Rand dokumentierte.

## Native Korrektur

- `test_legacy_reta_prompt.mojo` vergleicht den Legacy-Scope nicht mehr gegen
  eine historische Zahl, sondern gegen den aktuellen Snapshot des nativen
  Interaktionsbesitzers.
- Der Vertrag prüft weiter die relevanten Stabilitätsanker:
  `class=PromptInteractionBundle`, die neue gespeicherte-Ausgabe-Zeile und den
  delegierten Ausführungsrand.
- `scripts/test_stage12c5by.sh` baut gezielt die Legacy-Fassade und den
  Interaktionsbesitzer zusammen, damit zukünftige Snapshot-Erweiterungen nicht
  wieder nur im breiten Gesamtlauf sichtbar werden.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5by.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
