from std.collections import List
from reta_mojo.parallel_execution import (
    bootstrap_parallel_execution,
    decode_religion_cell,
    extract_parallel_config_from_argv,
    make_parallel_config,
    parallel_config_snapshot_json,
    parallel_execution_bundle_snapshot_json,
    parse_kombi_number,
    processor_core_counts,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var cores = processor_core_counts()
    assert_true(cores.physical >= 1, "physical cores")
    checks += 1
    assert_true(cores.virtual >= cores.physical, "virtual cores")
    checks += 1
    assert_true(cores.available >= 1, "available cores")
    checks += 1
    assert_true(cores.default_workers() >= 1, "default workers")
    checks += 1

    var process_alias_config = make_parallel_config(
        "processes", 2, 2, 1, "fork", "unit"
    )
    assert_true(
        process_alias_config.enabled_by_mode(), "legacy process alias enabled"
    )
    checks += 1
    assert_true(
        process_alias_config.resolved_backend() == "threads",
        "legacy process alias uses threads",
    )
    checks += 1
    assert_true(
        process_alias_config.should_use_threads(4),
        "legacy alias thread threshold",
    )
    checks += 1
    assert_true(
        not process_alias_config.should_use_threads(0), "empty threshold"
    )
    checks += 1

    var thread_config = make_parallel_config("threads", 2, 2, 1, "", "unit")
    assert_true(thread_config.enabled_by_mode(), "thread mode")
    checks += 1
    assert_true(thread_config.resolved_backend() == "threads", "thread backend")
    checks += 1
    assert_true(thread_config.should_use_threads(4), "thread threshold")
    checks += 1
    assert_true(not thread_config.should_use_processes(4), "threads avoid fork")
    checks += 1

    var auto_config = make_parallel_config("auto", 2, 2, 1, "", "unit")
    assert_true(
        auto_config.resolved_backend() == "threads", "auto prefers threads"
    )
    checks += 1
    assert_true(auto_config.should_use_threads(4), "auto thread threshold")
    checks += 1

    var serial_config = make_parallel_config("off", 8, 2, 1, "", "unit")
    assert_true(not serial_config.enabled_by_mode(), "serial mode")
    checks += 1
    var unknown_config = make_parallel_config("typo", 8, 2, 1, "", "unit")
    assert_true(
        not unknown_config.enabled_by_mode(), "unknown mode stays disabled"
    )
    checks += 1
    var fallback_config = make_parallel_config(
        "processes", 2, 0, -1, "fork", "unit"
    )
    assert_true(fallback_config.chunk_size == 64, "invalid chunk falls back")
    checks += 1
    assert_true(
        fallback_config.threshold == 128, "invalid threshold falls back"
    )
    checks += 1

    var argv = List[String]()
    argv.append("reta")
    argv.append("--parallel=processes")
    argv.append("--parallel-workers=3")
    argv.append("--parallel-chunk-size")
    argv.append("7")
    argv.append("--parallel-threshold=9")
    argv.append("--parallel-start=fork")
    argv.append("--foo")
    var parsed = extract_parallel_config_from_argv(argv, serial_config)
    assert_true(len(parsed.argv) == 2, "argv clean length")
    checks += 1
    assert_true(parsed.argv[1] == "--foo", "argv keeps ordinary flag")
    checks += 1
    assert_true(parsed.config.mode == "threads", "argv mode")
    checks += 1
    assert_true(parsed.config.workers == 3, "argv workers")
    checks += 1
    assert_true(parsed.config.chunk_size == 7, "argv chunk")
    checks += 1
    assert_true(parsed.config.threshold == 9, "argv threshold")
    checks += 1
    assert_true(parsed.config.start_method == "", "legacy start method ignored")
    checks += 1
    assert_true(parsed.config.source == "argv", "argv source")
    checks += 1

    var config_json = parallel_config_snapshot_json(process_alias_config)
    assert_true(
        config_json.find('"mode":"threads"') >= 0, "config snapshot mode"
    )
    checks += 1
    assert_true(
        config_json.find('"runtime":"Mojo"') >= 0, "config snapshot runtime"
    )
    checks += 1
    var bundle_json = parallel_execution_bundle_snapshot_json(
        bootstrap_parallel_execution(process_alias_config)
    )
    assert_true(
        bundle_json.find("thread_only_chunked_table_work") >= 0,
        "bundle strategy",
    )
    checks += 1
    assert_true(
        bundle_json.find("prime_factors_threaded") >= 0, "bundle morphism"
    )
    checks += 1
    assert_true(
        bundle_json.find("prepare_rows_threaded") < 0,
        "unported morphism excluded",
    )
    checks += 1

    assert_true(
        decode_religion_cell("<x>", "html") == "&lt;x&gt;", "html escape"
    )
    checks += 1
    assert_true(
        decode_religion_cell(
            '|{"":"x","html":"<b>x</b>","bbcode":"[b]x[/b]"}|', "html"
        )
        == "<b>x</b>",
        "religion html",
    )
    checks += 1
    assert_true(
        decode_religion_cell(
            '|{"":"x","html":"<b>x</b>","bbcode":"[b]x[/b]"}|', "bbcode"
        )
        == "[b]x[/b]",
        "religion bbcode",
    )
    checks += 1

    var parsed_fraction = parse_kombi_number("(12/5)")
    assert_true(len(parsed_fraction) == 2, "kombi fraction length")
    checks += 1
    assert_true(
        parsed_fraction[0] == 12 and parsed_fraction[1] == 5,
        "kombi fraction values",
    )
    checks += 1

    print("parallel execution config tests:", checks, "/", checks)
