# Stage 12c5am – native retaPrompt facade and generated-column integration

## Ziel

Diese Stage schließt zwei verbliebene dynamische Besitzergrenzen, ohne bereits
native Algorithmen zu duplizieren:

1. die historische Import- und Controllerfassade `retaPrompt.py`,
2. die heterogene `Concat`-Anwendungsgrenze von `generated_columns.py`.

Zusätzlich wird der im lokalen 12c5al-Lauf sichtbar gewordene letzte
Reproduzierbarkeitsfehler des Architektursnapshots geschlossen.

## Korrektur des 12c5al-Assetfehlers

Der 12c5al-Generator isolierte bereits Git, HOME, Terminalzustand und lokale
Dateien. `snapshot-json.json` enthielt jedoch als einzigen nicht separat
materialisierten Abschnitt `parallel_execution`. Dessen physische, logische und
verfügbare Prozessorkernzahlen wurden beim Import aus dem jeweiligen Rechner
erkannt. Deshalb unterschieden sich auf einem anderen Rechner nur
`snapshot-json.json` und infolgedessen `manifest.tsv`.

`tools/generate_architecture_probe_assets.py` importiert die Referenzarchitektur
nun unter einer kanonischen Prozessortopologie von acht Kernen. Vor dem Import
werden `os.cpu_count`, `os.process_cpu_count`, `os.sched_getaffinity` und der
Linux-`/proc/cpuinfo`-Fallback kontrolliert. Bereits geladene
`reta_architecture`-Module werden entfernt, damit kein früher Import die
kanonische Umgebung umgeht.

Ein Regressionstest startet den Generator über ein künstliches
`sitecustomize.py`, das 173, 19 und 17 Kerne meldet. Die 63 Assets bleiben dabei
byteidentisch; der Snapshot enthält weiterhin exakt acht kanonische Kerne.

## Native `retaPrompt.py`-Besitzergrenze

Neu sind:

- `src/reta_mojo/legacy_reta_prompt_catalog.mojo`
- `src/reta_mojo/legacy_reta_prompt.mojo`
- `tools/generate_legacy_reta_prompt_catalog.py`
- `tests/test_legacy_reta_prompt.mojo`
- `tests/test_legacy_reta_prompt_source.py`

Der Generator erfasst die 55 wirksamen öffentlichen Modulnamen in exakter
Python-Reihenfolge. Der native `LegacyRetaPromptBundle` ersetzt die historischen
Importzeit-Globals durch einen expliziten Wert und verbindet sie mit den
bestehenden Besitzern für Startup, Session, Interaktion, Vorbereitung und
Ausführung.

Die beobachtbare Terminal- und Prozess-I/O bleibt ausschließlich bei
`src/prompt_main.mojo`. Die Kompatibilitätsfassade selbst druckt nichts, startet
keinen Kindprozess und besitzt keine Python-Brücke.

## Typisierte Integration von `generated_columns.py`

Neu sind:

- `src/reta_mojo/generated_columns_integration.mojo`
- `tests/test_generated_columns_integration.mojo`
- `tests/test_generated_columns_integration_source.py`

`GeneratedColumnsApplicationRequest` ersetzt das beliebige Python-`Concat`-
Objekt durch neun explizite Felder. `GeneratedColumnsRuntime.apply()` delegiert
den geordneten historischen Ablauf an
`generated_table_columns.apply_native_generated_columns`.

Die eigentlichen Algorithmen bleiben bei ihren vorhandenen Besitzern:

- `generated_columns.mojo`
- `generated_table_columns.mojo`
- `prime_cross_columns.mojo`
- `prime_universe_columns.mojo`
- `meta_columns.mojo`
- `fraction_concat_columns.mojo`

## Prüfvertrag

Der lokale Stage-Test führt in dieser Reihenfolge aus:

1. den vollständigen 12c5al-Asset- und I18n-Vertrag,
2. Regeneration des exakten 55-Namen-`retaPrompt`-Katalogs,
3. nativen `legacy_reta_prompt`-Modultest,
4. nativen `generated_columns_integration`-Modultest,
5. Source-, Eigentums-, Installations-, Defekt- und Archivverträge.

Compilerunabhängig bestanden für diese Stage 211 Source-Vertragstests; ein
compilerabhängiger Test wurde begründet übersprungen. Die fokussierte
Stage-/Infrastrukturgruppe besteht aus 88 Tests.

Der vollständige Modular-Nachweis erfolgt lokal mit:

```sh
./do.sh 12c5am
```
