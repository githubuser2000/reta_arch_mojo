Chatverlauf (letzte zwei Fragen und Antworten)

Nutzer

Wie lässt sich ein Morphismus hinzufügen?

ChatGPT

In deiner Architektur ist ein Morphismus wesentlich mehr als eine normale Funktion. Er beschreibt eine erlaubte Transformation innerhalb einer Kategorie.

Der einfachste Weg, einen Morphismus hinzuzufügen, besteht aus vier Schritten.

1. Die Quellkategorie festlegen

Beispielsweise:

ParameterCategory

Objekte:

ParameterSet

---

2. Die Zielkategorie festlegen

Bleibt dieselbe Kategorie:

ParameterCategory

Ein Morphismus arbeitet normalerweise innerhalb einer Kategorie.

---

3. Den Morphismus definieren

Beispiel:

class RemoveDefaultParametersMorphism(Morphism):

    source = ParameterCategory
    target = ParameterCategory

    def apply(self, parameter_set):

        ...

---

4. Den Morphismus registrieren

Zum Beispiel:

ParameterCategory.add_morphism(
RemoveDefaultParametersMorphism()
)

---

Beispiel aus "reta"

Aliasauflösung:

class AliasResolutionMorphism(Morphism):

    source = ParameterCategory
    target = ParameterCategory

    def apply(self, parameters):

        resolved = ...

        return resolved

---

Oder Tabellen:

class RemoveEmptyColumnsMorphism(Morphism):

    source = TableSectionCategory
    target = TableSectionCategory

    def apply(self, table):

        ...

---

Oder:

class SortRowsMorphism(Morphism):

    source = TableSectionCategory
    target = TableSectionCategory

    def apply(self, table):

        ...

---

Mathematisch

Ein Morphismus bildet

A

↓

B

ab,

bleibt aber innerhalb derselben Kategorie.

---

Geeignete Morphismen für "reta"

Parameter

↓

Parameter

z.B.

Aliasauflösung

Defaults einsetzen

Parameter filtern

---

Semantik

↓

Semantik

z.B.

Validierung

Normalisierung

Optimierung

---

Tabelle

↓

Tabelle

z.B.

Spalten sortieren

Spalten filtern

Zeilen sortieren

Chunkbildung

---

Output

↓

Output

z.B.

HTML komprimieren

Whitespace entfernen

Farben einsetzen

---

Wann braucht man stattdessen einen Funktor?

Wenn die Kategorie wechselt, z.B.

Parameter

↓

Semantik

oder

Semantik

↓

Tabelle

oder

Tabelle

↓

HTML

dann handelt es sich um Funktoren, nicht um Morphismen.

---

Nutzer

Füge einen beispiel Morphismus hinzu und printe das hier

ChatGPT

Ein einfacher Morphismus innerhalb der "TableSectionCategory":

from dataclasses import dataclass

class Morphism:
"""Basisklasse aller Morphismen."""

    source = None
    target = None

    def apply(self, obj):
        raise NotImplementedError()

class TableSectionCategory:

    objects = []
    morphisms = []

    @classmethod
    def add_morphism(cls, morphism):
        cls.morphisms.append(morphism)

@dataclass
class TableSection:
rows: list[list[str]]

class WhitespaceNormalizationMorphism(Morphism):
"""
Entfernt führende und nachfolgende Leerzeichen
aus jeder Tabellenzelle.
"""

    source = TableSectionCategory
    target = TableSectionCategory

    def apply(self, table: TableSection) -> TableSection:

        normalized = [
            [cell.strip() for cell in row]
            for row in table.rows
        ]

        return TableSection(normalized)

TableSectionCategory.add_morphism(
WhitespaceNormalizationMorphism()
)

table = TableSection(
[
[" Name ", " Alter "],
[" Alice ", " 23 "],
[" Bob ", " 42"],
]
)

morphism = WhitespaceNormalizationMorphism()

new_table = morphism.apply(table)

print("Vorher:")
print(table)

print()

print("Nachher:")
print(new_table)

Ausgabe:

Vorher:

TableSection(
rows=[
[' Name ', ' Alter '],
[' Alice ', ' 23 '],
[' Bob ', ' 42']
]
)

Nachher:

TableSection(
rows=[
['Name', 'Alter'],
['Alice', '23'],
['Bob', '42']
]
)

Warum ist das ein Morphismus?

Die Kategorie bleibt dieselbe:

TableSection
│
▼
WhitespaceNormalizationMorphism
│
▼
TableSection

Es findet kein Kategorienwechsel statt.

Weitere sinnvolle Morphismen für "reta"

- "AliasResolutionMorphism"
- "RemoveEmptyColumnsMorphism"
- "SortColumnsMorphism"
- "SortRowsMorphism"
- "NormalizeCellValuesMorphism"
- "RemoveDuplicateRowsMorphism"
- "ColumnWidthNormalizationMorphism"
- "HtmlEscapingMorphism"

Diese modellieren Transformationen innerhalb ihrer jeweiligen Kategorien.
