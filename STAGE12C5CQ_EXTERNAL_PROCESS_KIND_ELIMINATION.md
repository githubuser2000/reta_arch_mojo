# Stage 12c5cq – external process kind elimination

Der externe Prompt-Prozessplan hatte nach Stage 12c5cn/cp zwei parallele Darstellungen derselben Entscheidung: ein numerisches `process_kind`-Enum und die ausführbaren Effektflags `run_shell`, `run_python`, `run_math`, `run_reta`. Diese Stage entfernt das redundante Enum aus dem Plan.

## Änderung

- `PromptExternalProcessDispatchPlan` besitzt kein `process_kind: Int` mehr.
- Die `EXTERNAL_PROMPT_*`-Konstanten sind aus `prompt_interaction.mojo` entfernt.
- Shell, Python, Math und Reta werden ausschließlich über die geplanten Effektflags und die typisierten Nutzlasten `payload`/`arguments` ausgeführt.
- Der Snapshot enthält `external_process_kind=eliminated-from-external-process-plan`.

## Zweck

Die Prozesskante ist damit nicht nur von Rohzeilen befreit, sondern auch von einer zweiten, ungenutzten Routingkodierung. Der Controller sieht weiterhin nur die Effektflags; der Plan selbst trägt keine alte Enum-Klassifikation mehr mit.

## Prüfung

Ohne Mojo-Kompilation prüfbar mit:

```sh
scripts/run_pytest.sh -q tests/test_stage12c5cq_source.py tests/test_stage12c5cp_source.py tests/test_prompt_interaction_source.py
```

Vollständige Stage-Prüfung lokal:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cq.sh -- -j 4
```
