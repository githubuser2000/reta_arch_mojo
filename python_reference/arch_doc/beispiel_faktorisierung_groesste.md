# Umfangreiche Faktorisierung einer universellen Eigenschaft aus `reta_arch`

Die umfangreichste universelle Eigenschaft in deinem Quelltext ist wahrscheinlich die **Tabellenerzeugung durch Gluing**:

```text
lokale Sektionen
    CSV
    Prompt
    Aliase
    Defaults
    Generator-Spalten
        │
        ▼
Presheaf
        │
        ▼
ParameterSemanticsSheaf
        │
        ▼
TableGenerationGluingFunctor
        │
        ▼
TableSection
```

Die universelle Idee:

```text
Jeder Weg, aus lokalen Daten eine Tabelle zu erzeugen,
soll eindeutig über die kanonische Semantik und das Tabellen-Gluing faktorisieren.
```

Das folgende Python-Beispiel modelliert diese Faktorisierung ausführbar.

---

```python
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, Iterable, List, Optional, Tuple


# ============================================================
# 1. Lokale Sektionen / Prägarbe
# ============================================================

@dataclass(frozen=True)
class LocalSection:
    """
    Lokale Sektion einer Prägarbe.

    Beispiele:
        scope = "cli",      name = "row_range"
        scope = "csv",      name = "available_columns"
        scope = "defaults", name = "output_mode"
    """

    scope: str
    name: str
    data: Dict[str, Any]


@dataclass
class RetaPresheaf:
    """
    Prägarbe:
        sammelt lokale Informationen aus verschiedenen Kontexten.

    Noch keine globale Semantik.
    Noch keine fertige Tabelle.
    """

    sections: Dict[str, LocalSection] = field(default_factory=dict)

    def add_section(self, section: LocalSection) -> None:
        key = f"{section.scope}:{section.name}"
        self.sections[key] = section

    def restrict(self, scope: str) -> Dict[str, LocalSection]:
        """
        Einschränkung auf einen lokalen Kontext.
        """
        return {
            key: section
            for key, section in self.sections.items()
            if section.scope == scope
        }


# ============================================================
# 2. Globale Semantik / Garbe
# ============================================================

@dataclass(frozen=True)
class ParameterSemantics:
    """
    Globale, kanonische Semantik.

    Der Rest des Programms arbeitet nicht mehr mit Rohdaten,
    sondern mit dieser kanonischen Semantik.
    """

    row_range: Tuple[int, ...]
    selected_columns: Tuple[str, ...]
    output_mode: str
    generated_columns: Tuple[str, ...]


@dataclass
class ParameterSemanticsSheaf:
    """
    Garbe:
        klebt lokale Sektionen zu einer globalen Semantik.

    Universelle Idee:
        Alle kompatiblen lokalen Parameterdaten besitzen
        genau eine kanonische globale Semantik.
    """

    allowed_output_modes: frozenset[str] = frozenset(
        {
            "shell",
            "html",
            "csv",
            "markdown",
            "bbcode",
        }
    )

    known_columns: frozenset[str] = frozenset(
        {
            "nummer",
            "name",
            "religion",
            "primzahl",
            "bruch",
            "motivation",
            "liebe",
        }
    )

    known_generated_columns: frozenset[str] = frozenset(
        {
            "primzahl",
            "bruch",
            "liebe",
        }
    )

    def compatible(self, presheaf: RetaPresheaf) -> bool:
        """
        Verträglichkeit der lokalen Sektionen.

        In einer vollständigen mathematischen Garbe müsste man
        auch Überlappungen offener Mengen prüfen.

        Hier prüfen wir pragmatisch:
            - row_range enthält nur positive int-Werte
            - output_mode ist erlaubt
            - selected_columns sind bekannt
            - generated_columns sind bekannt
        """

        for section in presheaf.sections.values():
            if section.name == "row_range":
                rows = section.data.get("rows", ())
                if not all(isinstance(row, int) and row > 0 for row in rows):
                    return False

            elif section.name == "output_mode":
                mode = section.data.get("output_mode")
                if mode not in self.allowed_output_modes:
                    return False

            elif section.name == "selected_columns":
                columns = section.data.get("columns", ())
                if not set(columns).issubset(self.known_columns):
                    return False

            elif section.name == "generated_columns":
                columns = section.data.get("columns", ())
                if not set(columns).issubset(self.known_generated_columns):
                    return False

        return True

    def glue(self, presheaf: RetaPresheaf) -> ParameterSemantics:
        """
        Gluing:
            lokale Sektionen -> globale Semantik

        Priorität:
            CLI überschreibt Defaults.
            CSV liefert bekannte Spalten.
            Generatoren ergänzen Spalten.
        """

        if not self.compatible(presheaf):
            raise ValueError(
                "Lokale Sektionen sind nicht kompatibel und können nicht geklebt werden."
            )

        row_range: Tuple[int, ...] = tuple(range(1, 10))
        selected_columns: Tuple[str, ...] = ("nummer", "name")
        output_mode: str = "shell"
        generated_columns: Tuple[str, ...] = tuple()

        for section in presheaf.sections.values():
            if section.name == "row_range":
                row_range = tuple(section.data["rows"])

            elif section.name == "selected_columns":
                selected_columns = tuple(section.data["columns"])

            elif section.name == "output_mode":
                output_mode = section.data["output_mode"]

            elif section.name == "generated_columns":
                generated_columns = tuple(section.data["columns"])

        final_columns = tuple(
            dict.fromkeys(
                selected_columns + generated_columns
            )
        )

        return ParameterSemantics(
            row_range=row_range,
            selected_columns=final_columns,
            output_mode=output_mode,
            generated_columns=generated_columns,
        )


# ============================================================
# 3. Tabellenobjekt
# ============================================================

@dataclass(frozen=True)
class TableSection:
    """
    Globale Tabelle.

    Dies ist das Zielobjekt der Tabellenerzeugung.
    """

    header: Tuple[str, ...]
    rows: Tuple[Tuple[str, ...], ...]


# ============================================================
# 4. TableGenerationGluingFunctor
# ============================================================

@dataclass
class TableGenerationGluingFunctor:
    """
    Funktor / universeller Architektur-Knoten:

        ParameterSemanticsSheaf
            ↓
        TableSection

    Er erzeugt aus kanonischer Semantik eine Tabelle.

    Universelle Faktorisierungsidee:
        Jede Tabellenerzeugung muss über ParameterSemantics
        und diesen Gluing-Funktor laufen.
    """

    database: Dict[int, Dict[str, str]]

    def map_object(self, semantics: ParameterSemantics) -> TableSection:
        header = semantics.selected_columns

        rows: List[Tuple[str, ...]] = []

        for row_number in semantics.row_range:
            source_row = self.database.get(row_number, {})

            output_row: List[str] = []

            for column in header:
                output_row.append(
                    source_row.get(column, "")
                )

            rows.append(tuple(output_row))

        return TableSection(
            header=header,
            rows=tuple(rows),
        )


# ============================================================
# 5. Morphismus: lokaler direkter Tabellenalgorithmus
# ============================================================

@dataclass
class DirectTableAlgorithm:
    """
    Ein beliebiger direkter Algorithmus:

        RetaPresheaf -> TableSection

    In einer chaotischen Architektur könnte jeder solche Wege bauen.

    Die universelle Faktorisierung verlangt aber:

        DirectAlgorithm
            =
        TableGenerationGluingFunctor ∘ ParameterSemanticsSheaf.glue

    Also:

        Presheaf
            ↓
        Semantics
            ↓
        Table
    """

    name: str
    func: Callable[[RetaPresheaf], TableSection]

    def apply(self, presheaf: RetaPresheaf) -> TableSection:
        return self.func(presheaf)


# ============================================================
# 6. Faktorisierungskonstruktion
# ============================================================

@dataclass
class TableGenerationFactorization:
    """
    Die eigentliche Faktorisierung:

        direkter Weg:
            RetaPresheaf -> TableSection

        faktorisierter Weg:
            RetaPresheaf
                ↓ glue
            ParameterSemantics
                ↓ table_generation
            TableSection

    In einer vollständigen universellen Eigenschaft müsste
    zusätzlich bewiesen werden:

        - Existenz der Faktorisierung
        - Eindeutigkeit der Faktorisierung
        - Kommutativität des Diagramms

    Hier prüfen wir Kommutativität anhand eines Beispiels.
    """

    sheaf: ParameterSemanticsSheaf
    table_functor: TableGenerationGluingFunctor

    def factor(
        self,
        presheaf: RetaPresheaf,
    ) -> TableSection:
        semantics = self.sheaf.glue(presheaf)
        return self.table_functor.map_object(semantics)

    def commutes(
        self,
        presheaf: RetaPresheaf,
        direct_algorithm: DirectTableAlgorithm,
    ) -> bool:
        """
        Prüft:

            direct_algorithm(presheaf)
                ==
            table_functor(sheaf.glue(presheaf))

        Also: Das Diagramm kommutiert.
        """

        direct_result = direct_algorithm.apply(presheaf)
        factored_result = self.factor(presheaf)

        return direct_result == factored_result


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
        "motivation": "Start",
        "liebe": "ja",
    },
    2: {
        "nummer": "2",
        "name": "Beta",
        "religion": "Thomas",
        "primzahl": "2",
        "bruch": "1/2",
        "motivation": "Weg",
        "liebe": "nein",
    },
    3: {
        "nummer": "3",
        "name": "Gamma",
        "religion": "Thomas",
        "primzahl": "3",
        "bruch": "1/3",
        "motivation": "Ziel",
        "liebe": "ja",
    },
}


# ============================================================
# 8. Ein direkter Algorithmus, der korrekt faktorisiert
# ============================================================

def direct_table_algorithm(
    presheaf: RetaPresheaf,
) -> TableSection:
    """
    Dieser direkte Algorithmus tut absichtlich dasselbe wie die Faktorisierung.

    In einem echten Refactoring wäre das z. B. ein alter Legacy-Pfad,
    den man gegen den neuen Architekturpfad vergleicht.
    """

    sheaf = ParameterSemanticsSheaf()
    semantics = sheaf.glue(presheaf)

    table_functor = TableGenerationGluingFunctor(
        database=DATABASE
    )

    return table_functor.map_object(semantics)


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
                "output_mode": "shell",
            },
        )
    )

    print("Lokale Sektionen der Prägarbe:")
    for key, section in presheaf.sections.items():
        print(key, "=>", section)

    sheaf = ParameterSemanticsSheaf()

    print()
    print("Sind lokale Sektionen kompatibel?")
    print(sheaf.compatible(presheaf))

    semantics = sheaf.glue(presheaf)

    print()
    print("Globale ParameterSemantics nach Gluing:")
    print(semantics)

    table_functor = TableGenerationGluingFunctor(
        database=DATABASE
    )

    factorization = TableGenerationFactorization(
        sheaf=sheaf,
        table_functor=table_functor,
    )

    table = factorization.factor(presheaf)

    print()
    print("Tabelle über faktorisierte Konstruktion:")
    print(table)

    direct_algorithm = DirectTableAlgorithm(
        name="legacy_direct_table_algorithm",
        func=direct_table_algorithm,
    )

    direct_table = direct_algorithm.apply(presheaf)

    print()
    print("Tabelle über direkten Algorithmus:")
    print(direct_table)

    print()
    print("Kommutiert das Diagramm?")
    print(
        factorization.commutes(
            presheaf,
            direct_algorithm,
        )
    )


if __name__ == "__main__":
    main()
```

---

# Erwartete Ausgabe

```text
Lokale Sektionen der Prägarbe:
cli:row_range => LocalSection(scope='cli', name='row_range', data={'rows': (1, 2, 3)})
cli:selected_columns => LocalSection(scope='cli', name='selected_columns', data={'columns': ('nummer', 'name', 'religion')})
cli:generated_columns => LocalSection(scope='cli', name='generated_columns', data={'columns': ('primzahl', 'bruch')})
cli:output_mode => LocalSection(scope='cli', name='output_mode', data={'output_mode': 'shell'})

Sind lokale Sektionen kompatibel?
True

Globale ParameterSemantics nach Gluing:
ParameterSemantics(row_range=(1, 2, 3), selected_columns=('nummer', 'name', 'religion', 'primzahl', 'bruch'), output_mode='shell', generated_columns=('primzahl', 'bruch'))

Tabelle über faktorisierte Konstruktion:
TableSection(header=('nummer', 'name', 'religion', 'primzahl', 'bruch'), rows=(('1', 'Alpha', 'Thomas', '', '1/1'), ('2', 'Beta', 'Thomas', '2', '1/2'), ('3', 'Gamma', 'Thomas', '3', '1/3')))

Tabelle über direkten Algorithmus:
TableSection(header=('nummer', 'name', 'religion', 'primzahl', 'bruch'), rows=(('1', 'Alpha', 'Thomas', '', '1/1'), ('2', 'Beta', 'Thomas', '2', '1/2'), ('3', 'Gamma', 'Thomas', '3', '1/3')))

Kommutiert das Diagramm?
True
```

---

# Diagramm der Faktorisierung

```text
                direct_table_algorithm
RetaPresheaf ─────────────────────────────► TableSection
     │                                           ▲
     │                                           │
     │ glue                                      │ map_object
     ▼                                           │
ParameterSemantics ───────── TableGenerationGluingFunctor
```

Dass das Diagramm kommutiert, bedeutet:

```text
direct_table_algorithm(presheaf)
=
TableGenerationGluingFunctor(
    ParameterSemanticsSheaf.glue(presheaf)
)
```

---

# Warum ist das die umfangreichste Kandidaten-Faktorisierung?

Weil sie mehrere Architekturkonzepte gleichzeitig verbindet:

```text
Prägarbe
    lokale Sektionen

Garbe
    globale Semantik durch Gluing

Funktor
    Semantik → Tabelle

Morphismen
    direkter Algorithmus vs. faktorisierter Pfad

universelle Konstruktion
    alle Tabellenwege laufen über den Gluing-Knoten

natürliche Transformation
    Legacy-Pfad ≙ Architektur-Pfad
```

In deinem `reta_arch` entspricht das am ehesten:

```text
PresheafToSheafGluingTransformation
        +
CanonicalParameterSheafFunctor
        +
TableGenerationGluingFunctor
        +
LegacyToArchitectureTransformation
```

Die mathematisch harte universelle Eigenschaft wäre erst vollständig, wenn zusätzlich bewiesen würde:

```text
Für jeden passenden direkten Algorithmus
existiert genau eine Faktorisierung
über ParameterSemanticsSheaf und TableGenerationGluingFunctor.
```

Das Beispiel prüft immerhin bereits die wichtigste praktische Bedingung:

```text
Das Diagramm kommutiert.
```
