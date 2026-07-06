# Stage 12c5db - fallback process handled flag

Diese Stage macht den bereits in 12c5cy eingeführten nativen Fallback-Prozessplan vollständiger: `PromptFallbackProcessDispatchPlan` besitzt nun wie die anderen Dispatch-Pläne ein explizites `handled`-Flag.

Vorher lieferte der Fallback-Plan nur Profil-argv und Kommando-argv. Der Prozess-Controller musste implizit wissen, dass jeder erzeugte Plan ausführbar ist. Jetzt ist die Effektkante selbst Teil des Plans:

```text
handled
profile_arguments
command_arguments
```

`prompt_main.mojo` prüft dieses Flag vor dem Aufruf des expliziten `retaPrompt.py`-Kindprozesses. Damit gleicht die Fallback-Kante den übrigen nativen Prompt-Dispatch-Plänen an: Der Interaktions-Owner beschreibt nicht nur die Daten, sondern auch, ob der Effekt auszuführen ist.

Die Runtime-Grenze bleibt absichtlich unverändert: unbewiesene historische Sonderfälle laufen weiterhin atomar über den expliziten Referenzkindprozess. Entfernt wurde nur die implizite Annahme im Controller.

Neuer Snapshotmarker:

```text
fallback_process_handled=native-explicit-fallback-effect-flag
```
