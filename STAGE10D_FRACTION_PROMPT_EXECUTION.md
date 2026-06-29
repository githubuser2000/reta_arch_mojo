# Stage 10d – Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache

Stage 10d erweitert den besitzenden `PromptTablePlan` um die stabilen vorzeichenbehafteten Zweige der hinteren `prompt_execution.py`-Mengenalgebra. Die Portierung bleibt bewusst referenzgetrieben: Semantisch definierte Fälle laufen nativ; Zweige, in denen das Python-Original abstürzt oder eine andere All-Zeilen-Algebra öffnet, bleiben als kompletter Befehl an der Kompatibilitätsgrenze.

## Neu portierte Datenflüsse

```text
Prompt-Bruchtoken
  → v-/Minus-Präfix typisieren
  → positive und ausgeschlossene _PromptFractionPair-Werte
  → CPython-kompatible Mengenordnung
  → Ganzzahl-, Reziprok- oder echte n/m-Achse
  → optional Teiler- oder Reziprok-Vielfachenexpansion
  → geordnete PromptTableInvocation-Liste
  → reta-native
```

Nativ sind nun:

- Bruchteiler wie `universum teiler 2/6`
- nicht kollidierende Reziprokausschlüsse wie `universum 1/2,-1/4`
- nicht kollidierende echte Bruchausschlüsse wie `universum 2/3,-2/4`
- reine negative Bruchauswahlen als vollständig behandelter leerer Plan
- Reziprok-Vielfache wie `universum v1/256,-1/512`
- positive und vorzeichenbehaftete CPython-Ganzzahlmengenordnungen

Die Vielfachenexpansion bewahrt die beobachtete CPython-Reihenfolge, nicht eine nachträglich sortierte mathematische Reihenfolge. Das ist bei großen Mengen sichtbar, etwa in Folgen wie `4,516,12,524,1020,20,…`.

## Bewusste Kompatibilitätsgrenze

Echte `v n/m`-Vielfache mit Zähler größer 1 bleiben am Fallback. Die Python-Referenz endet beispielsweise für `v2/3` und `vielfache 2/3` selbst mit `IndexError: string index out of range`; eine neue Mojo-Semantik wäre daher keine Transpilierung, sondern eine fachliche Neudefinition.

Ebenfalls atomar am Fallback bleiben Ausschlusskombinationen, die im Original eine gesonderte All-Zeilen-Algebra aktivieren, darunter:

- exakt gleiche positive und negative Brüche wie `2/4,-2/4`
- positive echte Brüche zusammen mit ausschließlich negativem Reziprok wie `2/3,-1/4`
- kollidierende reduzierte Reziproke wie `2/4,-1/2`

## Korrektur der historischen Zeilengrenzen

Die Python-Tabellenlaufzeit besitzt standardmäßig zwei Grenzen: 1024 für generierte Zeilen und 163 für gewöhnliche Haupttabellenzeilen. Ein explizites `--oberesmaximum` setzt über den Python-Property-Setter beide Grenzen auf denselben Wert.

Der native Kern hatte stattdessen eine feste Kurzgrenze 114 verwendet. Stage 10d korrigiert beides:

- Standard-Kurzgrenze: 163
- bei explizitem `--oberesmaximum`: Kurzgrenze = oberes Maximum

Dadurch wird im Referenzfall `v1/256,-1/512` neben Zeile 256 auch die nicht-mondartige Zeile 768 korrekt ausgegeben.

## Referenzprüfung

Die normalisierten geordneten CSV-Tokenströme sind für 14 reale Fälle identisch. Neu hinzugekommen sind:

```text
universum teiler 2/6
universum 1/2,-1/4
universum 2/3,-2/4
universum v1/256,-1/512
```

Zusätzlich bestehen 16/16 Tabellenplanertests, 18/18 reine Bruchparserfälle, 7/7 bestehende Prompt-Ausführungsfixtures und 3/3 fokussierte Zeilenfiltertests. Präsentationshinweise des Python-Prompts werden bei der CSV-Semantikprüfung verworfen; Reihenfolge und Inhalte aller Tabellenfelder bleiben Teil des Vergleichs.
