# Stage 12c5fm: reta top-level native completion

Diese Stage schließt den historischen Top-Level-Einstieg `reta.py` als nativen
Besitzer ab.  Der Schritt ist kein weiterer Prompt-Mikro-Gate-Umbau, sondern
ein Porting-Matrix-Abschluss für die zweite der drei zuletzt offenen Dateien.

## Neuer nativer Abschlussbeweis

`src/reta_mojo/legacy_reta_program.mojo` enthält nun:

- `LegacyRetaProgramNativeCompletionPlan`
- `plan_legacy_reta_program_native_completion`
- `legacy_reta_program_native_completion_valid`

Der Witness friert den Vertrag ein:

- Quelle: `reta.py`
- Status: `nativ`
- 214 Referenzzeilen
- 27 öffentliche Namen
- 18 historische Program-Methoden
- 10 Owner-Snapshot-Einträge
- native Startup-/Sprach-/Hilfe-/Debug-/Nichts-Kontrollen
- nativer Tabellenkern und nativer Workflow
- injizierbare Parallelumgebung
- explizite atomare Kindprozess-Kompatibilitätsgrenze für unbewiesene
  Legacy-Vektoren
- keine eingebettete CPython-Laufzeit

## Porting-Metrik

`reta.py` wird in `tools/generate_porting_matrix.py` von `teilweise nativ` auf
`nativ` hochgestuft.  Damit steigt die Vollständig-Metrik von 90/92 auf 91/92.

Die letzte verbleibende unvollständige Datei ist danach:

- `reta_architecture/prompt_execution.py`

## Prüfumfang

Die Stage baut lokal die historischen `legacy_reta_program`-Tests sowie
Architekturprogress/-boundaries und ergänzt Source-Guards für Matrix,
Exports und Witness.
