"""Native inventory for the historical architecture-refactor regression suite.

The old Python test module mixed 70 contracts from unrelated architecture
owners into one ``unittest`` class.  The production behavior now belongs to
focused Mojo modules and focused Mojo tests.  This owner loads the generated
one-to-one contract map and makes omissions, reordering, and stale mappings
observable without importing the Python suite at runtime.
"""

from std.collections import List

from .csv_table import read_text_file
from .resource_paths import asset_resource


@fieldwise_init
struct ArchitectureRefactorContract(Copyable, Equatable):
    var ordinal: Int
    var python_test: String
    var source_line: Int
    var assertions: Int
    var category: String
    var native_owner: String
    var native_test: String
    var evidence: String
    var ast_sha256: String


@fieldwise_init
struct ArchitectureRefactorContractSnapshot(Copyable, Equatable):
    var contracts: Int
    var assertions: Int
    var categories: Int
    var native_tests: Int
    var architecture_contracts: Int
    var table_contracts: Int
    var prompt_contracts: Int


def _refactor_contract_contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def load_architecture_refactor_contracts(
    path: String = "",
) raises -> List[ArchitectureRefactorContract]:
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("architecture_refactor_contracts.tsv")
    )
    var contracts = List[ArchitectureRefactorContract]()
    var lines = read_text_file(source_path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("ordinal\t"):
            continue
        var fields = line.split("\t")
        if len(fields) != 9:
            raise Error(
                "invalid architecture-refactor contract row "
                + String(line_index + 1)
            )
        contracts.append(
            ArchitectureRefactorContract(
                atol(String(fields[0])),
                String(fields[1]),
                atol(String(fields[2])),
                atol(String(fields[3])),
                String(fields[4]),
                String(fields[5]),
                String(fields[6]),
                String(fields[7]),
                String(fields[8]),
            )
        )
    return contracts^


def architecture_refactor_contract_index(
    contracts: List[ArchitectureRefactorContract], python_test: String
) -> Int:
    for index in range(len(contracts)):
        if contracts[index].python_test == python_test:
            return index
    return -1


def architecture_refactor_category_count(
    contracts: List[ArchitectureRefactorContract], category: String
) -> Int:
    var count = 0
    for index in range(len(contracts)):
        if contracts[index].category == category:
            count += 1
    return count


def architecture_refactor_contracts_valid(
    contracts: List[ArchitectureRefactorContract],
) -> Bool:
    if len(contracts) == 0:
        return False
    var names = List[String]()
    for index in range(len(contracts)):
        var contract = contracts[index].copy()
        if contract.ordinal != index + 1:
            return False
        if not contract.python_test.startswith("test_"):
            return False
        if contract.source_line <= 0 or contract.assertions <= 0:
            return False
        if (
            contract.category.byte_length() == 0
            or not contract.native_owner.endswith(".mojo")
            or not contract.native_test.startswith("tests/")
            or contract.evidence.byte_length() == 0
            or contract.ast_sha256.byte_length() != 64
        ):
            return False
        if _refactor_contract_contains(names, contract.python_test):
            return False
        names.append(contract.python_test.copy())
    return True


def architecture_refactor_contract_snapshot(
    contracts: List[ArchitectureRefactorContract],
) -> ArchitectureRefactorContractSnapshot:
    var assertions = 0
    var categories = List[String]()
    var native_tests = List[String]()
    for index in range(len(contracts)):
        var contract = contracts[index].copy()
        assertions += contract.assertions
        if not _refactor_contract_contains(categories, contract.category):
            categories.append(contract.category.copy())
        if not _refactor_contract_contains(native_tests, contract.native_test):
            native_tests.append(contract.native_test.copy())
    return ArchitectureRefactorContractSnapshot(
        len(contracts),
        assertions,
        len(categories),
        len(native_tests),
        architecture_refactor_category_count(contracts, "architecture"),
        architecture_refactor_category_count(contracts, "table"),
        architecture_refactor_category_count(contracts, "prompt"),
    )
