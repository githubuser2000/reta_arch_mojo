# Stage 12c5dc: fallback profile argument expectation

Stage 12c5dc fixes the Mojo test expectation introduced with the fallback
process argv plan.

`parse_prompt_startup("rpe", [])` produces the historical rpe profile:

- `vi_mode=True`, so fallback argv begins with `-vi`.
- `force_e_command=True`, so fallback argv includes `-e`.
- fallback execution always appends `-befehl`.

The native plan was already correct.  The test incorrectly expected only two
profile arguments and skipped the `-vi` flag, which caused
`test_fallback_process_dispatch_is_planned_by_interaction_owner` to fail at
runtime.  The corrected test now asserts the exact historical fallback profile
argv:

```text
-vi -e -befehl
```

No process boundary is widened.  The fallback command itself remains owned by
`PromptFallbackProcessDispatchPlan`, and the external process adapter still
receives only profile argv plus command argv.
