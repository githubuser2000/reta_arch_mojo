"""Complete typed native owner for ``reta_architecture.morphisms``.

The Python layer stores a shared topology object and forwards work to callable
owners.  The native layer keeps the same four morphism families, uses the
ported topology/semantic/output types directly, and represents the only
unowned callback boundary (prompt shorthand expansion) as a typed request.
"""

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
from .output_modes import (
    OutputRuntimeState,
    apply_output_mode as apply_native_output_mode,
    canonicalize_output_mode,
)
from .topology import ContextSelection, unrestricted_selection


@fieldwise_init
struct PromptExpansionRequest(Copyable, Equatable, Writable):
    var prompt_mode: Int
    var prompt_text: String
    var additional_text: String


@fieldwise_init
struct MorphismSnapshot(Copyable):
    var available: List[String]


@fieldwise_init
struct AliasMorphisms(Copyable):
    var topology_context: ContextSelection
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
    var topology_context: ContextSelection
    var maximum: Int

    def parse_row_range(self, text: String) raises -> List[Int]:
        var values = range_to_numbers(text, False, self.maximum)
        var result = List[Int]()
        for value in values:
            result.append(value)
        _sort_ints(result)
        return _deduplicate_sorted(result^)


@fieldwise_init
struct PromptMorphisms(Copyable):
    var topology_context: ContextSelection
    var reta_command_prefix: String

    def split(self, text: String) -> List[String]:
        return split_top_level_commas(text)

    def split_prompt_text(self, text: String) -> List[String]:
        return self.split(text)

    def split_command_words(self, text: String) -> List[String]:
        # Python checks text[:4] == "reta". startswith is equivalent for the
        # fixed four-byte command prefix and also preserves the retaXYZ case.
        if not text.startswith(self.reta_command_prefix):
            return self.split(text)
        var slices = text.split()
        var result = List[String]()
        for index in range(len(slices)):
            var word = String(slices[index].strip())
            if word.byte_length() != 0:
                result.append(word^)
        return result^

    def expand_shorthand(
        self,
        prompt_mode: Int,
        prompt_text: String,
        additional_text: String,
    ) -> PromptExpansionRequest:
        """Preserve the historical callback invocation as a typed request.

        The Python method contains no expansion algorithm; it merely invokes a
        caller-supplied callable.  Native owners consume this request without
        reintroducing a dynamic callable or Python bridge.
        """
        return PromptExpansionRequest(
            prompt_mode, prompt_text.copy(), additional_text.copy()
        )


@fieldwise_init
struct RendererMorphisms(Copyable):
    var topology_context: ContextSelection
    var default_mode: String

    def output_mode_for_tables(self, state: OutputRuntimeState) -> String:
        var canonical = canonicalize_output_mode(state.canonical_name)
        if canonical.byte_length() != 0:
            return canonical
        return self.default_mode

    def apply_output_mode(
        self, state: OutputRuntimeState, mode: String
    ) -> OutputRuntimeState:
        return apply_native_output_mode(state, mode)

    def canonical_output_mode(self, requested_mode: String) -> String:
        var canonical = canonicalize_output_mode(requested_mode)
        if canonical.byte_length() != 0:
            return canonical
        return self.default_mode


@fieldwise_init
struct MorphismBundle(Copyable):
    var alias_morphisms: AliasMorphisms
    var range_morphisms: RangeMorphisms
    var prompt_morphisms: PromptMorphisms
    var renderer_morphisms: RendererMorphisms

    @staticmethod
    def from_topology_and_sheaves(
        topology_context: ContextSelection,
        parameter_semantics: ParameterSemanticsSheaf,
        maximum: Int = 1028,
        default_output_mode: String = "shell",
    ) -> Self:
        return Self(
            AliasMorphisms(
                topology_context.copy(), parameter_semantics.copy()
            ),
            RangeMorphisms(topology_context.copy(), maximum),
            PromptMorphisms(topology_context.copy(), "reta"),
            RendererMorphisms(topology_context.copy(), default_output_mode),
        )

    def snapshot(self) -> MorphismSnapshot:
        return MorphismSnapshot([
            "alias", "ranges", "prompt", "renderers"
        ])


def bootstrap_morphisms(
    parameter_semantics: ParameterSemanticsSheaf,
    maximum: Int = 1028,
    default_output_mode: String = "shell",
) -> MorphismBundle:
    return MorphismBundle.from_topology_and_sheaves(
        unrestricted_selection(),
        parameter_semantics,
        maximum,
        default_output_mode,
    )


def _deduplicate_sorted(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        if len(result) == 0 or result[len(result) - 1] != values[index]:
            result.append(values[index])
    return result^


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key
