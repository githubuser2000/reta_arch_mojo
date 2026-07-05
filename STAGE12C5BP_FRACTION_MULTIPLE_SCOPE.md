# Stage 12c5bp – historischer Zwischenstand des Bruchvielfachen-Geltungsbereichs

> **Korrigiert durch Stage 12c5bq.** Die ursprüngliche Annahme dieser Stage,
> ein an die erste Bruchkomponente angeheftetes `v` gelte für die gesamte
> Kommaliste, entspricht nicht dem Python-Code.

## Was 12c5bp aufdeckte

Der Laufzeitprüfer erreichte nach der 12c5bo-Korrektur erstmals den
positive-First-Kollisionszweig. Dabei wurde sichtbar, dass lokale und globale
Vielfachenschreibweisen im Mojo-Parser nicht ausdrücklich getrennt waren.

Die zunächst implementierte Vererbung eines führenden kompakten `v` auf alle
Kommakomponenten war jedoch zu weit. Die Referenzsemantik lautet:

- `v1/4,-1/8,2/3`: `v` gehört nur zu `1/4`;
- `1/4,v-1/8,v2/3`: jedes Präfix gehört nur zu seiner Komponente;
- `v 1/4,-1/8,2/3` oder `vielfache 1/4,-1/8,2/3`: globaler Modus für alle
  Komponenten;
- das eigenständige `v` darf in der vollständigen Befehlswortliste an jeder
  Position stehen.

## Endgültiger Vertrag

Die korrigierte Implementierung und sämtliche aktuellen Laufzeitverträge sind
in [`STAGE12C5BQ_POSITION_INDEPENDENT_MULTIPLE_SCOPE.md`](STAGE12C5BQ_POSITION_INDEPENDENT_MULTIPLE_SCOPE.md)
beschrieben. `MOJO-FIXED-067` erfasst den in 12c5bp entstandenen zu weiten
Geltungsbereich und dessen Korrektur.
