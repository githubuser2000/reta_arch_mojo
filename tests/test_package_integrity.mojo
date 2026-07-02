from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from reta_mojo.package_integrity import (
    default_repo_manifest,
    is_runtime_artifact,
    normalise_manifest_path,
    python_splitlines_count,
    repo_manifest_from_tree,
    repo_manifest_json,
    required_source_paths,
    sha256_bytes,
)


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def main() raises:
    assert_equal(normalise_manifest_path("./alpha/beta"), "alpha/beta")
    assert_equal(normalise_manifest_path("...///hidden"), "hidden")
    assert_equal(normalise_manifest_path("\\alpha\\beta"), "alpha/beta")
    assert_true(is_runtime_artifact("a/__pycache__/x.py"))
    assert_true(is_runtime_artifact(".git/objects/x"))
    assert_true(is_runtime_artifact("a/value.pyc"))
    assert_false(is_runtime_artifact("a/git/value.py"))

    var csv = open(
        "tests/fixtures/package_integrity/tree/csv/religion.csv", "r"
    ).read_bytes()
    assert_equal(python_splitlines_count(csv), 3)
    var beta = open(
        "tests/fixtures/package_integrity/tree/sub/beta.bin", "r"
    ).read_bytes()
    assert_equal(
        sha256_bytes(beta),
        "712450d3c4a79eea9509e75dc1dacdeff58034df538536cfae2da882bd8a0c50",
    )

    var required: List[String] = ["alpha.txt", "hidden", "missing.txt"]
    var manifest = repo_manifest_from_tree(
        "tests/fixtures/package_integrity/tree", required
    )
    assert_equal(manifest.file_count, 5)
    assert_equal(manifest.total_bytes, 32)
    assert_equal(
        manifest.digest,
        "ae3cc5cafa7c499461f06175e23db4056db2141e2fe6bfd7ba17dc7e69299582",
    )
    assert_equal(manifest.runtime_artifact_count, 0)
    assert_equal(len(manifest.missing_required), 1)
    assert_equal(manifest.missing_required[0], "missing.txt")
    assert_equal(len(manifest.suspicious_csvs), 1)
    assert_equal(manifest.suspicious_csvs[0], "csv/religion.csv")
    assert_equal(len(manifest.csv_line_counts), 1)
    assert_equal(manifest.csv_line_counts[0].line_count, 3)
    assert_equal(len(manifest.files), 5)
    assert_equal(manifest.files[0], "alpha.txt")
    assert_equal(manifest.files[1], "csv/religion.csv")
    assert_equal(manifest.files[2], "hidden")
    assert_equal(manifest.files[3], "link-alpha")
    assert_equal(manifest.files[4], "sub/beta.bin")
    assert_true(repo_manifest_json(manifest, True).find('"files"') >= 0)
    assert_equal(len(required_source_paths()), 74)
    print("package_integrity=27/27")
