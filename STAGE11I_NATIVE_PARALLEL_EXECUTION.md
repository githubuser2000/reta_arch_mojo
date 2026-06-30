> **Historischer Stand:** Stage 12a hat sämtliche hier beschriebenen nativen
> `fork`-/Pipe-Pfade entfernt und durch Mojo-Threads ersetzt. Die semantischen
> Tests und seriellen Referenzpfade bleiben erhalten.

# Stage 11i – native Tabellenparallelisierung (historischer Prozessstand)

## Ziel

`reta_architecture/parallel_execution.py` wird nicht als Python-
`multiprocessing`-Hülle konserviert, sondern als typisierte Mojo-Laufzeitschicht
neu aufgebaut. Die mutable Spaltengenerierung bleibt absichtlich seriell; nur
reine, deterministische Tabellen-, Zell- und Zahlenoperationen werden in
geordnete Chunks zerlegt.

## Native Laufzeit

Die neue Datei `src/reta_mojo/parallel_execution.mojo` enthält:

- typisierte Prozessor-, Konfigurations-, Ergebnis- und Statistikstrukturen,
- Linux-CPU-Erkennung aus `/proc/cpuinfo`,
- Umgebungs- und CLI-Auswertung für Modus, Workerzahl, Chunkgröße,
  Schwellwert und Startmethode,
- ein längenpräfixiertes UTF-8-Protokoll für beliebige Unicode- und
  Mehrzeilennutzlasten,
- echte Workerprozesse über `fork`, private Pipes und `waitpid`,
- deterministische Chunkreduktion in Python-definierter Zeilen-/Zahlenindexordnung,
- serielle Rückfallpfade mit derselben typisierten Ergebnisschnittstelle.

Die Transportgrenze verwendet weder Python-`Any` noch `pickle`,
`multiprocessing`, dynamische Imports oder eine Python-Bridge.

## Portierte reine Kerne und Prozesspfade

Folgende Operationen besitzen sowohl eine serielle Mojo-Referenz als auch einen
echten Prozess-Chunkpfad:

1. `decode_religion_rows_in_processes`
2. `decode_kombi_rows_in_processes`
3. `select_columns_in_processes`
4. `max_cell_text_len_in_processes`
5. `prepare_kombi_join_tables_in_processes`
6. `moon_numbers_in_processes`
7. `prime_factors_in_processes`
8. `filter_numbers_in_processes`
9. `factor_pairs_in_processes`
10. `normalize_column_buckets_in_processes`

Die Rückgaben enthalten stets Werte und Ausführungsstatistik. Anders als die
Python-Referenz liefert der native API bei unterschrittenem Schwellwert nicht
`None`, sondern denselben Ergebnisdatentyp mit `mode="serial"`. Dadurch muss
der Aufrufer keinen dynamischen Union-Typ behandeln.

## Öffentliche Oberfläche

```bash
./bin/reta-mojo-parallel-execution --summary
./bin/reta-mojo-parallel-execution --config processes 4 64 128 fork
./bin/reta-mojo-parallel-execution --demo 2 2
./bin/reta-mojo-parallel-execution --prime-factors 12 18 25 49
./bin/reta-mojo-parallel-execution --factor-pairs 12 18 25 49
```

Compilerziel:

```text
target/bin/reta-mojo-parallel-execution
```

Es wird durch `scripts/build-heavy.sh` erzeugt.

## Tabellenkopf-/Newline-Korrektur

Die kompakte Promptankündigung hatte Richs internen Aufruf
`Console.print(..., end="")` wörtlich nach Mojo übertragen. Rich rendert das
`Syntax`-Objekt jedoch als vollständige physische Zeile. Der beobachtbare
Python-Ausgabestrom enthält deshalb ein LF, obwohl der Hilfsaufruf intern
`end=""` verwendet.

Die Zeilengrenze ist nun Teil der Datenfunktion:

```mojo
compact_prompt_announcement_line(...) -> announcement + "\n"
```

`prompt_main.mojo` gibt diese bereits gerahmte Zeile mit `end=""` aus. Ein Test
prüft sowohl den exakten String als auch, dass genau ein zusätzliches Byte
vorhanden ist. Damit wird nicht länger eine Bibliotheksimplementierung, sondern
der tatsächliche Bytevertrag portiert.

## Prüfungen in dieser Arbeitsstufe

- Prompt-/LF-Test: **6/6** bestanden.
- Fixture-Integrität: **1/1** bestanden; keine leere oder verklebte Goldendatei.
- Konfiguration, CPU-Erkennung und Snapshots: **29/29** bestanden.
- Religion/Kombi über echte Prozessworker: **55/55** bestanden.
- Zahlenkerne über echte Prozessworker: **157/157** bestanden.
- Tabellen-Chunk-Laufzeittest: **26/26** bestanden.
- Python↔Mojo-Parität: **8/8** Demo-Kernel und **4/4** Primfaktorzeilen bestanden.
- Der neue CLI-Controller wurde kompiliert und sein echter Zwei-Worker-Demolauf erfolgreich ausgeführt.

Insgesamt sind damit **286/286** fokussierte Stage-11i-Prüfungen erfolgreich. Die Tests sind absichtlich auf mehrere kleine Executables verteilt, weil ein einziger großer Testcontroller unverhältnismäßige Compiler- und Linkerelaboration erzeugt.

## In Stage 11j abgeschlossen

`prepare_rows_in_processes` der Python-Referenz kapselt einen großen dynamischen
`Prepare`-Objektgraphen mit `deepcopy`-Zustand. Dieser Pfad wird nicht per
Pickle-Protokoll imitiert. Stage 11j ersetzt ihn durch einen expliziten,
typisierten `ParallelRowPreparationContext`, native Mojo-Threads und eine
deterministische Chunkslot-Reduktion. Stufe 11 ist damit formal abgeschlossen.

## SIMD/MMX-Grenze

Stage 11i führt Prozessparallelisierung ein; Stage 11j ergänzt Threadparallelisierung. Beides ist keine Vektorparallelisierung. Die
meisten Operationen sind Stringparsing, verzweigte Datenstrukturen,
SQLite-/Pipe-I/O und variable Listen. Diese Bereiche sind keine guten direkten
MMX-Kandidaten. Alte x86-MMX-Instruktionen werden deshalb nicht als
Architekturvertrag eingebaut: Sie wären x86-spezifisch, während Mojos
`SIMD`-/`vectorize`-Abstraktion je Zielprozessor moderne Vektorregister nutzen
kann.

Stage 12d soll erst messen und dann vektorisieren. Plausible Kandidaten sind:

- zusammenhängende ASCII-/UTF-8-Byte-Scans nach Trennzeichen,
- Ziffern- und Byteklassifikation im CSV-/Längenpräfixparser,
- flach gespeicherte Zellbreiten- oder Spaltenstatistiken,
- große, gleichförmige Zahlenbatches für einfache Teilbarkeitsprädikate oder
  siebartige Klassifikation.

Nicht sinnvoll sind voraussichtlich Prozesssteuerung, SQLite, Hash-/Set-Zugriffe,
variable Kombi-Joins, Unicode-Codepointlogik und divergente
Primfaktorzerlegungen. Für jeden Kandidaten werden serieller, Prozess- und
SIMD-Pfad benchmarkbasiert verglichen; erzeugte Assemblersprache kann dabei mit
`mojo build --emit asm` kontrolliert werden. Low-Level-LLVM-Intrinsics sind nur
für einen nachgewiesenen Hotspot vorgesehen.
