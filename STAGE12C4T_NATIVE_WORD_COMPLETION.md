# Stage 12c4t – native Wortvervollständigung und Unicode-Defektbeleg

Stage 12c4t portiert die deterministische Laufzeit von
`reta_architecture/completion_word.py` sowie die historische Fassade
`libs/word_completerAlx.py` nach Mojo.

## Nativer Besitz

`src/reta_mojo/completion_word.mojo` besitzt nun:

- den Stage-40-Morphismusvertrag mit Legacy-Besitzer und Aktivierungsstufe;
- die Wortsektion als besitzende `List[String]` sowie erneuerbare native Wortquellen;
- Dokumenteinschränkung über einen expliziten UTF-8-Bytecursor;
- normale Wort-, `WORD`- und Satzvervollständigung;
- Groß-/Kleinschreibungsignorierung und historische Middle-Match-Semantik;
- Unicode-skalare `start_position`-Werte statt fehlerhafter Byteanzahlen;
- Anzeige- und Metadatenersetzung über typisierte Dekorationen;
- einen besitzenden `ArchitectureWordCompleter` mit demselben `WORD`-/Satz-Ausschluss wie das Original;
- einen expliziten Präfixadapter, an den native Regex- oder Domänenmatcher ihre Restriktion übergeben;
- den vollständigen Stage-40-Snapshot mit Morphismus- und Kompatibilitätsnamen;
- stabile Eingabereihenfolge ohne Python-Objekte oder `prompt_toolkit`.

Der native interaktive Prompt hatte bereits eine stärkere verschachtelte
Completion. Diese Stufe schließt zusätzlich den bisher nur indirekt abgedeckten
allgemeinen `WordCompleter`-Baustein und dessen Architektur-Morphismus.

## Exakte historische Match-Semantik

Die Python-Funktion vergleicht nicht schlicht `word.startswith(prefix)`,
sondern schneidet den Präfix zunächst auf die Länge des Kandidaten. Dadurch
bleibt beispielsweise `word_completion_matches("reta", "reta-extra")` wahr.
Mojo reproduziert dies codepunkt- statt bytebasiert, damit mehrbyteige Zeichen
keine falschen Schnittpositionen erzeugen.

## Neu katalogisierter Python-Kandidat

Die aktive Python-Laufzeit delegiert die Standard-Wortgrenze an
`prompt_toolkit.Document.get_word_before_cursor()`. Dessen voreingestellter
Regulärausdruck trennt ASCII-Wortzeichen von allen anderen Nicht-Leerzeichen.
Daher wird aus `grö` nur `ö` als aktuelles Wort gelesen und der Kandidat
`größe` nicht angeboten. Dasselbe betrifft viele gemischt lateinisch-
Unicode geschriebene Wörter.

Mojo bewahrt dieses Verhalten vorerst bytegleich, damit die Transpilierung
keine stille Oberflächenänderung einführt. Der Befund ist als `PY-CAND-007` im
zentralen Fehlerkatalog erfasst. Nach Abschluss des Ports sollte Python auf
eine explizite Unicode-Wortgrenze umgestellt und Mojo gemeinsam auf den neuen
Sollvertrag migriert werden.

## Prüfungen

```text
native Completion-Unit-Tests:          5/5
Python↔Mojo-Paritätsdatensätze:       10/10 byteidentisch
Python-Unicode-Defektreproduktion:     1/1
Fehlerkatalog:                        37/37 konsistent
spätere Python-/PyPy3-Arbeitspunkte:     13
aktive std.python-Brücken:                0
Quellmanifest:                       1065/1065
regulärer Gesamtbuild:   3 Ziele neu erzeugt; Umgebungs-Timeout beim 4. Ziel
```


Der reguläre `scripts/build.sh`-Lauf wurde zweimal geprüft. In beiden Läufen
kompilierten `reta-mojo-native`, `reta-mojo-table` und `reta-mojo-tags` ohne
Fehler; die stark verlangsamte Sandbox erreichte danach beim unveränderten
`reta-native`-Ziel das 20- beziehungsweise 40-Minuten-Limit. Es gab keine
Compilerdiagnose. Die neue Completion-Quelle selbst wird durch
`scripts/check_completion_word.sh` separat vollständig kompiliert und
ausgeführt.

## Zusätzlich behobener Manifestfehler

Die entpackte Archivprüfung zeigte, dass `update_source_manifest.sh` nur die
oberste `.pytest_cache` ausschloss. Fünf Dateien aus
`python_reference/.pytest_cache` standen dadurch im Manifest, obwohl saubere
Releasearchive Cacheverzeichnisse nicht enthalten. `MOJO-FIXED-018` korrigiert
die Prune-Regel auf jede Baumtiefe und sichert sie in
`tests/test_known_defects.py` ab.
