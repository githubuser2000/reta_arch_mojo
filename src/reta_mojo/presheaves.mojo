"""Typed local sections and symbolic restriction for reta presheaves.

The Python presheaf accepts arbitrary ``object`` payloads. The native core uses
String payloads so ownership and serialization are explicit. More payload kinds
can later be added as tagged variants without weakening the type system.
"""
from std.collections import List
from .topology import ContextSelection, refine_selection, selection_is_empty


@fieldwise_init
struct LocalStringSection(Copyable):
    var context: ContextSelection
    var payload: String
    var source: String


struct StringPresheaf:
    var name: String
    var _sections: List[LocalStringSection]

    def __init__(out self, name: String):
        self.name = name
        self._sections = List[LocalStringSection]()

    def add_section(mut self, context: ContextSelection, payload: String, source: String = ""):
        self._sections.append(LocalStringSection(context.copy(), payload.copy(), source.copy()))

    def sections(self) -> List[LocalStringSection]:
        var result = List[LocalStringSection]()
        for index in range(len(self._sections)):
            result.append(self._sections[index].copy())
        return result^

    def restrict(self, context: ContextSelection) -> List[LocalStringSection]:
        var result = List[LocalStringSection]()
        for index in range(len(self._sections)):
            var refined = refine_selection(self._sections[index].context, context)
            if not selection_is_empty(refined):
                result.append(LocalStringSection(
                    refined^,
                    self._sections[index].payload.copy(),
                    self._sections[index].source.copy(),
                ))
        return result^
