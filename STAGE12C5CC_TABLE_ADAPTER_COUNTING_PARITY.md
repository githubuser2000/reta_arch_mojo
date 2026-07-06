# Stage 12c5cc — table adapter counting parity boundary

This stage fixes the broad-suite regression reported after Stage 12c5cb in
`test_table_adapters.mojo`:

```text
FAIL test_prepare_row_helpers_delegate_to_native_owners
left: 1
right: 0
```

The failing expectation was not a native runtime defect.  The Python reference
`set_zaehlungen` assigns rows 1-4 to the first counting group and row 5 to the
second counting group.  The previous Mojo adapter test accidentally expected the
row-zero sentinel group for `zeileWhichZaehlung(state, 1)`.

## Native contract

`table_adapters.mojo` already delegates `zeileWhichZaehlung` to the native
`counting_groups` owner.  The adapter contract now freezes the actual reference
parity instead of the stale sentinel expectation:

- row 1 -> group 1
- row 4 -> group 1
- row 5 -> group 2

The source test imports the Python reference owner and checks the same values so
future adapter changes cannot silently reintroduce the stale `right: 0` contract.

## Stage command

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cc.sh -- -j 8
```

The stage rebuilds `test_table_adapters.mojo` explicitly before the broad
`run-tests.sh` path is used again.
