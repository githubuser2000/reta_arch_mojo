from reta_mojo.table_preparation import bootstrap_table_preparation


def _join(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += "\x1f"
        result += values[index]
    return result^


def main() raises:
    var snapshot = bootstrap_table_preparation().snapshot()
    print("class=" + snapshot.class_name)
    print("display_line_morphism=" + snapshot.display_line_morphism)
    print("row_morphism=" + snapshot.row_morphism)
    print("tag_gluing_morphism=" + snapshot.tag_gluing_morphism)
    print("cell_morphism=" + snapshot.cell_morphism)
    print("parallel_row_morphism=" + snapshot.parallel_row_morphism)
    print("deduplication_morphism=" + snapshot.deduplication_morphism)
    print("last_line_morphism=" + snapshot.last_line_morphism)
    print("universal_operations=" + _join(snapshot.universal_operations))
    print("main_table_result=" + snapshot.main_table_result)
    print("kombi_table_result=" + snapshot.kombi_table_result)
    print("legacy_delegate=" + snapshot.legacy_delegate)
