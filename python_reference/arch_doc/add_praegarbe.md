# Beispiel: Eine neue Prägarbe zu `reta_arch` hinzufügen

Dieses Beispiel fügt eine neue Prägarbe hinzu:

```text
RuntimeConfigPresheaf
```

Sie sammelt **lokale Laufzeit-Konfigurationsdaten**, z. B.:

```text
runtime_mode = serial / parallel / cached
debug = true / false
audit = true / false
```

Eine Prägarbe ist hier:

```text
lokale Sektionen sammeln
```

noch **ohne** daraus schon eine globale Garbe zu machen.

---

# presheaves.py

```python
from dataclasses import dataclass, field
from typing import Any, Dict, Optional


@dataclass(frozen=True)
class LocalSection:
    """
    Eine lokale Sektion.

    Beispiel:
        name  = "runtime"
        scope = "cli"
        data  = {"runtime_mode": "parallel"}
    """

    name: str
    scope: str
    data: Dict[str, Any]


@dataclass
class Presheaf:
    """
    Basisklasse einer Prägarbe.

    Eine Prägarbe sammelt lokale Sektionen.
    Sie prüft noch nicht vollständig, ob alles global konsistent ist.
    """

    sections: Dict[str, LocalSection] = field(default_factory=dict)

    def add_section(self, section: LocalSection) -> None:
        key = f"{section.scope}:{section.name}"
        self.sections[key] = section

    def get_section(self, scope: str, name: str) -> Optional[LocalSection]:
        key = f"{scope}:{name}"
        return self.sections.get(key)

    def restrict(self, scope: str) -> Dict[str, LocalSection]:
        """
        Einschränkung auf einen lokalen Kontext.
        """
        return {
            key: section
            for key, section in self.sections.items()
            if section.scope == scope
        }


@dataclass
class RuntimeConfigPresheaf(Presheaf):
    """
    Neue Prägarbe für lokale Laufzeit-Konfigurationen.

    Sie sammelt z. B.:
        - CLI-Konfiguration
        - Umgebungsvariablen
        - Debug-Konfiguration
        - Audit-Konfiguration
    """

    def add_runtime_mode(
        self,
        scope: str,
        runtime_mode: str,
    ) -> None:
        self.add_section(
            LocalSection(
                name="runtime_mode",
                scope=scope,
                data={
                    "runtime_mode": runtime_mode,
                },
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
                data={
                    "debug": enabled,
                },
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
                data={
                    "audit": enabled,
                },
            )
        )


@dataclass
class PresheafBundle:
    """
    Bündel aller Prägarben.
    """

    runtime_config: RuntimeConfigPresheaf = field(
        default_factory=RuntimeConfigPresheaf
    )
```

---

# category_theory.py

```python
class Category:
    """
    Minimale Basisklasse für Kategorien.
    """

    objects = set()
    morphisms = set()


class LocalSectionCategory(Category):
    """
    Kategorie lokaler Sektionen / Prägarben.

    Objekte:
        LocalSection
        Presheaf
        RuntimeConfigPresheaf

    Morphismen:
        add_section
        restrict
    """

    objects = {
        "LocalSection",
        "Presheaf",
        "RuntimeConfigPresheaf",
    }

    morphisms = {
        "add_section",
        "restrict",
    }
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


class RuntimeConfigRestrictionMorphism(Morphism):
    """
    Morphismus innerhalb
```
