"""Fixed native plans for classic integer-family fraction parity."""

from std.collections import List
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import (
    plan_prompt_table_commands,
    serialize_prompt_table_plan,
)


def _emit(command: String) raises:
    var catalog = load_prompt_language_catalog("assets")
    var plan = plan_prompt_table_commands(
        split_prompt_words(command), "deutsch", catalog
    )
    if not plan.handled:
        print("FALLBACK")
    elif len(plan.invocations) == 0:
        print("NOOP")
    else:
        print(serialize_prompt_table_plan(plan))


def main() raises:
    _emit("mond 1/2")
    _emit("richtung 2/3")
    _emit("primzahlkreuz 2/4")
    _emit("alles -1/2")
    _emit("thomas 1/2,-1/4")
    _emit("mond 2/2")
    _emit("alles 4/2")
    _emit("mond 1/2,3")
