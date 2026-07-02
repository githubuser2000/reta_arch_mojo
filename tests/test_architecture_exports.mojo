from reta_mojo.architecture_exports import *


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var catalog = load_architecture_export_catalog()
    var snapshot = architecture_export_snapshot(catalog)
    assert_true(snapshot.imports == 314, "import count")
    assert_true(snapshot.public_exports == 232, "public export count")
    assert_true(snapshot.private_imports == 82, "private import count")
    assert_true(snapshot.modules == 46, "module count")

    var architecture = architecture_export(catalog, "RetaArchitecture")
    assert_true(architecture.module == "facade", "facade owner")
    assert_true(architecture.is_public, "facade public")

    var prompt = architecture_exports_for_module(catalog, "prompt_session", True)
    assert_true(len(prompt) == 5, "prompt_session public exports")
    assert_true(prompt[0].public_name == "PromptLoopSetup", "__all__ order")

    var public_exports = architecture_public_exports(catalog)
    assert_true(len(public_exports) == 232, "public list")
    assert_true(public_exports[0].all_ordinal == 0, "first ordinal")
    assert_true(public_exports[231].all_ordinal == 231, "last ordinal")
    print("architecture_exports=ok")
