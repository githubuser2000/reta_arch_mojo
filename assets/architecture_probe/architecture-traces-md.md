# Reta Stage-32 Architektur-Traces

## Trace-Baum

```text
ArchitectureTraceBundle
├─ legacy owner traces
│  └─ reta.py / retaPrompt.py / libs / i18n / csv / reta_architecture
├─ capsule traces
│  └─ capsule → category → functor/transformation → diagram → witness → law
└─ stage history traces
   └─ Stage 1 … Stage 32
```

## Mermaid

```mermaid
flowchart TD
    Legacy[alte reta-Komponente] --> Capsule[Architektur-Kapsel]
    Capsule --> Category[math Kategorie]
    Category --> Functor[Functor]
    Functor --> NT[natürliche Transformation]
    NT --> Diagram[kommutierendes Diagramm]
    Diagram --> Witness[Witness / Probe / Test]
    Witness --> Law[Refactor-Gesetz]
```
