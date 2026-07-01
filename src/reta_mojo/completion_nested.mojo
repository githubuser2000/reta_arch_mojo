"""Native owner of Reta's hierarchical prompt completion state machine.

This ports ``reta_architecture/completion_nested.py`` and the historical
``libs/nestedAlx.py`` facade.  The generated completion runtime supplies local
sections; this module owns context selection, main/parameter/value transitions,
comma fragments, fuzzy ordering and completion snapshots.
"""

from std.collections import List
from .completion_runtime import (
    CompletionRuntimeBundle,
    bootstrap_completion_runtime,
)
from .completion_word import utf8_scalar_count
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
)


@fieldwise_init
struct CompletionSituation(Copyable, Equatable):
    var value: Int

    @staticmethod
    def main_parameter() -> Self:
        return Self(0)

    @staticmethod
    def row_parameter() -> Self:
        return Self(1)

    @staticmethod
    def generic_value() -> Self:
        return Self(3)

    @staticmethod
    def neither() -> Self:
        return Self(4)

    @staticmethod
    def reta_begin() -> Self:
        return Self(5)

    @staticmethod
    def unknown() -> Self:
        return Self(6)

    @staticmethod
    def column_parameter() -> Self:
        return Self(7)

    @staticmethod
    def combination_parameter() -> Self:
        return Self(8)

    @staticmethod
    def combination_meta_parameter() -> Self:
        return Self(9)

    @staticmethod
    def output_parameter() -> Self:
        return Self(10)

    @staticmethod
    def column_value() -> Self:
        return Self(11)

    @staticmethod
    def row_value() -> Self:
        return Self(12)

    @staticmethod
    def combination_value() -> Self:
        return Self(13)

    @staticmethod
    def output_value() -> Self:
        return Self(14)

    @staticmethod
    def non_reta_command() -> Self:
        return Self(15)

    def name(self) -> String:
        if self.value == 0:
            return "hauptPara"
        if self.value == 1:
            return "zeilenPara"
        if self.value == 3:
            return "value"
        if self.value == 4:
            return "neitherNor"
        if self.value == 5:
            return "retaAnfang"
        if self.value == 6:
            return "unbekannt"
        if self.value == 7:
            return "spaltenPara"
        if self.value == 8:
            return "komiPara"
        if self.value == 9:
            return "kombiMetaPara"
        if self.value == 10:
            return "ausgabePara"
        if self.value == 11:
            return "spaltenValPara"
        if self.value == 12:
            return "zeilenValPara"
        if self.value == 13:
            return "kombiValPara"
        if self.value == 14:
            return "ausgabeValPara"
        if self.value == 15:
            return "befehleNichtReta"
        return "unbekannt"


@fieldwise_init
struct NestedCompletion(Copyable):
    var text: String
    var start_position: Int


@fieldwise_init
struct NestedCompletionMorphismBundle(Copyable):
    var legacy_owner: String
    var activated_stage: Int


@fieldwise_init
struct NestedCompletionSnapshot(Copyable):
    var class_name: String
    var stage: Int
    var legacy_owner: String
    var capsule: String
    var category: String
    var functor: String
    var natural_transformation: String
    var morphisms: List[String]
    var compatibility_names: List[String]
    var situations: List[String]


struct ArchitectureNestedCompleter(Copyable):
    """Typed, owning native nested completer."""

    var runtime: CompletionRuntimeBundle
    var situation: CompletionSituation
    var ignore_case: Bool

    def __init__(
        out self,
        runtime: CompletionRuntimeBundle,
        situation: CompletionSituation = CompletionSituation.reta_begin(),
        ignore_case: Bool = True,
    ):
        self.runtime = runtime.copy()
        self.situation = situation.copy()
        self.ignore_case = ignore_case

    def candidates(self, text_before_cursor: String) -> List[String]:
        return nested_completion_candidates(self.runtime, text_before_cursor)

    def get_completions(
        self, text_before_cursor: String
    ) -> List[NestedCompletion]:
        var values = self.candidates(text_before_cursor)
        var fragment = nested_completion_fragment(text_before_cursor)
        var start_position = -utf8_scalar_count(fragment)
        var result = List[NestedCompletion]()
        for index in range(len(values)):
            result.append(NestedCompletion(values[index], start_position))
        return result^

    def same_runtime(self, other: Self) -> Bool:
        return (
            self.runtime.language == other.runtime.language
            and len(self.runtime.root_commands) == len(other.runtime.root_commands)
            and len(self.runtime.main_parameters) == len(other.runtime.main_parameters)
        )


def bootstrap_nested_completion_morphisms() -> NestedCompletionMorphismBundle:
    return NestedCompletionMorphismBundle("libs.nestedAlx", 41)


def create_nested_completer(
    bundle: NestedCompletionMorphismBundle,
    runtime: CompletionRuntimeBundle,
    situation: CompletionSituation = CompletionSituation.reta_begin(),
    ignore_case: Bool = True,
) -> ArchitectureNestedCompleter:
    _ = bundle
    return ArchitectureNestedCompleter(runtime, situation, ignore_case)


def nested_completion_snapshot(
    bundle: NestedCompletionMorphismBundle
) -> NestedCompletionSnapshot:
    return NestedCompletionSnapshot(
        "NestedCompletionMorphismBundle",
        bundle.activated_stage,
        bundle.legacy_owner,
        "InputPromptCapsule",
        "ActivatedNestedCompletionCategory",
        "NestedCompletionActivationFunctor",
        "NestedCompleterToArchitectureTransformation",
        [
            "create_completer",
            "matchTextAlx",
            "paraZeilen",
            "paraSpalten",
            "paraAusgabe",
            "paraKombination",
            "gleichKommaZeilen",
            "gleichKommaSpalten",
            "gleichKommaAusg",
            "gleichKommaKombi",
            "get_completions",
        ],
        ["NestedCompleter", "ComplSitua", "nestedAlx.NestedCompleter"],
        [
            "hauptPara",
            "zeilenPara",
            "value",
            "neitherNor",
            "retaAnfang",
            "unbekannt",
            "spaltenPara",
            "komiPara",
            "kombiMetaPara",
            "ausgabePara",
            "spaltenValPara",
            "zeilenValPara",
            "kombiValPara",
            "ausgabeValPara",
            "befehleNichtReta",
        ],
    )


def _contains_nested(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_nested(mut values: List[String], value: String) -> None:
    if not _contains_nested(values, value):
        values.append(value)


@fieldwise_init
struct NestedFuzzyCandidate(Copyable):
    var value: String
    var start: Int
    var length: Int
    var order: Int


def _is_utf8_continuation_nested(value: Int) -> Bool:
    return value >= 0x80 and value < 0xC0


def _decode_codepoint_nested(text: String, start: Int) -> Int:
    var bytes = text.as_bytes()
    if start < 0 or start >= len(bytes):
        return -1
    var first = Int(bytes[start])
    if first < 0x80:
        return first
    if first < 0xE0 and start + 1 < len(bytes):
        return ((first & 0x1F) << 6) | (Int(bytes[start + 1]) & 0x3F)
    if first < 0xF0 and start + 2 < len(bytes):
        return (
            ((first & 0x0F) << 12)
            | ((Int(bytes[start + 1]) & 0x3F) << 6)
            | (Int(bytes[start + 2]) & 0x3F)
        )
    if start + 3 < len(bytes):
        return (
            ((first & 0x07) << 18)
            | ((Int(bytes[start + 1]) & 0x3F) << 12)
            | ((Int(bytes[start + 2]) & 0x3F) << 6)
            | (Int(bytes[start + 3]) & 0x3F)
        )
    return first


def _codepoints_nested(text: String) -> List[Int]:
    var result = List[Int]()
    var bytes = text.as_bytes()
    var index = 0
    while index < len(bytes):
        result.append(_decode_codepoint_nested(text, index))
        index += 1
        while index < len(bytes) and _is_utf8_continuation_nested(Int(bytes[index])):
            index += 1
    return result^


def _nested_fuzzy_match(value: String, query: String) -> NestedFuzzyCandidate:
    # prompt_toolkit's fuzzy matcher operates on Unicode characters, not UTF-8
    # bytes.  This matters for stable ordering of German completion names.
    var candidate = _codepoints_nested(value.lower())
    var wanted = _codepoints_nested(query.lower())
    if len(wanted) == 0:
        return NestedFuzzyCandidate(value, 0, 0, 0)
    var best_start = -1
    var best_length = 0
    for start in range(len(candidate)):
        if candidate[start] != wanted[0]:
            continue
        var candidate_index = start
        var wanted_index = 0
        while candidate_index < len(candidate) and wanted_index < len(wanted):
            if candidate[candidate_index] == wanted[wanted_index]:
                wanted_index += 1
            candidate_index += 1
        if wanted_index == len(wanted):
            var matched_length = candidate_index - start
            if (
                best_start < 0
                or start < best_start
                or (start == best_start and matched_length < best_length)
            ):
                best_start = start
                best_length = matched_length
    return NestedFuzzyCandidate(value, best_start, best_length, 0)


def _nested_filter_prefix(
    values: List[String], prefix: String
) -> List[String]:
    """Mirror prompt_toolkit FuzzyWordCompleter ordering."""
    var matches = List[NestedFuzzyCandidate]()
    for index in range(len(values)):
        var fuzzy = _nested_fuzzy_match(values[index], prefix)
        if fuzzy.start >= 0:
            fuzzy.order = index
            matches.append(fuzzy^)
    for index in range(1, len(matches)):
        var key = matches[index].copy()
        var previous = index - 1
        while previous >= 0:
            var item = matches[previous].copy()
            var after = (
                item.start > key.start
                or (item.start == key.start and item.length > key.length)
            )
            if not after:
                break
            matches[previous + 1] = item.copy()
            previous -= 1
        matches[previous + 1] = key^
    var result = List[String]()
    for index in range(len(matches)):
        _append_unique_nested(result, matches[index].value)
    return result^



@fieldwise_init
struct _NestedMatchRange(Copyable):
    var a_start: Int
    var a_end: Int
    var b_start: Int
    var b_end: Int


@fieldwise_init
struct _NestedLongestMatch(Copyable):
    var a_start: Int
    var b_start: Int
    var size: Int


@fieldwise_init
struct _NestedCloseCandidate(Copyable):
    var value: String
    var matches: Int
    var total: Int


def _nested_longest_match(
    a: List[Int],
    b: List[Int],
    region: _NestedMatchRange,
) -> _NestedLongestMatch:
    var best_a = region.a_start
    var best_b = region.b_start
    var best_size = 0
    for a_index in range(region.a_start, region.a_end):
        for b_index in range(region.b_start, region.b_end):
            if a[a_index] != b[b_index]:
                continue
            var size = 0
            while (
                a_index + size < region.a_end
                and b_index + size < region.b_end
                and a[a_index + size] == b[b_index + size]
            ):
                size += 1
            if size > best_size:
                best_a = a_index
                best_b = b_index
                best_size = size
    return _NestedLongestMatch(best_a, best_b, best_size)


def _nested_sequence_match_count(first: String, second: String) -> Int:
    """Match count used by difflib.SequenceMatcher without junk/autojunk.

    Completion parameter names are far below SequenceMatcher's 200-element
    autojunk threshold, so recursive longest contiguous blocks reproduce the
    relevant Python ratio exactly.
    """
    var a = _codepoints_nested(first)
    var b = _codepoints_nested(second)
    if len(a) == 0 or len(b) == 0:
        return 0
    var pending = List[_NestedMatchRange]()
    pending.append(_NestedMatchRange(0, len(a), 0, len(b)))
    var matched = 0
    while len(pending) > 0:
        var region = pending.pop()
        var block = _nested_longest_match(a, b, region)
        if block.size == 0:
            continue
        matched += block.size
        if region.a_start < block.a_start and region.b_start < block.b_start:
            pending.append(
                _NestedMatchRange(
                    region.a_start,
                    block.a_start,
                    region.b_start,
                    block.b_start,
                )
            )
        var a_after = block.a_start + block.size
        var b_after = block.b_start + block.size
        if a_after < region.a_end and b_after < region.b_end:
            pending.append(
                _NestedMatchRange(
                    a_after,
                    region.a_end,
                    b_after,
                    region.b_end,
                )
            )
    return matched


def _nested_close_score_after(
    left: _NestedCloseCandidate,
    right: _NestedCloseCandidate,
) -> Bool:
    # Descending ratio; Python's heap tuple uses descending lexical value for
    # equal scores as the secondary ordering.
    var left_scaled = left.matches * right.total
    var right_scaled = right.matches * left.total
    if left_scaled != right_scaled:
        return left_scaled < right_scaled
    return left.value < right.value


def _nested_close_matches(
    word: String,
    possibilities: List[String],
    maximum: Int = 3,
) -> List[String]:
    """Native ``difflib.get_close_matches(..., n=3, cutoff=0.6)``."""
    var scored = List[_NestedCloseCandidate]()
    var word_length = len(_codepoints_nested(word))
    for index in range(len(possibilities)):
        var candidate = possibilities[index]
        var candidate_length = len(_codepoints_nested(candidate))
        var total = word_length + candidate_length
        if total == 0:
            continue
        var matches = _nested_sequence_match_count(candidate, word)
        # 2 * matches / total >= 0.6  <=>  10 * matches >= 3 * total.
        if 10 * matches < 3 * total:
            continue
        var item = _NestedCloseCandidate(candidate, matches, total)
        var position = len(scored)
        scored.append(item.copy())
        while position > 0 and _nested_close_score_after(
            scored[position - 1], item
        ):
            scored[position] = scored[position - 1].copy()
            position -= 1
        scored[position] = item^
    var result = List[String]()
    for index in range(min(maximum, len(scored))):
        result.append(scored[index].value)
    return result^

def _last_nonempty_nested(values: List[String]) -> String:
    var index = len(values) - 1
    while index >= 0:
        if values[index].byte_length() > 0:
            return values[index]
        index -= 1
    return ""


def _main_context_nested(
    runtime: CompletionRuntimeBundle, words: List[String]
) -> String:
    var active = String()
    for word_index in range(len(words)):
        for main_index in range(len(runtime.main_parameters)):
            if words[word_index] == runtime.main_parameters[main_index]:
                active = words[word_index]
                break
    return active^


def _slice_nested(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _parameter_name_nested(token: String) -> String:
    var stripped = token
    if stripped.startswith("--"):
        stripped = _slice_nested(stripped, 2, stripped.byte_length())
    var equals = stripped.find("=")
    if equals >= 0:
        stripped = _slice_nested(stripped, 0, equals)
    return stripped^


def _current_fragment_nested(token: String) -> String:
    var equals = token.find("=")
    if equals < 0:
        return token
    var value = _slice_nested(token, equals + 1, token.byte_length())
    var pieces = value.split(",")
    if len(pieces) == 0:
        return ""
    return String(pieces[len(pieces) - 1])


def nested_completion_fragment(text_before_cursor: String) -> String:
    var text = String(text_before_cursor.lstrip())
    var words = balanced_prompt_split(text)
    if len(words) == 0:
        return ""
    return _current_fragment_nested(_last_nonempty_nested(words))


def nested_completion_candidates(
    runtime: CompletionRuntimeBundle,
    text_before_cursor: String,
) -> List[String]:
    """Resolve root, main, parameter and comma-separated value sections."""
    var text = String(text_before_cursor.lstrip())
    var ends_with_space = (
        text.endswith(" ")
        or text.endswith("\t")
        or text.endswith("\n")
        or text.endswith("\r")
    )
    var words = balanced_prompt_split(text)
    if len(words) == 0:
        return runtime.root_commands.copy()

    var first = _last_nonempty_nested(words)
    if words[0] != "reta":
        if len(words) == 1 and not ends_with_space:
            return _nested_filter_prefix(runtime.root_commands, first)
        if ends_with_space:
            return runtime.root_commands.copy()
        return _nested_filter_prefix(runtime.root_commands, first)

    if len(words) == 1:
        if ends_with_space:
            return runtime.main_parameters.copy()
        return _nested_filter_prefix(runtime.root_commands, words[0])

    var active_main = _main_context_nested(runtime, words)
    var current = String(words[len(words) - 1])
    if ends_with_space:
        current = ""

    if active_main.byte_length() == 0:
        return _nested_filter_prefix(runtime.main_parameters, current)

    for index in range(len(runtime.main_parameters)):
        if current == runtime.main_parameters[index]:
            if ends_with_space:
                return runtime.parameters(current)
            return _nested_filter_prefix(runtime.main_parameters, current)

    if current.startswith("-") and not current.startswith("--"):
        return _nested_filter_prefix(runtime.main_parameters, current)

    var parameters = runtime.parameters(active_main)
    if current.find("=") < 0:
        return _nested_filter_prefix(parameters, current)

    var name = _parameter_name_nested(current)
    var fragment = _current_fragment_nested(current)
    if runtime.has_value_context(active_main, name):
        return _nested_filter_prefix(
            runtime.value_options(active_main, name), fragment
        )
    return _nested_filter_prefix(
        _nested_close_matches(name, runtime.value_parameter_names(active_main)),
        fragment,
    )


def nested_completion_candidates_from_catalog(
    catalog: PromptLanguageCatalog,
    language: String,
    text_before_cursor: String,
) -> List[String]:
    return nested_completion_candidates(
        CompletionRuntimeBundle(catalog, language), text_before_cursor
    )


def bootstrap_nested_completer(
    asset_root: String,
    language: String = "deutsch",
) raises -> ArchitectureNestedCompleter:
    return ArchitectureNestedCompleter(
        bootstrap_completion_runtime(asset_root, language)
    )


def nested_sequence_match_count(first: String, second: String) -> Int:
    """Public test seam for the difflib-compatible matcher."""
    return _nested_sequence_match_count(first, second)


def nested_close_matches(
    word: String, possibilities: List[String], maximum: Int = 3
) -> List[String]:
    """Public typed equivalent of ``difflib.get_close_matches``."""
    return _nested_close_matches(word, possibilities, maximum)
