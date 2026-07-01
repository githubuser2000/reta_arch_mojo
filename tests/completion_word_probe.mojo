from reta_mojo.completion_word import *


def emit(label: String, values: List[WordCompletion]):
    for index in range(len(values)):
        print(
            label,
            "\t",
            values[index].text,
            "\t",
            values[index].start_position,
            "\t",
            values[index].display,
            "\t",
            values[index].display_meta,
            sep="",
        )


def main() raises:
    emit("prefix", iter_word_completions(["reta", "religion", "alpha"], "re"))
    emit("middle", iter_word_completions(["alpha", "beta", "theta"], "et", -1, False, False, False, True))
    emit("case", iter_word_completions(["Reta", "Religion"], "re", -1, True))
    emit("unicode", iter_word_completions(["größe", "grün", "öße", "öko"], "grö"))
    emit("whole", iter_word_completions(["alpha-beta", "beta"], "alpha-beta", -1, False, True))
    emit("sentence", iter_word_completions(["reta --hilfe", "reta --version"], "reta --h", -1, False, False, True))
