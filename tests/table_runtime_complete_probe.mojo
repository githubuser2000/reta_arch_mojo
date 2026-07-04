from reta_mojo.table_runtime import bootstrap_table_runtime


def _join(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += "\x1f"
        result += values[index]
    return result^


def main() raises:
    var snapshot = bootstrap_table_runtime().snapshot()
    print("class=" + snapshot.class_name)
    print("table_class=" + snapshot.table_class)
    print(
        "owns_legacy_tables="
        + ("true" if snapshot.owns_legacy_tables else "false")
    )
    print("legacy_facade=" + snapshot.legacy_facade)
    print("state_class=" + snapshot.state_sections.class_name)
    print("state_sections=" + _join(snapshot.state_sections.sections))
    print("state_architecture_owner=" + snapshot.state_sections.architecture_owner)
    print("state_legacy_owner=" + snapshot.state_sections.legacy_owner)
    print("component_morphisms=" + _join(snapshot.component_morphisms))
