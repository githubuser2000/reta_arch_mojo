"""Native Stage-40 word-completion morphisms.

This ports the deterministic runtime behaviour of
``reta_architecture/completion_word.py`` and the historical
``libs/word_completerAlx.py`` facade.  Mojo uses an explicit UTF-8 byte cursor,
matching the native prompt editor, while completion start positions remain
Unicode-scalar counts like prompt_toolkit/Python.
"""

from std.collections import List


@fieldwise_init
struct WordCompletionDecoration(Copyable):
    var word: String
    var display: String
    var display_meta: String


@fieldwise_init
struct WordCompletion(Copyable):
    var text: String
    var start_position: Int
    var display: String
    var display_meta: String


@fieldwise_init
struct WordCompletionMorphismBundle(Copyable):
    var legacy_owner: String
    var activated_stage: Int


def bootstrap_word_completion_morphisms() -> WordCompletionMorphismBundle:
    return WordCompletionMorphismBundle("libs.word_completerAlx", 40)


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _is_utf8_continuation(value: Int) -> Bool:
    return value >= 0x80 and value < 0xC0


def _previous_utf8_boundary(text: String, cursor: Int) -> Int:
    var result = min(max(cursor, 0), text.byte_length())
    if result == 0:
        return 0
    result -= 1
    var bytes = text.as_bytes()
    while result > 0 and _is_utf8_continuation(Int(bytes[result])):
        result -= 1
    return result


def _decode_codepoint(text: String, start: Int) -> Int:
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


def _is_unicode_whitespace(codepoint: Int) -> Bool:
    return (
        codepoint == 9
        or codepoint == 10
        or codepoint == 11
        or codepoint == 12
        or codepoint == 13
        or codepoint == 32
        or codepoint == 0x85
        or codepoint == 0xA0
        or (codepoint >= 0x2000 and codepoint <= 0x200A)
        or codepoint == 0x2028
        or codepoint == 0x2029
        or codepoint == 0x202F
        or codepoint == 0x205F
        or codepoint == 0x3000
    )


def _word_class(codepoint: Int) -> Int:
    """Mirror prompt_toolkit's default ``_FIND_WORD_RE`` classes.

    ASCII letters, digits and underscore form one class.  Every other
    non-whitespace codepoint forms the punctuation/Unicode class.  The class
    boundary is why ``grö`` completes from ``ö`` rather than ``grö`` in the
    historical prompt_toolkit route.
    """
    if _is_unicode_whitespace(codepoint):
        return 0
    if (
        (codepoint >= 48 and codepoint <= 57)
        or (codepoint >= 65 and codepoint <= 90)
        or (codepoint >= 97 and codepoint <= 122)
        or codepoint == 95
    ):
        return 1
    return 2


def utf8_scalar_count(text: String) -> Int:
    var count = 0
    var bytes = text.as_bytes()
    for index in range(len(bytes)):
        if not _is_utf8_continuation(Int(bytes[index])):
            count += 1
    return count


def word_before_cursor(
    text: String,
    cursor_byte: Int = -1,
    whole_word: Bool = False,
    sentence: Bool = False,
) -> String:
    """Return the prompt prefix inspected by the word completer.

    ``whole_word`` corresponds to prompt_toolkit's ``WORD=True``.  ``sentence``
    returns the complete text before the cursor.  The two modes are mutually
    exclusive, matching ``ArchitectureWordCompleter``.
    """
    var cursor = text.byte_length() if cursor_byte < 0 else min(
        max(cursor_byte, 0), text.byte_length()
    )
    while cursor > 0 and cursor < text.byte_length() and _is_utf8_continuation(
        Int(text.as_bytes()[cursor])
    ):
        cursor -= 1
    if sentence:
        return _slice(text, 0, cursor)

    if cursor == 0:
        return ""
    var previous = _previous_utf8_boundary(text, cursor)
    var last_codepoint = _decode_codepoint(text, previous)
    if _is_unicode_whitespace(last_codepoint):
        return ""
    var wanted_class = 1 if whole_word else _word_class(last_codepoint)
    var start = cursor
    while start > 0:
        previous = _previous_utf8_boundary(text, start)
        var codepoint = _decode_codepoint(text, previous)
        if whole_word:
            if _is_unicode_whitespace(codepoint):
                break
        elif _word_class(codepoint) != wanted_class:
            break
        start = previous
    return _slice(text, start, cursor)


def _utf8_prefix_scalars(text: String, count: Int) -> String:
    if count <= 0:
        return ""
    var seen = 0
    var end = 0
    var bytes = text.as_bytes()
    while end < len(bytes) and seen < count:
        if not _is_utf8_continuation(Int(bytes[end])):
            seen += 1
        end += 1
        while end < len(bytes) and _is_utf8_continuation(Int(bytes[end])):
            end += 1
    return _slice(text, 0, end)


def word_completion_matches(
    word: String,
    prefix: String,
    ignore_case: Bool = False,
    match_middle: Bool = False,
) -> Bool:
    """Preserve the historical, slightly unusual prefix-slice semantics."""
    var candidate = word.lower() if ignore_case else word
    var probe = prefix.lower() if ignore_case else prefix
    var sliced_probe = _utf8_prefix_scalars(
        probe, min(utf8_scalar_count(candidate), utf8_scalar_count(probe))
    )
    if match_middle:
        return candidate.find(sliced_probe) >= 0
    return candidate.startswith(sliced_probe)


def _decoration_for(
    decorations: List[WordCompletionDecoration], word: String
) -> WordCompletionDecoration:
    for index in range(len(decorations)):
        if decorations[index].word == word:
            return decorations[index].copy()
    return WordCompletionDecoration(word, word, "")


def resolve_words(words: List[String]) -> List[String]:
    """Resolve the owning native word section.

    A Python callable word source becomes a normal native producer that calls
    this API with a freshly produced list.  No untyped callback needs to remain
    stored in the completer.
    """
    return words.copy()


def iter_word_completions_from_prefix(
    words: List[String],
    prefix: String,
    ignore_case: Bool = False,
    match_middle: Bool = False,
    decorations: List[WordCompletionDecoration] = List[WordCompletionDecoration](),
) -> List[WordCompletion]:
    """Complete from an already restricted prefix section.

    This is the native adapter point for a custom pattern.  A typed regex or
    domain matcher computes its final prefix and passes it here; the matching,
    start-position and decoration semantics remain shared with the ordinary
    document route.
    """
    var result = List[WordCompletion]()
    var start_position = -utf8_scalar_count(prefix)
    for index in range(len(words)):
        var word = words[index]
        if word_completion_matches(word, prefix, ignore_case, match_middle):
            var decoration = _decoration_for(decorations, word)
            result.append(
                WordCompletion(
                    word,
                    start_position,
                    decoration.display,
                    decoration.display_meta,
                )
            )
    return result^


def iter_word_completions(
    words: List[String],
    text: String,
    cursor_byte: Int = -1,
    ignore_case: Bool = False,
    whole_word: Bool = False,
    sentence: Bool = False,
    match_middle: Bool = False,
    decorations: List[WordCompletionDecoration] = List[WordCompletionDecoration](),
) -> List[WordCompletion]:
    var prefix = word_before_cursor(text, cursor_byte, whole_word, sentence)
    return iter_word_completions_from_prefix(
        words, prefix, ignore_case, match_middle, decorations
    )



@fieldwise_init
struct WordCompletionSnapshot(Copyable):
    var class_name: String
    var stage: Int
    var legacy_owner: String
    var capsule: String
    var category: String
    var functor: String
    var natural_transformation: String
    var morphisms: List[String]
    var compatibility_names: List[String]
    var sample_prefix: String
    var sample_texts: List[String]


struct ArchitectureWordCompleter(Copyable):
    """Owning native equivalent of ``ArchitectureWordCompleter``.

    Python callables are resolved by the caller into a fresh ``List[String]``
    before construction or before calling ``iter_word_completions``.  This
    preserves dynamic vocabularies without retaining an untyped Python
    callback inside the native object.
    """

    var words: List[String]
    var ignore_case: Bool
    var decorations: List[WordCompletionDecoration]
    var whole_word: Bool
    var sentence: Bool
    var match_middle: Bool

    def __init__(
        out self,
        words: List[String],
        ignore_case: Bool = False,
        decorations: List[WordCompletionDecoration] = List[WordCompletionDecoration](),
        whole_word: Bool = False,
        sentence: Bool = False,
        match_middle: Bool = False,
    ) raises:
        if whole_word and sentence:
            raise Error("WORD and sentence completion are mutually exclusive")
        self.words = words.copy()
        self.ignore_case = ignore_case
        self.decorations = decorations.copy()
        self.whole_word = whole_word
        self.sentence = sentence
        self.match_middle = match_middle

    def get_completions(
        self, text: String, cursor_byte: Int = -1
    ) -> List[WordCompletion]:
        return iter_word_completions(
            self.words.copy(),
            text,
            cursor_byte,
            self.ignore_case,
            self.whole_word,
            self.sentence,
            self.match_middle,
            self.decorations.copy(),
        )

    def replace_words(mut self, words: List[String]):
        """Refresh a vocabulary produced by a native dynamic word source."""
        self.words = words.copy()

    def same_words(self, other: Self) -> Bool:
        if len(self.words) != len(other.words):
            return False
        for index in range(len(self.words)):
            if self.words[index] != other.words[index]:
                return False
        return True


def create_word_completer(
    bundle: WordCompletionMorphismBundle,
    words: List[String],
    ignore_case: Bool = False,
    decorations: List[WordCompletionDecoration] = List[WordCompletionDecoration](),
    whole_word: Bool = False,
    sentence: Bool = False,
    match_middle: Bool = False,
) raises -> ArchitectureWordCompleter:
    _ = bundle
    return ArchitectureWordCompleter(
        words,
        ignore_case,
        decorations,
        whole_word,
        sentence,
        match_middle,
    )

def sample_word_completions(prefix: String = "re") -> List[String]:
    var result = List[String]()
    var completions = iter_word_completions(
        ["reta", "religion", "alpha"], prefix
    )
    for index in range(len(completions)):
        result.append(completions[index].text)
    return result^


def word_completion_snapshot(
    bundle: WordCompletionMorphismBundle,
) -> WordCompletionSnapshot:
    return WordCompletionSnapshot(
        "WordCompletionMorphismBundle",
        bundle.activated_stage,
        bundle.legacy_owner,
        "InputPromptCapsule",
        "ActivatedWordCompletionCategory",
        "WordCompletionActivationFunctor",
        "WordCompleterToArchitectureTransformation",
        [
            "resolve_words",
            "word_before_cursor",
            "word_completion_matches",
            "iter_word_completions",
            "iter_word_completions_from_prefix",
            "create_completer",
        ],
        ["WordCompleter", "word_completerAlx.WordCompleter"],
        "re",
        sample_word_completions("re"),
    )
