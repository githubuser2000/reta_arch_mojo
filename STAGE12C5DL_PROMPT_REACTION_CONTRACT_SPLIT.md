# Stage 12c5dl – Prompt reaction contract split

Diese Stage setzt auf `12c5dk` auf und führt **keine technische `.so`-/`.dll`-Erzeugung** ein.
Sie bereinigt aber die spätere Library-Grenze weiter: Der Contract-Snapshot des interaktiven
Prompt-Controllers beschreibt jetzt nur noch die spätere `prompt-reaction`-Schicht.

## Änderung

Vorher enthielt `prompt_interaction_contract_snapshot()` noch detaillierte Marker für externe
Prozessausführung:

- `shell`
- `python`
- `math`
- `reta`
- `retaPrompt.py`-Fallback
- Prozess-argv- und Fallback-argv-Grenzen

Diese Details liegen fachlich nicht in der Reaktionsschicht. Sie gehören zur geplanten
`libreta_prompt_mojo-execution` bzw. zur Prozessgrenze.

Jetzt gilt:

```text
prompt_interaction_contract_snapshot()
  -> nur Prompt-Reaktion:
     Eingabeannahme, Session, Storage, History, lokale Ausgaben, Loop-Kontrolle

prompt_process_dispatch_contract_snapshot()
  -> Prompt-Ausführung an Prozessgrenzen:
     shell/python/math/reta/Fallback argv-Pläne und Prozessadapter-Grenze
```

## Kompatibilitätsfassade

Die historische `PromptScope(...)`-Fassade in `legacy_reta_prompt.mojo` bleibt bewusst vollständig.
Sie setzt den alten sichtbaren Scope aus zwei nativen Snapshots zusammen:

```text
PromptScope
  = prompt_interaction_contract_snapshot
  + prompt_process_dispatch_contract_snapshot
```

Dabei bleibt die alte Reihenfolge erhalten, damit `retaPrompt.py`-Kompatibilität nicht plötzlich
einen anderen öffentlichen Scope sieht.

## Bedeutung für spätere `.so` / `.dll`

Diese Stage markiert die geplante Trennung klarer:

```text
libreta_prompt_mojo-reaction.so/.dll
  - Eingabe
  - Promptzeile
  - History
  - Storage/Delete-Zustand
  - lokale Reaktionspläne
  - keine reta-core-Abhängigkeit nötig

libreta_prompt_mojo-execution.so/.dll
  - shell/python/math/reta Prozesspläne
  - retaPrompt.py-Fallback-argv
  - darf später reta-core/libreta-process verwenden
```

Damit kann die spätere `rp/rpl/rpe`-Eingabe-/Reaktions-Library unabhängig von `libreta_core_mojo`
bleiben. Nur die Ausführungs-Library muss `libreta_core_mojo` einbinden.

## Nicht geändert

- Keine `.so` oder `.dll` wird gebaut.
- Keine Launcher-Logik wird geändert.
- Keine Mojo-Buildoptionen werden geändert.
- Die formalen Porting-Metriken bleiben unverändert.
