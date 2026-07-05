from reta_mojo.prompt_historical_ownership import (
    historical_prompt_execution_supported,
)
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import (
    plan_prompt_table_commands,
    serialize_prompt_table_plan,
)


def _emit(text: String) raises:
    var catalog = load_prompt_language_catalog("assets")
    var words = split_prompt_words(text)
    var owned = historical_prompt_execution_supported(
        words.copy(), words.copy(), "deutsch", catalog
    )
    var plan = plan_prompt_table_commands(words^, "deutsch", catalog)
    var ownership = "OWNED" if owned else "FALLBACK"
    print(
        "CASE\t"
        + text
        + "\t"
        + ownership
        + "\t"
        + serialize_prompt_table_plan(plan)
    )


def main() raises:
    _emit("richtung 2 --justtext")
    _emit("richtung 2 --onetable")
    _emit("richtung 2 --endlessscreen")
    _emit("richtung 2 --endless")
    _emit("richtung 2 --dontwrap")
    _emit("richtung 2 --breiten=5,7")
    _emit(
        "richtung 2 --nocolor --justtext --art=csv --onetable "
        "--spaltenreihenfolgeundnurdiese=0,1 --endlessscreen --endless "
        "--dontwrap --breite=40 --breiten=5,7 --keineleereninhalte "
        "--keinenummerierung --keineueberschriften"
    )
