# Stage 10f – native kompakte Promptausführung mit Legacy-Echo

Stage 10f schließt die nächste sichtbare Promptgrenze. Die kompakte Sprache
wurde bereits in Mojo tokenisiert und geplant, aber vollständig ausführbare
Kurzformen mussten in Stage 10e noch Python starten, weil die Referenz vor der
Tabelle eine historische Expansion und gemischt geschriebene `reta`-Optionen
ausgibt. Ausführung und Präsentation sind nun getrennt typisiert.

## Getrennte kanonische und sichtbare Tokens

`prompt_legacy_echo.mojo` erzeugt ausschließlich die historische Anzeige. Der
native Tabellenplan behält seine kanonischen Tokens, während die sichtbare
Befehlszeile unter anderem folgende Referenzschreibweisen erhält:

- `--Menschliches=motivation`
- `--Grundstrukturen=...`
- `--Universum=...`
- `--Galaxie=...`
- `--Planet=...`
- `--Strukturgroesse=...`

Damit können kompakte Befehle bytegleich angekündigt werden, ohne veraltete
Schreibweisen zurück in den typisierten Planner zu speisen.

## Neu vollständig native Kurzformen

Die rendererstabilen Familien `absicht/motiv`, `geist`, `impulse`, `thomas`
und `richtung` laufen als kompakte oder einbuchstabige One-shots ohne
`mojo_bridge.py`. Geprüfte Beispiele sind `a2`, `ap15`, `G2`, `I2`, `t2`,
`r2` sowie `a 2`.

`mulpri` beziehungsweise `p` ist nun ein nativer zusammengesetzter Ablauf:

1. Primfaktorenvergleich bei mehreren Zahlen,
2. Primfaktorzerlegung,
3. nichttriviale Faktorpaare.

Das historische triviale Paar `(n, 1)` wurde aus `multis` entfernt. Für eine
Primzahl bleibt die sichtbare Sonderform wie `13: 13 (Primzahl)` erhalten.

## Bewusst atomare Restgrenze

Nicht jede kompakte Tabellenfamilie darf bereits denselben Fastpfad nehmen.
`bewusstsein`, `emotion`, `universum`, `triebe` und `wirklichkeit` zeigen in
der Python-Referenz noch rendererabhängige Breiten- oder Wrapdetails. Reine
Zahlenkürzel zeigen außerdem historische Zeilenmarkierungen über mehrere
kombinierte Tabellen. Diese Fälle gehen weiterhin als ganze Eingabe an die
Bridge; Stage 10f führt nicht nur einen nativen Teil eines zusammengesetzten
Legacybefehls aus. Der Besitzervertrag prüft jetzt auch jedes weitere
alphabetische Token. Gemischte Kürzel wie `a2s` dürfen deshalb nicht den
Tabellenteil ausführen und dabei einen Speicherbefehl verschlucken.

## Reproduzierbare Parität

Die alte Promptimplementierung exponiert die Reihenfolge eines Python-`set`.
Darum werden Referenzfixtures mit Python 3.13.5 und `PYTHONHASHSEED=0`
erzeugt. Fünf vollständige Ausgaben (`a2`, `ap15`, `p12`, `p13`, `G2`) sind
bytegleich. Der bestehende Vorbereitungstest bestätigt zusätzlich 27/27
deutsche und englische Kurzsprachenkontexte sowie 23/23 vollständige
Vorbereitungskontexte. Die CPython-SipHash-Nachbildung liest UTF-8 als Bytes;
ein eigener Test verhindert damit den früheren Bytegrenzen-Assert bei
`BefehlSpeicherungLöschen`.

Der isolierte One-shot-Test entfernt sowohl `mojo_bridge.py` als auch das
`reta-native`-Kindprogramm aus dem Laufzeitverzeichnis. Neun native
Befehlsklassen bleiben dort ausführbar; rendererempfindliche Kurzformen,
reine Zahlenkürzel und unbekannte rohe Optionen fordern weiterhin nachweislich
die Kompatibilitätsgrenze an.
