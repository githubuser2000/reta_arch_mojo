# Generatorbereich-Referenzströme

Diese sechs Dateien frieren die beobachtbare Python-Semantik der dokumentierten
arithmetischen Bereichssyntax ein: sichere Ganzzahlrechnungen, eine
Comprehension über `range`, subtraktive Mengen, negative Schrittweiten und die
gleiche Syntax in `--spaltenreihenfolgeundnurdiese`.

Regeneration:

```sh
RETA_REFRESH_GENERATOR_RANGE_FIXTURES=1 \
RETA_GENERATOR_RANGE_FIXTURES_ONLY=1 \
./scripts/check_generator_range_parity.sh
```

Die normale Prüfung startet direkt `reta-native`; ein Python-Kindprozess kann
die Bytegleichheit daher nicht vortäuschen.
