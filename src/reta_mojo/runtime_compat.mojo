"""Small typed compatibility values formerly owned by runtime_compat.py."""

from std.collections import List


comptime NPM_GAL_N = 2
comptime NPM_GAL_1_PLUS_N = 3
comptime NPM_UNI_N = 4
comptime NPM_UNI_1_PLUS_N = 5
comptime NPM_EMO_N = 6
comptime NPM_EMO_1_PLUS_N = 7
comptime NPM_GROE_N = 8
comptime NPM_GROE_1_PLUS_N = 9


def npm_galaxy() -> List[Int]:
    return [NPM_GAL_N, NPM_GAL_1_PLUS_N]


def npm_universe() -> List[Int]:
    return [NPM_UNI_N, NPM_UNI_1_PLUS_N]


def npm_emotion() -> List[Int]:
    return [NPM_EMO_N, NPM_EMO_1_PLUS_N]


def npm_size() -> List[Int]:
    return [NPM_GROE_N, NPM_GROE_1_PLUS_N]


def npm_n_values() -> List[Int]:
    return [NPM_GAL_N, NPM_UNI_N, NPM_EMO_N, NPM_GROE_N]


def npm_one_plus_n_values() -> List[Int]:
    return [
        NPM_GAL_1_PLUS_N,
        NPM_UNI_1_PLUS_N,
        NPM_EMO_1_PLUS_N,
        NPM_GROE_1_PLUS_N,
    ]


def fill_both(mut first: List[String], mut second: List[String]) -> None:
    while len(first) < len(second):
        first.append("")
    while len(second) < len(first):
        second.append("")
