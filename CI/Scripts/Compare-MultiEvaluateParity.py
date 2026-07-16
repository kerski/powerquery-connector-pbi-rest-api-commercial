"""Compare canonical multi-evaluate artifacts from PowerShell and Python probes.

This comparison focuses on API-level parity signals that are stable across tools:
- endpoint path
- content type
- stream count
- query line count

It emits a JSON summary artifact and exits non-zero on mismatch.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timezone


def read_json(path: str) -> dict:
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def compare(ps: dict, py: dict) -> tuple[list[str], dict]:
    mismatches: list[str] = []

    ps_endpoint = ps.get("endpoint", "")
    py_endpoint = py.get("endpoint", "")
    if isinstance(ps_endpoint, str):
        ps_endpoint = ps_endpoint.replace("https://api.powerbi.com/", "")
    if isinstance(py_endpoint, str):
        py_endpoint = py_endpoint.replace("https://api.powerbi.com/", "")
    if ps_endpoint != py_endpoint:
        mismatches.append(f"endpoint mismatch: ps={ps_endpoint!r} py={py_endpoint!r}")

    ps_ct = (ps.get("content_type", "") or "").lower().split(";")[0].strip()
    py_ct = (py.get("content_type", "") or "").lower().split(";")[0].strip()
    if ps_ct != py_ct:
        mismatches.append(f"content_type mismatch: ps={ps_ct!r} py={py_ct!r}")

    ps_streams = int(ps.get("stream_count", -1))
    py_streams = int(py.get("stream_count", len(py.get("results", []))))
    if ps_streams != py_streams:
        mismatches.append(f"stream_count mismatch: ps={ps_streams} py={py_streams}")

    ps_queries = len(ps.get("queries", []))
    py_queries = len(py.get("queries", []))
    if ps_queries != py_queries:
        mismatches.append(f"query_count mismatch: ps={ps_queries} py={py_queries}")

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "ps_endpoint": ps_endpoint,
        "py_endpoint": py_endpoint,
        "ps_content_type": ps_ct,
        "py_content_type": py_ct,
        "ps_stream_count": ps_streams,
        "py_stream_count": py_streams,
        "ps_query_count": ps_queries,
        "py_query_count": py_queries,
        "mismatch_count": len(mismatches),
        "mismatches": mismatches,
    }
    return mismatches, summary


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare PowerShell/Python multi-evaluate canonical artifacts")
    parser.add_argument("--powershell", default="artifacts/multi-eval-powershell-canonical.json")
    parser.add_argument("--python", default="artifacts/multi-eval-python-canonical.json")
    parser.add_argument("--output", default="artifacts/multi-eval-parity-compare.json")
    args = parser.parse_args()

    try:
        ps = read_json(args.powershell)
        py = read_json(args.python)
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] Failed to read artifacts: {exc}", file=sys.stderr)
        return 2

    mismatches, summary = compare(ps, py)

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as fh:
        json.dump(summary, fh, indent=2)

    if mismatches:
        print(f"FAIL — {len(mismatches)} mismatch(es)")
        for m in mismatches:
            print(f"  - {m}")
        return 1

    print("PASS — PowerShell and Python canonical artifacts align")
    return 0


if __name__ == "__main__":
    sys.exit(main())
