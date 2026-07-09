#!/usr/bin/env python3
from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def reference() -> dict[str, str]:
    code = r'''
import LibRetaPrompt as facade
pairs = {
    "mainParas_len": len(facade.mainParas),
    "mainParas_first": facade.mainParas[0],
    "mainParas_last": facade.mainParas[-1],
    "spalten_len": len(facade.spalten),
    "eigsN_len": len(facade.eigsN),
    "eigsR_len": len(facade.eigsR),
    "spaltenDict_len": len(facade.spaltenDict),
    "zeilenTypen_len": len(facade.zeilenTypen),
    "zeilenZeit_len": len(facade.zeilenZeit),
    "zeilenTypenB_len": len(facade.zeilenTypenB),
    "ausgabeParas_len": len(facade.ausgabeParas),
    "kombiMainParas_len": len(facade.kombiMainParas),
    "zeilenParas_len": len(facade.zeilenParas),
    "hauptForNeben_len": len(facade.hauptForNeben),
    "notParameterValues_len": len(facade.notParameterValues),
    "hauptForNebenSet_len": len(facade.hauptForNebenSet),
    "ausgabeArt_len": len(facade.ausgabeArt),
    "gebrochenErlaubteZahlen_len": len(facade.gebrochenErlaubteZahlen),
    "missingWahl15Values_len": len(facade.missingWahl15Values),
    "befehle_len": len(facade.befehle),
    "befehle2_len": len(facade.befehle2),
    "wahl15_len": len(facade.wahl15),
    "wahl16_len": len(facade.wahl16),
    "wahl15_first_key": next(iter(facade.wahl15)),
    "wahl16_first_key": next(iter(facade.wahl16)),
    "runtime_language": facade.promptRuntime.language,
    "program_class": type(facade.retaProgram).__name__,
}
for key, value in pairs.items():
    print(f"{key}={value}")
'''
    env = {
        **os.environ,
        "PYTHONHASHSEED": "0",
        "PYTHONPATH": os.pathsep.join(
            [str(ROOT / "python_reference"), str(ROOT / "python_reference/libs")]
        ),
    }
    result = subprocess.run(
        [sys.executable, "-c", code],
        cwd=ROOT,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(result.stderr)
    return parse(result.stdout)


def parse(text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in text.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            result[key] = value
    return result


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: check_legacy_libreta_prompt_parity.py PROBE", file=sys.stderr)
        return 64
    probe = Path(sys.argv[1])
    result = subprocess.run(
        [str(ROOT / "tools/wrappers/mojo-runtime-exec"), str(probe)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        return result.returncode
    expected = reference()
    actual = parse(result.stdout)
    if actual != expected:
        for key in sorted(set(expected) | set(actual)):
            if expected.get(key) != actual.get(key):
                print(
                    f"{key}: python={expected.get(key)!r} mojo={actual.get(key)!r}",
                    file=sys.stderr,
                )
        return 1
    print(f"LibRetaPrompt parity: {len(actual)} fields identical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
