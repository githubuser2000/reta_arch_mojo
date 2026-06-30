"""Compile-time integration probe for both final prompt boundary modules."""

from reta_mojo.prompt_python_bridge import read_prompt_line_encoded_bridge
from reta_mojo.prompt_external_commands import shell_quote


def main():
    # Importing both modules is the regression condition.  Stage 12c3 used a
    # second incompatible dlsym signature that only failed in this combination.
    print(shell_quote("ffi-integration"))
