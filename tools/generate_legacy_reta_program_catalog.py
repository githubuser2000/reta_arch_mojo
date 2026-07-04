#!/usr/bin/env python3
"""Generate the exact public module and Program method surface of reta.py."""
from __future__ import annotations
import argparse, ast, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'python_reference'/'reta.py'
OUTPUT=ROOT/'src'/'reta_mojo'/'legacy_reta_program_catalog.mojo'

def bound(t):
    if isinstance(t,ast.Name): return [t.id]
    if isinstance(t,(ast.Tuple,ast.List)):
        return [n for e in t.elts for n in bound(e)]
    return []

def surfaces():
    tree=ast.parse(SOURCE.read_text(encoding='utf-8'))
    public=[]; methods=[]
    for node in tree.body:
        if isinstance(node,ast.Import): public += [a.asname or a.name.split('.',1)[0] for a in node.names]
        elif isinstance(node,ast.ImportFrom):
            if node.module!='__future__': public += [a.asname or a.name for a in node.names]
        elif isinstance(node,ast.Assign):
            for t in node.targets: public += bound(t)
        elif isinstance(node,ast.AnnAssign): public += bound(node.target)
        elif isinstance(node,(ast.FunctionDef,ast.ClassDef)):
            public.append(node.name)
            if isinstance(node,ast.ClassDef) and node.name=='Program':
                methods += [x.name for x in node.body if isinstance(x,(ast.FunctionDef,ast.AsyncFunctionDef))]
    public=[x for x in public if not x.startswith('_')]
    return public,methods

def render():
    public,methods=surfaces()
    qp=',\n        '.join(json.dumps(x,ensure_ascii=False) for x in public)
    qm=',\n        '.join(json.dumps(x,ensure_ascii=False) for x in methods)
    return f'''"""Generated exact surface of historical ``reta.py``.\n\nRegenerate with ``tools/generate_legacy_reta_program_catalog.py``.\n"""\n\nfrom std.collections import List\n\n\ndef legacy_reta_program_public_names() -> List[String]:\n    return [\n        {qp}\n    ]\n\n\ndef legacy_reta_program_method_definitions() -> List[String]:\n    return [\n        {qm}\n    ]\n\n\ndef legacy_reta_program_public_count() -> Int:\n    return {len(public)}\n\n\ndef legacy_reta_program_method_definition_count() -> Int:\n    return {len(methods)}\n'''

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--check',action='store_true'); ap.add_argument('--output',type=Path,default=OUTPUT); a=ap.parse_args()
    text=render()
    if a.check:
        if not a.output.exists() or a.output.read_text(encoding='utf-8')!=text: raise SystemExit(f'legacy reta program catalog differs: {a.output}')
        p,m=surfaces(); print(f'legacy reta program catalog identical: {len(p)} public names, {len(m)} method definitions'); return
    a.output.parent.mkdir(parents=True,exist_ok=True); a.output.write_text(text,encoding='utf-8')
    p,m=surfaces(); print(f'generated {a.output}: {len(p)} public names, {len(m)} method definitions')
if __name__=='__main__': main()
