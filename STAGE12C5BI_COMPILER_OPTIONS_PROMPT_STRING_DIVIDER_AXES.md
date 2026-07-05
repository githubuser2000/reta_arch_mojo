# Stage 12c5bi – Compileroptionen, Prompt-Stringbesitz und Bruch-Teilerachsen

## Ausgangslage

Der Benutzer führte die neue zweiphasige Testsuite mit internen Compilerthreads
und vier Laufzeitjobs aus:

```sh
scripts/build-tests.sh -- -j 4
scripts/run-tests.sh --jobs 4
scripts/test_stage12c5bh.sh
```

Die sequenzielle Testkompilierung erreichte `tests/test_native_prompt_input.mojo`
und brach dort ab, weil `String.strip()` einen `StringSlice` liefert, die lokale
Variable aber anschließend wie ein besitzender `String` mutiert wurde:

```text
error: cannot implicitly convert 'String' value to
'StringSlice[origin_of(__call_result_tmp__)]'
```

Ein vorheriger vollständiger kombinierter Lauf hatte außerdem in
`test_true_fraction_multiples_follow_each_csv_rectangle` nur die Assertion am
Index 7 verfehlt. Die übrigen 28 Tabellenplanertests bestanden.

## Testkompilierung und Laufzeitparallelität

Die beiden Parallelitätsachsen sind jetzt vollständig getrennt:

```sh
scripts/build-tests.sh --heavy -- -j 4
scripts/run-tests.sh --jobs 4
```

oder kombiniert:

```sh
scripts/test_all.sh --heavy --run-jobs 4 -- -j 4
```

- `-j 4` wird an **jeden einzelnen** `mojo build`-Aufruf weitergereicht.
- Die Testquelldateien werden weiterhin nacheinander kompiliert; mehrere
  eigenständige Compilerprozesse werden nicht automatisch gestartet.
- `--run-jobs 4` betrifft ausschließlich die isolierte Ausführung fertiger
  Testprogramme; serielle und exklusive Barrieren bleiben wirksam.
- Mehrfach angegebene Threadoptionen werden über
  `scripts/mojo_build_options.sh` früh abgelehnt.
- Fokussierte Stage- und Bruchprobe-Skripte akzeptieren dieselbe Syntax hinter
  `--`. Ohne explizite Threadoption bleibt ihr konservativer lokaler Standard
  `-j 4` erhalten.

## StringSlice-/String-Grenze

Der Prompt-History-Test besitzt sein Sandboxverzeichnis nun ausdrücklich als
`String`:

```mojo
var root = String(getenv("RETA_TEST_SANDBOX", "/tmp"))
root = String(root.strip())
```

Damit bleibt die anschließende Zuweisung `root = "/tmp"` typkorrekt. Der Fix
betrifft nur den Testbesitz; die portable produktive History-Auflösung bleibt
unverändert.

## Korrigierte Mehrdomänen-Testposition

Für `emotion universum v1/2,2/3,5` besteht der 19-Aufruf-Plan aus:

- Emotion-Block: Indizes 0–5,
- Universe-Ganzzahlachse: Index 6,
- Universe-Reziprokachse: Index 7,
- anschließenden Universum-Bruch- und Gleichheitsachsen.

Die frühere Assertion prüfte `--vielfachevonzahlen=5` am Reziprokindex 7. Der
Produktionsplan war korrekt. Der Test bindet nun Index 6 als Ganzzahlachse und
prüft zusätzlich, dass Index 7 tatsächlich
`--Universum=transzendentaliereziproke` trägt und keine gewöhnliche
Vielfachenoption erbt.

## Weitere native Prompt-Komposition

Die bisher absichtlich offenen äußeren Grammatiken um echte Bruchvielfache sind
nun typisiert:

### Separat geschriebenes negatives Token

```text
universum motive v2/3 -10
```

Das historische Prompt konsumiert `-10` als parameterähnliches Token, ohne es
in die Zeilenachse einzubauen. Innerhalb des alten Python-Bruchrasters folgt
anschließend weiterhin `PY-OPEN-002`; der korrigierte native Plan ist dagegen
exakt derselbe wie für `universum motive v2/3`.

### Nichtpositive Teilerkomposition

```text
universum v2/3,0 teiler
universum v2/3,5,-10 teiler
universum motive v2/3,0 teiler
```

Der stabile äußere Python-Vertrag wird mit dem korrigierten physischen
Bruchrechteck komponiert:

- `--vielfachevonzahlen` entfällt im Teilerzweig,
- positive überlebende Werte liefern ihre Divisoren,
- ein mehrbyteiger Roh-Ausdruck wird danach nochmals in Quellreihenfolge
  angefügt,
- die `v`-Formen folgen zuletzt,
- Null liefert keinen Divisor und bleibt nur als `v0` sichtbar.

Beispiele der korrigierten Universe-Ganzzahlachse:

```text
v2/3,0 teiler       -> 2,1,4,6,3,v0
v2/3,5 teiler       -> 2,1,4,6,3,1,5,v5
v2/3,5,-10 teiler   -> 2,1,4,6,3,1,5,5,-10,v5,v-10
```

Die Python-Referenzprobe für alle äußeren Ganzzahl-/Teilerfälle wird nun in
einem einzigen Prozess gebündelt. Das reduziert die wiederholte Import- und
Prompt-Initialisierung erheblich, ohne die eingefrorene Referenz zu verändern.

## Verbleibende Grenze

Eine zusätzliche unabhängige Tabellenfamilie wie `mond` zusammen mit mehreren
physischen Bruchdomänen bleibt atomarer Fallback, bis ihr eigenes
Kompositionsgesetz vollständig bewiesen ist:

```text
mond universum motive v2/3
```

## Verbindlicher Benutzerlauf

```sh
scripts/build-all.sh -- -j 4
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bi.sh -- -j 4
scripts/build-tests.sh --heavy -- -j 4
scripts/run-tests.sh --jobs 4
```

Die Erstellungsumgebung kompiliert selbst kein Mojo.
