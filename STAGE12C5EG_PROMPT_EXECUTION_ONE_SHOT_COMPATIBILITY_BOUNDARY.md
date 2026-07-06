# Stage 12c5eg – Prompt execution one-shot compatibility boundary owner

## Ziel

`-befehl` führt den Python-Kompatibilitätspfad nicht direkt aus. Der native
Probeweg muss nur sauber entscheiden, ob er an dieser Grenze stoppt und den
Aufrufer die historische Python-Grenze betreten lässt. Diese Stop-/Weiter-
Entscheidung lag bisher noch als direkte `if fallback.should_run: return False`-
Logik im Controller.

## Änderung

Neu im Prompt-Execution-Owner:

```mojo
def plan_prompt_execution_one_shot_compatibility_boundary(
    fallback: PromptExecutionCompatibilityFallbackPlan,
    handled_when_no_fallback: Bool,
) -> PromptExecutionOneShotCompatibilityBoundaryPlan
```

Der Plan trägt:

- `stop_native_probe`: die native `-befehl`-Probe muss verlassen werden.
- `handled_without_fallback`: Rückgabewert, falls kein Kompatibilitätsstopp
  nötig ist.
- `source`: unberührte Quellzeile für die Boundary-Dokumentation.

## Wirkung

`prompt_main.mojo` interpretiert den generischen `PromptExecutionCompatibilityFallbackPlan`
in `_run_native_one_shot` nicht mehr selbst. Sowohl der abgewiesene Tabellen-/
mulpri-Branch als auch der finale One-shot-Residual-Fallback laufen durch den
gemeinsamen One-shot-Kompatibilitätsplan.

Der Controller bleibt I/O- und Prozessbesitzer. Die Entscheidung, wie die
native Probe an der Kompatibilitätsgrenze antwortet, gehört jetzt dem
Prompt-Execution-Owner.

## Lokale Prüfung

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5eg.sh -- -j 4
scripts/run-tests.sh
scripts/build-all.sh -- -j 6
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
