# Stage 12c5dr: Prompt execution table ownership owner

This stage moves the duplicated table/mulpri ownership algebra for
`PromptVonGrosserAusgabeSonderBefehlAusgaben` out of the prompt controller and
into the native prompt-execution owner.

`src/reta_mojo/prompt_execution.mojo` now owns
`PromptExecutionTableOwnershipPlan` and
`plan_prompt_execution_table_ownership(...)`.  The plan combines the prepared
prompt routing state with `plan_prompt_table_commands(...)`, the localized
`mulpri`/`p` aliases, integer argument discovery and the historical atomic
fallback guard.

The interactive prompt loop and the `-befehl` one-shot path now both consume the
same ownership plan.  `src/prompt_main.mojo` no longer duplicates:

- integer argument discovery for `mulpri`;
- localized `mulpri` alias detection;
- table candidate versus native ownership checks;
- historical compact/numeric support gating;
- the compound-command rule that prevents executing one native branch while a
  sibling branch still belongs to the compatibility boundary.

No `.so`/`.dll` split is implemented here.  This is still an internal ownership
cleanup: it reduces controller logic and makes the remaining prompt execution
boundary smaller and more auditable before the later shared-library separation.
