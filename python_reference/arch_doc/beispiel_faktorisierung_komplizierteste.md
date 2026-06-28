# Komplizierteste Faktorisierung einer universellen Eigenschaft aus `reta_arch`

Die komplizierteste sinnvolle Faktorisierung in deinem Quelltext ist nicht nur:

```text
lokale Daten → globale Semantik → Tabelle
```

sondern die größere Kette:

```text
lokale Sektionen
        ↓
Prägarbe
        ↓
Garbe / globale Semantik
        ↓
Tabellenerzeugung
        ↓
parallele Ausführung
        ↓
deterministische Reduktion
        ↓
normalisierte Ausgabe
```

Das kombiniert mehrere deiner Architekturkonzepte:

```text
Presheaf
Sheaf
Gluing
Functor
ExecutionNetwork
NaturalTransformation
Normalization
```

Die universelle Idee:

```text
Jeder direkte Weg von lokalen reta-Daten zur fertigen Ausgabe
soll eindeutig über diese kanonische Architektur faktorisieren.
```

Also:

```text
DirectRetaAlgorithm
=
NormalizeOutput
∘ RenderTable
∘ DeterministicReduce
∘ ExecuteChunks
∘ TableGeneration
∘ GlueSemantics
```

---

# Python-Beispiel

```python
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, Iterable, List, Tuple


# ============================================================
# 1. Lokale Sektionen / Prägarbe
# ============================================================

@dataclass(frozen=True)
class LocalSection:
    scope: str
    name: str
    data: Dict[str, Any]


@dataclass
class RetaPresheaf:
    """
    Prägarbe:
    sammelt lokale Daten aus CLI, CSV, Defaults, Generatoren.
    """

    sections: Dict[str, LocalSection] = field(default_factory=dict)

    def add_section(self, section: LocalSection) -> None:
        key = f"{section.scope}:{section.name}"
        self.sections[key] = section

    def restrict(self, scope: str) -> Dict[str, LocalSection]:
        return {
            key: section
            for key, section in self.sections.items()
            if section.scope == scope
        }


# ============================================================
# 2. Garbe: lokale Sektionen -> globale Semantik
# ============================================================

@dataclass(frozen=True)
class ParameterSemantics:
    row_range: Tuple[int, ...]
    selected_columns: Tuple[str, ...]
    generated_columns: Tuple[str, ...]
    output_mode: str
    runtime_mode: str


@dataclass
class ParameterSemanticsSheaf:
    """
    Garbe:
    klebt lokale Sektionen zu einer globalen Semantik.
    """

    known_columns: frozenset[str] = frozenset(
        {
            "nummer",
            "name",
            "religion",
            "primzahl",
            "bruch",
            "liebe",
        }
    )

    generated_column_names: frozenset[str] = frozenset(
        {
            "primzahl",
            "bruch",
            "liebe",
        }
    )

    output_modes: frozenset[str] = frozenset(
        {
            "shell",
            "html",
            "csv",
            "markdown",
        }
    )

    runtime_modes: frozenset[str] = frozenset(
        {
            "serial",
            "parallel",
        }
    )

    def compatible(self, presheaf: RetaPresheaf) -> bool:
        for section in presheaf.sections.values():
            if section.name == "row_range":
                rows = section.data.get("rows", ())
                if not all(isinstance(row, int) and row > 0 for row in rows):
                    return False

            elif section.name == "selected_columns":
                columns = section.data.get("columns", ())
                if not set(columns).issubset(self.known_columns):
                    return False

            elif section.name == "generated_columns":
                columns = section.data.get("columns", ())
                if not set(columns).issubset(self.generated_column_names):
                    return False

            elif section.name == "output_mode":
                mode = section.data.get("output_mode")
                if mode not in self.output_modes:
                    return False

            elif section.name == "runtime_mode":
                mode = section.data.get("runtime_mode")
                if mode not in self.runtime_modes:
                    return False

        return True

    def glue(self, presheaf: RetaPresheaf) -> ParameterSemantics:
        if not self.compatible(presheaf):
            raise ValueError("Unverträgliche lokale Sektionen")

        row_range: Tuple[int, ...] = (1,)
        selected_columns: Tuple[str, ...] = ("nummer", "name")
        generated_columns: Tuple[str, ...] = tuple()
        output_mode = "shell"
        runtime_mode = "serial"

        for section in presheaf.sections.values():
            if section.name == "row_range":
                row_range = tuple(section.data["rows"])

            elif section.name == "selected_columns":
                selected_columns = tuple(section.data["columns"])

            elif section.name == "generated_columns":
                generated_columns = tuple(section.data["columns"])

            elif section.name == "output_mode":
                output_mode = section.data["output_mode"]

            elif section.name == "runtime_mode":
                runtime_mode = section.data["runtime_mode"]

        all_columns = tuple(
            dict.fromkeys(
                selected_columns + generated_columns
            )
        )

        return ParameterSemantics(
            row_range=row_range,
            selected_columns=all_columns,
            generated_columns=generated_columns,
            output_mode=output_mode,
            runtime_mode=runtime_mode,
        )


# ============================================================
# 3. Tabelle
# ============================================================

@dataclass(frozen=True)
class TableSection:
    header: Tuple[str, ...]
    rows: Tuple[Tuple[str, ...], ...]


@dataclass
class TableGenerationFunctor:
    """
    Funktor:
        ParameterSemantics -> TableSection
    """

    database: Dict[int, Dict[str, str]]

    def map_object(self, semantics: ParameterSemantics) -> TableSection:
        header = semantics.selected_columns
        rows: List[Tuple[str, ...]] = []

        for row_number in semantics.row_range:
            source_row = self.database.get(row_number, {})
            rows.append(
                tuple(
                    source_row.get(column, "")
                    for column in header
                )
            )

        return TableSection(
            header=header,
            rows=tuple(rows),
        )


# ============================================================
# 4. Execution Network: Tabelle -> Tasks -> Results
# ============================================================

@dataclass(frozen=True)
class ExecutionTask:
    task_id: int
    row: Tuple[str, ...]


@dataclass(frozen=True)
class ExecutionResult:
    task_id: int
    row: Tuple[str, ...]


@dataclass
class TableChunkExecutionFunctor:
    """
    Funktor:
        TableSection -> ExecutionTask-Liste

    Die Tabelle wird in Tasks zerlegt.
    """

    def map_object(self, table: TableSection) -> Tuple[ExecutionTask, ...]:
        return tuple(
            ExecutionTask(
                task_id=index,
                row=row,
            )
            for index, row in enumerate(table.rows)
        )


@dataclass
class ExecutionNetwork:
    """
    Simulierte Ausführung.

    In echter Runtime könnten hier Queues, Worker,
    Semaphore und Channels beteiligt sein.
    """

    runtime_mode: str = "serial"

    def execute(
        self,
        tasks: Tuple[ExecutionTask, ...],
    ) -> Tuple[ExecutionResult, ...]:
        if self.runtime_mode == "serial":
            ordered_tasks = tasks

        elif self.runtime_mode == "parallel":
            # Simulation:
            # Parallele Ausführung kann Ergebnisse in anderer Reihenfolge liefern.
            ordered_tasks = tuple(reversed(tasks))

        else:
            raise ValueError(self.runtime_mode)

        return tuple(
            ExecutionResult(
                task_id=task.task_id,
                row=task.row,
            )
            for task in ordered_tasks
        )


@dataclass
class ExecutionResultGluingFunctor:
    """
    Funktor:
        ExecutionResult-Liste -> TableSection

    Universelle Idee:
        egal in welcher Reihenfolge Ergebnisse eintreffen,
        die deterministische Reduktion erzeugt genau eine Tabelle.
    """

    header: Tuple[str, ...]

    def map_object(
        self,
        results: Tuple[ExecutionResult, ...],
    ) -> TableSection:
        ordered = sorted(
            results,
            key=lambda result: result.task_id,
        )

        return TableSection(
            header=self.header,
            rows=tuple(result.row for result in ordered),
        )


# ============================================================
# 5. Renderer und Normalisierung
# ============================================================

@dataclass(frozen=True)
class RenderedOutput:
    mode: str
    text: str


@dataclass(frozen=True)
class NormalizedOutput:
    text: str


@dataclass
class OutputRenderingFunctor:
    """
    Funktor:
        TableSection -> RenderedOutput
    """

    output_mode: str

    def map_object(self, table: TableSection) -> RenderedOutput:
        if self.output_mode == "csv":
            lines = [
                ",".join(table.header)
            ]
            lines.extend(
                ",".join(row)
                for row in table.rows
            )

            return RenderedOutput(
                mode="csv",
                text="\n".join(lines),
            )

        if self.output_mode == "shell":
            lines = [
                " | ".join(table.header)
            ]
            lines.extend(
                " | ".join(row)
                for row in table.rows
            )

            return RenderedOutput(
                mode="shell",
                text="\n".join(lines),
            )

        raise ValueError(self.output_mode)


@dataclass
class OutputNormalizationFunctor:
    """
    Funktor:
        RenderedOutput -> NormalizedOutput

    Universelle Idee:
        verschiedene Renderer sollen über eine Normalform
        vergleichbar werden.
    """

    def map_object(self, rendered: RenderedOutput) -> NormalizedOutput:
        text = rendered.text

        if rendered.mode == "shell":
            text = text.replace(" | ", ",")

        text = "\n".join(
            line.strip()
            for line in text.splitlines()
            if line.strip()
        )

        return NormalizedOutput(text=text)


# ============================================================
# 6. Komplizierte Faktorisierung
# ============================================================

@dataclass
class FullRetaFactorization:
    """
    Die komplizierte Faktorisierung:

        RetaPresheaf
            ↓ glue
        ParameterSemantics
            ↓ table_generation
        TableSection
            ↓ chunk_execution
        ExecutionTask*
            ↓ execution_network
        ExecutionResult*
            ↓ deterministic_reduce
        TableSection
            ↓ render
        RenderedOutput
            ↓ normalize
        NormalizedOutput

    Der direkte Algorithmus RetaPresheaf -> NormalizedOutput
    soll über diese Kette faktorisieren.
    """

    sheaf: ParameterSemanticsSheaf
    table_generation: TableGenerationFunctor
    chunk_execution: TableChunkExecutionFunctor
    normalization: OutputNormalizationFunctor

    def factor(self, presheaf: RetaPresheaf) -> NormalizedOutput:
        semantics = self.sheaf.glue(presheaf)

        table = self.table_generation.map_object(semantics)

        tasks = self.chunk_execution.map_object(table)

        network = ExecutionNetwork(
            runtime_mode=semantics.runtime_mode
        )

        results = network.execute(tasks)

        result_gluing = ExecutionResultGluingFunctor(
            header=table.header
        )

        reduced_table = result_gluing.map_object(results)

        renderer = OutputRenderingFunctor(
            output_mode=semantics.output_mode
        )

        rendered = renderer.map_object(reduced_table)

        return self.normalization.map_object(rendered)

    def commutes(
        self,
        presheaf: RetaPresheaf,
        direct_algorithm: Callable[[RetaPresheaf], NormalizedOutput],
    ) -> bool:
        return direct_algorithm(presheaf) == self.factor(presheaf)


# ============================================================
# 7. Beispiel-Datenbank
# ============================================================

DATABASE = {
    1: {
        "nummer": "1",
        "name": "Alpha",
        "religion": "Thomas",
        "primzahl": "",
        "bruch": "1/1",
        "liebe": "ja",
    },
    2: {
        "nummer": "2",
        "name": "Beta",
        "religion": "Thomas",
        "primzahl": "2",
        "bruch": "1/2",
        "liebe": "nein",
    },
    3: {
        "nummer": "3",
        "name": "Gamma",
        "religion": "Thomas",
        "primzahl": "3",
        "bruch": "1/3",
        "liebe": "ja",
    },
}


# ============================================================
# 8. Direkter Legacy-Algorithmus
# ============================================================

def direct_legacy_algorithm(
    presheaf: RetaPresheaf,
) -> NormalizedOutput:
    """
    Direkter Weg:
        RetaPresheaf -> NormalizedOutput

    Er tut absichtlich dasselbe wie die Faktorisierung,
    aber ohne die Architektur sichtbar zu machen.
    """

    sheaf = ParameterSemanticsSheaf()
    semantics = sheaf.glue(presheaf)

    table_generation = TableGenerationFunctor(
        database=DATABASE
    )

    table = table_generation.map_object(semantics)

    # Legacy-Algorithmus berechnet seriell,
    # aber das Ergebnis muss gleich sein.
    renderer = OutputRenderingFunctor(
        output_mode=semantics.output_mode
    )

    rendered = renderer.map_object(table)

    normalization = OutputNormalizationFunctor()

    return normalization.map_object(rendered)


# ============================================================
# 9. Beispielprogramm
# ============================================================

def main() -> None:
    presheaf = RetaPresheaf()

    presheaf.add_section(
        LocalSection(
            scope="cli",
            name="row_range",
            data={
                "rows": (1, 2, 3),
            },
        )
    )

    presheaf.add_section(
        LocalSection(
            scope="cli",
            name="selected_columns",
            data={
                "columns": (
                    "nummer",
                    "name",
                    "religion",
                ),
            },
        )
    )

    presheaf.add_section(
        LocalSection(
            scope="cli",
            name="generated_columns",
            data={
                "columns": (
                    "primzahl",
                    "bruch",
                ),
            },
        )
    )

    presheaf.add_section(
        LocalSection(
            scope="cli",
            name="output_mode",
            data={
                "output_mode": "csv",
            },
        )
    )

    presheaf.add_section(
        LocalSection(
            scope="cli",
            name="runtime_mode",
            data={
                "runtime_mode": "parallel",
            },
        )
    )

    factorization = FullRetaFactorization(
        sheaf=ParameterSemanticsSheaf(),
        table_generation=TableGenerationFunctor(
            database=DATABASE
        ),
        chunk_execution=TableChunkExecutionFunctor(),
        normalization=OutputNormalizationFunctor(),
    )

    print("Lokale Sektionen:")
    for key, section in presheaf.sections.items():
        print(key, "=>", section)

    print()
    print("Faktorisierter Weg:")
    print(factorization.factor(presheaf))

    print()
    print("Direkter Legacy-Weg:")
    print(direct_legacy_algorithm(presheaf))

    print()
    print("Kommutiert das Diagramm?")
    print(
        factorization.commutes(
            presheaf,
            direct_legacy_algorithm,
        )
    )


if __name__ == "__main__":
    main()
```

---

# Erwartete Ausgabe

```text
Lokale Sektionen:
cli:row_range => LocalSection(scope='cli', name='row_range', data={'rows': (1, 2, 3)})
cli:selected_columns => LocalSection(scope='cli', name='selected_columns', data={'columns': ('nummer', 'name', 'religion')})
cli:generated_columns => LocalSection(scope='cli', name='generated_columns', data={'columns': ('primzahl', 'bruch')})
cli:output_mode => LocalSection(scope='cli', name='output_mode', data={'output_mode': 'csv'})
cli:runtime_mode => LocalSection(scope='cli', name='runtime_mode', data={'runtime_mode': 'parallel'})

Faktorisierter Weg:
NormalizedOutput(text='nummer,name,religion,primzahl,bruch
1,Alpha,Thomas,,1/1
2,Beta,Thomas,2,1/2
3,Gamma,Thomas,3,1/3')

Direkter Legacy-Weg:
NormalizedOutput(text='nummer,name,religion,primzahl,bruch
1,Alpha,Thomas,,1/1
2,Beta,Thomas,2,1/2
3,Gamma,Thomas,3,1/3')

Kommutiert das Diagramm?
True
```

---

# Faktorisierungsdiagramm

```text
                            direct_legacy_algorithm
RetaPresheaf ─────────────────────────────────────────────► NormalizedOutput
     │                                                            ▲
     │                                                            │
     │ glue                                                       │ normalize
     ▼                                                            │
ParameterSemantics                                                │
     │                                                            │
     │ table_generation                                           │
     ▼                                                            │
TableSection                                                      │
     │                                                            │
     │ chunk_execution                                            │
     ▼                                                            │
ExecutionTask*                                                    │
     │                                                            │
     │ execution_network                                          │
     ▼                                                            │
ExecutionResult*                                                  │
     │                                                            │
     │ deterministic_reduce                                       │
     ▼                                                            │
TableSection                                                      │
     │                                                            │
     │ render                                                     │
     ▼                                                            │
RenderedOutput ───────────────────────────────────────────────────┘
```

---

# Die Faktoren

Die direkte Abbildung

```text
RetaPresheaf -> NormalizedOutput
```

wird zerlegt in diese Faktoren:

| Faktor                                    | Typ                                  | Bedeutung                                         |
| ----------------------------------------- | ------------------------------------ | ------------------------------------------------- |
| `ParameterSemanticsSheaf.glue`            | `RetaPresheaf -> ParameterSemantics` | lokale Sektionen zu globaler Semantik kleben      |
| `TableGenerationFunctor.map_object`       | `ParameterSemantics -> TableSection` | globale Semantik in Tabelle übersetzen            |
| `TableChunkExecutionFunctor.map_object`   | `TableSection -> ExecutionTask*`     | Tabelle in ausführbare Tasks zerlegen             |
| `ExecutionNetwork.execute`                | `ExecutionTask* -> ExecutionResult*` | Tasks seriell oder parallel ausführen             |
| `ExecutionResultGluingFunctor.map_object` | `ExecutionResult* -> TableSection`   | Ergebnisse deterministisch zur Tabelle reduzieren |
| `OutputRenderingFunctor.map_object`       | `TableSection -> RenderedOutput`     | Tabelle in CSV/Shell/etc. rendern                 |
| `OutputNormalizationFunctor.map_object`   | `RenderedOutput -> NormalizedOutput` | Ausgabe in Normalform bringen                     |

---

# Die Komposition

Die „Multiplikation“ der Faktoren ist die Komposition:

```text
NormalizedOutput
=
OutputNormalizationFunctor
∘ OutputRenderingFunctor
∘ ExecutionResultGluingFunctor
∘ ExecutionNetwork
∘ TableChunkExecutionFunctor
∘ TableGenerationFunctor
∘ ParameterSemanticsSheaf.glue
```

Oder typisiert:

```text
RetaPresheaf
    --glue-->
ParameterSemantics
    --table_generation-->
TableSection
    --chunk_execution-->
ExecutionTask*
    --execute-->
ExecutionResult*
    --deterministic_reduce-->
TableSection
    --render-->
RenderedOutput
    --normalize-->
NormalizedOutput
```

---

# Warum ist das die komplizierteste Faktorisierung?

Weil sie fast alle zentralen Architekturideen deines `reta_arch` kombiniert:

```text
Prägarbe
Garbe
Gluing
Funktor
Execution Network
Queue/Task-Idee
deterministische Reduktion
Renderer
Normalisierung
natürliche Transformation Legacy ≙ Architektur
```

Die mathematisch vollständige universelle Eigenschaft wäre:

```text
Jeder direkte Algorithmus
RetaPresheaf -> NormalizedOutput

faktorisiert eindeutig über

RetaPresheaf
→ ParameterSemantics
→ TableSection
→ ExecutionTask*
→ ExecutionResult*
→ TableSection
→ RenderedOutput
→ NormalizedOutput
```

Im Beispiel wird zumindest die wichtigste praktische Bedingung geprüft:

```text
direct_legacy_algorithm(presheaf)
=
factorized_architecture_path(presheaf)
```

Also:

```text
Das Diagramm kommutiert.
```
