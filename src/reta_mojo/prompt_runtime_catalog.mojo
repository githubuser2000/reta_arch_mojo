"""Generated prompt-runtime contract; do not edit by hand.

Regenerate with ``tools/generate_prompt_runtime_catalog.py``.
"""

from std.collections import List
from .prompt_runtime import (
    PromptProgramViewContract,
    PromptVocabularyContract,
    PromptRuntimeContract,
)


def prompt_runtime_contract(language: String) -> PromptRuntimeContract:
    var normalized = language.strip().lower()
    if normalized == "deutsch" or normalized == "de" or normalized == "german":
        return PromptRuntimeContract(
            "deutsch",
            PromptProgramViewContract(
                "PromptProgramView",
                ["zeilen", "spalten", "kombination", "ausgabe", "debug", "h", "help"],
                [0, 1, 2, 3, -1, -1, -1],
                432,
                4155,
                [556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0],
                46,
                51,
                556,
                1024,
                163,
            ),
            PromptVocabularyContract(
                7,
                15,
                14,
                7,
                3,
                385,
                386,
                84,
                4160,
                21,
                7,
            ),
            ">",
            "was speichern>",
            "was löschen>",
            True,
            [],
        )
    elif normalized == "english" or normalized == "en" or normalized == "englisch":
        return PromptRuntimeContract(
            "english",
            PromptProgramViewContract(
                "PromptProgramView",
                ["lines", "columns", "combination", "output", "debug", "h", "help"],
                [0, 1, 2, 3, -1, -1, -1],
                432,
                2671,
                [556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0],
                35,
                41,
                556,
                1024,
                163,
            ),
            PromptVocabularyContract(
                7,
                15,
                14,
                7,
                3,
                366,
                367,
                64,
                2676,
                21,
                7,
            ),
            ">",
            "save what>",
            "delete what>",
            True,
            [],
        )
    elif normalized == "vietnamese":
        return PromptRuntimeContract(
            "vietnamese",
            PromptProgramViewContract(
                "PromptProgramView",
                ["lines", "columns", "combination", "output", "debug", "h", "help"],
                [0, 1, 2, 3, -1, -1, -1],
                432,
                2671,
                [556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0],
                35,
                41,
                556,
                1024,
                163,
            ),
            PromptVocabularyContract(
                7,
                15,
                14,
                7,
                3,
                366,
                367,
                64,
                2676,
                21,
                7,
            ),
            ">",
            "save what>",
            "delete what>",
            True,
            [],
        )
    elif normalized == "chinese":
        return PromptRuntimeContract(
            "chinese",
            PromptProgramViewContract(
                "PromptProgramView",
                ["lines", "columns", "combination", "output", "debug", "h", "help"],
                [0, 1, 2, 3, -1, -1, -1],
                432,
                2671,
                [556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0],
                35,
                41,
                556,
                1024,
                163,
            ),
            PromptVocabularyContract(
                7,
                15,
                14,
                7,
                3,
                366,
                367,
                64,
                2676,
                21,
                7,
            ),
            ">",
            "save what>",
            "delete what>",
            True,
            [],
        )
    elif normalized == "korean":
        return PromptRuntimeContract(
            "korean",
            PromptProgramViewContract(
                "PromptProgramView",
                ["lines", "columns", "combination", "output", "debug", "h", "help"],
                [0, 1, 2, 3, -1, -1, -1],
                432,
                2671,
                [556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0],
                35,
                41,
                556,
                1024,
                163,
            ),
            PromptVocabularyContract(
                7,
                15,
                14,
                7,
                3,
                366,
                367,
                64,
                2676,
                21,
                7,
            ),
            ">",
            "save what>",
            "delete what>",
            True,
            [],
        )
    return prompt_runtime_contract("deutsch")
