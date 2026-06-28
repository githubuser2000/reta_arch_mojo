# Testergebnisse – Stufe 5

## Native Tests

```text
24 Testdateien
111 Testfälle
111 bestanden
0 fehlgeschlagen
0 übersprungen
```

Der vollständige Lauf erfolgt mit:

```bash
./scripts/test_all.sh
```

## Buildprüfung

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

Geprüft werden acht ausführbare ELF-64-Dateien unter `target/bin/`. Gleichzeitig wird sichergestellt, dass `bin/` keine kompilierten ELF-Dateien enthält und `target/` in `.gitignore` steht.

## Neue Tabellenparität

- sieben Tagarten
- 19 Primärgruppen
- 478 Primär-Rückabbildungen
- 483 Primärverknüpfungen
- zwei Gruppen im ersten Kombinationsschema
- zwei Gruppen im zweiten Kombinationsschema
- vollständige Vorwärts- und Rückfingerprints
- Tabellenzustand mit Standard- und expliziten Zeilengrenzen
- Unicode-sicheres hartes Wrapping
- `width_for_row` und Breitenbegrenzungen
- Anwendung aller sieben Ausgabe-Modi

Prüfungen:

```bash
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
```

## `multis3`

Die native Dreifach-Faktorisierung wird für alle Werte von 2 bis 256 gegen die Python-Referenz geprüft. Der Test verifiziert:

- Anzahl aller Tripel
- Anzahl je Eingabewert
- vollständigen geordneten Fingerprint
- Sortierung innerhalb jedes Tripels
- Produktgleichheit
- Ausschluss des Faktors 1

```bash
./scripts/check_multis3_parity.sh
```

## Prozess- und HTML-Integration

Erfolgreich geprüft:

- `rpb prim 60`
- `prim24 29`
- `multis 12`
- `multis3 36`
- `modulo 5`
- interaktives, per Pipe gesteuertes `rp`
- Promptspeicher
- direkte `reta`-Weitergabe
- historischer Python-Fallback eines komplexen Kurzbefehls
- Byteparität der Kompatibilitätsausgabe
- Byteparität von `grundStrukHtml`
- Byteparität der `generate_html`-Komposition

```bash
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
```

## Referenzbaseline

Die unveränderte Python-Referenz hatte bereits beim Eingang drei fehlschlagende und einen übersprungenen Test. Diese bekannten Baseline-Abweichungen wurden weder dem Mojo-Port zugerechnet noch verdeckt geändert.
