"""Native query CLI for the generated split i18n.words contract."""

from std.sys import argv
from std.collections.string import atol
from reta_mojo.i18n_words import *


def _usage() -> None:
    print("reta-mojo-i18n")
    print("  --summary [LANGUAGE]")
    print("  --get LANGUAGE MODULE PATH")
    print("  --classify LANGUAGE 0..4")
    print("  --dump LANGUAGE")


def _print_summary(language: String) raises:
    var catalog = load_i18n_words_catalog(language)
    var snapshot = i18n_words_snapshot(catalog)
    print("language=" + snapshot.language)
    print("rows=" + String(snapshot.rows))
    print("roots=" + String(snapshot.roots))
    print("bootstrap_rows=" + String(snapshot.bootstrap_rows))
    print("context_rows=" + String(snapshot.context_rows))
    print("matrix_rows=" + String(snapshot.matrix_rows))
    print("runtime_rows=" + String(snapshot.runtime_rows))
    print("facade_rows=" + String(snapshot.facade_rows))
    print("legacy_monolith_rows=" + String(snapshot.legacy_monolith_rows))


def main() raises:
    var args = argv()
    if len(args) == 1:
        _print_summary("deutsch")
        return
    var command = String(args[1])
    if command == "--summary":
        var language = "deutsch"
        if len(args) >= 3:
            language = String(args[2])
        _print_summary(language)
        return
    if command == "--get" and len(args) == 5:
        var catalog = load_i18n_words_catalog(String(args[2]))
        var node = i18n_words_node(catalog, String(args[3]), String(args[4]))
        print(node.kind + "\t" + node.value)
        return
    if command == "--classify" and len(args) == 4:
        var catalog = load_i18n_words_catalog(String(args[2]))
        print(classify_i18n_relation(catalog, atol(String(args[3]))))
        return
    if command == "--dump" and len(args) == 3:
        var catalog = load_i18n_words_catalog(String(args[2]))
        print(render_i18n_words_catalog(catalog), end="")
        return
    _usage()
    raise Error("invalid i18n words arguments")
