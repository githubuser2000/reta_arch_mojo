"""Generated native packaging contract from ``setup.py``.

Regenerate with ``tools/generate_setup_metadata.py``.
"""

from std.collections import List


def setup_package_name() -> String:
    return "reta"


def setup_package_version() -> String:
    return "3.20250507.4591"


def setup_description() -> String:
    return "Religions-Tabelle"


def setup_author() -> String:
    return "Jupiter 3.0 alias trace"


def setup_install_requirements() -> List[String]:
    return [
        "html2text==2020.1.16",
        "bbcode==1.1.0",
	#"pyphen==0.9.5",
	#"PyHyphen==3.0.1",
        "prompt_toolkit==3.0.19",
        "rich==10.12.0"
    ]


def setup_package_data_patterns() -> List[String]:
    return [
        ".\t*.txt",
        ".\t*.csv",
        "reta\ti18n/*.po",
        "reta\ti18n/*.mo"
    ]


def setup_discovered_packages() -> List[String]:
    return [
        "reta_architecture",
        "tests"
    ]


def setup_command_class_names() -> List[String]:
    return [
        "Build",
        "BuildExt",
        "BuildClib",
        "BuildScripts",
        "ExtractMessages"
    ]


def setup_command_class_bases() -> List[String]:
    return [
        "build_py",
        "build_ext",
        "build_clib",
        "build_scripts",
        "Command"
    ]


def setup_command_class_methods() -> List[String]:
    return [
        "run,has_ext_modules",
        "run",
        "run",
        "run",
        "initialize_options,finalize_options,run"
    ]



def setup_command_method_count() -> Int:
    return 8


def setup_defined_command_rows() -> List[String]:
    return [
        "build\tBuild",
        "build_ext\tBuildExt",
        "build_clib\tBuildClib",
        "build_scripts\tBuildScripts"
    ]


def setup_active_command_rows() -> List[String]:
    return [
        "extract_messages\tExtractMessages"
    ]


def setup_extract_message_files() -> List[String]:
    return [
        "i18n/words.py",
        "i18n/words_bootstrap.py",
        "i18n/words_context.py",
        "i18n/words_legacy_monolith.py",
        "i18n/words_matrix.py",
        "i18n/words_runtime.py"
    ]



def setup_extract_message_output() -> String:
    return "i18n/messages.pot"
