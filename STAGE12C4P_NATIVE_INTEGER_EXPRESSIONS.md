# Stage 12c4p – sichere native Ganzzahlausdrücke und Generatorbereiche

Die historische Python-Referenz akzeptiert in Zeilenbereichen geklammerte
Ganzzahlausdrücke über `eval`. Der native Launcher hatte diese Syntax bereits
als eigenen Pfad beansprucht, aber Comprehensions wie
`{2*n for n in range(2,5)}` nicht ausgewertet. Dadurch entstand ohne Fehler eine
zu kleine Zeilenauswahl.

Stage 12c4p ersetzt diesen falschen Besitz durch einen sicheren, endlichen
Mojo-Parser. Nativ unterstützt werden:

- Ganzzahlliterale, Klammern sowie unäres `+` und `-`;
- `+`, `-`, `*`, `//`, `%` und nichtnegative `**` mit Python-Semantik;
- Listen-, Mengen- und Tupelanzeigen aus Ganzzahlausdrücken;
- eine gebundene Variable in Comprehensions über `range(stop)`,
  `range(start, stop)` oder `range(start, stop, step)`;
- dieselbe Syntax in additiven/subtraktiven Zeilenbereichen und in
  `--spaltenreihenfolgeundnurdiese`.

Nicht besessen werden Zwischenergebnisse außerhalb ±10^9, beliebiger Python-Code, `/` mit Gleitkommaergebnis,
Funktions-/Attribut-/Indexzugriffe, Bedingungen und verschachtelte
Comprehensions. Solche Argumentvektoren fallen atomar auf die Python-Referenz
zurück, statt unvollständig nativ ausgeführt zu werden.

## Reproduzierbare Prüfungen

```bash
scripts/check_generator_range_parity.sh
```

Sechs deutsche und englische End-to-End-Ströme prüfen Comprehensions,
arithmetische Einzelwerte, negative `range`-Schritte, Subtraktion und
Generator-Spaltenordnung. Die Parserprobe vergleicht 15 sichere Ausdrücke mit
der historischen Python-Mengenbildung und weist acht nicht besessene oder außerhalb der nativen Ganzzahlgrenze liegende Formen
explizit zurück.
