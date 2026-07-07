# Stage 12c5fj – Prompt execution one-shot probe pipeline gate owner

## Ziel

`_run_native_one_shot` hatte nach den letzten Stages mehrere sauber typisierte
Einzel-Gates (`pre_native`, `post_native`, `post_local`, `final`), musste aber
weiterhin jedes Gate mit einem eigenen Controller-Feld auswerten. Diese Stage
führt einen gemeinsamen Pipeline-Gate-Owner ein, der die Übergänge vereinheitlicht.

## Neuer Owner

In `src/reta_mojo/prompt_execution.mojo`:

- `PromptExecutionOneShotProbePipelineGatePlan`
- `plan_prompt_execution_one_shot_pipeline_pre_native_gate(...)`
- `plan_prompt_execution_one_shot_pipeline_post_native_gate(...)`
- `plan_prompt_execution_one_shot_pipeline_post_local_gate(...)`
- `plan_prompt_execution_one_shot_pipeline_final_gate(...)`

Der gemeinsame Plan hält:

- `handled`
- `stop_native_probe`
- `continue_pipeline`
- `result_owner`
- `next_phase`
- `source`

## Controller-Änderung

`src/prompt_main.mojo` konsumiert nach jeder bereits isolierten Phase nun ein
Pipeline-Gate statt direkt phasenspezifische Felder wie `should_probe_native`,
`should_probe_local` oder `should_probe_external` auszuwerten.

Damit bleiben die Terminal- und Prozess-Seiteneffekte im Controller, aber die
reine Return-/Weiterlauf-Algebra wandert weiter nach `prompt_execution.mojo`.

## Tests

- `tests/test_prompt_execution.mojo` prüft die gemeinsame Gate-Normalisierung.
- `tests/test_stage12c5fj_source.py` schützt die neue Controller-Form.
- Ältere Source-Guards wurden so erweitert, dass sie den neuen Pipeline-Gate-
  Owner als spätere, strengere Form akzeptieren.
