# Stage 12c5dv – Prompt execution mulpri render plan

This stage moves the complete pure output planning for the historical `mulpri`
/ `p` prompt branch from `src/prompt_main.mojo` into the prompt-execution
owner.

New native owner surface:

- `PromptExecutionMulpriRenderPlan`
- `plan_prompt_execution_mulpri_render(...)`

The controller now calls one pure plan and prints its returned lines. It no
longer knows how `mulpri` composes `prim`, `multis` and
`primfaktorenvergleich`, how integer arguments are selected, or how prime-number
fallback rows are localized.

No `.so`/`.dll` split is implemented in this stage. The change is a pure
ownership/transpilation step inside the existing native executable layout.
