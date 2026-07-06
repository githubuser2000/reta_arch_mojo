# Stage 12c5de – Fallback merged argument owner

Diese Stage schiebt die letzte spezielle `retaPrompt.py`-Fallback-Ausführung aus
dem externen Prozessadapter heraus. Der native Interaktions-Owner erzeugt jetzt
den vollständigen Kindprozess-argv-Vektor für einen atomaren Prompt-Fallback:

- `fallback_profile_arguments(profile)` liefert die historischen Profilflags.
- `shell_split(line)` tokenisiert die noch nicht nativ besessene Promptzeile.
- `reta_prompt_fallback_arguments_native(profile_flags, command_args)` baut den
  vollständigen `retaPrompt.py`-argv-Vektor.
- `prompt_main.mojo` startet diesen Vektor über den normalen
  `run_reta_prompt_arguments_native(...)`-Adapter.

Damit gibt es keinen separaten `run_reta_prompt_fallback_arguments_native(...)`-
Ausführungspfad mehr. Der Prozessadapter unterscheidet nicht mehr zwischen
normalem `retaPrompt.py`-argv und Fallback-argv; die Fallback-Semantik liegt im
Interaktionsplan.

Neuer Contract-Marker:

```text
fallback_process_arguments=native-merged-fallback-argv
```

Die Rohzeilen-Kompatibilität bleibt weiterhin nur an den historischen Fassaden,
während der Adapter ausschließlich payload-/argv-Ausführung besitzt.
