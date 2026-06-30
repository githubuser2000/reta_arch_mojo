from reta_mojo.architecture_traces import (
    bootstrap_architecture_traces,
    capsule_trace_index,
    component_trace_index,
    stage_trace_index,
    trace_route_hop_count,
    trace_snapshot_validation_passed,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_traces()
    assert_true(len(bundle.component_traces) == 34, "component count")
    assert_true(len(bundle.capsule_traces) == 11, "capsule count")
    assert_true(len(bundle.stage_traces) == 42, "stage count")
    assert_true(trace_route_hop_count(bundle) == 204, "route hop count")
    assert_true(trace_snapshot_validation_passed(bundle), "trace validation")
    assert_true(component_trace_index(bundle, "reta.py") >= 0, "known component")
    assert_true(capsule_trace_index(bundle, "InputPromptCapsule") >= 0, "known capsule")
    assert_true(stage_trace_index(bundle, "Stage 32") >= 0, "known stage")
    assert_true(component_trace_index(bundle, "missing.py") == -1, "missing component")
    print("architecture trace tests: 9/9")
