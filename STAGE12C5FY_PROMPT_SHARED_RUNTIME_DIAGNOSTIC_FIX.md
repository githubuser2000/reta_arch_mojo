# Stage 12c5fy – Prompt-Shared-Runtime-Diagnosefix

Diese Stage repariert den harten `build-all`-Gate aus 12c5fw/12c5fx.
Der Prompt-Shared-Runtime-Smoke prüfte absichtlich:

```sh
RETA_PROMPT_LIBRARY=/definitely/missing target/bin/rpb prim 60
```

Der Test erwartete nur die spätere `dlopen`-Diagnose
`Prompt-Bibliothek konnte nicht geladen werden`.  Der dünne Loader prüft aber
vor `dlopen` bereits die `.reta-source-id`-Stempel.  Diese Stempelprüfung ist
absichtlich vorgezogen, damit alte Starter nicht mit neuen Bibliotheken laufen.  Bei einem fehlenden
Override-Pfad ist deshalb auch diese Diagnose korrekt:

```text
Prompt-Starter und Shared Library stammen nicht aus demselben Quellstand.
```

12c5fy akzeptiert beide Diagnosen als gültigen Fehlschlag für eine fehlende
`libreta-prompt.so`.  Dadurch bleibt der Sicherheitszweck erhalten:

- `rpb` muss ohne `libreta-prompt-interactive.so` laufen.
- `rpb` muss mit kaputter `libreta-prompt.so` scheitern.
- `rp/rpl/rpe` bleiben interaktive Starter über `libreta-prompt-interactive.so`.

Zusätzlich druckt der Smoke bei abweichender `rpb prim 60`- oder `rp prim 29`-
Ausgabe jetzt den tatsächlichen Inhalt.  Dadurch gibt es keinen stillen
`Exitstatus 1` mehr direkt nach `Buildlayout und Build-Frische korrekt`.
