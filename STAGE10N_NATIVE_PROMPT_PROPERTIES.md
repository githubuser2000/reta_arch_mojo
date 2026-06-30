# Stage 10n – native Prompt-Eigenschaften EIGN/EIGR

Stage 10n übernimmt die beiden dynamisch gebildeten Eigenschaftsfamilien
`EIGN…` und `EIGR…` aus dem hinteren Teil von
`reta_architecture/prompt_execution.py`. Damit werden alle **165** im deutschen
Promptkatalog veröffentlichten Eigenschaftsbefehle vor dem Python-Import
geplant und im nativen Tabellenkern ausgeführt.

## Eigener typisierter Planer

`src/reta_mojo/prompt_property_execution.mojo` trennt die beiden historischen
Achsen explizit:

- `EIGN<name>` erzeugt `--konzept=<name>` und verwendet die normale
  Ganzzahl-/Ganzzahlbruch-Achse.
- `EIGR<name>` erzeugt `--konzept2=<name>` und verwendet für `1/n` die
  reziproke Achse.
- Bei einer zusätzlichen Ganzzahl bewahrt `EIGR` die ungewöhnliche zweite
  `-zeilen`-Sektion des Originals hinter dem Ausgabeabschnitt.
- Ein echter positiver Bruch `n/m` ohne ganzzahlige oder reziproke Projektion
  wird erkannt, erzeugt aber wie die Referenz keine Tabelle.
- Die nackten Präfixe `EIGN` und `EIGR` ohne Eigenschaftsnamen bleiben an
  der Kompatibilitätsgrenze. Die Referenz erzeugt dort eine Diagnose bzw. läuft
  in den bekannten `deepcopy(module)`-Defekt; Stage 10n beansprucht diese
  fehlerhaften Randfälle daher nicht nativ.

Beispiele der geplanten Argumentverträge:

```text
EIGNgut 2
→ -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025
  -spalten --konzept=gut --breite=0 -ausgabe

EIGRwerte 1/2
→ -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025
  -spalten --konzept2=werte --breite=0 -ausgabe

EIGRwerte 2
→ -zeilen --vorhervonausschnitt=0
  -spalten --konzept2=werte --breite=0 -ausgabe
  -zeilen --vorhervonausschnitt=2 --oberesmaximum=1025
```

## CPython-Mengenreihenfolge

Das Original wandelt den **gesamten** Promptbefehl in eine Menge um und filtert
erst danach die `EIGN`-/`EIGR`-Präfixe. Deshalb darf nicht nur die bereits
gefilterte Eigenschaftsliste sortiert werden. Der native Planer wendet die
vorhandene CPython-3.13-Set-Nachbildung auf sämtliche Tokens an und extrahiert
erst anschließend die Suffixe. So bleibt beispielsweise

```text
EIGNgut EIGNehrlich 2 → --konzept=ehrlich,gut
```

reproduzierbar erhalten.

## Defekter EIGR-Referenzwrapper

Die aktuelle Python-Promptstrecke bricht bei `EIGR` vor dem Tabellenaufruf in
`copy.deepcopy(Txt)` mit `TypeError: cannot pickle 'module' object` ab. Der
beabsichtigte Argumentvektor ist im unmittelbar folgenden Referenzcode dennoch
eindeutig und funktioniert über `reta.py` vollständig. Stage 10n übernimmt
diesen expliziten Vertrag, statt den vorgeschalteten `deepcopy`-Defekt zu
imitieren. Die Tabellenparität wird deshalb für `EIGR` gegen den direkten
Python-CLI-Aufruf geprüft.

## Native Besitzgrenze

Der Einmalpfad erkennt Eigenschaftsbefehle bereits in
`prompt_table_execution.mojo`. Vollständig besessene EIGN-/EIGR-Befehle werden
vor `Python.import_module("mojo_bridge")` ausgeführt. Ein isolierter Test stellt
nur `assets/` und die CSV-Daten bereit; weder Python-Module noch ein
`reta-native`-Kindprozess sind vorhanden.

## Verifikation

- `test_prompt_property_execution.mojo`: **6/6** bestanden,
- fokussierte Planerintegration: **23** Vertragsprüfungen bestanden,
- vollständiger deutscher Katalog: **165/165** EIGN-/EIGR-Befehle besitzen
  einen nativen Plan,
- Python↔Mojo-Tabellenparität: **5/5** geordnete, whitespace-normalisierte
  CSV-Zellströme identisch,
- EIGN-Promptnutzlasten: **2/2** gegen den funktionsfähigen Python-Prompt
  semantisch identisch,
- isolierter nativer One-shot-Besitztest: **6/6** bestanden,
- der funktional integrierte `reta-prompt-native`-Controller wurde erfolgreich
  gebaut und in den One-shot- sowie Paritätstests verwendet,
- der erneute Monolithbuild nach der rein kostenbezogenen
  Ein-Set-Reihenfolge-Optimierung erreichte nach 30 Minuten die
  Mojo-Compilergrenze ohne Diagnose; die endgültige Eigenschaftsquelle selbst
  kompiliert in den Unit- und Integrationszielen.

Die Roh-CSV-Serialisierung unterscheidet sich weiterhin in bereits bekannten
präsentationsbedingten Leerzeichen und Leerzeilen. Stage 10n beansprucht daher
für diese fünf Referenzfälle Zellstrom-, nicht Rohbyte-Parität.

**Es wurde kein Test und kein Lauf mit `--alles` ausgeführt.** Dieser Pfad ist
bewusst vollständig von der Stage-10n-Verifikation ausgeschlossen.
