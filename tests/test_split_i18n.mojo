from std.testing import assert_equal, assert_false, assert_true
from reta_mojo.split_i18n import (
    build_split_i18n_proxy,
    build_split_i18n_proxy_from_modules,
    default_split_i18n_module_names,
    split_i18n_has,
    split_i18n_kind,
    split_i18n_node,
    split_i18n_node_count,
    split_i18n_root_count,
    split_i18n_value,
)


def main() raises:
    var names = default_split_i18n_module_names()
    assert_equal(len(names), 3)
    assert_equal(names[0], "i18n.words_context")
    assert_equal(names[1], "i18n.words_matrix")
    assert_equal(names[2], "i18n.words_runtime")

    var proxy = build_split_i18n_proxy("de")
    assert_equal(proxy.language, "deutsch")
    assert_equal(len(proxy.source_modules), 3)
    assert_true(split_i18n_has(proxy, "sprachen"))
    assert_true(split_i18n_has(proxy, "__behavior__.classify[4]"))
    assert_false(split_i18n_has(proxy, "does_not_exist"))
    # Later modules override earlier modules, exactly like setattr in Python.
    var sprachen = split_i18n_node(proxy, "sprachen")
    assert_equal(sprachen.module, "i18n.words_runtime")
    assert_equal(sprachen.kind, "ref")
    assert_equal(sprachen.value, "i18n.words_context:sprachen")
    assert_equal(split_i18n_kind(proxy, "x"), "function")
    assert_equal(
        split_i18n_value(proxy, "__behavior__.classify[1]"), "Gegenteil"
    )
    assert_true(split_i18n_node_count(proxy) > 6000)
    assert_true(split_i18n_root_count(proxy) > 60)

    var context_only = build_split_i18n_proxy_from_modules(
        "english", ["i18n.words_context"]
    )
    assert_equal(context_only.language, "english")
    assert_equal(
        split_i18n_node(context_only, "sprachen").module, "i18n.words_context"
    )
    assert_equal(split_i18n_node(context_only, "sprachen").kind, "defaultdict")
    assert_false(split_i18n_has(context_only, "__behavior__.classify[4]"))
    print("split_i18n=12/12")
