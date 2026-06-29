"""Historical visible prompt spellings separated from native execution tokens.

The native planner intentionally uses canonical reta option names.  Compact and
one-letter prompt commands historically print older mixed-case option spellings
before executing the same table.  This module preserves that presentation
contract without feeding legacy spellings back into the typed native planner.
"""

from std.collections import List
from .prompt_language import normalize_prompt_language


def _slice_after(text: String, prefix: String) -> String:
    return String(StringSlice(text)[byte=prefix.byte_length():])


def join_prompt_echo_tokens(tokens: List[String]) -> String:
    var result = String()
    for index in range(len(tokens)):
        if index > 0:
            result += " "
        result += tokens[index]
    return result^


def compact_prompt_announcement(
    prepared_tokens: List[String], source: String, language: String
) -> String:
    """Render the visible legacy compact-expansion announcement."""
    var expanded = join_prompt_echo_tokens(prepared_tokens)
    if normalize_prompt_language(language) == "english":
        return (
            "'"
            + expanded
            + "' results from '"
            + source
            + "' and results reta command after:"
        )
    return (
        "'"
        + expanded
        + "' ergibt sich aus '"
        + source
        + "' und ergibt danach reta-Befehl:"
    )


def legacy_table_echo_tokens(tokens: List[String]) -> List[String]:
    """Return historical display argv while retaining canonical execution argv."""
    var result = List[String]()
    for index in range(len(tokens)):
        var token = tokens[index]
        if token == "--menschliches=motive":
            result.append("--Menschliches=motivation")
        elif token.startswith("--grundstrukturen="):
            var value = _slice_after(token, "--grundstrukturen=")
            if value == "trieb,System":
                value = "Triebe_und_Bedürfnisse_(6),System"
            result.append("--Grundstrukturen=" + value)
        elif token.startswith("--universum="):
            result.append(
                "--Universum=" + _slice_after(token, "--universum=")
            )
        elif token.startswith("--galaxie="):
            result.append("--Galaxie=" + _slice_after(token, "--galaxie="))
        elif token.startswith("--planet="):
            result.append("--Planet=" + _slice_after(token, "--planet="))
        elif token.startswith("--strukturgroesse="):
            result.append(
                "--Strukturgroesse="
                + _slice_after(token, "--strukturgroesse=")
            )
        else:
            result.append(token)
    return result^
