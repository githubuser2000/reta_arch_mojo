# Stage 12c5az – getrennte Reziprok-/Bruchvielfachenachsen

## Ausgangslage

Der native Promptplaner besaß echte `v n/m`-Vielfache bereits als absichtliche
Korrektur des offenen Python-Fehlers `PY-OPEN-002`. Ein gemischtes Token wie

```text
universum v1/2,2/3
```

blieb jedoch am atomaren Referenzfallback, obwohl beide Teilachsen für dieselbe
Universum-Domäne einzeln vollständig typisiert waren. Die eingefrorene
Python-Referenz stürzt sowohl bei `universum v2/3` als auch bei der gemischten
Form mit `IndexError` in `prompt_execution.py` ab.

## Nativer Vertrag

`prompt_table_execution.mojo` trennt die Bruchpaare jetzt nach ihrer Achse:

- `1/n`-Paare bilden die reziproke Zeilenachse mit der historischen Obergrenze
  1024, also sichtbaren Zeilen bis 1023.
- echte `n/m`-Paare mit `n != 1` expandieren Zähler und Nenner ausschließlich
  innerhalb des ausgewählten physischen Bruch-CSV-Rechtecks.
- Ganzzahl-, Reziprok-, Bruchspalten- und Gleichheitsprojektionen werden danach
  deterministisch zusammengeführt.
- positive und negative reziproke Vielfachen verwenden weiterhin die
  CPython-kompatible Integer-Set-Reihenfolge.
- mehrere gleichzeitig ausgewählte, verschieden große Bruch-CSV-Domänen
  bleiben atomar am Fallback; dafür wäre ein eigener domänenspezifischer
  Mehrfachplan erforderlich.

Für `universum v1/2,2/3` entstehen 13 native Aufrufe. Die reziproke Achse ist

```text
{2,4,...,1022} ∪ {1,3,9}
```

während Zähler 2..20 und Nenner 3..21 weiterhin am realen
Universum-Bruchrechteck begrenzt bleiben.

## Verifikation

Die Stage baut und führt aus:

- `tests/test_prompt_table_execution.mojo`
- `tests/prompt_true_fraction_multiple_probe.mojo`
- `scripts/check_prompt_true_fraction_multiples.py`
- `tests/test_prompt_mixed_fraction_multiple_source.py`

Der Paritätsprüfer verlangt weiterhin die reproduzierbaren Python-Abstürze,
prüft aber den korrigierten Mojo-Plan, alle 13 direkten `reta-native`-Aufrufe und
die voneinander unabhängigen Obergrenzen. Mojo wird ausschließlich durch den
Benutzer kompiliert.

## Ausführen

```bash
scripts/build-all.sh
scripts/test_stage12c5az.sh
```
