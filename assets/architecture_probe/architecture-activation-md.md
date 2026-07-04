# Reta Stage-36 Architektur-Aktivierung

## Aktivierungs-/Commit-/Rollback-Baum

```text
ArchitectureActivationBundle
├─ ActivationWindowSpec
│  └─ rehearsal open sets as controlled activation windows
├─ ActivationUnitSpec
│  └─ rehearsal moves as not-yet-executed commit envelopes
├─ ActivationGateSpec
│  └─ preflight / commit / postflight / rollback command sections
├─ ActivationRollbackSpec
│  └─ rollback anchors protecting diagrams and laws
├─ ActivationTransactionSpec
│  └─ universal gluing of local activation units into wave transactions
└─ ActivationValidationSpec
   └─ rehearsal coverage, gate coverage, rollback coverage, transaction coverage and naturality references
```

## Mermaid

flowchart TD
    Rehearsal[ArchitectureRehearsalBundle] -->|RehearsalActivationFunctor| Unit[ActivationUnitSpec]
    Rehearsal -->|GateActivationFunctor| Gate[ActivationGateSpec]
    Unit -->|ActivationTransactionFunctor| Tx[ActivationTransactionSpec]
    Gate --> Tx
    Gate -->|ActivationRollbackFunctor| Rollback[ActivationRollbackSpec]
    Tx -->|ActivationValidationFunctor| Validation[ArchitectureValidationBundle]
