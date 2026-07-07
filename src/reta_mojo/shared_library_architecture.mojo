"""Shared-library target architecture for the post-porting native layout.

The porting matrix is now fully native.  This module freezes the next concrete
architecture step before build scripts start moving every executable behind
shared-library ABIs: reta and grundStrukHtml become thin starters over the core
library; rp/rpl/rpe/rpb share the prompt execution library; only rp/rpl/rpe load
the interactive prompt-input library.
"""

from std.collections import List


@fieldwise_init
struct SharedLibraryTarget(Copyable):
    """One planned cross-platform shared library target."""

    var logical_name: String
    var elf_name: String
    var dll_name: String
    var purpose: String
    var consumers: List[String]
    var dependencies: List[String]
    var contains_interactive_input: Bool
    var depends_on_core: Bool


@fieldwise_init
struct ThinStarterTarget(Copyable):
    """One executable that should become a thin dynamic starter."""

    var starter_name: String
    var libraries: List[String]
    var interactive: Bool


@fieldwise_init
struct SharedLibraryArchitecturePlan(Copyable):
    """Controller-facing snapshot of the requested shared-library split."""

    var libraries: List[SharedLibraryTarget]
    var starters: List[ThinStarterTarget]
    var core_library: String
    var prompt_library: String
    var prompt_interactive_library: String
    var rpb_uses_interactive_library: Bool
    var thin_starter_count: Int


def _strings() -> List[String]:
    return List[String]()


def _consumer_list(
    a: String,
    b: String,
    c: String,
    d: String,
    e: String,
    f: String,
) -> List[String]:
    var result = List[String]()
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    result.append(e)
    result.append(f)
    return result^


def _prompt_consumers() -> List[String]:
    var result = List[String]()
    result.append("rp")
    result.append("rpl")
    result.append("rpe")
    result.append("rpb")
    return result^


def _interactive_consumers() -> List[String]:
    var result = List[String]()
    result.append("rp")
    result.append("rpl")
    result.append("rpe")
    return result^


def _deps_core() -> List[String]:
    var result = List[String]()
    result.append("libreta-core")
    return result^


def _deps_prompt() -> List[String]:
    var result = List[String]()
    result.append("libreta-prompt")
    return result^


def load_shared_library_targets() -> List[SharedLibraryTarget]:
    """Return the three primary libraries requested for the next layout."""

    var targets = List[SharedLibraryTarget]()
    targets.append(
        SharedLibraryTarget(
            "libreta-core",
            "libreta-core.so",
            "libreta-core.dll",
            "shared native reta core: parameters, tables, output, CLI planning, GrundstrukHtml",
            _consumer_list("reta", "rp", "rpl", "rpe", "rpb", "grundStrukHtml"),
            _strings(),
            False,
            False,
        )
    )
    targets.append(
        SharedLibraryTarget(
            "libreta-prompt",
            "libreta-prompt.so",
            "libreta-prompt.dll",
            "shared prompt execution for rp rpl rpe rpb; one-shot rpb lives here too",
            _prompt_consumers(),
            _deps_core(),
            False,
            True,
        )
    )
    targets.append(
        SharedLibraryTarget(
            "libreta-prompt-interactive",
            "libreta-prompt-interactive.so",
            "libreta-prompt-interactive.dll",
            "interactive prompt input/session/history layer for rp rpl rpe only",
            _interactive_consumers(),
            _deps_prompt(),
            True,
            False,
        )
    )
    return targets^


def _starter_libraries_single(name: String) -> List[String]:
    var result = List[String]()
    result.append(name)
    return result^


def _starter_libraries_prompt() -> List[String]:
    var result = List[String]()
    result.append("libreta-prompt")
    result.append("libreta-core")
    return result^


def _starter_libraries_prompt_interactive() -> List[String]:
    var result = List[String]()
    result.append("libreta-prompt-interactive")
    result.append("libreta-prompt")
    result.append("libreta-core")
    return result^


def load_thin_starter_targets() -> List[ThinStarterTarget]:
    """Return the executables that should become thin dynamic starters."""

    var starters = List[ThinStarterTarget]()
    starters.append(ThinStarterTarget("reta", _starter_libraries_single("libreta-core"), False))
    starters.append(ThinStarterTarget("grundStrukHtml", _starter_libraries_single("libreta-core"), False))
    starters.append(ThinStarterTarget("rpb", _starter_libraries_prompt(), False))
    starters.append(ThinStarterTarget("rp", _starter_libraries_prompt_interactive(), True))
    starters.append(ThinStarterTarget("rpl", _starter_libraries_prompt_interactive(), True))
    starters.append(ThinStarterTarget("rpe", _starter_libraries_prompt_interactive(), True))
    return starters^


def plan_shared_library_architecture() -> SharedLibraryArchitecturePlan:
    """Freeze the requested dynamic-library split as a testable plan."""

    var libraries = load_shared_library_targets()
    var starters = load_thin_starter_targets()
    var rpb_uses_interactive = False
    for starter_index in range(len(starters)):
        if starters[starter_index].starter_name == "rpb":
            for lib_index in range(len(starters[starter_index].libraries)):
                if starters[starter_index].libraries[lib_index] == "libreta-prompt-interactive":
                    rpb_uses_interactive = True
    return SharedLibraryArchitecturePlan(
        libraries,
        starters,
        "libreta-core",
        "libreta-prompt",
        "libreta-prompt-interactive",
        rpb_uses_interactive,
        len(starters),
    )


def shared_library_architecture_valid(plan: SharedLibraryArchitecturePlan) -> Bool:
    """Validate the non-negotiable edges of the requested layout."""

    if len(plan.libraries) != 3:
        return False
    if plan.core_library != "libreta-core":
        return False
    if plan.prompt_library != "libreta-prompt":
        return False
    if plan.prompt_interactive_library != "libreta-prompt-interactive":
        return False
    if plan.rpb_uses_interactive_library:
        return False
    if plan.thin_starter_count != 6:
        return False

    var saw_core = False
    var saw_prompt = False
    var saw_interactive = False
    for index in range(len(plan.libraries)):
        var target = plan.libraries[index]
        if target.logical_name == "libreta-core":
            saw_core = True
            if target.contains_interactive_input:
                return False
            if not _target_has_consumer(target, "reta"):
                return False
            if not _target_has_consumer(target, "grundStrukHtml"):
                return False
        if target.logical_name == "libreta-prompt":
            saw_prompt = True
            if target.contains_interactive_input:
                return False
            if not target.depends_on_core:
                return False
            if not _target_has_dependency(target, "libreta-core"):
                return False
            if not _target_has_consumer(target, "rpb"):
                return False
        if target.logical_name == "libreta-prompt-interactive":
            saw_interactive = True
            if not target.contains_interactive_input:
                return False
            if _target_has_consumer(target, "rpb"):
                return False
            if not _target_has_consumer(target, "rp"):
                return False
            if not _target_has_consumer(target, "rpl"):
                return False
            if not _target_has_consumer(target, "rpe"):
                return False
    return saw_core and saw_prompt and saw_interactive


def _target_has_consumer(target: SharedLibraryTarget, consumer: String) -> Bool:
    for index in range(len(target.consumers)):
        if target.consumers[index] == consumer:
            return True
    return False


def _target_has_dependency(target: SharedLibraryTarget, dependency: String) -> Bool:
    for index in range(len(target.dependencies)):
        if target.dependencies[index] == dependency:
            return True
    return False
