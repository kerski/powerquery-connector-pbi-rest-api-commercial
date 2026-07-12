# Arrow Helper Unit Tests Epic

**Status**: ✅ COMPLETED (2026-06-09)
**Goal**: Add deterministic, targeted unit coverage for Arrow helper functions so regressions are caught quickly with low-token test runs.

## Overview

WHY: Arrow helper defects can silently break DAX query parsing or cause hard-to-triage failures. This epic focuses only on helper-level tests for detection, binary operations, error-path hardening, and actionable diagnostics to keep feedback fast and reliable.

---

## Task 1: Detection Reliability Tests

Add focused unit tests for `Arrow.Detection.GetContentType`, `Arrow.Detection.IsArrowContentType`, `Arrow.Detection.HasArrowMagic`, and `Arrow.Detection.IsArrowResponse`.

Status: Completed on 2026-06-09.

**Requirements**:
- Given a valid Arrow content-type header, should classify the response as Arrow.
- Given a non-Arrow content-type header, should classify the response as non-Arrow.
- Given valid Arrow magic bytes, should return `true` for magic detection.
- Given missing or invalid Arrow magic bytes, should return `false` or deterministic error per helper contract.
- Given conflicting signals between header and bytes, should apply consistent precedence behavior.

## Task 2: Diagnostic Message Quality Tests

Add assertions that helper failures include context needed for rapid triage.

Status: Completed on 2026-06-09.

**Requirements**:
- Given a detection failure, should report helper/function name and failure reason.
- Given a binary boundary failure, should report index/length context.
- Given unsupported compression, should report compression identifier when available.
- Given malformed payload, should report parse stage context (detection, metadata, or batch decode).

## Task 3: Binary Helper Correctness Tests

Add unit tests for `Arrow.BinaryEx.Buffer`, `Arrow.BinaryEx.Slice`, and `Arrow.BinaryEx.Length` for normal and boundary cases.

Status: Completed on 2026-06-09.

**Requirements**:
- Given valid slice arguments, should return exact expected bytes.
- Given out-of-bounds slice arguments, should fail deterministically.
- Given buffered binary input, should preserve byte-for-byte identity.
- Given empty and non-empty payloads, should return accurate binary length.

## Task 4: Unsupported and Malformed Payload Hardening Tests

Add negative-path tests validating fail-fast behavior for invalid streams.

Status: Completed on 2026-06-09.

**Requirements**:
- Given unsupported compression metadata, should fail fast with explicit unsupported-compression behavior.
- Given malformed Arrow stream structure, should fail with deterministic parse failure behavior.
- Given truncated payloads, should not produce partial or undefined parse output.
- Given invalid magic at expected offsets, should stop before record-batch parsing.

## Task 5: Targeted Execution Integration

Ensure the Arrow helper unit test file can be run in isolation through the CI script without invoking the full suite.

Status: Completed on 2026-06-09.

**Requirements**:
- Given a helper unit test file name, should run only that file via `CI/Scripts/Run-PQTests.ps1 -TestFileName`.
- Given a helper test failure, should identify the failing test file clearly in summary output.
- Given passing helper tests, should complete without requiring full split-suite execution.

## Definition of Done

- Arrow helper unit tests exist for detection, binary helpers, and error paths.
- Failure messages include enough context for quick diagnosis.
- Unit test file(s) can be run in isolation with `-TestFileName`.
- Epic remains scoped to helper-level testing only (no endpoint parity integration expansion in this epic).
