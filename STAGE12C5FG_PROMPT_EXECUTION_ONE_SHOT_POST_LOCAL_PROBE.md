# Stage 12c5fg – prompt execution one-shot post-local probe owner

Diese Stage setzt auf `12c5ff` auf und zieht den nächsten Rücksprung aus
`_run_native_one_shot` in den Prompt-Execution-Owner.

## Änderung

Neu in `src/reta_mojo/prompt_execution.mojo`:

- `PromptExecutionOneShotPostLocalProbeResultPlan`
- `plan_prompt_execution_one_shot_post_local_probe_result(...)`

Der lokale One-Shot-Dispatch entscheidet weiterhin über Hilfe/Befehle,
Terminal-Clear, One-Shot-Logging und einfache Ausgaben. Danach gehört aber
der Gate-Rand nicht mehr dem Controller:

```mojo
if local_dispatch_result.stop_native_probe:
    return local_dispatch_result.handled
```

Stattdessen konsumiert der Controller einen geplanten Wert:

```mojo
var post_local_probe_result = plan_prompt_execution_one_shot_post_local_probe_result(
    local_dispatch_result
)
if not post_local_probe_result.should_probe_external:
    return post_local_probe_result.handled
```

Damit ist der Übergang `local dispatch -> external process probe` explizit
typisiert. Der externe Prozesspfad bleibt unverändert und wird nur betreten,
wenn der neue Plan `should_probe_external` setzt.

## Grund

`_run_native_one_shot` soll Schritt für Schritt zu einer klaren Pipeline werden:
Loop-Control, Native-Branch, Local-Dispatch, Post-Local-Gate, External-Probe
und Final-Probe. Diese Stage zieht den Post-Local-Gate als eigenen Owner heraus,
ohne die terminalen Seiteneffekte der lokalen Handler zu verschieben.

## Prüfziel

- lokale Handler stoppen weiterhin erfolgreich den One-Shot-Probe
- unhandled local dispatch läuft weiter zum External-Process-Owner
- der Controller interpretiert `local_dispatch_result.stop_native_probe` nicht
  mehr direkt
- Source-Guard schützt den neuen Owner und die neue Stage-Verkettung
