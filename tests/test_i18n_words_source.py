from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_generated_catalog_inventory() -> None:
    manifest = json.loads((ROOT / "assets/i18n_words/manifest.json").read_text())
    assert manifest["format"] == "reta-i18n-words-tree-v2"
    assert manifest["canonical_languages"] == [
        "deutsch",
        "english",
        "vietnamese",
        "chinese",
        "korean",
    ]
    assert manifest["source_modules"] == [
        "i18n.words_bootstrap",
        "i18n.words_context",
        "i18n.words_matrix",
        "i18n.words_runtime",
        "i18n.words",
        "i18n.words_legacy_monolith",
    ]
    assert manifest["total_rows"] == 68265
    expected = {
        "deutsch": 13645,
        "english": 13655,
        "vietnamese": 13655,
        "chinese": 13655,
        "korean": 13655,
    }
    for item in manifest["languages"]:
        language = item["language"]
        path = ROOT / f"assets/i18n_words/{language}.tsv"
        assert path.is_file()
        assert sum(1 for _ in path.open(encoding="utf-8")) == expected[language]
        assert item["rows"] == expected[language]
        assert item["module_rows"]["i18n.words_matrix"] in {4764, 4766}
        assert item["module_rows"]["i18n.words_legacy_monolith"] in {6718, 6720}
        assert item["module_roots"]["i18n.words_legacy_monolith"] in {68, 70}


def test_native_owner_has_no_python_bridge() -> None:
    source = (ROOT / "src/reta_mojo/i18n_words.mojo").read_text()
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert "asset_resource" in source
    assert "duplicate_i18n_strings" in source
    assert "classify_i18n_relation" in source
    assert "legacy_i18n_monolith_snapshot" in source
    assert "legacy_i18n_duplicate_strings" in source


def test_generator_and_runtime_are_wired() -> None:
    assert (ROOT / "tools/generate_i18n_words_catalog.py").is_file()
    assert (ROOT / "scripts/check_i18n_words_catalog.sh").is_file()
    assert (ROOT / "scripts/check_i18n_words_native_parity.sh").is_file()
    build = (ROOT / "scripts/build.sh").read_text()
    assert "src/i18n_words_main.mojo reta-mojo-i18n" in build
    install = (ROOT / "scripts/check_install_layout.sh").read_text()
    assert "assets/i18n_words/deutsch.tsv" in install
    assert "reta-mojo-i18n" in install


def test_original_language_error_is_preserved_for_parity() -> None:
    rows = (ROOT / "assets/i18n_words/deutsch.tsv").read_text(encoding="utf-8")
    assert "wrongLangSentence\tstr\tfür '-languages='" in rows
    assert "'en', 'en', 'de', 'de'" in rows


def test_installed_native_inspection_launchers_resolve_symlinks() -> None:
    launchers = [
        "reta-mojo-activation",
        "reta-mojo-boundaries",
        "reta-mojo-coherence",
        "reta-mojo-contracts",
        "reta-mojo-execution-network",
        "reta-mojo-i18n",
        "reta-mojo-impact",
        "reta-mojo-migration",
        "reta-mojo-package-integrity",
        "reta-mojo-parallel-execution",
        "reta-mojo-persistence",
        "reta-mojo-progress",
        "reta-mojo-rehearsal",
        "reta-mojo-row-preparation",
        "reta-mojo-traces",
        "reta-mojo-validation",
        "reta-mojo-witnesses",
    ]
    for name in launchers:
        source = (ROOT / "tools" / "wrappers" / name).read_text()
        assert "SELF=$0" in source, name
        assert 'readlink -f "$0"' in source, name
        assert 'dirname -- "$SELF"' in source, name


def test_generated_catalog_contains_no_checkout_absolute_paths() -> None:
    for language in ("deutsch", "english", "vietnamese", "chinese", "korean"):
        rows = (ROOT / f"assets/i18n_words/{language}.tsv").read_text(encoding="utf-8")
        assert str(ROOT) not in rows
        assert "\tstr\tpython_reference/i18n\n" in rows


def test_legacy_monolith_catalog_covers_all_classes_and_functions() -> None:
    rows = (ROOT / "assets/i18n_words/deutsch.tsv").read_text(encoding="utf-8").splitlines()
    roots = []
    for row in rows:
        module, path, kind, value = row.split("\t", 3)
        if module != "i18n.words_legacy_monolith":
            continue
        if "[" not in path and "." not in path:
            roots.append((path, kind, value))
    classes = [path for path, kind, _ in roots if kind == "class"]
    functions = [path for path, kind, _ in roots if kind == "function"]
    assert classes == [
        "tableHandling", "concat", "lib4tables", "retapy",
        "nested", "retaPrompt", "csvFileNames", "readMeFileNames",
    ]
    assert functions == ["alxp", "x", "finde_mehrfache_vorkommen", "classify"]
    assert len(roots) == 68
