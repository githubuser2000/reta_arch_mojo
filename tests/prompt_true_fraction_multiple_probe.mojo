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
    print("CASE\t" + text + "\t" + serialize_prompt_table_plan(plan))


def main() raises:
    _emit("universum v2/3")
    _emit("universum vielfache 2/3")
    _emit("universum v2/3 teiler")
    _emit("emotion v2/3")
    _emit("groesse v2/3")
    _emit("motive v2/3")
    _emit("emotion v8/3")
    _emit("groesse v17/3")
    _emit("motive v22/3")
    _emit("universum v20/3")
    _emit("universum motive v2/3")
    _emit("emotion groesse motive universum v2/3")
    _emit("emotion universum v8/3")
    _emit("emotion universum v1/2,2/3")
    _emit("mond universum motive v2/3")
    _emit("universum v2/3,5")
    _emit("universum v2/3,5 teiler")
    _emit("universum motive v2/3,5")
    _emit("emotion universum v8/3,5")
    _emit("emotion universum v1/2,2/3,5")
    _emit("universum motive v2/3,5-7")
    _emit("universum motive v2/3,0")
    _emit("universum motive v2/3,5,-10")
    _emit("universum motive v2/3 -10")
    _emit("universum v1/2,2/3")
    _emit("universum vielfache 1/2,2/3")
    _emit("universum v-1/4,2/3")
    _emit("universum v-2/3")
    _emit("universum v-2/3,1/4")
    _emit("universum v1/4,-2/3")
    _emit("universum v1/2,-2/3")
    _emit("emotion v1/4,-2/3")
    _emit("universum v1/4,-2/3 teiler")
    _emit("universum v1/4,-1/8,2/3")
