# Stage 12c5fa – Prompt execution one-shot result imports

This stage repairs and guards the native prompt controller import surface after the
one-shot result ownership split.

The previous source-only stage introduced and consumed
`plan_prompt_execution_one_shot_native_completion_result(...)`, but
`src/prompt_main.mojo` did not import that symbol from
`src/reta_mojo/prompt_execution.mojo`.  Python source guards still passed, but the
full native `prompt_main.mojo` build failed with an unknown declaration.

12c5fa makes the ownership boundary explicit at the import surface too:

- `prompt_execution.mojo` owns the one-shot result plans.
- `prompt_main.mojo` imports every `plan_prompt_execution_*` function that it
  consumes from that owner module.
- `tests/test_stage12c5fa_source.py` checks that every prompt-execution plan
  used by the controller and defined by the owner is present in the controller
  import block.

This is a correctness transpilations step: the typed owner already existed; the
native controller wiring is now also hermetic enough for the full Mojo build.
