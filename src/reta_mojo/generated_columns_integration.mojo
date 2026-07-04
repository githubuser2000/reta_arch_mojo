"""Typed integration boundary for historical generated-column mutation.

``generated_columns.py`` accepted a heterogeneous Python ``Concat`` object and
mutated its table, selections and generator bookkeeping in place.  All actual
algorithms already have native owners.  This module replaces the final dynamic
object boundary with one explicit request/result pair and delegates the ordered
pipeline to ``generated_table_columns.apply_native_generated_columns``.
"""

from std.collections import List
from .csv_table import CsvTable
from .generated_aliases import (
    FractionColumnRequest,
    MetaColumnRequest,
    ModalConcept,
)
from .generated_columns import (
    GeneratedColumnsBundle,
    bootstrap_generated_columns,
)
from .generated_table_columns import (
    GeneratedTableResult,
    apply_native_generated_columns,
)


@fieldwise_init
struct GeneratedColumnsApplicationRequest(Copyable):
    var table: CsvTable
    var selected_columns: List[Int]
    var modal_concepts: List[ModalConcept]
    var meta_requests: List[MetaColumnRequest]
    var fraction_requests: List[FractionColumnRequest]
    var generated_commands: List[String]
    var language: String
    var output_mode: String
    var last_row: Int


@fieldwise_init
struct GeneratedColumnsIntegrationSnapshot(Copyable, Equatable):
    var class_name: String
    var registry_count: Int
    var request_fields: Int
    var ordered_pipeline: Bool
    var dynamic_concat_object: Bool
    var python_runtime: Bool


@fieldwise_init
struct GeneratedColumnsRuntime(Copyable):
    var bundle: GeneratedColumnsBundle

    def snapshot(self) -> GeneratedColumnsIntegrationSnapshot:
        return GeneratedColumnsIntegrationSnapshot(
            "GeneratedColumnsRuntime",
            self.bundle.registry.snapshot().count,
            9,
            True,
            False,
            False,
        )

    def apply(
        self,
        request: GeneratedColumnsApplicationRequest,
    ) raises -> GeneratedTableResult:
        return apply_native_generated_columns(
            request.table,
            request.selected_columns,
            request.modal_concepts,
            request.meta_requests,
            request.fraction_requests,
            request.generated_commands,
            request.language,
            request.output_mode,
            request.last_row,
        )


def bootstrap_generated_columns_runtime() -> GeneratedColumnsRuntime:
    return GeneratedColumnsRuntime(bootstrap_generated_columns())


def apply_generated_columns_request(
    request: GeneratedColumnsApplicationRequest,
) raises -> GeneratedTableResult:
    return bootstrap_generated_columns_runtime().apply(request)


def generated_columns_integration_contract() -> List[String]:
    return [
        "python_owner=reta_architecture/generated_columns.py",
        "dynamic_input=removed",
        "request=GeneratedColumnsApplicationRequest",
        "result=GeneratedTableResult",
        "registry=GeneratedColumnsBundle",
        "order=historical-mutation-order",
        "scalar=generated_columns.mojo",
        "table=generated_table_columns.mojo",
        "prime_cross=prime_cross_columns.mojo",
        "prime_universe=prime_universe_columns.mojo",
        "meta=meta_columns.mojo",
        "fraction=fraction_concat_columns.mojo",
        "python_runtime=none",
    ]
