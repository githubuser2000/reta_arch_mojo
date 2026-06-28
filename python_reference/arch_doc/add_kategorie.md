# Beispiel: Eine neue mathematische Kategorie zu `reta_arch` hinzufügen

Dieses Beispiel fügt eine neue Kategorie hinzu:

```text
RuntimeConfigCategory
```

Sie beschreibt globale Runtime-Konfigurationen als Objekte und erlaubte Transformationen als Morphismen.

Die Kategorie enthält:

```text
Objekte:
    RuntimeConfig

Morphismen:
    IdentityRuntimeConfigMorphism
    EnableDebugMorphism
    EnableAuditMorphism
    SetRuntimeModeMorphism
```

Zusätzlich werden implementiert:

```text
Identitätsmorphismus
Komposition
einfache Validierung der Kategoriegesetze
```

---

# category_runtime_config.py

```python
from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Callable, Dict, Iterable, List, Optional, Tuple


# ============================================================
# Objekt der Kategorie
# ============================================================

@dataclass(frozen=True)
class RuntimeConfig:
    """
    Objekt der RuntimeConfigCategory.

    Eine RuntimeConfig beschreibt den globalen Laufzeitmodus.
    """

    runtime_mode: str = "serial"
    debug: bool = False
    audit: bool = False


# ============================================================
# Morphismus
# ============================================================

@dataclass(frozen=True)
class RuntimeConfigMorphism:
    """
    Morphismus innerhalb der RuntimeConfigCategory.

    Mathematisch:
        RuntimeConfig -> RuntimeConfig

    Also ein Endomorphismus der Kategorie.
    """

    name: str
    func: Callable[[RuntimeConfig], RuntimeConfig]

    domain: str = "RuntimeConfig"
    codomain: str = "RuntimeConfig"

    def apply(
        self,
        obj: RuntimeConfig,
    ) -> RuntimeConfig:
        return self.func(obj)

    def then(
        self,
        other: RuntimeConfigMorphism,
    ) -> RuntimeConfigMorphism:
        """
        Komposition:

            self ; other

        bedeutet:

            other(self(x))

        Also mathematisch:

            other ∘ self
        """

        if self.codomain != other.domain:
            raise TypeError(
                f"Nicht komponierbar: {self.codomain} != {other.domain}"
            )

        return RuntimeConfigMorphism(
            name=f"{other.name} ∘ {self.name}",
            func=lambda obj: other.apply(self.apply(obj)),
            domain=self.domain,
            codomain=other.codomain,
        )


# ============================================================
# Kategorie
# ============================================================

class RuntimeConfigCategory:
    """
    Neue mathematische Kategorie.

    Objekte:
        RuntimeConfig

    Morphismen:
        RuntimeConfig -> RuntimeConfig

    Diese Kategorie ist sehr einfach:
        Alle Morphismen sind Endomorphismen auf RuntimeConfig.
    """

    object_name: str = "RuntimeConfig"

    allowed_runtime_modes = frozenset(
        {
            "serial",
            "parallel",
            "cached",
            "debug",
            "audit",
            "benchmark",
        }
    )

    def __init__(self) -> None:
        self.objects: Dict[str, type] = {
            self.object_name: RuntimeConfig,
        }

        self.morphisms: Dict[str, RuntimeConfigMorphism] = {}

        self.add_morphism(
            self.identity()
        )

    # --------------------------------------------------------
    # Identität
    # --------------------------------------------------------

    def identity(self) -> RuntimeConfigMorphism:
        """
        Identitätsmorphismus:

            id_RuntimeConfig : RuntimeConfig -> RuntimeConfig
        """

        return RuntimeConfigMorphism(
            name="id_RuntimeConfig",
            func=lambda obj: obj,
        )

    # --------------------------------------------------------
    # Morphismus registrieren
    # --------------------------------------------------------

    def add_morphism(
        self,
        morphism: RuntimeConfigMorphism,
    ) -> None:
        if morphism.domain not in self.objects:
            raise ValueError(
                f"Unbekannte Domäne: {morphism.domain}"
            )

        if morphism.codomain not in self.objects:
            raise ValueError(
                f"Unbekannte Codomäne: {morphism.codomain}"
            )

        self.morphisms[morphism.name] = morphism

    # --------------------------------------------------------
    # Komposition
    # --------------------------------------------------------

    def compose(
        self,
        first: RuntimeConfigMorphism,
        second: RuntimeConfigMorphism,
    ) -> RuntimeConfigMorphism:
        """
        Komposition:

            second ∘ first
        """

        composed = first.then(second)

        self.add_morphism(composed)

        return composed

    # --------------------------------------------------------
    # Validierung
    # --------------------------------------------------------

    def is_valid_object(
        self,
        obj: RuntimeConfig,
    ) -> bool:
        return obj.runtime_mode in self.allowed_runtime_modes

    def validate_identity_law(
        self,
        morphism: RuntimeConfigMorphism,
        samples: Iterable[RuntimeConfig],
    ) -> bool:
        """
        Prüft:

            f ∘ id = f
            id ∘ f = f

        anhand konkreter Beispielobjekte.
        """

        identity = self.identity()

        left = identity.then(morphism)
        right = morphism.then(identity)

        for sample in samples:
            if left.apply(sample) != morphism.apply(sample):
                return False

            if right.apply(sample) != morphism.apply(sample):
                return False

        return True

    def validate_associativity(
        self,
        f: RuntimeConfigMorphism,
        g: RuntimeConfigMorphism,
        h: RuntimeConfigMorphism,
        samples: Iterable[RuntimeConfig],
    ) -> bool:
        """
        Prüft Assoziativität:

            h ∘ (g ∘ f) = (h ∘ g) ∘ f

        anhand konkreter Beispielobjekte.
        """

        left = f.then(g).then(h)
        right = f.then(g.then(h))

        for sample in samples:
            if left.apply(sample) != right.apply(sample):
                return False

        return True


# ============================================================
# Konkrete Morphismen
# ============================================================

def enable_debug_morphism() -> RuntimeConfigMorphism:
    return RuntimeConfigMorphism(
        name="enable_debug",
        func=lambda cfg: replace(
            cfg,
            debug=True,
        ),
    )


def disable_debug_morphism() -> RuntimeConfigMorphism:
    return RuntimeConfigMorphism(
        name="disable_debug",
        func=lambda cfg: replace(
            cfg,
            debug=False,
        ),
    )


def enable_audit_morphism() -> RuntimeConfigMorphism:
    return RuntimeConfigMorphism(
        name="enable_audit",
        func=lambda cfg: replace(
            cfg,
            audit=True,
        ),
    )


def set_runtime_mode_morphism(
    mode: str,
) -> RuntimeConfigMorphism:
    allowed = RuntimeConfigCategory.allowed_runtime_modes

    if mode not in allowed:
        raise ValueError(
            f"Ungültiger runtime_mode: {mode}"
        )

    return RuntimeConfigMorphism(
        name=f"set_runtime_mode_{mode}",
        func=lambda cfg: replace(
            cfg,
            runtime_mode=mode,
        ),
    )
```

---

# example_runtime_config_category.py

```python
from category_runtime_config import (
    RuntimeConfig,
    RuntimeConfigCategory,
    enable_debug_morphism,
    disable_debug_morphism,
    enable_audit_morphism,
    set_runtime_mode_morphism,
)


def main() -> None:
    category = RuntimeConfigCategory()

    enable_debug = enable_debug_morphism()
    disable_debug = disable_debug_morphism()
    enable_audit = enable_audit_morphism()
    set_parallel = set_runtime_mode_morphism("parallel")
    set_cached = set_runtime_mode_morphism("cached")

    category.add_morphism(enable_debug)
    category.add_morphism(disable_debug)
    category.add_morphism(enable_audit)
    category.add_morphism(set_parallel)
    category.add_morphism(set_cached)

    start = RuntimeConfig()

    print("Startobjekt:")
    print(start)

    print()
    print("enable_debug:")
    cfg1 = enable_debug.apply(start)
    print(cfg1)

    print()
    print("set_parallel:")
    cfg2 = set_parallel.apply(cfg1)
    print(cfg2)

    print()
    print("enable_audit:")
    cfg3 = enable_audit.apply(cfg2)
    print(cfg3)

    print()
    print("Komposition:")
    composed = category.compose(
        enable_debug,
        set_parallel,
    )

    print(composed.name)
    print(composed.apply(start))

    print()
    print("Dreifache Komposition:")
    full_pipeline = composed.then(enable_audit)

    print(full_pipeline.name)
    print(full_pipeline.apply(start))

    samples = [
        RuntimeConfig(),
        RuntimeConfig(runtime_mode="serial", debug=False, audit=False),
        RuntimeConfig(runtime_mode="parallel", debug=True, audit=False),
        RuntimeConfig(runtime_mode="cached", debug=False, audit=True),
    ]

    print()
    print("Identitätsgesetz für enable_debug:")
    print(
        category.validate_identity_law(
            enable_debug,
            samples,
        )
    )

    print()
    print("Assoziativitätsgesetz:")
    print(
        category.validate_associativity(
            enable_debug,
            set_parallel,
            enable_audit,
            samples,
        )
    )

    print()
    print("Registrierte Morphismen:")
    for name in category.morphisms:
        print("-", name)


if __name__ == "__main__":
    main()
```

---

# Ausgabe

```text
Startobjekt:
RuntimeConfig(runtime_mode='serial', debug=False, audit=False)

enable_debug:
RuntimeConfig(runtime_mode='serial', debug=True, audit=False)

set_parallel:
RuntimeConfig(runtime_mode='parallel', debug=True, audit=False)

enable_audit:
RuntimeConfig(runtime_mode='parallel', debug=True, audit=True)

Komposition:
set_runtime_mode_parallel ∘ enable_debug
RuntimeConfig(runtime_mode='parallel', debug=True, audit=False)

Dreifache Komposition:
enable_audit ∘ set_runtime_mode_parallel ∘ enable_debug
RuntimeConfig(runtime_mode='parallel', debug=True, audit=True)

Identitätsgesetz für enable_debug:
True

Assoziativitätsgesetz:
True

Registrierte Morphismen:
- id_RuntimeConfig
- enable_debug
- disable_debug
- enable_audit
- set_runtime_mode_parallel
- set_runtime_mode_cached
- set_runtime_mode_parallel ∘ enable_debug
```

---

# Was wurde hinzugefügt?

Eine neue mathematische Kategorie:

```text
RuntimeConfigCategory
```

mit:

```text
Objekt:
    RuntimeConfig

Morphismen:
    id_RuntimeConfig
    enable_debug
    disable_debug
    enable_audit
    set_runtime_mode_parallel
    set_runtime_mode_cached
```

---

# Warum ist das eine Kategorie?

Weil sie die wichtigsten Bestandteile besitzt:

## 1. Objekte

```text
RuntimeConfig
```

---

## 2. Morphismen

```text
RuntimeConfig -> RuntimeConfig
```

---

## 3. Identitätsmorphismus

```text
id_RuntimeConfig
```

---

## 4. Komposition

```text
enable_debug
        │
        ▼
set_runtime_mode_parallel
```

ergibt:

```text
set_runtime_mode_parallel ∘ enable_debug
```

---

## 5. Identitätsgesetz

```text
f ∘ id = f
id ∘ f = f
```

wird anhand von Beispielen geprüft.

---

## 6. Assoziativität

```text
h ∘ (g ∘ f) = (h ∘ g) ∘ f
```

wird ebenfalls anhand von Beispielen geprüft.

---

# Architektur-Einordnung in `reta_arch`

```text
RuntimeConfigPresheaf
        │
        ▼
RuntimeConfigSheaf
        │
        ▼
RuntimeConfigCategory
        │
        ▼
RuntimeConfigMorphism
        │
        ▼
ExecutionNetworkCategory
```

Die Kategorie könnte also zwischen Garbe und Execution-Netzwerk stehen.

Sie beschreibt nicht mehr nur:

```text
Welche lokalen Runtime-Daten existieren?
```

sondern:

```text
Welche erlaubten Transformationen globaler Runtime-Konfigurationen gibt es?
```

---

# Warum ist das nützlich?

Weil Runtime-Konfigurationen nicht mehr beliebig verändert werden.

Statt überall im Code:

```python
cfg.debug = True
cfg.runtime_mode = "parallel"
```

gibt es erlaubte Morphismen:

```text
enable_debug

set_runtime_mode_parallel

enable_audit
```

Dadurch wird klar:

```text
Welche Änderungen erlaubt sind

in welcher Reihenfolge sie zusammengesetzt werden können

ob sie die Kategoriegesetze erfüllen
```

Das ist sauberer als freie Mutation.
