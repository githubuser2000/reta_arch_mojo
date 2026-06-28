"""Typed native morphisms over the ported Reta architecture layers."""

from std.collections import List
from .parameter_semantics import (
    ParameterSemanticsSheaf,
    CanonicalPair,
    resolve_main_alias,
    resolve_parameter_alias,
    canonicalize_pair,
    column_numbers_for_pair,
)
from .row_ranges import range_to_numbers, split_top_level_commas
from .output_modes import output_mode_spec


@fieldwise_init
struct AliasMorphisms(Copyable):
    var parameter_semantics: ParameterSemanticsSheaf

    def resolve_main_alias(self, main_name: String) -> String:
        return resolve_main_alias(self.parameter_semantics, main_name)

    def resolve_parameter_alias(
        self, main_name: String, parameter_name: String
    ) -> String:
        return resolve_parameter_alias(
            self.parameter_semantics, main_name, parameter_name
        )

    def canonicalize_pair(
        self, main_name: String, parameter_name: String
    ) -> CanonicalPair:
        return canonicalize_pair(
            self.parameter_semantics, main_name, parameter_name
        )

    def column_numbers_for_pair(
        self, main_name: String, parameter_name: String
    ) -> List[Int]:
        return column_numbers_for_pair(
            self.parameter_semantics, main_name, parameter_name
        )


@fieldwise_init
struct RangeMorphisms(Copyable):
    var maximum: Int

    def parse_row_range(self, text: String) raises -> List[Int]:
        var values = range_to_numbers(text, False, self.maximum)
        var result = List[Int]()
        for value in values:
            result.append(value)
        _sort_ints(result)
        return result^


@fieldwise_init
struct PromptMorphisms(Copyable):
    var reta_command_prefix: String

    def split(self, text: String) -> List[String]:
        return split_top_level_commas(text)

    def split_prompt_text(self, text: String) -> List[String]:
        return self.split(text)

    def split_command_words(self, text: String) -> List[String]:
        if not text.startswith(self.reta_command_prefix):
            return self.split(text)
        var slices = text.split()
        var result = List[String]()
        for index in range(len(slices)):
            var word = String(slices[index].strip())
            if word.byte_length() != 0:
                result.append(word^)
        return result^


@fieldwise_init
struct RendererMorphisms(Copyable):
    var default_mode: String

    def canonical_output_mode(self, requested_mode: String) -> String:
        var spec = output_mode_spec(requested_mode)
        if spec.canonical_name.byte_length() != 0:
            return spec.canonical_name
        return self.default_mode


@fieldwise_init
struct MorphismBundle(Copyable):
    var alias_morphisms: AliasMorphisms
    var range_morphisms: RangeMorphisms
    var prompt_morphisms: PromptMorphisms
    var renderer_morphisms: RendererMorphisms


def bootstrap_morphisms(
    parameter_semantics: ParameterSemanticsSheaf,
    maximum: Int = 1028,
    default_output_mode: String = "terminal",
) -> MorphismBundle:
    return MorphismBundle(
        AliasMorphisms(parameter_semantics.copy()),
        RangeMorphisms(maximum),
        PromptMorphisms("reta"),
        RendererMorphisms(default_output_mode),
    )


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key
