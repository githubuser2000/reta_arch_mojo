# Reta Stage-33 Architektur-Impact

## Impact-Baum

```text
ArchitectureImpactBundle
├─ ImpactSourceSpec
│  └─ old/new reta owner → capsule → category/functor/natural transformation
├─ ImpactContractSpec
│  └─ source → affected diagrams/laws/transformations → required probes
├─ RegressionGateSpec
│  └─ category/map/contract/witness/coherence/trace/boundary/impact/parity gates
├─ MigrationCandidateSpec
│  └─ future extraction candidates are guarded, not silently moved
└─ ImpactValidationSpec
   └─ Stage-33 coverage over sources, contracts, gates, capsules and naturality
```

## Mermaid

```mermaid
flowchart TD
    Trace[ArchitectureTraceBundle<br/>old owner routes] --> Impact[ArchitectureImpactBundle]
    Boundary[ArchitectureBoundariesBundle<br/>module/import edges] --> Impact
    Contracts[ArchitectureContractsBundle<br/>diagrams + laws] --> Impact
    Witness[ArchitectureWitnessBundle<br/>probes + obligations] --> Impact
    Impact --> Sources[Impact sources]
    Impact --> Affected[Affected contracts]
    Impact --> Gates[Regression gates]
    Impact --> Candidates[Migration candidates]
    Gates --> Future[Future stage<br/>move only when gates pass]
```
