# Stage 12c5al – vollständiger nativer Legacy-I18n-Monolith

## Ziel

`python_reference/i18n/words_legacy_monolith.py` bleibt als historische
Referenz erhalten, besitzt aber keinen Python-Laufzeitpfad mehr. Seine gesamte
wirksame öffentliche Oberfläche wird gemeinsam mit den Splitmodulen in den
fünfsprachigen nativen I18n-Katalog aufgenommen.

## Übertragene Oberfläche

- 68 öffentliche Wurzeln auf Deutsch, 70 in den vier übersetzten Varianten;
- acht historische Klassen: `tableHandling`, `concat`, `lib4tables`,
  `retapy`, `nested`, `retaPrompt`, `csvFileNames`, `readMeFileNames`;
- vier Funktionen: `alxp`, `x`, `finde_mehrfache_vorkommen`, `classify`;
- 6.718 beziehungsweise 6.720 Katalogzeilen je Sprache;
- Containerarten, Reihenfolge, Referenzkanten, benannte Tupel und statische
  Klassenattribute bleiben im bestehenden typisierten Baumformat erhalten.

Die Verhaltensfunktionen delegieren auf bereits vorhandene native Besitzer:
Debugausgabe auf `i18n_debug_value`/`i18n_debug_pair`, Duplikaterkennung auf
`duplicate_i18n_strings` und Relationsklassifikation auf
`classify_i18n_relation`.

## Reproduzierbarkeit

`tools/generate_i18n_words_catalog.py` behandelt den alten Monolithen bewusst
anders als die Splitmodule: Da er historisch kein `__all__` besitzt, wird seine
nicht-private wirksame Domänenoberfläche erfasst. Importierte Hilfsmodule und
Typing-Objekte werden verworfen. `PYTHONHASHSEED=0` stabilisiert alte Sets;
absolute Checkoutpfade werden weiterhin portabel normalisiert.

## Lokaler Compilernachweis

```sh
scripts/test_stage12c5al.sh
```

Der Test kompiliert den erweiterten Mojo-Katalogbesitzer, prüft alle acht
Klassen und vier Funktionen und vergleicht anschließend 68.265 native
Katalogzeilen über fünf Sprachen bytegenau mit den generierten Assets.

## Korrektur des lokal gemeldeten 12c5ak-Assetfehlers

Der 12c5ak-Vollbuild war erfolgreich; nur der aktuelle Stage-Test scheiterte,
weil vermeintlich statische Architekturassets noch vier lokale Zustände
beobachteten: `$HOME`, Terminalgeometrie, einen lesbaren Eltern-Gitbaum und
ungetrackte Dateien im Python-Referenzverzeichnis.

Der Generator materialisiert nun ausschließlich die in
`SOURCE_MANIFEST.sha256` und `SOURCE_SYMLINKS.txt` eingetragenen
`python_reference`-Dateien in einem temporären Verzeichnis außerhalb von Git.
Er verwendet dort eine kanonische Home- und Terminalumgebung. Referenzwurzel
und Homeverzeichnis werden als `@@RETA_REFERENCE_ROOT@@` beziehungsweise
`@@RETA_HOME@@` gespeichert und vom nativen Loader erst zur Laufzeit ersetzt.

Der Regressionstest erzeugt absichtlich `.git`, `target`, eine lokale `.alx`-
Datei, ein fremdes `$HOME` und ein Pseudo-TTY. Alle 63 Assets bleiben dabei
bytegleich. Der Befund ist als `TEST-FIXED-042` dokumentiert.

## Portable Prüfung

- 202 Source-Vertragstests bestanden, ein compilerabhängiger Skip;
- 72 fokussierte Stage-/Infrastrukturtests bestanden;
- fünf I18n-Kataloge mit zusammen 68.265 Zeilen bytegleich regeneriert;
- 119 dokumentierte Defekte und 19 spätere Python-Bereinigungspunkte konsistent.
