from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.setup_metadata import *


def test_setup_metadata_matches_reference() raises:
    var snapshot = setup_metadata_snapshot()
    assert_equal(snapshot.name, "reta")
    assert_equal(snapshot.version, "3.20250507.4591")
    assert_equal(snapshot.description, "Religions-Tabelle")
    assert_equal(snapshot.author, "Jupiter 3.0 alias trace")
    assert_equal(len(snapshot.requirements), 4)
    assert_equal(snapshot.requirements[0], "html2text==2020.1.16")
    assert_equal(snapshot.requirements[3], "rich==10.12.0")
    assert_equal(snapshot.discovered_packages, ["reta_architecture", "tests"])
    assert_equal(len(snapshot.command_classes), 5)
    assert_equal(snapshot.command_method_count, 8)
    assert_equal(snapshot.defined_commands[0], "build\tBuild")
    assert_equal(snapshot.active_commands, ["extract_messages\tExtractMessages"])
    assert_false(snapshot.python_build_backend_required)


def test_build_hooks_and_extract_messages_are_explicit() raises:
    var classes = setup_command_specs()
    assert_equal(classes[0].name, "Build")
    assert_equal(classes[0].base_class, "build_py")
    assert_equal(classes[0].method_names, ["run", "has_ext_modules"])
    assert_equal(classes[0].defined_command_key, "build")
    assert_equal(classes[0].followup_command, "build_mo")
    assert_true(classes[0].has_extension_modules)
    assert_equal(classes[4].name, "ExtractMessages")
    assert_equal(classes[4].active_command_key, "extract_messages")
    assert_equal(classes[4].followup_command, "")

    var plan = setup_extract_messages_plan()
    assert_equal(len(plan.source_files), 6)
    assert_equal(plan.source_files[0], "i18n/words.py")
    assert_equal(plan.source_files[5], "i18n/words_runtime.py")
    assert_equal(plan.output_file, "i18n/messages.pot")
    assert_true(plan.command.startswith("xgettext --language=Python"))
    assert_true(plan.command.endswith("i18n/words_runtime.py"))
    assert_true(plan.external_tool_required)


def test_native_install_owner_replaces_setuptools_runtime() raises:
    var install = setup_install_plan()
    assert_equal(install.installer, "scripts/install.sh")
    assert_equal(install.target_manifest, "scripts/install_targets.txt")
    assert_equal(install.private_runtime, "${PREFIX}/lib/reta")
    assert_equal(install.shared_data, "${PREFIX}/share/reta")
    assert_false(install.python_build_backend_required)
    assert_equal(len(setup_metadata_owner_contract()), 10)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
