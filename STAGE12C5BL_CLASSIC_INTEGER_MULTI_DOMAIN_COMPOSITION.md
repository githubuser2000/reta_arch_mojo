# Stage 12c5bl – klassische Ganzzahltabellen neben mehreren Bruchdomänen

## Geschlossene Restgrenze

Bis Stage 12c5bk waren klassische Ganzzahlfamilien bei reinen echten Brüchen
korrekt inert. Sobald jedoch eine echte gewöhnliche Achse hinzukam, blieb etwa

```text
mond universum motive v2/3,5
```

atomarer Fallback. Die eingefrorene Python-Steuerung besitzt für diese äußere
Komposition trotz ihres defekten gemeinsamen `n/m`-Rechtecks eine stabile
Reihenfolge.

## Historische Ausführungsordnung

Der gebündelte Referenzprobe belegt:

1. `thomas` läuft vor den physischen Bruchfamilien;
2. die Bruchfamilien behalten Emotion → Größe → Motive → Universum;
3. danach folgen `mond`, `alles`, `primzahlkreuz`, `richtung`;
4. `primzahlkreuz` ersetzt den gewöhnlichen Zeilenselektor durch
   `--oberesmaximum=1029` und übernimmt nur die originale
   `--vielfachevonzahlen`-Achse;
5. im `teiler`-Modus entfällt `--vielfachevonzahlen` auch für die klassischen
   Tabellen.

Die Python-Referenz wird nicht als Beleg für ihr inneres Bruchrechteck benutzt.
Der Probe vergleicht die klassischen Präfixe und Suffixe ausschließlich relativ
zu demselben Python-Basisplan.

## Korrigierte native Komposition

Jede physische Domäne behält ihr eigenes korrektes Zähler×Nenner-Rechteck. Für
die einzige klassische Ganzzahlachse werden die daraus entstehenden ganzen
Projektionen in physischer Domänenreihenfolge vereinigt und dedupliziert.
Danach werden die originalen Ganzzahlkomponenten genau einmal angefügt.

Beispiel:

```text
mond emotion universum v2/3,5
```

Emotion projiziert `[2,1]`, Universum `[2,1,4,6,3]`. Die klassische Mondtabelle
erhält deshalb:

```text
--vorhervonausschnitt=2,1,4,6,3,5,v5
```

Sie wählt weder willkürlich eine Domäne noch vervielfacht sie projizierte Werte
ein zweites Mal.

## Vollständig native Beispiele

```text
mond universum motive v2/3,5
mond universum motive v2/3,5 teiler
mond emotion universum v2/3,5
mond richtung primzahlkreuz alles thomas universum motive v2/3,5
```

Der letzte Plan besitzt 31 Aufrufe:

- 1 Thomas-Aufruf;
- 26 korrigierte Motive-/Universum-Aufrufe;
- Mond, Alles, Primzahlkreuz und Richtung als vier Nachläufer.

## Vollständig hermetische Shell-Parität

Der vorherige Prüfer setzte zwar die Repository-Ressourcenpfade, erbte aber
weiterhin das interaktive `stdin`-Terminal. Der native Renderer fragt nach
stdout auch stdin mit `TIOCGWINSZ` ab. In einem 180-Spalten-Terminal wurden
deshalb mehrere 40-Zeichen-Spalten nebeneinander statt untereinander
gerendert; die beiden Shell-Referenzen wuchsen von 1990 auf 2830 und von 2804
auf 3570 Zeichen.

Der Runner verwendet nun gleichzeitig:

```text
stdin = DEVNULL
stdout/stderr = Pipes
COLUMNS = 80
LINES = 24
```

Damit ist die Seitenaufteilung unabhängig vom aufrufenden Terminal. Der Fix
wurde unter einem künstlichen 180-Spalten-Pseudoterminal reproduziert: vor der
Änderung scheiterten exakt die beiden gemeldeten Shell-Fälle, danach bestanden
alle vier kanonischen Kommando-Paritätsfälle.

## Prüfung

```sh
python3 scripts/check_prompt_classic_fraction_composition.py
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bl.sh -- -j 4
```
