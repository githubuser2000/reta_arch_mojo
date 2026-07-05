# Stage 12c5bg – deterministische Kommandoassets und Ganzzahlachsen neben Bruchvielfachen

## Zwei Befunde aus dem Benutzerlauf

Der vollständige native Build von Stage 12c5bf war erfolgreich. Die historische
Stage-Kette erreichte anschließend `test_stage12c5aq.sh`, wo ausschließlich die
Markdown- und HTML-Assets des repräsentativen Kommandokatalogs abwichen. Die
beiden Shell-Assets blieben identisch. Ursache war keine fachliche Änderung der
Tabelle, sondern die optionale `rich`-Installation des jeweils gewählten
Test-Python: `console_io.py` rendert Markdown/HTML über `rich.syntax.Syntax`,
dessen Ausgabe zwischen Rich-Versionen nicht als eingefrorenes Dateiformat
garantiert ist.

Gleichzeitig war seit Stage 12c5bf noch eine echte Promptlücke ausdrücklich
offen: positive gewöhnliche Ganzzahlachsen neben korrigierten echten
Bruchvielfachen. Der Ein- und Mehrdomänenfall musste bisher entweder
zurückfallen oder verlor die Bedeutung von `--vielfachevonzahlen`.

## Kanonische Referenzlaufzeit für Kommandoassets

`tools/generate_command_parity_assets.py` setzt für seinen eingefrorenen
Python-Referenzprozess nun einen kleinen lokalen `rich`-Kompatibilitätsadapter
vor alle installierten Site-Packages. Dieser Adapter besitzt genau die drei vom
Referenzbaum verwendeten Oberflächen:

- `rich.console.Console`;
- `rich.markdown.Markdown`;
- `rich.syntax.Syntax`.

Er verändert weder Referenzquellen noch Tabelleninhalt. Er neutralisiert nur
die optionale Präsentationsbibliothek und reproduziert die bereits
versionierten vier Asset-Hashes. `PYTHONNOUSERSITE=1` verhindert zusätzliche
Benutzerpakete; ein absichtlich defektes fremdes `rich` im aufrufenden
`PYTHONPATH` darf den Katalog nicht mehr beeinflussen. Bei einer echten
Abweichung meldet der Generator nun Ist- und Soll-SHA-256 statt nur Dateinamen.

## Positive Ganzzahlachsen neben `v n/m`

Für einen Befehl wie

```text
universum motive v2/3,5
```

sind drei Zeilengruppen unabhängig zu bewahren:

1. ganzzahlige Projektionen des domänenspezifischen Bruchrasters;
2. die ursprüngliche positive Ganzzahl- oder Bereichsschreibweise;
3. dieselbe Schreibweise mit historischem `v`-Präfix.

Nur die zweite Gruppe speist `--vielfachevonzahlen`. Würden die aus dem
Bruchraster projizierten Ganzzahlen ebenfalls in diese Option gelegt, würden
sie ein zweites Mal und fachlich falsch vervielfacht. Der neue typisierte
Basiserzeuger `_base_projected_fraction_multiple_tokens` hält diese Rollen
getrennt.

Beispiele des neuen nativen Besitzes:

- `universum v2/3,5`: 13 Aufrufe;
- `universum motive v2/3,5`: 26 Aufrufe;
- `emotion universum v8/3,5`: leere Ganzzahlprojektionen behalten trotzdem
  die gewöhnliche `5,v5`-Achse;
- `emotion universum v1/2,2/3,5`: domänenspezifische Reziprok-, Bruch- und
  Ganzzahlachsen;
- `universum motive v2/3,5-7`: die Quellschreibweise `5-7` und `v5-7` bleibt
  erhalten;
- `teiler`/`w`: die sichtbare Zeilenreihenfolge bleibt, aber
  `--vielfachevonzahlen` wird wie in der Referenz nicht weitergereicht.

## Bewusst verbleibende Grenze

Diese Stage besitzt nur strikt positive gewöhnliche Ganzzahlkomponenten. Null,
in-token Ausschlüsse und separat geschriebene negative Parameter bleiben als
gesamter Vektor am Fallback:

```text
universum motive v2/3,0
universum motive v2/3,5,-10
universum motive v2/3 -10
```

Die eingefrorene Python-Referenz hat für diese Formen eine andere, teilweise
widersprüchliche Algebra. Sie wird erst übernommen, wenn ein eigener
Korrektheitsvertrag für Null und Ausschlussachsen vorliegt.

## Portable Prüfung

- alle Source-Testmodule: **304 bestanden, 1 compilerabhängiger Skip**;
- fokussierte Stage-/Prompt-/Defekt-/Metrikgruppe: **91 bestanden**;
- zusätzliche Build-, Installations-, Manifest- und Fail-fast-Verträge: **87 bestanden**;
- ursprüngliche Python-Kommandomatrix: **1 Test mit 4 Subtests bestanden**;
- Kommandoassets vor Generierung, nach Generierung und unter einem absichtlich
  defekten fremden `rich`: identischer Gesamthash;
- Defektledger: **131** Befunde, **20** spätere Python-Aufräumpunkte;
- Portierungsmetriken: **89/92** vollständig nativ/generiert, **92/92**
  mindestens teilweise, **48.831/48.831** Referenzzeilen angegriffen.

Die Erstellungsumgebung führt weiterhin keine Mojo-/Native-Kompilierung aus.

## Benutzerprüfung

Nur diese Stage auf einer bereits bestätigten 12c5bf-Arbeitskopie:

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bg.sh
```

Mit der vollständigen historischen Stage-Kette:

```bash
scripts/test_stage12c5bg.sh
```

Danach:

```bash
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
