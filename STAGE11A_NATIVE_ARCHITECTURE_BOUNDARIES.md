# Stage 11a – Native Architecture Map and Boundaries

## Ziel

Der erste Stage-11-Block überträgt die bisher rein pythonische Architekturkarte
und den realen Modul-/Importgrenzgraph in getrennte typisierte Mojo-Bundles.
Normale Architekturabfragen benötigen damit keine Python-Laufzeit mehr.

## Native Datenmodelle

`src/reta_mojo/architecture_map.mojo` enthält:

- 11 `ArchitectureCapsuleSpec`
- 34 `CapsuleContainmentSpec`
- 53 `ArchitectureFlowSpec`
- 34 `RetaPartMappingSpec`
- 42 `StageArchitectureStep`
- den vollständigen Markdown-Audit und beide Diagramme

`src/reta_mojo/architecture_boundaries.mojo` enthält:

- 161 `ModuleOwnershipSpec`
- 279 `ImportEdgeSpec`
- 37 `CapsuleImportEdgeSpec`
- 11 `CapsuleBoundarySpec`
- fünf `BoundaryCheckSpec`
- Validierungs-, Plan- und Diagrammdaten

## Regenerationsgrenze

Die Python-Referenz verwendet `ast` und `pathlib`, um den Quellbaum zu scannen.
Dieser Scan bleibt als explizites Erzeugungswerkzeug erhalten:

```bash
python3 tools/generate_architecture_map.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_map.mojo
python3 tools/generate_architecture_boundaries.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_boundaries.mojo
```

Die erzeugten Bundles, Suche, Navigation, Validierungsstatus und Ausgabe laufen
anschließend ausschließlich in Mojo. Die Generatoren wurden mit
`PYTHONHASHSEED=0`, `1`, `42` und `random` byteidentisch geprüft.

## Executable

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-boundaries --summary
./bin/reta-mojo-boundaries --module reta.py
./bin/reta-mojo-boundaries --capsule InputPromptCapsule
./bin/reta-mojo-boundaries --diagram mermaid
```

Kategorienkatalog und Grenzgraph sind absichtlich getrennte schwere Ziele. Das
verhindert einen unnötigen Compiler-Monolithen.

## Tests

- Architekturkarte: 3/3
- Boundary-Graph: 4/4
- Generatorregeneration: byteidentisch
- Hash-Seed-Reproduktion: 4/4 je Generator
- `reta-mojo-boundaries` erfolgreich als ELF gebaut und abgefragt

Kein Test oder Programmaufruf dieser Stage verwendet `--alles`.
