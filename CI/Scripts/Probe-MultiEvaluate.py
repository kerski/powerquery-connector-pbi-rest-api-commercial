"""Live baseline oracle for multiple EVALUATE statements in executeDaxQueries.

This script is a **live integration probe** — it requires Power BI credentials
and an active tenant.  It is NOT author-time only and is NOT required to build
the .mez connector or run the M-based test suite.

Purpose
-------
Send a single DAX query string containing two EVALUATE statements to the
``executeDaxQueries`` (Arrow IPC) endpoint and verify that the response
contains two independent result tables.  Save a canonical JSON oracle to
``artifacts/multi-evaluate-canonical.json`` for human review and use as
reference values when writing the companion Power Query test
``PBIRESTAPIComm.tests.multievaluate.query.pq``.

DAX payload (one query object, two EVALUATE blocks)
----------------------------------------------------
    EVALUATE TOPN(5, DateDim, DateDim[Date], ASC)
    EVALUATE ROW("Count", COUNTROWS(DateDim))

Authentication precedence (same as Run-PQTests.ps1 / Assert-ArrowResponseShape.ps1)
-------------------------------------------------------------------------------------
1. ``--token <bearer-token>``  — pre-obtained token, skips MSAL entirely.
2. ``PPU_USERNAME`` / ``PPU_PASSWORD`` environment variables.
3. ``PPU_USERNAME`` / ``PPU_PASSWORD`` fields in the variables JSON file.
4. ``UserName`` / ``Password`` fields in the variables JSON file.
5. MSAL device-code flow (interactive fallback).

Usage
-----
    .venv\\Scripts\\python.exe CI\\Scripts\\Probe-MultiEvaluate.py
    .venv\\Scripts\\python.exe CI\\Scripts\\Probe-MultiEvaluate.py \\
        --variables CI/Scripts/variables.test.json \\
        --group \\
        --token <bearer-token>

Exit codes
----------
    0  All assertions passed.
    1  One or more assertions failed.
    2  Configuration / authentication error.
"""

from __future__ import annotations

import argparse
import io
import json
import os
import sys
from datetime import datetime, timezone
from typing import Any

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
DEFAULT_VARIABLES = os.path.join(SCRIPT_DIR, "variables.test.json")
ARTIFACTS_DIR = os.path.join(REPO_ROOT, "artifacts")
ORACLE_PATH = os.path.join(ARTIFACTS_DIR, "multi-evaluate-canonical.json")

PBI_API_BASE = "https://api.powerbi.com"
MSAL_AUTHORITY = "https://login.microsoftonline.com/common"
MSAL_SCOPE = ["https://analysis.windows.net/powerbi/api/.default"]
MSAL_CLIENT_ID = "1b730954-1685-4b74-9bfd-dac224a7b894"  # Azure PowerShell public client

# EOS marker: Arrow stream continuation marker (0xFFFFFFFF) + zero metadata length (0x00000000)
ARROW_EOS = b"\xff\xff\xff\xff\x00\x00\x00\x00"

# Multi-EVALUATE DAX query — two EVALUATE statements in one query string
DAX_QUERY1 = "EVALUATE TOPN(5, DateDim, DateDim[Date], ASC)"
DAX_QUERY2 = 'EVALUATE ROW("Count", COUNTROWS(DateDim))'
MULTI_EVAL_DAX = DAX_QUERY1 + "\n" + DAX_QUERY2


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Live multi-EVALUATE Arrow IPC baseline probe for PBI REST API connector."
    )
    p.add_argument(
        "--variables",
        default=DEFAULT_VARIABLES,
        help="Path to variables.test.json (default: CI/Scripts/variables.test.json)",
    )
    p.add_argument(
        "--token",
        default=None,
        help="Pre-obtained bearer token; skips MSAL authentication.",
    )
    p.add_argument(
        "--group",
        action="store_true",
        default=True,
        help="Use the group endpoint (default: True). Pass --no-group for My workspace.",
    )
    p.add_argument(
        "--no-group",
        dest="group",
        action="store_false",
        help="Use the My workspace endpoint instead of the group endpoint.",
    )
    return p.parse_args()


# ---------------------------------------------------------------------------
# Configuration loading
# ---------------------------------------------------------------------------

def load_variables(path: str) -> dict[str, Any]:
    if not os.path.exists(path):
        print(f"[ERROR] Variables file not found: {path}", file=sys.stderr)
        print(
            "        Create it from CI/Scripts/variables.test.template.json and populate "
            "GroupTestID, DatasetTestID, and credentials.",
            file=sys.stderr,
        )
        sys.exit(2)
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def resolve_credentials(args: argparse.Namespace, variables: dict[str, Any]) -> tuple[str | None, str | None]:
    """Return (username, password) with env vars taking precedence over JSON fields."""
    username = (
        os.environ.get("PPU_USERNAME")
        or variables.get("PPU_USERNAME")
        or variables.get("UserName")
        or None
    )
    password = (
        os.environ.get("PPU_PASSWORD")
        or variables.get("PPU_PASSWORD")
        or variables.get("Password")
        or None
    )
    # Treat empty strings as None
    username = username if username else None
    password = password if password else None
    return username, password


# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------

def acquire_token(args: argparse.Namespace, variables: dict[str, Any]) -> str:
    if args.token:
        print("[AUTH] Using pre-supplied bearer token.")
        return args.token

    try:
        import msal  # noqa: PLC0415
    except ImportError:
        print(
            "[ERROR] msal is not installed. Run: pip install msal",
            file=sys.stderr,
        )
        sys.exit(2)

    username, password = resolve_credentials(args, variables)

    app = msal.PublicClientApplication(MSAL_CLIENT_ID, authority=MSAL_AUTHORITY)

    if username and password:
        print(f"[AUTH] Acquiring token via ROPC for user: {username}")
        result = app.acquire_token_by_username_password(
            username=username, password=password, scopes=MSAL_SCOPE
        )
    else:
        print("[AUTH] No credentials found — starting device-code flow.")
        flow = app.initiate_device_flow(scopes=MSAL_SCOPE)
        if "user_code" not in flow:
            print(f"[ERROR] Failed to initiate device flow: {flow}", file=sys.stderr)
            sys.exit(2)
        print(flow["message"])
        result = app.acquire_token_by_device_flow(flow)

    if "access_token" not in result:
        error = result.get("error_description", result.get("error", "Unknown error"))
        print(f"[ERROR] Authentication failed: {error}", file=sys.stderr)
        sys.exit(2)

    print("[AUTH] Token acquired successfully.")
    return result["access_token"]


# ---------------------------------------------------------------------------
# Arrow stream splitting
# ---------------------------------------------------------------------------

def split_arrow_streams(data: bytes) -> list[bytes]:
    """Split a concatenated Arrow IPC byte buffer at EOS markers.

    Each Arrow IPC stream ends with an 8-byte EOS marker:
      0xFFFFFFFF (continuation) + 0x00000000 (zero metadata length).
    PBI returns one stream per EVALUATE result, concatenated end-to-end.
    """
    segments: list[bytes] = []
    start = 0
    while start < len(data):
        pos = data.find(ARROW_EOS, start)
        if pos == -1:
            # No more EOS markers; treat remaining bytes as a (possibly
            # truncated) stream — include for diagnostic output.
            remaining = data[start:]
            if remaining:
                segments.append(remaining)
            break
        end = pos + len(ARROW_EOS)
        segment = data[start:end]
        # Only include non-trivial segments (more than just an EOS frame)
        if len(segment) > len(ARROW_EOS):
            segments.append(segment)
        start = end
    return segments


# ---------------------------------------------------------------------------
# Arrow parsing helpers
# ---------------------------------------------------------------------------

def parse_arrow_stream(segment: bytes) -> dict[str, Any]:
    """Parse one Arrow IPC stream segment and return a summary dict."""
    try:
        import pyarrow as pa  # noqa: PLC0415
        import pyarrow.ipc as ipc  # noqa: PLC0415
    except ImportError:
        print(
            "[ERROR] pyarrow is not installed. Run: pip install pyarrow",
            file=sys.stderr,
        )
        sys.exit(2)

    reader = ipc.open_stream(io.BytesIO(segment))
    table = reader.read_all()
    columns = table.schema.names
    row_count = table.num_rows

    # Collect first 5 rows as plain Python values for the oracle
    preview_rows: list[list[Any]] = []
    for i in range(min(5, row_count)):
        row = [col[i].as_py() for col in table.columns]
        preview_rows.append(row)

    return {
        "columns": columns,
        "row_count": row_count,
        "preview_rows": preview_rows,
    }


# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

def assert_eq(label: str, expected: Any, actual: Any, failures: list[str]) -> None:
    if expected == actual:
        print(f"  [PASS] {label}: {actual!r}")
    else:
        msg = f"{label}: expected {expected!r}, got {actual!r}"
        print(f"  [FAIL] {msg}")
        failures.append(msg)


def assert_true(label: str, condition: bool, failures: list[str], detail: str = "") -> None:
    if condition:
        print(f"  [PASS] {label}")
    else:
        msg = label + (f" ({detail})" if detail else "")
        print(f"  [FAIL] {msg}")
        failures.append(msg)


# ---------------------------------------------------------------------------
# Oracle saving
# ---------------------------------------------------------------------------

def save_oracle(endpoint: str, results: list[dict[str, Any]]) -> None:
    os.makedirs(ARTIFACTS_DIR, exist_ok=True)
    oracle = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "endpoint": endpoint,
        "queries": [DAX_QUERY1, DAX_QUERY2],
        "results": [
            {
                "query_index": i,
                "query": [DAX_QUERY1, DAX_QUERY2][i],
                "columns": r["columns"],
                "row_count": r["row_count"],
                "preview_rows": r["preview_rows"],
            }
            for i, r in enumerate(results)
        ],
    }
    with open(ORACLE_PATH, "w", encoding="utf-8") as fh:
        json.dump(oracle, fh, indent=2, default=str)
    print(f"\n[ORACLE] Saved canonical oracle to: {ORACLE_PATH}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:  # noqa: C901
    args = parse_args()
    variables = load_variables(args.variables)

    group_id = variables.get("GroupTestID", "")
    dataset_id = variables.get("DatasetTestID", "")

    if not group_id or not dataset_id:
        print(
            "[ERROR] GroupTestID and DatasetTestID must be set in variables.test.json.",
            file=sys.stderr,
        )
        return 2

    token = acquire_token(args, variables)

    # Build endpoint URL
    if args.group:
        endpoint_path = f"v1.0/myorg/groups/{group_id}/datasets/{dataset_id}/executeDaxQueries"
    else:
        endpoint_path = f"v1.0/myorg/datasets/{dataset_id}/executeDaxQueries"
    url = f"{PBI_API_BASE}/{endpoint_path}"

    # Build payload — single query object containing both EVALUATE statements
    payload = {
        "queries": [{"query": MULTI_EVAL_DAX}],
        "serializerSettings": {"includeNulls": True},
    }

    print(f"\n[HTTP] POST {url}")
    print(f"[DAX ] {MULTI_EVAL_DAX!r}")

    try:
        import requests as req  # noqa: PLC0415
    except ImportError:
        print(
            "[ERROR] requests is not installed. Run: pip install requests",
            file=sys.stderr,
        )
        return 2

    headers = {
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json",
        "Accept": (
            "application/vnd.apache.arrow.stream, "
            "application/vnd.apache.arrow.file, "
            "application/octet-stream, "
            "application/json"
        ),
    }
    response = req.post(url, headers=headers, data=json.dumps(payload), timeout=60)

    print(f"[HTTP] Status: {response.status_code}")
    print(f"[HTTP] Content-Type: {response.headers.get('Content-Type', '?')}")
    print(f"[HTTP] Body length: {len(response.content)} bytes")

    if response.status_code != 200:
        print(f"[ERROR] Unexpected HTTP status: {response.status_code}", file=sys.stderr)
        print(response.text[:500], file=sys.stderr)
        return 1

    raw_bytes = response.content

    # Split at Arrow EOS markers
    segments = split_arrow_streams(raw_bytes)
    print(f"\n[ARROW] Found {len(segments)} Arrow IPC stream segment(s) after EOS split.")
    for i, seg in enumerate(segments):
        print(f"         Segment {i}: {len(seg)} bytes")

    failures: list[str] = []

    print("\n--- Assertions ---")
    assert_eq("Number of Arrow stream segments", 2, len(segments), failures)

    if len(segments) < 1:
        print("[ERROR] No Arrow stream segments found — cannot continue.")
        return 1

    # Parse each segment
    results: list[dict[str, Any]] = []
    for i, seg in enumerate(segments):
        print(f"\n[PARSE] Parsing segment {i} ...")
        try:
            result = parse_arrow_stream(seg)
        except Exception as exc:  # noqa: BLE001
            print(f"  [ERROR] Failed to parse segment {i}: {exc}", file=sys.stderr)
            failures.append(f"Segment {i} parse error: {exc}")
            continue
        results.append(result)
        print(f"         Columns   : {result['columns']}")
        print(f"         Row count : {result['row_count']}")
        if result["preview_rows"]:
            print(f"         First row : {result['preview_rows'][0]}")

    print("\n--- Result Assertions ---")

    if len(results) >= 1:
        assert_eq("Result[0] row count (TOPN 5 ASC)", 5, results[0]["row_count"], failures)
        assert_true(
            "Result[0] has at least 1 column",
            len(results[0]["columns"]) >= 1,
            failures,
            detail=str(results[0]["columns"]),
        )

    if len(results) >= 2:
        assert_eq("Result[1] row count (COUNTROWS scalar)", 1, results[1]["row_count"], failures)
        assert_true(
            "Result[1] has exactly 1 column (Count)",
            len(results[1]["columns"]) == 1,
            failures,
            detail=str(results[1]["columns"]),
        )
        assert_true(
            "Result[1] Count value > 0",
            results[1]["preview_rows"][0][0] is not None and results[1]["preview_rows"][0][0] > 0,
            failures,
            detail=str(results[1]["preview_rows"]),
        )

    # Save oracle (even on partial failure so column names can be inspected)
    if results:
        save_oracle(endpoint_path, results)

    print("\n--- Summary ---")
    if failures:
        print(f"FAIL — {len(failures)} assertion(s) failed:")
        for f in failures:
            print(f"  • {f}")
        return 1
    else:
        print("PASS — all assertions passed.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
