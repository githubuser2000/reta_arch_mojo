#!/usr/bin/env python3
from __future__ import annotations
import csv, io
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
CSV=ROOT/'python_reference'/'csv'
MOD=1000000007

def stats(path:Path):
    rows=list(csv.reader(io.StringIO(path.read_text(encoding='utf-8')),delimiter=';'))
    value=17; cells=0; maximum=0
    for row in rows:
        cells+=len(row); maximum=max(maximum,len(row))
        for cell in row:
            for b in cell.encode('utf-8'): value=(value*257+b+1)%MOD
            value=(value*257+257)%MOD
        value=(value*257+258)%MOD
    return len(rows),maximum,cells,value

def main():
    names=[p.name for p in sorted(CSV.glob('*.csv')) if not any(p.name.startswith(x) for x in ('cn-','en-','kr-','vn-'))]
    lines=['from std.testing import assert_equal, TestSuite','from reta_mojo.csv_table import *','','def _check(path: String, rows: Int, columns: Int, cells: Int, fingerprint: Int) raises:','    var table = read_semicolon_csv(path)','    assert_equal(len(table.rows), rows)','    assert_equal(table.maximum_columns, columns)','    assert_equal(table_cell_count(table), cells)','    assert_equal(table_fingerprint(table), fingerprint)','','def test_reference_csv_files() raises:']
    for name in names:
        a,b,c,d=stats(CSV/name)
        lines.append(f'    _check("python_reference/csv/{name}", {a}, {b}, {c}, {d})')
    lines += ['','def main() raises:','    TestSuite.discover_tests[__functions_in_module()]().run()','']
    out=ROOT/'tests'/'test_csv_reference.mojo'
    out.write_text('\n'.join(lines),encoding='utf-8')
    print(out,len(names))
if __name__=='__main__':main()
