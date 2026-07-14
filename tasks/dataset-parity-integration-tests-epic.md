# Dataset Parity Integration Tests Epic

**Status**: ✅ COMPLETED (2026-06-09)
**Goal**: Add deterministic JSON-vs-Arrow parity coverage for dataset query endpoints with actionable mismatch reporting and targeted execution.

## Overview

WHY: endpoint-level parity is the quality gate that proves Arrow parsing returns the same analytical results as the JSON baseline. This epic adds canonical comparison rules and focused fixtures so regressions are found quickly without broad-suite reruns.

---

## Canonical Normalization Helpers

Add shared test helpers that normalize values consistently before comparison across endpoint families.

Status: Completed on 2026-06-09.

**Requirements**:
- Given null and missing values, should normalize into one deterministic representation.
- Given numeric values, should normalize with explicit precision/tolerance policy.
- Given date/time/datetimezone values, should normalize to a stable comparable format.
- Given text and boolean values, should normalize with exact-match semantics.

## Core Type Parity Fixtures

Add parity fixtures for representative core data types and compare ExecuteQueryInGroup against ExecuteDaxQueriesInGroup cell-by-cell.

Status: Completed on 2026-06-09.

**Requirements**:
- Given integer and decimal fixtures, should return matching normalized rows and columns between endpoint families.
- Given boolean and text fixtures, should return matching normalized rows and columns between endpoint families.
- Given datetime fixtures, should return matching normalized rows and columns between endpoint families.
- Given blank/null-heavy fixture rows, should return matching normalized rows and columns between endpoint families.

## Edge Case Parity Fixtures

Add parity fixtures for boundary and shape-oriented scenarios.

Status: Completed on 2026-06-09.

**Requirements**:
- Given an empty result fixture, should report parity success with zero-row table expectations.
- Given a single-row fixture, should report parity success with exact coordinate checks.
- Given wide/computed-column fixtures, should preserve ordered column names and compare every cell deterministically.

## Actionable Mismatch Reporting

Add explicit mismatch diagnostics for fast triage.

Status: Completed on 2026-06-09.

**Requirements**:
- Given a mismatch, should report query identifier and endpoint pair.
- Given a mismatch, should report row index and column name coordinates.
- Given a mismatch, should report normalized expected and actual values.
- Given a mismatch with type-sensitive logic, should report relevant type metadata in failure details.

## Targeted Execution Integration

Ensure parity tests are runnable in isolation with the CI script.

Status: Completed on 2026-06-09.

**Requirements**:
- Given the parity test file name, should run only that file via `CI/Scripts/Run-PQTests.ps1 -TestFileName`.
- Given a parity file failure, should surface the failing file clearly in summary output.
- Given a passing parity file, should complete without requiring full split-suite execution.

## Definition of Done

- Deterministic parity assertions exist for core types and edge-case fixtures.
- Canonical normalization is centralized and reused by all parity checks.
- Failure output includes exact mismatch coordinates and normalized values.
- Targeted parity file execution works as default development loop.
