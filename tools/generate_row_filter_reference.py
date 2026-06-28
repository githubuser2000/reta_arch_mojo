#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REF=ROOT/'python_reference'
sys.path.insert(0,str(REF))
sys.path.insert(0,str(REF/'libs'))
from libs.lib4tables_prepare import Prepare

CASES = {
    'ka':['ka'], 'all':['all'], 'absolute':['_a_1-9'],
    'absolute_exclusion':['_a_1-9,-3'], 'absolute_divisors':['_a_12','_w_'],
    'relative_multiples':['_b_3'], 'relative_exclusion':['_b_2-4,-3'],
    'time_past':['<'], 'time_present':['='], 'time_future':['>'],
    'absolute_time':['_a_1-20','>'],
    'counting_one':['_n_1'], 'counting_two':['_n_2'], 'counting_one_to_three':['_n_1-3'],
    'outside_first':['aussenerste'], 'inside_first':['innenerste'],
    'outside_all':['aussenalle'], 'inside_all':['innenalle'],
    'moon':['mond'], 'sun':['sonne'], 'planet':['planet'],
    'black_sun':['schwarzesonne'], 'sun_with_moon_part':['SonneMitMondanteil'],
    'prime_multiple_two':['2p'], 'prime_multiple_two_three':['2p','3p'],
    'power_two':['_^_2'], 'power_two_three':['_^_2-3'],
    'multiple_three':['3v'], 'multiple_three_five':['3v','5v'],
    'invert_absolute':['_a_2,4,6','_i_'],
    'position_absolute':['_a_2-20','_z_2-4'],
    'position_multiple':['_a_2-20','_y_2'],
    'combo_planet_multiple':['_a_1-50','planet','3v'],
    'combo_all_moon_prime':['all','mond','2p'],
    'combo_relative_time':['_b_2','<'],
    'combo_type_position':['_a_1-100','aussenalle','_z_1-5'],
}
class Tables:
    hoechsteZeile={1024:100,114:60}

def mojo_str(s:str)->str:
    return '"'+s.replace('\\','\\\\').replace('"','\\"')+'"'

def main():
    p=Prepare(Tables(),Tables.hoechsteZeile)
    p.ifZeilenSetted=True
    lines=[
        'from std.testing import assert_equal, TestSuite',
        'from std.collections import Set',
        'from reta_mojo.row_filtering import *',
        '',
        'def _initial() -> Set[Int]:',
        '    var values = Set[Int]()',
        '    for value in range(104):',
        '        values.add(value)',
        '    return values^',
        '',
        'def test_python_reference_vectors() raises:',
        '    var config = RowFilterConfig(100, 60, True)',
    ]
    for name,conditions in CASES.items():
        p.gezaehlt=False
        p.zaehlungen=[0,{}, {}, {}, {}]
        result=sorted(p.FilterOriginalLines(set(p.originalLinesRange),set(conditions)))
        cond='['+', '.join(mojo_str(x) for x in conditions)+']'
        expect='['+', '.join(map(str,result))+']'
        lines.append(f'    # {name}')
        lines.append(f'    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), {cond})), {expect})')
    lines += ['', 'def main() raises:', '    TestSuite.discover_tests[__functions_in_module()]().run()', '']
    out=ROOT/'tests'/'test_row_filtering_reference.mojo'
    out.write_text('\n'.join(lines),encoding='utf-8')
    print(f'wrote {out} ({len(CASES)} vectors)')
if __name__=='__main__': main()
