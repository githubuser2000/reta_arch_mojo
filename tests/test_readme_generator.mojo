from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite

from reta_mojo.readme_generator import *


def test_readme_bundle_and_language_contract() raises:
    var bundle = bootstrap_readme_generator()
    assert_true(readme_generator_valid(bundle))
    assert_equal(bundle.canonical_python_hash_seed, 0)
    assert_equal(normalize_readme_language("englisch"), "english")
    assert_equal(normalize_readme_language("deutsch"), "german")
    var arguments = List[String]()
    arguments.append("ignored")
    arguments.append("-language=english")
    assert_equal(readme_language_from_arguments(arguments), "english")


def test_generated_documents_load_exact_assets() raises:
    var german = generate_readme("german")
    var english = generate_readme("english")
    assert_equal(german.asset_name, "generated_readme_german.md")
    assert_equal(english.asset_name, "generated_readme_english.md")
    assert_true(german.text.startswith("Hauptprogramm ist reta oder reta.py"))
    assert_true(english.text.startswith("Main program is reta or reta.py."))
    assert_equal(german.byte_count, 13562)
    assert_equal(english.byte_count, 12877)
    assert_equal(german.line_count, 206)
    assert_equal(english.line_count, 208)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
