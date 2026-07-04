from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "scripts/test_all.sh").read_text(encoding="utf-8")


def test_persistence_tests_link_sqlite_and_crypto() -> None:
    assert "tests/test_execution_network_persistence.mojo|tests/test_persistence.mojo" in SOURCE
    assert "set -- -Xlinker -lsqlite3 -Xlinker -lcrypto" in SOURCE


def test_package_integrity_links_crypto() -> None:
    assert "tests/test_package_integrity.mojo)" in SOURCE
    assert "set -- -Xlinker -lcrypto" in SOURCE


def test_all_build_forwards_per_test_link_flags() -> None:
    assert '"$test_file" "$@" -o "$TARGET/$name"' in SOURCE
