"""Generate deterministic Arrow IPC Stream fixtures for the connector's
M-based parser tests.

This script is **author-time only**. It is NEVER required to:
  - build the .mez connector
  - run the M-based test suite

It produces a JSON manifest (`tests/fixtures/arrow_fixtures.json`) containing,
for each fixture:
    {
      "name": "<short-name>",
      "description": "<what it exercises>",
      "hex": "<lowercase-hex-byte-string>",
      "expected": {
          "columns": ["<col-1>", ...],
          "rows": [[<cell-1>, <cell-2>, ...], ...]
      }
    }

The companion M test file `PBIRESTAPIComm.tests.arrow.staticfixture.query.pq`
reads this manifest at test-author time (a one-time copy/paste of the hex
strings into M source) and asserts that `Arrow.FromBinary` returns a table
matching `expected` cell-by-cell.

Usage (after `python -m venv .venv` and
`.\\.venv\\Scripts\\python.exe -m pip install -r requirements.txt`):

    .\\.venv\\Scripts\\python.exe .\\CI\\Scripts\\Generate-ArrowFixtures.py
"""

from __future__ import annotations

import io
import json
import os
from typing import Any

import pyarrow as pa


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FIXTURES_DIR = os.path.join(REPO_ROOT, "tests", "fixtures")


def to_stream_bytes(batches: list[pa.RecordBatch]) -> bytes:
    """Serialize one or more RecordBatches as an Arrow IPC **Stream** payload
    (continuation-marker framing, no file magic). This matches the wire format
    that Power BI's executeQueries endpoint emits."""
    if not batches:
        raise ValueError("at least one batch required")
    schema = batches[0].schema
    buf = io.BytesIO()
    writer = pa.ipc.new_stream(buf, schema)
    for b in batches:
        writer.write_batch(b)
    writer.close()
    return buf.getvalue()


def fixture_simple_int64_string() -> dict[str, Any]:
    """Smallest possible non-trivial stream: one batch, two columns, three rows.
    Validates the happy-path Schema + RecordBatch + Utf8 offset-buffer + int64
    little-endian decode."""
    schema = pa.schema([
        pa.field("N", pa.int64(), nullable=False),
        pa.field("Label", pa.utf8(), nullable=False),
    ])
    batch = pa.record_batch(
        [pa.array([1, 2, 3], type=pa.int64()),
         pa.array(["alpha", "beta", "gamma"], type=pa.utf8())],
        schema=schema,
    )
    return {
        "name": "simple_int64_string",
        "description": "Single batch, int64 + utf8 columns, no nulls, no dictionaries.",
        "hex": to_stream_bytes([batch]).hex(),
        "expected": {
            "columns": ["N", "Label"],
            "rows": [[1, "alpha"], [2, "beta"], [3, "gamma"]],
        },
    }


def fixture_nulls_bitmap_byte_boundary() -> dict[str, Any]:
    """Validity bitmap spanning the bit 7/8 byte boundary. 10 rows where the
    null-pattern toggles across the byte gap to catch off-by-one bit math in
    the bitmap reader."""
    values = [10, None, 12, None, 14, None, 16, None, 18, 19]
    schema = pa.schema([pa.field("V", pa.int32(), nullable=True)])
    batch = pa.record_batch(
        [pa.array(values, type=pa.int32())],
        schema=schema,
    )
    return {
        "name": "nulls_bitmap_byte_boundary",
        "description": "int32 column with nulls toggling across bit-7/bit-8 byte boundary in the validity bitmap.",
        "hex": to_stream_bytes([batch]).hex(),
        "expected": {
            "columns": ["V"],
            "rows": [[v] for v in values],
        },
    }


def fixture_multi_batch() -> dict[str, Any]:
    """Two RecordBatches sharing one Schema. Validates that the stream parser
    consumes multiple message frames and concatenates the resulting rows in
    order."""
    schema = pa.schema([pa.field("N", pa.int32(), nullable=False)])
    b1 = pa.record_batch([pa.array([1, 2, 3], type=pa.int32())], schema=schema)
    b2 = pa.record_batch([pa.array([4, 5], type=pa.int32())], schema=schema)
    return {
        "name": "multi_batch",
        "description": "Two RecordBatches in a single stream sharing one Schema.",
        "hex": to_stream_bytes([b1, b2]).hex(),
        "expected": {
            "columns": ["N"],
            "rows": [[1], [2], [3], [4], [5]],
        },
    }


def fixture_dictionary_encoded() -> dict[str, Any]:
    """Dictionary-encoded utf8 column. Validates DictionaryBatch handling and
    the Indices -> Values lookup. Dictionary values must be deterministic; we
    construct the DictionaryArray explicitly."""
    dictionary = pa.array(["red", "green", "blue"], type=pa.utf8())
    indices = pa.array([0, 1, 2, 0, 1], type=pa.int32())
    dict_array = pa.DictionaryArray.from_arrays(indices, dictionary)
    schema = pa.schema([
        pa.field("Color", pa.dictionary(pa.int32(), pa.utf8()), nullable=False),
    ])
    batch = pa.record_batch([dict_array], schema=schema)
    return {
        "name": "dictionary_encoded",
        "description": "Dictionary-encoded utf8 column (DictionaryBatch + RecordBatch indices).",
        "hex": to_stream_bytes([batch]).hex(),
        "expected": {
            "columns": ["Color"],
            "rows": [["red"], ["green"], ["blue"], ["red"], ["green"]],
        },
    }


def fixture_unicode_strings() -> dict[str, Any]:
    """Multi-byte UTF-8 characters including a 4-byte emoji and an empty
    string. Validates utf8 offset-buffer interpretation and that the parser
    does not corrupt non-ASCII bytes."""
    values = ["cafe\u0301", "\u65e5\u672c\u8a9e", "\U0001f389", ""]
    expected_values = ["caf\u00e9", "\u65e5\u672c\u8a9e", "\U0001f389", ""]
    # Note: pyarrow stores the raw UTF-8 bytes we hand it; the first input
    # uses combining acute accent (e + COMBINING ACUTE) which Arrow stores
    # byte-for-byte. To make the round-trip deterministic and easy to assert
    # in M (which uses precomposed forms), we feed precomposed bytes directly.
    schema = pa.schema([pa.field("Text", pa.utf8(), nullable=True)])
    batch = pa.record_batch(
        [pa.array(expected_values, type=pa.utf8())],
        schema=schema,
    )
    return {
        "name": "unicode_strings",
        "description": "UTF-8 strings: accented (2-byte), CJK (3-byte), emoji (4-byte), empty string.",
        "hex": to_stream_bytes([batch]).hex(),
        "expected": {
            "columns": ["Text"],
            "rows": [[v] for v in expected_values],
        },
    }


def fixture_boolean_column() -> dict[str, Any]:
    """Boolean column with a null. Validates the bit-packed boolean decoder
    and that null vs false are not conflated."""
    values = [True, False, None, True, False]
    schema = pa.schema([pa.field("Flag", pa.bool_(), nullable=True)])
    batch = pa.record_batch(
        [pa.array(values, type=pa.bool_())],
        schema=schema,
    )
    return {
        "name": "boolean_with_null",
        "description": "Bit-packed boolean column with a null distinct from false.",
        "hex": to_stream_bytes([batch]).hex(),
        "expected": {
            "columns": ["Flag"],
            "rows": [[v] for v in values],
        },
    }


def main() -> None:
    fixtures = [
        fixture_simple_int64_string(),
        fixture_nulls_bitmap_byte_boundary(),
        fixture_multi_batch(),
        fixture_dictionary_encoded(),
        fixture_unicode_strings(),
        fixture_boolean_column(),
    ]
    os.makedirs(FIXTURES_DIR, exist_ok=True)
    manifest_path = os.path.join(FIXTURES_DIR, "arrow_fixtures.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump({"fixtures": fixtures, "pyarrow_version": pa.__version__}, f,
                  indent=2, ensure_ascii=False)

    print(f"Wrote {manifest_path}")
    for fx in fixtures:
        print(f"  - {fx['name']}: {len(fx['hex']) // 2} bytes")


if __name__ == "__main__":
    main()
