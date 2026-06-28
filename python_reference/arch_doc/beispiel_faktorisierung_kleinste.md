# Kleinste Faktorisierung einer universellen Eigenschaft aus `reta_arch`

Die kleinste sinnvolle Faktorisierung in deinem Quelltext ist:

```text
Rohparameter
    │
    ▼
kanonische Parameter
    │
    ▼
weitere Verarbeitung
```

Das entspricht konzeptionell:

```text
RawToCanonicalParameterTransformation
```

oder:

```text
CanonicalParameterSheafFunctor
```

Die universelle Idee:

```text
Jeder Weg, der Rohparameter weiterverarbeiten will,
muss zuerst über die kanonische Parameterform laufen.
```

---

# Python-Beispiel

```python
from dataclasses import dataclass
from typing import Callable, Dict


# ============================================================
# 1. Rohparameter
# ============================================================

@dataclass(frozen=True)
class RawParameters:
    """
    Rohparameter aus Benutzerinput.

    Beispiel:
        -sp
        --breite=0
        html
    """

    values: Dict[str, str]


# ============================================================
# 2. Kanonische Parameter
# ============================================================

@dataclass(frozen=True)
class CanonicalParameters:
    """
    Kanonische Parameterform.

    Der Rest des Programms arbeitet nur noch damit.
    """

    main_parameter: str
    output_mode: str
    width: int


# ============================================================
# 3. Universeller Knoten: Kanonisierung
# ============================================================

class CanonicalParameterFactor:
    """
    Universelle Architektur-Konstruktion:

        RawParameters
            ↓
        CanonicalParameters

    Alle weiteren Verarbeitungen sollen über diese Form laufen.
    """

    MAIN_ALIASES = {
        "-sp": "-spalten",
        "-s": "-spalten",
        "-z": "-zeilen",
    }

    OUTPUT_ALIASES = {
        "htm": "html",
        "html": "html",
        "shell": "shell",
        "csv": "csv",
    }

    def apply(
        self,
        raw: RawParameters,
    ) -> CanonicalParameters:
        main = raw.values.get(
            "main",
            "-zeilen",
        )

        output = raw.values.get(
            "output",
            "shell",
        )

        width = raw.values.get(
            "width",
            "80",
        )

        return CanonicalParameters(
            main_parameter=self.MAIN_ALIASES.get(
                main,
                main,
            ),
            output_mode=self.OUTPUT_ALIASES.get(
                output,
                output,
            ),
            width=int(width),
        )


# ============================================================
# 4. Direkter Algorithmus
# ============================================================

@dataclass
class DirectAlgorithm:
    """
    Ein beliebiger direkter Algorithmus:

        RawParameters -> str

    In einer ungeordneten Architektur könnte dieser direkt
    mit Rohparametern arbeiten.

    Die Faktorisierung verlangt aber:

        DirectAlgorithm
            =
        VerarbeitungNachKanonisierung ∘ CanonicalParameterFactor
    """

    name: str
    func: Callable[[RawParameters], str]

    def apply(
        self,
        raw: RawParameters,
    ) -> str:
        return self.func(raw)


# ============================================================
# 5. Verarbeitung nach der Faktorisierung
# ============================================================

class ProcessCanonicalParameters:
    """
    Verarbeitung, die nur noch kanonische Parameter kennt.

    CanonicalParameters -> str
    """

    def apply(
        self,
        canonical: CanonicalParameters,
    ) -> str:
        return (
            f"main={canonical.main_parameter}; "
            f"output={canonical.output_mode}; "
            f"width={canonical.width}"
        )


# ============================================================
# 6. Faktorisierung
# ============================================================

@dataclass
class CanonicalParameterFactorization:
    """
    Faktorisierungsdiagramm:

        RawParameters ───────────────► Ergebnis
              │                         ▲
              │                         │
              ▼                         │
        CanonicalParameters ────────────┘

    Es wird geprüft:

        direct(raw)
            ==
        process(canonicalize(raw))
    """

    canonicalize: CanonicalParameterFactor
    process: ProcessCanonicalParameters

    def factor(
        self,
        raw: RawParameters,
    ) -> str:
        canonical = self.canonicalize.apply(raw)
        return self.process.apply(canonical)

    def commutes(
        self,
        raw: RawParameters,
        direct: DirectAlgorithm,
    ) -> bool:
        return direct.apply(raw) == self.factor(raw)


# ============================================================
# 7. Beispiel eines direkten Legacy-Algorithmus
# ============================================================

def legacy_direct_algorithm(
    raw: RawParameters,
) -> str:
    """
    Alter direkter Weg.

    Er tut absichtlich dasselbe wie der faktorisierte Weg.
    In `reta` wäre das z. B. alte Alias-/Parameterlogik.
    """

    canonicalize = CanonicalParameterFactor()
    process = ProcessCanonicalParameters()

    canonical = canonicalize.apply(raw)

    return process.apply(canonical)


# ============================================================
# 8. Beispielprogramm
# ============================================================

def main() -> None:
    raw = RawParameters(
        values={
            "main": "-sp",
            "output": "htm",
            "width": "0",
        }
    )

    canonicalize = CanonicalParameterFactor()
    process = ProcessCanonicalParameters()

    factorization = CanonicalParameterFactorization(
        canonicalize=canonicalize,
        process=process,
    )

    direct = DirectAlgorithm(
        name="legacy_direct_algorithm",
        func=legacy_direct_algorithm,
    )

    print("Rohparameter:")
    print(raw)

    print()
    print("Kanonische Parameter:")
    print(canonicalize.apply(raw))

    print()
    print("Direkter Weg:")
    print(direct.apply(raw))

    print()
    print("Faktorisierter Weg:")
    print(factorization.factor(raw))

    print()
    print("Kommutiert das Diagramm?")
    print(factorization.commutes(raw, direct))


if __name__ == "__main__":
    main()
```

---

# Erwartete Ausgabe

```text
Rohparameter:
RawParameters(values={'main': '-sp', 'output': 'htm', 'width': '0'})

Kanonische Parameter:
CanonicalParameters(main_parameter='-spalten', output_mode='html', width=0)

Direkter Weg:
main=-spalten; output=html; width=0

Faktorisierter Weg:
main=-spalten; output=html; width=0

Kommutiert das Diagramm?
True
```

---

# Faktorisierungsdiagramm

```text
                 legacy_direct_algorithm
RawParameters ─────────────────────────────► Ergebnis
      │                                         ▲
      │                                         │
      │ CanonicalParameterFactor                │ ProcessCanonicalParameters
      ▼                                         │
CanonicalParameters ───────────────────────────┘
```

Das bedeutet:

```text
legacy_direct_algorithm(raw)
=
ProcessCanonicalParameters(
    CanonicalParameterFactor(raw)
)
```

---

# Warum ist das die kleinste Faktorisierung?

Weil nur drei Dinge beteiligt sind:

```text
1. Rohobjekt
2. kanonisches Objekt
3. Ergebnis
```

Also:

```text
RawParameters
        │
        ▼
CanonicalParameters
        │
        ▼
Result
```

In deinem `reta_arch` entspricht das am ehesten:

```text
RawToCanonicalParameterTransformation
```

oder:

```text
CanonicalParameterSheafFunctor
```

Der architektonische Gewinn ist:

```text
Der Rest des Programms muss keine Aliase,
Kurzformen oder Rohparameter mehr kennen.
```

Alles läuft über:

```text
CanonicalParameters
```
