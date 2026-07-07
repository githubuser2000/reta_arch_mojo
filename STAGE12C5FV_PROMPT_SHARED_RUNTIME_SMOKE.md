# Stage 12c5fv – Prompt-Shared-Runtime-Smoke

Diese Stage ergänzt die offizielle Prompt-Shared-Library-Struktur aus 12c5fu
um einen aktiven Runtime-Smoke für die dünnen Prompt-Starter.

## Vertrag

- `rpb` bleibt ein One-shot-Starter.
- `rpb` lädt `libreta-prompt.so`.
- `rpb` lädt nicht `libreta-prompt-interactive.so`.
- `rp`, `rpl` und `rpe` laden zuerst die gemeinsame Prompt-Bibliothek und dann
  die interaktive Prompt-Bibliothek.
- Alle Prompt-Starter und beide Prompt-Bibliotheken müssen dieselbe
  `.reta-source-id` tragen.

## Neue Runtime-Prüfung

`scripts/test_prompt_shared_runtime.sh` prüft nach einem Build:

1. alle vier dünnen Prompt-Starter existieren,
2. `libreta-prompt.so` und `libreta-prompt-interactive.so` existieren,
3. die Source-ID-Sidecars zusammenpassen,
4. `rpb prim 60` auch mit absichtlich kaputter
   `RETA_PROMPT_INTERACTIVE_LIBRARY` funktioniert,
5. `rpb prim 60` mit absichtlich kaputter `RETA_PROMPT_LIBRARY` scheitert,
6. `rp` mindestens ein kurzes interaktives stdin-Kommando ausführt.

## Loader-Anpassung

`tools/reta_prompt_loader.c` lädt für interaktive Profile nun die gemeinsame
`libreta-prompt.so` mit `RTLD_GLOBAL`, bevor die interaktive Bibliothek geladen
wird.  Dadurch wird der gewünschte Prozessvertrag sichtbar:

```text
rpb       -> libreta-prompt.so
rp/rpl/rpe -> libreta-prompt.so + libreta-prompt-interactive.so
```

Die Stage bleibt source-seitig ausführbar, auch wenn die Shared Libraries noch
nicht gebaut wurden.  In diesem Fall meldet `scripts/test_stage12c5fv.sh` den
übersprungenen Runtime-Smoke und verweist auf `scripts/build-all.sh` oder
`scripts/build_prompt_shared.sh`.
