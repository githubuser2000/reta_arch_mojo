#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
BIN=${RETA_PARALLEL_EXECUTION_BIN:-"$ROOT/target/bin/reta-mojo-parallel-execution"}
PYTHON=$("$ROOT/scripts/select_reference_python.sh")
TMP=${TMPDIR:-/tmp}/reta-parallel-execution-parity-$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$ROOT/python_reference${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON" - <<'PY' > "$TMP/expected"
from reta_architecture.parallel_execution import (
    ParallelExecutionConfig,
    decode_kombi_rows_in_processes,
    decode_religion_rows_in_processes,
    factor_pairs_in_processes,
    filter_numbers_in_processes,
    moon_numbers_in_processes,
    prime_factors_in_processes,
)

config = ParallelExecutionConfig(
    mode="processes", workers=2, chunk_size=2, threshold=1,
    start_method="fork", source="parity",
)
religion_rows = [
    (1, ['|{"":"eins","html":"<b>eins</b>","bbcode":"[b]eins[/b]"}|', "ä"]),
    (2, ["3/4", "βeta"]),
    (3, ["5", "line\nbreak"]),
    (4, ["7", "終"]),
]
kombi_rows = [
    (1, ["2", "alpha"]),
    (2, ["3/4", "beta"]),
    (3, ["5", "gamma"]),
    (4, ["7", "delta"]),
]
numbers = [6, 8, 12, 18, 25, 27, 30, 49]
religion = decode_religion_rows_in_processes(religion_rows, "html", config=config)
kombi = decode_kombi_rows_in_processes(kombi_rows, config=config)
factors = prime_factors_in_processes(numbers, config=config)
moon = moon_numbers_in_processes(numbers, config=config)
filtered = filter_numbers_in_processes(numbers, "ordinary_multiples", [2, 5], config=config)
pairs = factor_pairs_in_processes(numbers, include_one=True, config=config)
print(f"religion_mode={'threads' if religion else 'serial'}")
print(f"religion_chunks={religion.chunks}")
print(f"religion_first={religion.values[0][0]}")
print(f"kombi_mode={'threads' if kombi else 'serial'}")
print(f"kombi_numbers={len(kombi.values[1][2])}")
print(f"prime_factors_mode={'threads' if factors else 'serial'}")
print("prime_factors_first=" + ",".join(map(str, factors.values[0][1])))
print(f"moon_mode={'threads' if moon else 'serial'}")
print(f"moon_records={len(moon.values)}")
print("filtered=" + ",".join(map(str, sorted(filtered.values))))
print(f"factor_pairs_mode={'threads' if pairs else 'serial'}")
print(f"factor_pairs_first={len(pairs.values[0][1])}")
PY

"$BIN" --demo 2 2 > "$TMP/actual"
if ! diff -u "$TMP/expected" "$TMP/actual"; then
    printf '%s\n' 'parallel-execution Python↔Mojo demo parity failed' >&2
    exit 1
fi

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$ROOT/python_reference${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON" - <<'PY' > "$TMP/prime.expected"
from reta_architecture.number_theory import primFak
for number in sorted((49, 6, 18, 6)):
    print(f"{number}:" + ",".join(map(str, primFak(number))))
PY
"$BIN" --prime-factors 49 6 18 6 > "$TMP/prime.actual"
cmp "$TMP/prime.expected" "$TMP/prime.actual"
printf '%s\n' 'parallel-execution Python↔Mojo parity: 8/8 demo kernels plus 4/4 prime-factor rows'
