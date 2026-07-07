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
MOJO_TEST=ROOT/'tests'/'test_legacy_reta_program.mojo'

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
        'bootstrap_legacy_reta_program_with_parallel_config','produceAllSpaltenNumbers','breiteBreitenSysArgvPara','apply_output_mode',
        'storeParamtersForColumns','parametersToCommandsAndNumbers','helpPage',
        'bringAllImportantBeginThings','oberesMaximumArg','oberesMaximum2',
        'oberesMaximum','propInfoLog','set_propInfoLog','invertAlles','run',
        'resultingTable','workflowEverything','combiTableWorkflow',
    ]:
        assert f'def {name}(' in text
    assert 'struct LegacyRetaProgram(Copyable)' in text
    assert 'run_native_reta' in text
    assert 'run_reta_arguments_native' in text
    assert 'struct LegacyRetaProgramNativeCompletionPlan' in text
    assert 'def plan_legacy_reta_program_native_completion(' in text
    assert 'def legacy_reta_program_native_completion_valid(' in text
    assert 'std.python' not in text and 'PythonObject' not in text
    assert 'extract_parallel_config_from_argv(' in text
    assert 'parallel_config_from_environment()' in text
    assert 'normalize_native_cli_controls' in text
    assert 'native_cli_startup' in text

def test_catalog_generator_and_package_export_are_present():
    assert GEN.exists()
    package=PACKAGE.read_text()
    assert 'from .legacy_reta_program_catalog import (' in package
    assert 'from .legacy_reta_program import (' in package
    assert 'bootstrap_legacy_reta_program,' in package
    assert 'bootstrap_legacy_reta_program_with_parallel_config,' in package


def test_upper_limit_adapter_test_preserves_historical_monotonic_ceiling():
    text=MOJO_TEST.read_text()
    assert 'oberesMaximum(program, "--oberesmaximum=77")' in text
    assert 'assert_equal(program.runtime.highest, 1024)' in text
    assert 'oberesMaximum(program, "--oberesmaximum=2048")' in text
    assert 'assert_equal(program.runtime.highest, 2048)' in text


def test_native_completion_witness_freezes_reta_top_level_contract():
    text=MOJO.read_text()
    mojo_test=MOJO_TEST.read_text()
    assert 'struct LegacyRetaProgramNativeCompletionPlan' in text
    assert 'var source_lines: Int' in text
    assert '"reta.py"' in text
    assert '"nativ"' in text
    assert 'legacy_reta_program_public_count()' in text
    assert 'legacy_reta_program_method_definition_count()' in text
    assert 'plan.source_lines != 214' in text
    assert 'plan.public_names != 27' in text
    assert 'plan.method_definitions != 18' in text
    assert 'plan.owner_entries != 10' in text
    assert 'test_reta_program_native_completion_witness_marks_top_level_complete' in mojo_test
