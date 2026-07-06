# Stage 12c5cw – current-stage guard normalization

This stage removes stale source-test coupling between historical ownership
stages and the moving `scripts/test_current_stage.sh` entrypoint.

The historical `12c5a*`/`12c5b*` source guards still verify their own stage
chain, documents and native ownership assertions.  They no longer require the
current-stage wrapper to point at the stage that was current when the guard was
first written.

Why this matters:

- `test_current_stage.sh` is intentionally mutable and must point at the newest
  stage.
- Old guards such as `test_py_reta_truth_native_source.py` still expected
  `test_stage12c5bk.sh`, causing focused legacy source runs to fail after the
  prompt ownership stages moved the current entrypoint forward.
- The actual porting invariant is the historical chain, not a frozen current
  pointer.

The normalization also refreshes the old `12c5bx` storage-output source guard to
match the later interaction-owner split: the controller now delegates through
`plan_inline_stored_output_command`, while `plan_inline_storage_output_command`
remains private to the interaction owner.
