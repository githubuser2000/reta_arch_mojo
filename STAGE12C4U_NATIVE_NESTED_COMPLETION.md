# Stage 12c4u – native verschachtelte Prompt-Completion

## Ziel

Stage 12c4u überführt die eigentlichen Python-Besitzer der hierarchischen
Prompt-Completion in eigenständige typisierte Mojo-Module. Die Completion war
zuvor im nativen Promptpfad bereits funktional vorhanden, ihre Zustandsmaschine
und ihr Laufzeitobjekt waren jedoch noch in `prompt_language.mojo` mitgeführt
und die Portierungsmatrix musste deshalb drei Originaldateien weiterhin als
Python-Bridge zählen.

## Vollständig übernommene Originaldateien

- `reta_architecture/completion_runtime.py` (192 Zeilen)
- `reta_architecture/completion_nested.py` (589 Zeilen)
- `libs/nestedAlx.py` (24 Zeilen)

Die zusammen **805 Python-Zeilen** besitzen nun explizite native Eigentümer:

- `src/reta_mojo/completion_runtime.mojo`
- `src/reta_mojo/completion_nested.mojo`

## Native Architektur

`CompletionRuntimeBundle` lädt den reproduzierbar generierten fünfsprachigen
Katalog und besitzt Root-Befehle, Hauptparameter, Parameter-/Wertsektionen,
Startbefehle, Kontextindizes und Snapshots ohne Python-Objektgraphen.

`ArchitectureNestedCompleter` besitzt die vollständige Zustandsmaschine:
Root-, Hauptparameter-, Nebenparameter- und Wertkontexte, Kommafragmente,
Nicht-`reta`-Rekursion, Präfixfilterung, Fuzzy-Reihenfolge sowie die historische
`nestedAlx`-Fassade. `NestedCompletionMorphismBundle` und
`NestedCompletionSnapshot` erhalten die architektonischen Metadaten als
statisch typisierte Werte.

Produktiv verwenden nun der TTY-Zeileneditor, die Completion-CLI, die
Batch-Paritätsprobe und der dauerhafte Readline-Arbeiter diese neuen Besitzer.
Es gibt keinen Python-Callback und keine `std.python`-Bridge.

Die vorher in `prompt_language.mojo` verbliebene zweite, bytebasierte Completion-Implementierung wurde vollständig entfernt. Dadurch wird die Zustandsmaschine nicht mehr doppelt gepflegt oder über jedes Prompt-Language-Importziel erneut elaboriert.

## Während der Portierung entdeckte Mojo-Fehler

### Unicode-Fuzzy-Reihenfolge

Die ältere native Fuzzy-Suche bewertete UTF-8-Bytes statt Unicode-Skalare.
Dadurch konnte die deutsche Reihenfolge bei Umlauten von Python abweichen.
Die neue Implementierung dekodiert Codepoints und vergleicht die tatsächliche
Zeichenfolge.

### Falsche englische Zeilenwert-Kontexte im Generator

`generate_prompt_nested_catalog.py` verwendete für allgemeine englische
Zeilenparameter die übersetzten Dictionary-Werte. Das Python-Original iteriert
jedoch zunächst die Dictionary-Schlüssel und überschreibt danach nur drei
lokalisierte Spezialdomänen. Der Generator bildet diese Reihenfolge nun exakt
ab. Der Befund ist als `MOJO-FIXED-019` im zentralen Fehlerkatalog erfasst.

## Validierung

- Completion-Runtime: **3/3** native Tests
- verschachtelte Zustandsmaschine: **5/5** native Tests
- bisherige Prompt-Completion-Parität: **12/12** Kontexte
- erweiterte Deutsch-/Englisch-Parität: **67/67** Kontexte
  - Deutsch: 33
  - Englisch: 34
- inklusive Unicode, Tippfehlernähe, Kommafragmenten, Nicht-`reta`-Rekursion,
  Haupt-/Nebenparameterwechseln und `difflib`-kompatibler Näheordnung

Der reproduzierte Katalog enthält nun **25.834 Completion-Werte in 561
Sektionen**, dazu **200 Dispatch-Aliase**, 95 Kurzersetzungen, 370 numerische
Kurzbefehlszeilen und 1.355 Vokabularaliase.

## Fortschrittswirkung

Die funktionale Oberfläche lag bereits bei **96–98 %**; diese Stage erhöht
vor allem den strengeren Dateibesitz:

- vollständig native/reproduzierbar generierte Originaldateien:
  **35/92 → 38/92 = 41,3 %**
- mindestens teilweise portierte Originaldateien:
  **63/92 → 66/92 = 71,7 %**
- gewichteter Quellzeilenstand:
  **ca. 52,6 % → ca. 54,2 %**

Diese Kennzahlen messen verschiedene Dinge und dürfen nicht als ein einziges
wechselndes Gesamtprozent gelesen werden: 96–98 % ist Funktionsabdeckung,
41,3 % vollständiger Dateiersatz und 54,2 % gewichteter Quellzeilenersatz.


## Buildbeobachtung

Der isolierte produktive Build von `src/prompt_completion_main.mojo` benötigt in der Sandbox **8,64 s** und liefert für `reta -lines --primes=p` die Python-konformen Kandidaten `primenumbers` und `primzahlen`. Der Nutzer hat auf dem Zielsystem seit Stage 12c4r ungefähr eine **Verdopplung der Gesamtbuildgeschwindigkeit** beobachtet; diese Zielsystemmessung ist für den praktischen Build maßgeblicher als die stark schwankende Sandbox.

Ein sauberer Sandboxlauf von `scripts/build.sh` erzeugte die ersten drei regulären Ziele fehlerfrei, traf beim unveränderten monolithischen `reta-native`-Ziel jedoch erneut das 60-Minuten-Umgebungslimit ohne Compilerdiagnose. Das ist kein Gegenbeleg zur lokalen Beschleunigung und kein Fehler der neuen Completion-Module; diese wurden separat vollständig kompiliert und ausgeführt.

## Source-only-Prüfung

Die erste Entpackprüfung deckte `TEST-FIXED-003` auf: Der Katalogcheck rief
fest `.venv/bin/python` auf, obwohl `.venv` nicht Bestandteil eines
Source-only-Archivs ist. Das Skript verwendet nun `RETA_PYTHON`, eine optional
vorhandene lokale Umgebung oder als portable Rückfallebene `python3`. Der
Katalog kann damit direkt aus dem sauberen Archiv regeneriert werden.
