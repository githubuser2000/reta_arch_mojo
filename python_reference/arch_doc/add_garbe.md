# Beispiel: Eine neue Garbe zu `reta_arch` hinzufügen

Dieses Beispiel ergänzt zur vorherigen Prägarbe

```text
RuntimeConfigPresheaf
```

eine passende Garbe:

```text
RuntimeConfigSheaf
```

Die Prägarbe sammelt lokale Sektionen:

```text
cli
env
config-file
defaults
```

Die Garbe klebt daraus eine **globale, kanonische Runtime-Konfiguration**.

---

# Ziel

Aus mehreren lokalen Quellen:

```text
defaults: runtime_mode = serial
env:      audit = true
cli:      runtime_mode = parallel
cli:      debug = true
```

wird eine globale Runtime-Konfiguration:

```text
runtime_mode = parallel
debug        = true
audit        = true
```

Dabei gilt die Priorität:

```text
cli > env > config-file > defaults
```

---

# sheaves.py

```python
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, Optional


@dataclass(frozen=True)
class LocalSection:
    """
    Lokale Sektion einer Prägarbe.

    Beispiel:
        scope = "cli"
        name  = "runtime_mode"
        data  = {"runtime_mode": "parallel"}
    """

    name: str
    scope: str
    data: Dict[str, Any]


@dataclass
class RuntimeConfigPresheaf:
    """
    Prägarbe: sammelt lokale Runtime-Konfigurationssektionen.

    Sie entscheidet noch nicht endgültig,
    welche Quelle gewinnt.
    """

    sections: Dict[str, LocalSection] = field(default_factory=dict)

    def add_section(self, section: LocalSection) -> None:
        key = f"{section.scope}:{section.name}"
        self.sections[key] = section

    def add_runtime_mode(
        self,
        scope: str,
        runtime_mode: str,
    ) -> None:
        self.add_section(
            LocalSection(
                name="runtime_mode",
                scope=scope,
                data={"runtime_mode": runtime_mode},
            )
        )

    def add_debug_mode(
        self,
        scope: str,
        enabled: bool,
    ) -> None:
        self.add_section(
            LocalSection(
                name="debug",
                scope=scope,
                data={"debug": enabled},
            )
        )

    def add_audit_mode(
        self,
        scope: str,
        enabled: bool,
    ) -> None:
        self.add_section(
            LocalSection(
                name="audit",
                scope=scope,
                data={"audit": enabled},
            )
        )

    def restrict(self, scope: str) -> Dict[str, LocalSection]:
        """
        Prägarben-Einschränkung auf einen lokalen Scope.
        """
        return {
            key: section
            for key, section in self.sections.items()
            if section.scope == scope
        }


@dataclass(frozen=True)
class RuntimeConfig:
    """
    Globale, kanonische Runtime-Konfiguration.
    """

    runtime_mode: str = "serial"
    debug: bool = False
    audit: bool = False


@dataclass
class RuntimeConfigSheaf:
    """
    Garbe: klebt lokale Runtime-Konfigurationssektionen
    zu einer globalen RuntimeConfig.

    Garbenidee:
        lokale Sektionen
            ↓
        Verträglichkeit / Priorität
            ↓
        globale Sektion
    """

    priority: tuple[str, ...] = (
        "defaults",
        "config-file",
        "env",
        "cli",
    )

    allowed_runtime_modes: frozenset[str] = frozenset(
        {
            "serial",
            "parallel",
            "cached",
            "debug",
            "audit",
            "benchmark",
        }
    )

    def compatible(
        self,
        presheaf: RuntimeConfigPresheaf,
    ) -> bool:
        """
        Verträglichkeitsprüfung.

        In diesem einfachen Beispiel heißt verträglich:
        - runtime_mode muss ein erlaubter Wert sein
        - debug muss bool sein
        - audit muss bool sein
        """

        for section in presheaf.sections.values():
            if section.name == "runtime_mode":
                value = section.data.get("runtime_mode")
                if value not in self.allowed_runtime_modes:
                    return False

            elif section.name == "debug":
                value = section.data.get("debug")
                if not isinstance(value, bool):
                    return False

            elif section.name == "audit":
                value = section.data.get("audit")
                if not isinstance(value, bool):
                    return False

        return True

    def glue(
        self,
        presheaf: RuntimeConfigPresheaf,
    ) -> RuntimeConfig:
        """
        Klebt lokale Sektionen zu einer globalen Konfiguration.

        Priorität:
            cli > env > config-file > defaults

        Technisch:
            Wir laufen von niedriger zu hoher Priorität.
            Höhere Priorität überschreibt niedrigere.
        """

        if not self.compatible(presheaf):
            raise ValueError(
                "RuntimeConfigPresheaf enthält unverträgliche Sektionen"
            )

        merged: Dict[str, Any] = {
            "runtime_mode": "serial",
            "debug": False,
            "audit": False,
        }

        priority_index = {
            scope: index
            for index, scope in enumerate(self.priority)
        }

        ordered_sections = sorted(
            presheaf.sections.values(),
            key=lambda section: priority_index.get(section.scope, -1),
        )

        for section in ordered_sections:
            if section.name == "runtime_mode":
                merged["runtime_mode"] = section.data["runtime_mode"]

            elif section.name == "debug":
                merged["debug"] = section.data["debug"]

            elif section.name == "audit":
                merged["audit"] = section.data["audit"]

        return RuntimeConfig(
            runtime_mode=merged["runtime_mode"],
            debug=merged["debug"],
            audit=merged["audit"],
        )

    def restrict(
        self,
        global_config: RuntimeConfig,
        names: Iterable[str],
    ) -> Dict[str, Any]:
        """
        Einschränkung einer globalen Sektion auf bestimmte Felder.

        Beispiel:
            globale RuntimeConfig
                ↓
            nur {"runtime_mode", "debug"}
        """

        result: Dict[str, Any] = {}

        for name in names:
            if not hasattr(global_config, name):
                raise KeyError(name)

            result[name] = getattr(global_config, name)

        return result


@dataclass
class SheafBundle:
    """
    Bündel aller Garben.
    """

    runtime_config: RuntimeConfigSheaf = field(
        default_factory=RuntimeConfigSheaf
    )
```

---

# morphisms.py

```python
class Morphism:
    """
    Minimale Basisklasse für Morphismen.
    """

    source = None
    target = None

    def apply(self, obj):
        raise NotImplementedError()


class RuntimeConfigGluingMorphism(Morphism):
    """
    Morphismus:
        RuntimeConfigPresheaf
            ↓
        RuntimeConfig

    Er verwendet die RuntimeConfigSheaf zum Gluing.
    """

    source = "RuntimeConfigPresheaf"
    target = "RuntimeConfig"

    def __init__(self, sheaf):
        self.sheaf = sheaf

    def apply(self, presheaf):
        return self.sheaf.glue(presheaf)


class RuntimeConfigRestrictionMorphism(Morphism):
    """
    Morphismus:
        RuntimeConfig
            ↓
        Teilkonfiguration
    """

    source = "RuntimeConfig"
    target = "RuntimeConfigSection"

    def __init__(self, sheaf):
        self.sheaf = sheaf

    def apply(self, global_config, names):
        return self.sheaf.restrict(global_config, names)
```

---

# category_theory.py

```python
class Category:
    """
    Minimale Kategorie.
    """

    objects = set()
    morphisms = set()


class LocalSectionCategory(Category):
    """
    Kategorie lokaler Sektionen / Prägarben.
    """

    objects = {
        "LocalSection",
        "RuntimeConfigPresheaf",
    }

    morphisms = {
        "add_section",
        "restrict",
    }


class RuntimeConfigSheafCategory(Category):
    """
    Kategorie der global geklebten Runtime-Konfigurationen.
    """

    objects = {
        "RuntimeConfig",
        "RuntimeConfigSheaf",
    }

    morphisms = {
        "glue",
        "restrict",
    }
```

---

# functors.py

```python
class Functor:
    """
    Minimale Basisklasse für Funktoren.
    """

    source = None
    target = None


class RuntimeConfigSheafificationFunctor(Functor):
    """
    Funktor:
        LocalSectionCategory
            ↓
        RuntimeConfigSheafCategory

    Er macht aus lokalen Runtime-Sektionen
    eine globale Runtime-Konfiguration.
    """

    source = "LocalSectionCategory"
    target = "RuntimeConfigSheafCategory"

    def __init__(self, sheaf):
        self.sheaf = sheaf

    def map_object(self, presheaf):
        return self.sheaf.glue(presheaf)
```

---

# natural_transformations.py

```python
class NaturalTransformation:
    """
    Minimale Basisklasse für natürliche Transformationen.
    """

    source = None
    target = None


class RuntimeConfigSheafificationNaturality(
    NaturalTransformation
):
    """
    Natürliche Transformation:

    Direkte Runtime-Konfiguration
        ≙
    Prägarbe + Gluing zur RuntimeConfigSheaf

    Bedeutung:
        Egal, ob Runtime-Konfiguration direkt erzeugt
        oder aus lokalen Sektionen geklebt wird,
        die globale Semantik muss gleich sein.
    """

    source = "DirectRuntimeConfigFunctor"
    target = "RuntimeConfigSheafificationFunctor"
```

---

# example_runtime_config_sheaf.py

```python
from sheaves import (
    RuntimeConfigPresheaf,
    RuntimeConfigSheaf,
    SheafBundle,
)

from morphisms import (
    RuntimeConfigGluingMorphism,
    RuntimeConfigRestrictionMorphism,
)


def main() -> None:
    presheaf = RuntimeConfigPresheaf()

    # Niedrigste Priorität
    presheaf.add_runtime_mode(
        scope="defaults",
        runtime_mode="serial",
    )

    # Mittlere Priorität
    presheaf.add_audit_mode(
        scope="env",
        enabled=True,
    )

    # Höchste Priorität
    presheaf.add_runtime_mode(
        scope="cli",
        runtime_mode="parallel",
    )

    presheaf.add_debug_mode(
        scope="cli",
        enabled=True,
    )

    print("Lokale Sektionen der Prägarbe:")
    for key, section in presheaf.sections.items():
        print(key, "=>", section)

    sheaf = RuntimeConfigSheaf()

    print()
    print("Verträglich?")
    print(sheaf.compatible(presheaf))

    glue = RuntimeConfigGluingMorphism(sheaf)
    global_config = glue.apply(presheaf)

    print()
    print("Globale RuntimeConfig nach Gluing:")
    print(global_config)

    restrict = RuntimeConfigRestrictionMorphism(sheaf)

    print()
    print("Einschränkung auf runtime_mode und debug:")
    print(
        restrict.apply(
            global_config,
            names={"runtime_mode", "debug"},
        )
    )

    print()
    print("SheafBundle:")
    bundle = SheafBundle(
        runtime_config=sheaf,
    )
    print(bundle)


if __name__ == "__main__":
    main()
```

---

# Ausgabe

```text
Lokale Sektionen der Prägarbe:
defaults:runtime_mode => LocalSection(name='runtime_mode', scope='defaults', data={'runtime_mode': 'serial'})
env:audit => LocalSection(name='audit', scope='env', data={'audit': True})
cli:runtime_mode => LocalSection(name='runtime_mode', scope='cli', data={'runtime_mode': 'parallel'})
cli:debug => LocalSection(name='debug', scope='cli', data={'debug': True})

Verträglich?
True

Globale RuntimeConfig nach Gluing:
RuntimeConfig(runtime_mode='parallel', debug=True, audit=True)

Einschränkung auf runtime_mode und debug:
{'runtime_mode': 'parallel', 'debug': True}

SheafBundle:
SheafBundle(runtime_config=RuntimeConfigSheaf(priority=('defaults', 'config-file', 'env', 'cli'), allowed_runtime_modes=frozenset({'serial', 'parallel', 'cached', 'debug', 'audit', 'benchmark'})))
```

---

# Was wurde hinzugefügt?

```text
RuntimeConfigSheaf
```

als neue Garbe.

Sie ergänzt die vorherige Prägarbe:

```text
RuntimeConfigPresheaf
```

---

# Architektur-Einordnung

```text
lokale Runtime-Konfigurationen
        │
        ▼
RuntimeConfigPresheaf
        │
        ▼
RuntimeConfigSheafificationFunctor
        │
        ▼
RuntimeConfigSheaf
        │
        ▼
RuntimeConfigGluingMorphism
        │
        ▼
globale RuntimeConfig
```

---

# Warum ist das eine Garbe?

Weil sie aus lokalen Sektionen:

```text
defaults
env
cli
config-file
```

eine globale Sektion erzeugt:

```text
RuntimeConfig(runtime_mode='parallel', debug=True, audit=True)
```

Sie besitzt außerdem:

1. **lokale Sektionen**
2. **Verträglichkeitsprüfung**
3. **Gluing**
4. **globale Sektion**
5. **Restriction einer globalen Sektion**

Damit ist sie näher an einer mathematischen Garbe als eine reine Hilfsfunktion.

---

# Was wäre noch nötig für eine vollständig mathematische Garbe?

Noch fehlen echte offene Mengen und vollständige Überdeckungen:

```text
OpenSet
ContextCover
Intersection
RestrictionMap
```

Außerdem müsste man formal prüfen:

```text
Existenz des Gluings

Eindeutigkeit des Gluings

Verträglichkeit auf Überlappungen
```

Für die Architektur von `reta_arch` reicht diese Version aber bereits als sinnvolle, ausführbare Garben-Schicht.
