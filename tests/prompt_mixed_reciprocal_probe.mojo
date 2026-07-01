from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import (
    plan_prompt_table_commands,
    serialize_prompt_table_plan,
)


def _emit(text: String) raises:
    var catalog = load_prompt_language_catalog("assets")
    var plan = plan_prompt_table_commands(
        split_prompt_words(text), "deutsch", catalog
    )
    print(serialize_prompt_table_plan(plan))


def main() raises:
    _emit("universum teiler 1/2")
    _emit("universum vielfache 1/2")
    _emit("universum vielfache teiler 1/2")
    _emit("universum v1/2 teiler")
    _emit("universum vielfache teiler 1/2,-1/4")
