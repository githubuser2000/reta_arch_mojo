from tools.audit_native_boundaries import audit


def test_native_boundary_audit() -> None:
    result = audit()
    assert result["native_posix_process_primitives"] == 0
    assert result["thread_module_count"] == 3
    assert result["canonical_thread_api_count"] == 10
    assert result["explicit_child_process_adapter_count"] == 1
    assert result["active_bridge_count"] == 2
