"""Generated lightweight prompt-prefix contract; do not edit by hand.

Regenerate with ``tools/generate_prompt_runtime_catalog.py``.
"""


@fieldwise_init
struct PromptPrefixContract(Copyable):
    var normal: String
    var store: String
    var delete: String


def prompt_prefix_contract(language: String) -> PromptPrefixContract:
    var normalized = language.strip().lower()
    if normalized == "deutsch" or normalized == "de" or normalized == "german":
        return PromptPrefixContract(
            ">",
            "was speichern>",
            "was löschen>",
        )
    elif normalized == "english" or normalized == "en" or normalized == "englisch":
        return PromptPrefixContract(
            ">",
            "save what>",
            "delete what>",
        )
    elif normalized == "vietnamese":
        return PromptPrefixContract(
            ">",
            "save what>",
            "delete what>",
        )
    elif normalized == "chinese":
        return PromptPrefixContract(
            ">",
            "save what>",
            "delete what>",
        )
    elif normalized == "korean":
        return PromptPrefixContract(
            ">",
            "save what>",
            "delete what>",
        )
    return prompt_prefix_contract("deutsch")
