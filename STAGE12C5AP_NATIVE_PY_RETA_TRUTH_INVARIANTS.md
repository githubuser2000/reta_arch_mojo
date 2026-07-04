# Stage 12c5ap: native Py-Reta truth invariants

## Ziel

Die zwei bislang unberührten Referenztests
`tests/test_py_reta_truth_matrix.py` und
`tests/test_py_reta_truth_output_invariants.py` werden nicht lediglich als
Python-Tests weitergeführt, sondern durch einen typisierten nativen
Wahrheitsbesitzer ersetzt.

## Behobener Compilerabbruch aus 12c5an/12c5ao

Das Listenliteral in `test_parameter_runtime_complete.mojo` wurde von Mojo als
`List[StringSlice[StaticConstantOrigin]]` inferiert. Der Test deklariert den
öffentlichen API-Vertrag nun ausdrücklich:

```mojo
var tokens: List[String] = [
    "-spalten",
    "--religionen=sternpolygon",
    "-ausgabe",
    "--art=markdown",
]
```

Die Runtime-Signaturen bleiben damit absichtlich streng bei `List[String]`;
es wird kein unsicherer oder duplizierter StringSlice-Adapter eingeführt.

## Neuer nativer Besitzer

`src/reta_mojo/py_reta_truth.mojo` setzt die historischen Wahrheiten aus den
bereits nativen Besitzern zusammen:

- `schema_catalog.mojo` und `parameter_semantics.mojo` liefern die exakten
  Spaltenmengen für `Strukturgrösse` und `Organisationen`;
- `csv_table.mojo` und `resource_paths.mojo` prüfen alle fünf Religion-CSV-
  Aliasnamen mit 746 Kopfspalten und den Endspalten 744/745;
- `tag_schema.mojo` und `tag_schema_catalog.mojo` beweisen die Tagzuordnungen
  der neuen Wahrheitsspalten semantisch.

Die frühere Python-Prüfung suchte Teile davon nur als Zeichenfolgen im
Python-Quelltext. Der native Test ruft stattdessen die tatsächlichen
Laufzeitbesitzer auf und ist damit strenger.

## Prüfung

```sh
./do.sh 12c5ap
```

Die fokussierte Stage baut nach der vollständigen 12c5ao-Kette
`tests/test_py_reta_truth_native.mojo`, regeneriert die Portierungsmatrix und
führt die Ownership-, Metrik-, Defekt- und Archivverträge aus.

## Fortschritt

- vollständig nativ/generiert: **86/92 = 93,5 %**
- mindestens teilweise portiert: **89/92 = 96,7 %**
- angegriffene Referenzzeilen: **46.729/48.831 = 95,7 %**
- native Mojo-Zeilen unter `src/`: **62.068**
