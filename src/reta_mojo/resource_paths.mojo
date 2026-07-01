"""Portable runtime resource locations for source trees and FHS installs.

The native executables intentionally do not embed an absolute build-machine
path.  Launchers may provide explicit directories, while direct development
runs keep the historical repository-relative layout.

Environment contract:

* ``RETA_ROOT``: project/private runtime root;
* ``RETA_SHARE_DIR``: immutable shared-data root containing ``csv`` and
  ``assets``;
* ``RETA_DATA_DIR``: direct CSV-directory override;
* ``RETA_ASSET_DIR``: direct asset-directory override;
* ``RETA_REFERENCE_DIR``: Python compatibility-tree override.
"""

from std.os import getenv


def _clean_root(path: String) -> String:
    return String(path.strip())


def _join_resource(root: String, relative: String) -> String:
    var base = _clean_root(root)
    if base.byte_length() == 0:
        return relative
    if relative.byte_length() == 0:
        return base^
    if base.endswith("/"):
        return base + relative
    return base + "/" + relative


def runtime_root() -> String:
    return _clean_root(String(getenv("RETA_ROOT", "")))


def share_root() -> String:
    return _clean_root(String(getenv("RETA_SHARE_DIR", "")))


def csv_root() -> String:
    var configured = _clean_root(
        String(getenv("RETA_DATA_DIR", ""))
    )
    if configured.byte_length() > 0:
        return configured^
    var shared = share_root()
    if shared.byte_length() > 0:
        return _join_resource(shared, "csv")
    var root = runtime_root()
    if root.byte_length() > 0:
        return _join_resource(root, "python_reference/csv")
    return "python_reference/csv"


def asset_root() -> String:
    var configured = _clean_root(
        String(getenv("RETA_ASSET_DIR", ""))
    )
    if configured.byte_length() > 0:
        return configured^
    var shared = share_root()
    if shared.byte_length() > 0:
        return _join_resource(shared, "assets")
    var root = runtime_root()
    if root.byte_length() > 0:
        return _join_resource(root, "assets")
    return "assets"


def reference_root() -> String:
    var configured = _clean_root(
        String(getenv("RETA_REFERENCE_DIR", ""))
    )
    if configured.byte_length() > 0:
        return configured^
    var root = runtime_root()
    if root.byte_length() > 0:
        return _join_resource(root, "python_reference")
    return "python_reference"


def csv_resource(filename: String) -> String:
    return _join_resource(csv_root(), filename)


def asset_resource(filename: String) -> String:
    return _join_resource(asset_root(), filename)
