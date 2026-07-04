"""Native owner of the historical setuptools metadata and command intent.

The Python ``setup.py`` mixed immutable distribution metadata with five command
classes.  Installation of the native project is owned by ``scripts/install.sh``
and ``scripts/install_targets.txt``.  This module preserves the remaining
observable setup surface as typed values and an explicit gettext extraction
plan; it does not import setuptools or embed Python.
"""

from std.collections import List
from .setup_metadata_catalog import *


@fieldwise_init
struct SetupCommandClassSpec(Copyable):
    var name: String
    var base_class: String
    var method_names: List[String]
    var defined_command_key: String
    var active_command_key: String
    var followup_command: String
    var has_extension_modules: Bool


@fieldwise_init
struct SetupExtractMessagesPlan(Copyable):
    var source_files: List[String]
    var output_file: String
    var command: String
    var prints_walk_object: Bool
    var prints_source_files: Bool
    var external_tool_required: Bool


@fieldwise_init
struct SetupInstallPlan(Copyable):
    var installer: String
    var target_manifest: String
    var private_runtime: String
    var shared_data: String
    var python_build_backend_required: Bool


@fieldwise_init
struct SetupMetadataSnapshot(Copyable):
    var name: String
    var version: String
    var description: String
    var author: String
    var requirements: List[String]
    var package_data_patterns: List[String]
    var discovered_packages: List[String]
    var command_classes: List[SetupCommandClassSpec]
    var defined_commands: List[String]
    var active_commands: List[String]
    var command_method_count: Int
    var extract_messages: SetupExtractMessagesPlan
    var install: SetupInstallPlan
    var python_build_backend_required: Bool


def _split_setup_methods(text: String) -> List[String]:
    var result = List[String]()
    if text.byte_length() == 0:
        return result^
    var pieces = text.split(",")
    for index in range(len(pieces)):
        result.append(String(pieces[index]))
    return result^


def _command_key_for_class(rows: List[String], class_name: String) -> String:
    for index in range(len(rows)):
        var pieces = rows[index].split("\t")
        if len(pieces) == 2 and String(pieces[1]) == class_name:
            return String(pieces[0])
    return String()


def setup_command_specs() -> List[SetupCommandClassSpec]:
    var names = setup_command_class_names()
    var bases = setup_command_class_bases()
    var methods = setup_command_class_methods()
    var defined_rows = setup_defined_command_rows()
    var active_rows = setup_active_command_rows()
    var result = List[SetupCommandClassSpec]()
    for index in range(len(names)):
        var name = names[index].copy()
        var followup = "build_mo" if name != "ExtractMessages" else String()
        result.append(
            SetupCommandClassSpec(
                name.copy(),
                bases[index].copy(),
                _split_setup_methods(methods[index]),
                _command_key_for_class(defined_rows, name),
                _command_key_for_class(active_rows, name),
                followup^,
                name == "Build",
            )
        )
    return result^


def setup_extract_messages_plan() -> SetupExtractMessagesPlan:
    var files = setup_extract_message_files()
    var output = setup_extract_message_output()
    var command = "xgettext --language=Python --output=" + output
    for index in range(len(files)):
        command += " " + files[index]
    return SetupExtractMessagesPlan(
        files^,
        output^,
        command^,
        True,
        True,
        True,
    )


def setup_install_plan() -> SetupInstallPlan:
    return SetupInstallPlan(
        "scripts/install.sh",
        "scripts/install_targets.txt",
        "${PREFIX}/lib/reta",
        "${PREFIX}/share/reta",
        False,
    )


def setup_metadata_snapshot() -> SetupMetadataSnapshot:
    return SetupMetadataSnapshot(
        setup_package_name(),
        setup_package_version(),
        setup_description(),
        setup_author(),
        setup_install_requirements(),
        setup_package_data_patterns(),
        setup_discovered_packages(),
        setup_command_specs(),
        setup_defined_command_rows(),
        setup_active_command_rows(),
        setup_command_method_count(),
        setup_extract_messages_plan(),
        setup_install_plan(),
        False,
    )


def setup_metadata_owner_contract() -> List[String]:
    return [
        "python_owner=setup.py",
        "metadata=generated-exact",
        "packages=find-packages-frozen",
        "command_classes=5/8-methods",
        "build_hooks=build_mo-plan",
        "gettext=xgettext-plan",
        "compiled_targets=scripts/install_targets.txt",
        "resources=scripts/install.sh",
        "setuptools_runtime=none",
        "python_runtime=none",
    ]
