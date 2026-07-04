from __future__ import annotations
import ast
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'python_reference'/'reta.py'
MOJO=ROOT/'src'/'reta_mojo'/'legacy_reta_program.mojo'
CATALOG=ROOT/'src'/'reta_mojo'/'legacy_reta_program_catalog.mojo'
GEN=ROOT/'tools'/'generate_legacy_reta_program_catalog.py'
PACKAGE=ROOT/'src'/'reta_mojo'/'__init__.mojo'

def _public_and_methods():
    tree=ast.parse(SOURCE.read_text(encoding='utf-8'))
    public=[]; methods=[]
    def bound(t):
        if isinstance(t,ast.Name): return [t.id]
        if isinstance(t,(ast.Tuple,ast.List)): return [n for e in t.elts for n in bound(e)]
        return []
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
                methods += [x.name for x in node.body if isinstance(x,ast.FunctionDef)]
    return [x for x in public if not x.startswith('_')],methods

def _quoted_list(text,name):
    m=re.search(rf"def {name}\(\).*?return \[(.*?)\n    \]",text,re.S)
    assert m
    return re.findall(r'"((?:[^"\\]|\\.)*)"',m.group(1))

def test_generated_catalog_matches_python_surface_exactly():
    public,methods=_public_and_methods(); text=CATALOG.read_text()
    assert _quoted_list(text,'legacy_reta_program_public_names')==public
    assert _quoted_list(text,'legacy_reta_program_method_definitions')==methods
    assert len(public)==27 and len(methods)==18

def test_native_facade_has_all_historical_program_adapters():
    text=MOJO.read_text()
    for name in [
        'produceAllSpaltenNumbers','breiteBreitenSysArgvPara','apply_output_mode',
        'storeParamtersForColumns','parametersToCommandsAndNumbers','helpPage',
        'bringAllImportantBeginThings','oberesMaximumArg','oberesMaximum2',
        'oberesMaximum','propInfoLog','set_propInfoLog','invertAlles','run',
        'resultingTable','workflowEverything','combiTableWorkflow',
    ]:
        assert f'def {name}(' in text
    assert 'struct LegacyRetaProgram(Copyable)' in text
    assert 'run_native_reta' in text
    assert 'run_reta_arguments_native' in text
    assert 'std.python' not in text and 'PythonObject' not in text

def test_catalog_generator_and_package_export_are_present():
    assert GEN.exists()
    package=PACKAGE.read_text()
    assert 'from .legacy_reta_program_catalog import (' in package
    assert 'from .legacy_reta_program import (' in package
    assert 'bootstrap_legacy_reta_program,' in package
