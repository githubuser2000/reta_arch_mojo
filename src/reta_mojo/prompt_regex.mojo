"""Native regex/wildcard expansion for the interactive prompt.

This module is intentionally independent from the heavier row-range and divisor
preparation owner so the productive prompt controller can import it without
recompiling the complete table-generation graph.
"""

from std.collections import List
from std.collections.string import ord
from std.ffi import CStringSlice, c_int, c_size_t, external_call
from std.memory import stack_allocation
from .prompt_language import (
    PromptLanguageCatalog,
    normalize_prompt_language,
    prompt_root_commands,
    prompt_vocabulary_alias,
)
from .prompt_preparation_catalog import PromptPreparationCatalog

comptime _REG_EXTENDED = 1
comptime _REG_NOSUB = 8
comptime _REGEX_STORAGE_WORDS = 128


@fieldwise_init
struct PromptRegexResult(Copyable):
    var tokens: List[String]
    var changed: Bool


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _tail(text: String, start: Int) -> String:
    return String(StringSlice(text)[byte=start:])


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique(mut values: List[String], value: String) -> None:
    if not _contains(values, value):
        values.append(value)


def _join(values: List[String], separator: String) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += separator
        result += values[index]
    return result^


def _translate_python_regex(pattern: String) -> String:
    """Translate common Python-regex spellings to POSIX extended syntax.

    The historical prompt UI primarily uses literals, ``.*``, groups and
    alternation.  Character-class shorthands and non-capturing groups are
    normalized so those useful Python forms remain accepted natively.
    Unsupported look-around/back-reference constructs fail closed.
    """
    var result = String()
    var index = 0
    while index < pattern.byte_length():
        if index + 3 <= pattern.byte_length() and _slice(pattern, index, index + 3) == "(?:":
            result += "("
            index += 3
            continue
        if index + 2 <= pattern.byte_length():
            var pair = _slice(pattern, index, index + 2)
            if pair == "\\d":
                result += "[0-9]"
                index += 2
                continue
            if pair == "\\D":
                result += "[^0-9]"
                index += 2
                continue
            if pair == "\\w":
                result += "[[:alnum:]_]"
                index += 2
                continue
            if pair == "\\W":
                result += "[^[:alnum:]_]"
                index += 2
                continue
            if pair == "\\s":
                result += "[[:space:]]"
                index += 2
                continue
            if pair == "\\S":
                result += "[^[:space:]]"
                index += 2
                continue
        result += _slice(pattern, index, index + 1)
        index += 1
    return result^


@fieldwise_init
struct _RegexSearchResult(Copyable):
    var valid: Bool
    var matched: Bool


def _regex_search(pattern: String, text: String) raises -> _RegexSearchResult:
    if pattern.find("(?=") >= 0 or pattern.find("(?!") >= 0 or pattern.find("(?<") >= 0:
        return _RegexSearchResult(False, False)
    var translated = _translate_python_regex(pattern)
    var storage = stack_allocation[_REGEX_STORAGE_WORDS, UInt64]()
    var pattern_storage = translated + "\0"
    var text_storage = text + "\0"
    var code = external_call["regcomp", c_int](
        storage,
        CStringSlice(pattern_storage),
        c_int(_REG_EXTENDED | _REG_NOSUB),
    )
    if Int(code) != 0:
        return _RegexSearchResult(False, False)
    var match_code = external_call["regexec", c_int](
        storage,
        CStringSlice(text_storage),
        c_size_t(0),
        None,
        c_int(0),
    )
    external_call["regfree", NoneType](storage)
    return _RegexSearchResult(True, Int(match_code) == 0)


def _matches(pattern: String, text: String) raises -> Bool:
    var result = _regex_search(pattern, text)
    return result.valid and result.matched


def _is_regex_token(text: String) -> Bool:
    return text.byte_length() >= 3 and text.startswith("r\"") and text.endswith("\"")


def _regex_body(text: String) -> String:
    return _slice(text, 2, text.byte_length() - 1)


def _domain_parameters(
    catalog: PromptPreparationCatalog,
    language: String,
    main_parameter: String,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.domains)):
        var domain = catalog.domains[index].copy()
        if domain.language == normalized and domain.main_parameter == main_parameter:
            _append_unique(result, domain.parameter)
    return result^


def _domain_values(
    catalog: PromptPreparationCatalog,
    language: String,
    main_parameter: String,
    parameter: String,
) -> List[String]:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.domains)):
        var domain = catalog.domains[index].copy()
        if (
            domain.language == normalized
            and domain.main_parameter == main_parameter
            and domain.parameter == parameter
        ):
            return domain.values.copy()
    return List[String]()


def _is_no_value_domain(values: List[String]) -> Bool:
    return len(values) == 1 and values[0] == ""


def _main_parameter_from_tokens(
    catalog: PromptLanguageCatalog,
    language: String,
    tokens: List[String],
) -> String:
    var result = String()
    for index in range(len(tokens)):
        var token = tokens[index]
        if token.byte_length() > 1 and token.startswith("-") and not token.startswith("--"):
            result = _tail(token, 1)
    return result^


def _main_aliases(
    catalog: PromptLanguageCatalog,
    language: String,
) -> List[String]:
    var result = List[String]()
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "zeilen"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "spalten"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "kombination"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "ausgabe"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "h"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "help"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "debug"))
    _append_unique(result, prompt_vocabulary_alias(catalog, language, "main", "nichts"))
    return result^


def _matching_main_parameters(
    catalog: PromptLanguageCatalog,
    language: String,
    pattern: String,
) raises -> List[String]:
    var result = List[String]()
    var aliases = _main_aliases(catalog, language)
    for index in range(len(aliases)):
        if _matches(pattern, aliases[index]) or _matches(pattern, "-" + aliases[index]):
            _append_unique(result, "-" + aliases[index])
    return result^


def _matching_root_commands(
    catalog: PromptLanguageCatalog,
    language: String,
    pattern: String,
) raises -> List[String]:
    var result = List[String]()
    var roots = prompt_root_commands(catalog, language)
    for index in range(len(roots)):
        if roots[index].byte_length() > 1 and _matches(pattern, roots[index]):
            _append_unique(result, roots[index])
    return result^


def _matching_no_value_parameters(
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    main_parameter: String,
    pattern: String,
) raises -> List[String]:
    var result = List[String]()
    var parameters = _domain_parameters(
        preparation_catalog, language, main_parameter
    )
    for index in range(len(parameters)):
        var values = _domain_values(
            preparation_catalog, language, main_parameter, parameters[index]
        )
        if (
            _is_no_value_domain(values)
            and (
                _matches(pattern, parameters[index])
                or _matches(pattern, "--" + parameters[index])
            )
        ):
            result.append("--" + parameters[index])
    return result^


@fieldwise_init
struct _ExpandedParameter(Copyable):
    var parameter: String
    var values: List[String]
    var no_value: Bool


def _find_expanded_parameter(
    values: List[_ExpandedParameter], parameter: String
) -> Int:
    for index in range(len(values)):
        if values[index].parameter == parameter:
            return index
    return -1


def _append_expansion(
    mut expansions: List[_ExpandedParameter],
    parameter: String,
    value: String,
    no_value: Bool,
) -> None:
    var found = _find_expanded_parameter(expansions, parameter)
    if found < 0:
        var values = List[String]()
        if not no_value or value.byte_length() > 0:
            values.append(value)
        expansions.append(_ExpandedParameter(parameter, values^, no_value))
        return
    if not no_value or value.byte_length() > 0:
        _append_unique(expansions[found].values, value)


def _render_expansions(expansions: List[_ExpandedParameter]) -> List[String]:
    var result = List[String]()
    for index in range(len(expansions)):
        var expansion = expansions[index].copy()
        if expansion.no_value and len(expansion.values) == 0:
            result.append("--" + expansion.parameter)
        elif len(expansion.values) > 0:
            result.append(
                "--" + expansion.parameter + "=" + _join(expansion.values, ",")
            )
    return result^


def _parameter_candidates(
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    main_parameter: String,
    left: String,
) raises -> Tuple[List[String], Bool]:
    var result = List[String]()
    var normalized_left = left
    if normalized_left == "*" or normalized_left == "--*" or normalized_left == "--":
        normalized_left = "r\"(.*)\""
    if _is_regex_token(normalized_left):
        var pattern = _regex_body(normalized_left)
        var parameters = _domain_parameters(
            preparation_catalog, language, main_parameter
        )
        for index in range(len(parameters)):
            if (
                _matches(pattern, parameters[index])
                or _matches(pattern, parameters[index] + "=")
                or _matches(pattern, "--" + parameters[index])
            ):
                result.append(parameters[index])
        return (result^, True)
    var plain = normalized_left
    if plain.startswith("--"):
        plain = _tail(plain, 2)
    if plain.endswith("="):
        plain = _slice(plain, 0, plain.byte_length() - 1)
    result.append(plain)
    return (result^, False)


def _expand_equals_token(
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    main_parameter: String,
    token: String,
) raises -> PromptRegexResult:
    var equals = -1
    for index in range(token.byte_length()):
        if ord(token[byte=index]) == 61:
            equals = index
            break
    if equals < 0:
        var unchanged = List[String]()
        unchanged.append(token)
        return PromptRegexResult(unchanged^, False)

    var left = _slice(token, 0, equals)
    var right = _tail(token, equals + 1)
    var candidates_and_regex = _parameter_candidates(
        preparation_catalog, language, main_parameter, left
    )
    var candidates = candidates_and_regex[0].copy()
    var left_changed = candidates_and_regex[1]
    var right_parts = right.split(",")
    var expansions = List[_ExpandedParameter]()
    var changed = left_changed

    for right_index in range(len(right_parts)):
        var right_value = String(right_parts[right_index])
        var right_regex = False
        var pattern = String()
        if right_value == "*":
            right_regex = True
            pattern = "(.*)"
        elif _is_regex_token(right_value):
            right_regex = True
            pattern = _regex_body(right_value)
        if right_regex:
            changed = True
        for candidate_index in range(len(candidates)):
            var parameter = candidates[candidate_index]
            var values = _domain_values(
                preparation_catalog, language, main_parameter, parameter
            )
            if len(values) == 0:
                continue
            var no_value = _is_no_value_domain(values)
            if right_regex:
                if no_value:
                    _append_expansion(expansions, parameter, "", True)
                else:
                    for value_index in range(len(values)):
                        var value = values[value_index]
                        if (
                            _matches(pattern, value)
                            or _matches(pattern, "=" + value)
                        ):
                            _append_expansion(
                                expansions, parameter, value, False
                            )
            elif left_changed:
                changed = True
                if no_value:
                    if right_value.byte_length() > 0:
                        _append_expansion(
                            expansions, parameter, right_value, False
                        )
                    else:
                        _append_expansion(expansions, parameter, "", True)
                elif _contains(values, right_value):
                    _append_expansion(
                        expansions, parameter, right_value, False
                    )

    if not changed:
        var unchanged = List[String]()
        unchanged.append(token)
        return PromptRegexResult(unchanged^, False)
    return PromptRegexResult(_render_expansions(expansions), True)


def _is_reta_command_token(token: String) -> Bool:
    return token == "reta" or token == "+reta"


def regex_replace(
    catalog: PromptLanguageCatalog,
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    input_tokens: List[String],
) raises -> PromptRegexResult:
    var needs_expansion = False
    for index in range(len(input_tokens)):
        if input_tokens[index].find("r\"") >= 0 or input_tokens[index].find("*") >= 0:
            needs_expansion = True
            break
    if not needs_expansion:
        return PromptRegexResult(input_tokens.copy(), False)

    var if_reta = len(input_tokens) > 0 and _is_reta_command_token(input_tokens[0])
    var result = List[String]()
    var changed = False
    for token_index in range(len(input_tokens)):
        var token = input_tokens[token_index]
        if token.find("=") >= 0:
            var main_parameter = _main_parameter_from_tokens(
                catalog, language, result
            )
            var expanded = _expand_equals_token(
                preparation_catalog,
                language,
                main_parameter,
                token,
            )
            if expanded.changed:
                changed = True
            for index in range(len(expanded.tokens)):
                result.append(expanded.tokens[index])
            continue
        if _is_regex_token(token):
            changed = True
            var pattern = _regex_body(token)
            if not if_reta:
                var roots = _matching_root_commands(catalog, language, pattern)
                for index in range(len(roots)):
                    result.append(roots[index])
                continue
            var main_parameter = _main_parameter_from_tokens(
                catalog, language, result
            )
            if main_parameter.byte_length() > 0:
                var parameters = _matching_no_value_parameters(
                    preparation_catalog,
                    language,
                    main_parameter,
                    pattern,
                )
                for index in range(len(parameters)):
                    result.append(parameters[index])
            var mains = _matching_main_parameters(catalog, language, pattern)
            for index in range(len(mains)):
                result.append(mains[index])
            continue
        result.append(token)
    return PromptRegexResult(result^, changed)


