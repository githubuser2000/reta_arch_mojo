#!/usr/bin/env python3
from __future__ import annotations
import json, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REF=ROOT/'python_reference'

def collect(language:str):
    code=r'''
import json,sys
from pathlib import Path
root=Path(sys.argv[1]); lang=sys.argv[2]
sys.path.insert(0,str(root)); sys.path.insert(0,str(root/'libs'))
sys.argv=['catalog','-language='+lang]
import i18n.words_context as context
import i18n.words_matrix as matrix
import i18n.words_runtime as runtime
from reta_architecture.schema import RetaContextSchema
from reta_architecture.sheaves import ParameterSemanticsSheaf
schema=RetaContextSchema.from_words_parts(context,matrix,runtime)
sheaf=ParameterSemanticsSheaf.from_schema(schema)
rows=[]
for main_group in sheaf.main_alias_groups:
    canonical=main_group['canonical']
    parameter_groups=sheaf.parameter_alias_groups.get(canonical,[])
    for pgroup in parameter_groups:
        pair=(canonical,pgroup['canonical'])
        cols=sheaf.pair_to_columns.get(pair,[])
        if not cols: continue
        for ma in main_group['aliases']:
            for pa in pgroup['aliases']:
                rows.append((str(ma),str(pa),tuple(sorted(map(int,cols)))))
print(json.dumps(rows,ensure_ascii=False))
'''
    p=subprocess.run([sys.executable,'-c',code,str(REF),language],capture_output=True,text=True,check=True)
    return [(x[0], x[1], tuple(x[2])) for x in json.loads(p.stdout)]

def main():
    rows=set()
    for lang in ('german','english'):
        rows.update(collect(lang))
    out=ROOT/'assets'/'parameter_aliases.tsv'
    out.parent.mkdir(exist_ok=True)
    with out.open('w',encoding='utf-8',newline='\n') as f:
        for main_alias,param_alias,cols in sorted(rows,key=lambda r:(r[0],r[1],r[2])):
            if '\t' in main_alias or '\t' in param_alias or '\n' in main_alias or '\n' in param_alias:
                raise ValueError('unsupported alias control character')
            f.write(f"{main_alias}\t{param_alias}\t{','.join(map(str,cols))}\n")
    print(out, len(rows), out.stat().st_size)
if __name__=='__main__':main()
