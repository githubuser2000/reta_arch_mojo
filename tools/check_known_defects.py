#!/usr/bin/env python3
"""Validate KNOWN_DEFECTS.json and reproduce KNOWN_DEFECTS.md."""
from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "KNOWN_DEFECTS.json"
MD_PATH = ROOT / "KNOWN_DEFECTS.md"
PYTHON_BACKLOG_PATH = ROOT / "PYTHON_CLEANUP_BACKLOG.md"
REQUIRED = {
    "id",
    "title",
    "origin",
    "classification",
    "severity",
    "python_status",
    "mojo_status",
    "discovered_stage",
    "reproducer",
    "python_locations",
    "mojo_locations",
    "current_contract",
    "post_port_fix",
    "evidence",
}
ALLOWED_PYTHON = {
    "open",
    "candidate",
    "fixed",
    "correct_reference",
    "not_applicable",
    "intentional_for_now",
}
ALLOWED_MOJO = {
    "fixed",
    "compatibility_preserved",
    "not_applicable",
}


def load() -> dict[str, Any]:
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    if data.get("schema_version") != 1:
        raise SystemExit("unsupported defect-ledger schema")
    audit = data.get("audit")
    if not isinstance(audit, dict):
        raise SystemExit("audit must be an object")
    sources = audit.get("audited_sources")
    if not isinstance(sources, list) or not sources:
        raise SystemExit("audit.audited_sources must be a non-empty list")
    for source in sources:
        if not (ROOT / source).exists():
            raise SystemExit(f"missing audited source: {source}")
    defects = data.get("defects")
    if not isinstance(defects, list):
        raise SystemExit("defects must be a list")
    ids: set[str] = set()
    for index, item in enumerate(defects):
        if not isinstance(item, dict):
            raise SystemExit(f"defect {index} is not an object")
        missing = REQUIRED - item.keys()
        if missing:
            raise SystemExit(f"defect {index} missing: {sorted(missing)}")
        defect_id = item["id"]
        if defect_id in ids:
            raise SystemExit(f"duplicate defect id: {defect_id}")
        ids.add(defect_id)
        if item["python_status"] not in ALLOWED_PYTHON:
            raise SystemExit(f"invalid python_status in {defect_id}")
        if item["mojo_status"] not in ALLOWED_MOJO:
            raise SystemExit(f"invalid mojo_status in {defect_id}")
        for field in ("python_locations", "mojo_locations", "evidence"):
            if not isinstance(item[field], list):
                raise SystemExit(f"{defect_id}.{field} must be a list")
        for path in item["evidence"]:
            if not (ROOT / path).exists():
                raise SystemExit(f"missing evidence for {defect_id}: {path}")
    return data


def render(data: dict[str, Any]) -> str:
    defects = data["defects"]
    counts = Counter(item["python_status"] for item in defects)
    lines = [
        "# Zentraler Fehlerkatalog",
        "",
        "Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Der JSON-Katalog ist die",
        "maßgebliche, maschinenlesbare Quelle.",
        "",
        "## Arbeitsregel",
        "",
        data["policy"]["reference_freeze"],
        "",
        data["policy"]["post_port_action"],
        "",
        "**Erfassungsumfang:** " + data["policy"]["scope"],
        "",
        "**Python-Originalregel:** " + data["policy"]["python_original_rule"],
        "",
        "**Release-Auditregel:** " + data["policy"]["audit_rule"],
        "",
        "## Rückwirkender Audit",
        "",
        f"- letzter vollständiger Rückwärtsaudit: `{data['audit']['last_full_backfill_stage']}`",
        f"- geprüfte Quellen: **{len(data['audit']['audited_sources'])}**",
        f"- Reichweite: {data['audit']['scope_note']}",
        "",
        "## Übersicht",
        "",
        f"- Einträge insgesamt: **{len(defects)}**",
        f"- offene bestätigte Python-Fehler: **{counts['open']}**",
        f"- zu entscheidende Python-Fehlerkandidaten: **{counts['candidate']}**",
        f"- bereits im Python-Baum behobene Fehler: **{counts['fixed']}**",
        "",
        "## Einträge",
        "",
    ]
    for item in defects:
        lines.extend(
            [
                f"### {item['id']} – {item['title']}",
                "",
                f"- Ursprung: `{item['origin']}`",
                f"- Klasse / Schwere: `{item['classification']}` / `{item['severity']}`",
                f"- Python-Status: `{item['python_status']}`",
                f"- Mojo-Status: `{item['mojo_status']}`",
                f"- entdeckt in: `{item['discovered_stage']}`",
                f"- Reproduktion: `{item['reproducer']}`",
                f"- heutiger Vertrag: {item['current_contract']}",
                f"- spätere Python-Aktion: {item['post_port_fix']}",
            ]
        )
        if item["python_locations"]:
            lines.append("- Python-Orte: " + ", ".join(f"`{p}`" for p in item["python_locations"]))
        if item["mojo_locations"]:
            lines.append("- Mojo-Orte: " + ", ".join(f"`{p}`" for p in item["mojo_locations"]))
        lines.append("- Belege: " + ", ".join(f"`{p}`" for p in item["evidence"]))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def render_python_backlog(data: dict[str, Any]) -> str:
    actionable = [
        item
        for item in data["defects"]
        if item["python_status"] in {"open", "candidate", "intentional_for_now"}
    ]
    lines = [
        "# Python-/PyPy3-Bereinigungsrückstand nach der Transpilierung",
        "",
        "Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Sie ist die gezielte",
        "Arbeitsliste für die Phase nach dem vollständigen Mojo-Port.",
        "",
        "## Vorgehen",
        "",
        "1. Den dokumentierten Istzustand mit dem Reproduktionsbefehl bestätigen.",
        "2. Einen eigenständigen korrigierten Solltest anlegen.",
        "3. Den Python-/PyPy3-Code korrigieren, ohne den Mojo-Vertrag zu verschlechtern.",
        "4. Python und Mojo gegen denselben korrigierten Sollvertrag prüfen.",
        "5. Den Eintrag in `KNOWN_DEFECTS.json` auf `fixed` setzen.",
        "",
        f"Offene oder zu entscheidende Einträge: **{len(actionable)}**",
        "",
    ]
    for index, item in enumerate(actionable, start=1):
        lines.extend(
            [
                f"## {index}. {item['id']} – {item['title']}",
                "",
                f"- Priorität: `{item['severity']}`",
                f"- Python-Status: `{item['python_status']}`",
                f"- Mojo-Status: `{item['mojo_status']}`",
                f"- Reproduktion: `{item['reproducer']}`",
                f"- heutiger Vertrag: {item['current_contract']}",
                f"- Python-Arbeitsauftrag: {item['post_port_fix']}",
            ]
        )
        if item["python_locations"]:
            lines.append(
                "- Python-Orte: "
                + ", ".join(f"`{path}`" for path in item["python_locations"])
            )
        lines.append("- Belege: " + ", ".join(f"`{p}`" for p in item["evidence"]))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    data = load()
    rendered = render(data)
    backlog = render_python_backlog(data)
    if args.write:
        MD_PATH.write_text(rendered, encoding="utf-8")
        PYTHON_BACKLOG_PATH.write_text(backlog, encoding="utf-8")
        print(f"wrote {MD_PATH.relative_to(ROOT)}")
        print(f"wrote {PYTHON_BACKLOG_PATH.relative_to(ROOT)}")
        return 0
    if not MD_PATH.exists() or MD_PATH.read_text(encoding="utf-8") != rendered:
        raise SystemExit("KNOWN_DEFECTS.md is stale; run tools/check_known_defects.py --write")
    if (
        not PYTHON_BACKLOG_PATH.exists()
        or PYTHON_BACKLOG_PATH.read_text(encoding="utf-8") != backlog
    ):
        raise SystemExit(
            "PYTHON_CLEANUP_BACKLOG.md is stale; run tools/check_known_defects.py --write"
        )
    print(
        f"known defects: {len(data['defects'])}, "
        f"Python cleanup items: {sum(item['python_status'] in {'open', 'candidate', 'intentional_for_now'} for item in data['defects'])}, "
        "ledger consistent"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
