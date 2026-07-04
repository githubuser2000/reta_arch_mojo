"""Generated exact surface catalogs for historical ``mojo_bridge.py``.

Regenerate with ``tools/generate_legacy_mojo_bridge_catalog.py``.
"""

from std.collections import List


def legacy_mojo_bridge_public_names() -> List[String]:
    return [
        "REFERENCE_ROOT",
        "run_reta",
        "run_reta_encoded",
        "run_reta_subprocess_encoded",
        "read_prompt_line_encoded",
        "run_reta_prompt_subprocess_encoded",
        "run_shell_line",
        "run_python_code",
        "run_math_expression",
        "run_reta_line",
        "run_reta_prompt_line_encoded",
        "run_shell_prompt_line",
        "run_python_prompt_line",
        "run_math_prompt_line",
        "generate_html_document"
    ]


def legacy_mojo_bridge_function_names() -> List[String]:
    return [
        "run_reta",
        "run_reta_encoded",
        "run_reta_subprocess_encoded",
        "_close_prompt_completion_process",
        "_prompt_completion_process",
        "_native_prompt_completion",
        "_configure_prompt_readline",
        "complete",
        "read_prompt_line_encoded",
        "run_reta_prompt_subprocess_encoded",
        "run_shell_line",
        "run_python_code",
        "run_math_expression",
        "run_reta_line",
        "run_reta_prompt_line_encoded",
        "run_shell_prompt_line",
        "run_python_prompt_line",
        "run_math_prompt_line",
        "generate_html_document"
    ]


def legacy_mojo_bridge_public_count() -> Int:
    return 15


def legacy_mojo_bridge_function_count() -> Int:
    return 19
