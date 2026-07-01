from reta_mojo.resource_paths import (
    asset_resource,
    asset_root,
    csv_resource,
    csv_root,
    reference_root,
    runtime_root,
    share_root,
)


def main():
    print("root=" + runtime_root())
    print("share=" + share_root())
    print("csv=" + csv_root())
    print("asset=" + asset_root())
    print("reference=" + reference_root())
    print("religion=" + csv_resource("religion.csv"))
    print("aliases=" + asset_resource("parameter_aliases.tsv"))
