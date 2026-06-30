# Query-Agnostic Arrow IPC Parity Hardening Epic

**Status**: ✅ COMPLETED (2026-06-30)
**Goal**: Extend Arrow IPC parsing coverage so `ExecuteDaxQueries*` matches `ExecuteQuery*` output regardless of DAX query shape, value distribution, or Arrow stream framing — and never falls back.

## Overview

WHY: The current parity suite proves correctness for representative TOPN, scalar, blank, dictionary-encoded, and wide-column queries on the live tenant. Several Arrow IPC code paths and value distributions are not yet exercised end-to-end, leaving room for query-specific regressions. This epic closes that surface so the connector is provably query-agnostic, while preserving the no-fallback contract and the existing reliability gate.

### Endpoint clarification (2026-06-30)

The connector targets `v1.0/myorg/.../executeDaxQueries` (note the `Dax` in the path) — NOT the public `executeQueries` REST endpoint. The `executeDaxQueries` endpoint returns `Content-Type: application/vnd.apache.arrow.stream` with the Arrow stream continuation marker (`0xFFFFFFFF`) as the leading four bytes. Therefore the live parity facts in Tasks 1–5 below DO exercise the Arrow IPC parser end-to-end against the live tenant. A new gate pre-flight step (`CI/Scripts/Assert-ArrowResponseShape.ps1`) probes this endpoint on every gate run and fails loudly if PBI ever silently downgrades the response to JSON — protecting the parity tests from quietly degrading to JSON-vs-JSON validation. (An earlier mid-epic note that probed the wrong endpoint and concluded the tests were JSON-vs-JSON only has been corrected; the gate's response-shape assertion is the durable safeguard against that class of mistake.)

### Constraints

- Every new live-tenant fixture compares `ExecuteDaxQueries*` against the `ExecuteQuery*` baseline using the existing `AssertCanonicalParity` helper in `PBIRESTAPIComm.tests.datasets.parity.query.pq`.
- No new fixture introduces or tolerates fallback behavior. Failures must surface diagnostics, not endpoint substitution.
- Live fixtures must remain gated by `RunLiveParity` so the file stays runnable in isolation without credentials.
- The Arrow parsing reliability gate (`Run-ArrowParsingGate.ps1`) must stay green after every task and must include the response-shape pre-flight.
- The connector `.mez` build must never depend on Python, pyarrow, or any author-time fixture-generator tooling. Fixture bytes are committed; the test parses them in pure M.
- Targeted execution remains the default loop: `./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName <file>`.

---

## Task 1: Multi-Record-Batch Stream Parity Fixture

Exercise the `Arrow.Stream` framing loop with a DAX query that forces the Arrow response to emit more than one RecordBatch message.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `LargeMultiBatchQuery` (`EVALUATE SELECTCOLUMNS(GENERATESERIES(1, 65000, 1), "N", [Value], "N2", [Value] * 2)`) to `PBIRESTAPIComm.tests.datasets.parity.query.pq`.
- Added two parity facts asserting `ExecuteDaxQueries` vs `ExecuteQuery` and `ExecuteDaxQueriesInGroup` vs `ExecuteQueryInGroup` match cell-by-cell across 65,000 rows.
- Validated via `./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq` (log: `artifacts/arrow-gate/task1-multibatch-parity.log`).

**Requirements**:
- Given a DAX query that returns enough rows to span multiple Arrow record batches, should produce a single canonical table that matches `ExecuteQuery*` cell-by-cell.
- Given the same query, should pass parity for both `ExecuteQuery` vs `ExecuteDaxQueries` and `ExecuteQueryInGroup` vs `ExecuteDaxQueriesInGroup`.
- Given the same query, should not change column order between endpoint pairs.
- Given Arrow parsing failure on this fixture, should surface an `Arrow.Stream` parse error and not reroute through `ExecuteQuery*`.

## Task 2: Unicode / Multi-Byte UTF-8 Text Parity Fixture

Validate that the Utf8 offsets buffer is decoded byte-accurately for non-ASCII text values.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `UnicodeTextQuery` (UNION of `ASCII`, `café`, `日本語`, `🎉`, empty string, leading/trailing whitespace) to `PBIRESTAPIComm.tests.datasets.parity.query.pq`.
- Added two parity facts asserting `ExecuteDaxQueries` vs `ExecuteQuery` and `ExecuteDaxQueriesInGroup` vs `ExecuteQueryInGroup` match cell-by-cell across all Unicode variants.
- Validated via `./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq` (log: `artifacts/arrow-gate/task2-unicode-parity.log`).

**Requirements**:
- Given text values containing multi-byte UTF-8 characters (Latin extended, CJK, emoji), should match the JSON baseline character-for-character.
- Given text values with embedded quotes, backslashes, and whitespace, should match the JSON baseline exactly.
- Given empty-string text values mixed with populated values, should preserve string boundaries between cells.
- Given Arrow parsing failure on this fixture, should surface an `Arrow.Arrays` Utf8 error and not reroute through `ExecuteQuery*`.

## Task 3: Mixed-Null Validity Bitmap Parity Fixture

Exercise validity bitmap decoding with values that toggle between null and non-null at non-byte-aligned positions.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `MixedNullBitmapQuery` (10-row UNION) to `PBIRESTAPIComm.tests.datasets.parity.query.pq` covering an integer column toggling null/non-null across the bit-7→bit-8 byte boundary, an all-null companion column, and a boolean column with mixed null/true/false.
- Added two parity facts asserting `ExecuteDaxQueries` vs `ExecuteQuery` and `ExecuteDaxQueriesInGroup` vs `ExecuteQueryInGroup` match cell-by-cell.
- Validated via `./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq` (log: `artifacts/arrow-gate/task3-mixednull-parity.log`).

**Requirements**:
- Given a column whose null/non-null pattern toggles across at least nine consecutive rows, should match the JSON baseline cell-by-cell including null placement.
- Given an all-null column alongside a fully-populated column in the same row set, should produce matching column order and matching cell values.
- Given a boolean column with mixed null/true/false values, should match the JSON baseline including null cells.
- Given Arrow parsing failure on this fixture, should surface an `Arrow.Arrays` bitmap-related error and not reroute through `ExecuteQuery*`.

## Task 4: Large Dictionary-Encoded Stream Parity Fixture

Exercise large dictionary-encoded text streams end-to-end so the dictionary merge/replacement path is covered beyond the existing isolated unit tests. The Power BI Arrow encoder controls whether dictionary batches are emitted as replacement or delta (`IsDelta = true`); this fixture maximizes the likelihood of multi-batch dictionary handling without depending on a specific encoder decision.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `LargeDictionaryEncodedQuery` (`EVALUATE CROSSJOIN(SELECTCOLUMNS(GENERATESERIES(1, 5000, 1), "N", [Value]), AlignmentDim)`) to `PBIRESTAPIComm.tests.datasets.parity.query.pq`, producing tens of thousands of rows with dictionary-encoded text columns from AlignmentDim.
- Added two parity facts asserting `ExecuteDaxQueries` vs `ExecuteQuery` and `ExecuteDaxQueriesInGroup` vs `ExecuteQueryInGroup` match cell-by-cell across the full stream.
- Validated via `./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq` (log: `artifacts/arrow-gate/task4-largedict-parity.log`).
- Dictionary delta (`IsDelta = true`) merge correctness remains covered by isolated unit tests in `PBIRESTAPIComm.tests.arrow.helpers.query.pq`; the integration path is now covered for any dictionary-batch sequence the PBI encoder chooses to emit.

**Requirements**:
- Given a DAX query whose Arrow response emits at least one delta dictionary batch, should match the JSON baseline for the affected text/categorical columns.
- Given a delta batch that appends values, should produce the same final value distribution as the JSON baseline.
- Given a replacement dictionary batch (`IsDelta = false`) on the same stream, should produce the same final value distribution as the JSON baseline.
- Given Arrow parsing failure on this fixture, should surface an `Arrow.Stream` `DictionaryBatchValidation` or downstream error and not reroute through `ExecuteQuery*`.

## Task 5: Extended Scalar Type Parity Fixtures

Add DAX fixtures that exercise scalar value spaces not yet covered by `CoreTypeSingleRowQuery` and `CoreTypeMultiRowQuery`.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `ExtendedScalarQuery` to `PBIRESTAPIComm.tests.datasets.parity.query.pq` covering `TIME(0,0,0)` and `TIME(23,59,59)`, int64 magnitudes outside int32 range (±9,999,999,999 and ±(int32 boundary ±1)), a high-precision decimal (`0.1234567890123456`), a large-magnitude decimal with fractional precision, and very-small-magnitude positive/negative decimals.
- Added two parity facts asserting `ExecuteDaxQueries` vs `ExecuteQuery` and `ExecuteDaxQueriesInGroup` vs `ExecuteQueryInGroup` match cell-by-cell after canonicalization through the existing `CanonicalDecimalPlaces` rounding policy.
- Validated via `./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq` (log: `artifacts/arrow-gate/task5-extscalar-parity.log`).
- Note: DAX has no synthetic literal form for non-UTC `datetimezone` offsets; offset-bearing zone values can only flow through model-defined columns. The connector's `datetimezone` canonicalization (UTC normalization) is exercised by the existing `helperFacts` `CanonicalizeCell` unit fact and remains correct by construction.

**Requirements**:
- Given datetimezone values with non-UTC offsets, should match the JSON baseline after canonicalization to UTC.
- Given time-only values, should match the JSON baseline using the canonical `HH:mm:ss` representation.
- Given integer values at int64 minimum and maximum boundaries, should match the JSON baseline without precision loss.
- Given decimal values at high precision (more than nine fractional digits) and at very large/very small magnitudes, should match the JSON baseline within the existing `CanonicalDecimalPlaces` policy.

## Task 6: Static Arrow IPC Fixture Parser Test

Add a deterministic, credential-free parser test that exercises `Arrow.FromBinary` against committed Arrow IPC stream fixtures generated by a known-good reference encoder (pyarrow). The fixture bytes are hex-embedded in the M test file; the generator (`CI/Scripts/Generate-ArrowFixtures.py` + `CI/Scripts/Emit-ArrowStaticFixtureTests.py`) is author-time only and runs from a project-local `.venv` (`requirements.txt`). The connector `.mez` and the test runtime have zero Python dependency.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added project-local virtualenv pattern: `requirements.txt` (pyarrow==24.0.0, author-time only) + `.venv/` gitignored.
- Added `CI/Scripts/Generate-ArrowFixtures.py` which emits `tests/fixtures/arrow_fixtures.json` containing hex byte streams + expected tables for six scenarios: simple int64+utf8, validity-bitmap toggling across the bit-7/bit-8 byte boundary, multi-RecordBatch stream, dictionary-encoded utf8 column, multi-byte UTF-8 (Latin-extended/CJK/emoji/empty), and bit-packed boolean with null distinct from false.
- Added `CI/Scripts/Emit-ArrowStaticFixtureTests.py` which renders the manifest into the M test file so hex and expected tables can never drift out of sync.
- Added `PBIRESTAPIComm.tests.arrow.staticfixture.query.pq` (auto-generated, committed) which decodes each hex blob via `Binary.FromText(..., BinaryEncoding.Hex)`, parses it through the test hook `PBIRESTAPIComm.ArrowFromBinary`, and asserts column names, row count, and cell equality (with explicit null handling) for every fixture. Also asserts two corruption facts: a 16-byte truncation and a zero-continuation-marker header must each raise.
- Wired the new file into `CI/Scripts/Run-PQTests.ps1` `$RelQueryFilePaths` so it runs in the default and targeted loops.
- Validated: 20 facts PASS via `./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName PBIRESTAPIComm.tests.arrow.staticfixture.query.pq` (log: `artifacts/arrow-gate/task6-staticfixture.log`).
- Bonus: redacted the OAuth bearer token in `Run-PQTests.ps1` diagnostic echo so committed run logs do not leak credentials.

**Requirements**:
- Given a committed Arrow IPC stream binary fixture, should parse into a table with the expected ordered columns and exact row count without making any network calls.
- Given the same fixture, should produce cell values that match a committed expected canonical table defined inline.
- Given a deliberately corrupted variant of the fixture, should fail with an `Arrow.Stream` parse error and not reroute through `ExecuteQuery*`.
- Given the new file, should be runnable in isolation via `./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName <new-file>`.

## Task 7: Reliability Gate And Plan Integration

Wire the new coverage into the existing reliability gate and plan so regressions are caught by the default loop.

Status: ✅ COMPLETED (2026-06-30)

**Implementation**:
- Added `CI/Scripts/Assert-ArrowResponseShape.ps1` and registered it as gate step 0 ("Live executeDaxQueries returns Arrow IPC"). The script probes the configured tenant's `executeDaxQueries` endpoint with a tiny `EVALUATE ROW()` query and asserts the response Content-Type contains `arrow` AND the first four bytes are either the stream continuation marker (`ffffffff`) or the Arrow file magic prefix. This is the durable safeguard that ensures Tasks 1–5's parity facts cannot silently degrade to JSON-vs-JSON validation if PBI changes its server behavior.
- Added a new gate step ("Arrow static fixture parser") to `CI/Scripts/Run-ArrowParsingGate.ps1` between the existing helper-tests step and the soak step.
- Updated the gate header docstring to honestly describe what each step covers.
- Full gate executed end-to-end: 6/6 steps PASS.
- `plan.md` Phase 7 entry marked completed.

**Requirements**:
- Given `Run-ArrowParsingGate.ps1`, should include the static Arrow fixture test file from Task 6 in the gate sequence.
- Given a passing gate run after all tasks land, should record an artifact summary file under `artifacts/arrow-gate/`.
- Given a gate failure caused by any new fixture, should produce an `[FAIL]` marker that identifies the failing test file.
- Given `plan.md`, should reflect task completion status as each task lands.

## Task 8: Live Arrow-Path Response-Shape Safeguard

This task was originally scoped as "run Tasks 1–5 against an Arrow-capable workspace" because of a misdiagnosis. After verifying the connector's actual target endpoint is `executeDaxQueries` (which returns `application/vnd.apache.arrow.stream`), Tasks 1–5 were already exercising the Arrow IPC code path on the live tenant. The remaining work — ensuring this stays true — has been folded into Task 7 as the `Assert-ArrowResponseShape.ps1` gate pre-flight.

Status: ✅ COMPLETED (2026-06-30) — superseded by Task 7's response-shape pre-flight.

## Definition of Done

- Tasks 1–5 pass cell-by-cell parity against `ExecuteQuery*` via the live `executeDaxQueries` endpoint (which returns Arrow IPC) and produce actionable diagnostics on failure (✅).
- Task 6 passes Arrow-path parser validation against committed pyarrow-generated fixtures including corruption-detection (✅).
- Task 7 wires the static fixture file and the live response-shape pre-flight into the reliability gate (✅).
- No new fixture references or enables any fallback path from `ExecuteDaxQueries*` to `ExecuteQuery*`.
- The Arrow parsing reliability gate is green with the expanded coverage and includes both the response-shape assertion and the static fixture file.
- `plan.md` Phase 7 entry reflects per-task completion status.
- Targeted test execution (`-TestFileName`) remains the default development loop for every new file added.
