# Dictionary Batch Parsing Hardening Epic

**Status**: ✅ COMPLETED (2026-06-19)
**Goal**: Fix recursive dictionary batch parsing failures so TOPN queries with text/categorical columns succeed reliably.

## Overview

WHY: Power BI uses Arrow dictionary encoding for text/categorical columns in DAX query results. Current implementation fails with recursive "Dictionary batch parsing failed" errors when processing dictionary batches that contain nested dictionary-encoded fields. This blocks all real-world parity testing and makes Arrow support unusable for production queries.

---

## Task 1: Fix Recursive Dictionary Lookup

Fix the circular dependency when dictionary values are themselves dictionary-encoded.

Status: ✅ COMPLETED (2026-06-16)

**Root Cause**: 
- When parsing a DictionaryBatch, `ArrowRecordBatchToTable` was called with empty dictionaries `[ ]`
- If the dictionary's values referenced OTHER dictionaries already parsed, lookup failed
- This created recursive "Dictionary batch parsing failed" errors

**Solution**:
- Changed DictionaryBatch parsing to pass accumulated `[Dictionaries]` instead of `[ ]`
- Dictionary values can now reference previously-parsed dictionaries
- All TOPN parity tests with text columns now pass successfully

## Task 2: Add Dictionary Batch Unit Tests

Add isolated unit tests for dictionary batch message parsing.

Status: ✅ COMPLETED (2026-06-19)

**Implementation**:
- Added dictionary batch validation unit tests for Id, Data pointer, and IsDelta fields.
- Added explicit error-path unit tests for missing Id, invalid Data pointer, and invalid IsDelta flag.
- Added dictionary merge unit tests to verify delta append behavior and replacement behavior.
- Validated with targeted test run on `PBIRESTAPIComm.tests.arrow.helpers.query.pq`.

**Requirements**:
- Given valid dictionary batch metadata, should parse Id, Data object reference, and IsDelta flag correctly
- Given a dictionary batch with delta flag, should merge with previous dictionary values
- Given a dictionary batch with replacement mode, should replace previous dictionary values
- Given missing or invalid dictionary batch fields, should fail with actionable error

## Task 3: Add Dictionary-Encoded Parity Tests

Re-enable TOPN parity tests for tables with text columns after fix is validated.

Status: ✅ COMPLETED (2026-06-16)

**Implementation**:
- Added TOPN(10) parity tests for DateDim with text columns
- Added TOPN(10) parity tests for MarvelFact
- Added TOPN(10) parity tests for AlignmentDim and EyeDim
- All tests validate both ExecuteQuery/ExecuteDaxQueries and ExecuteQueryInGroup/ExecuteDaxQueriesInGroup
- All tests pass successfully with dictionary-encoded columns

## Task 4: Document Arrow Feature Support

Add README section documenting supported vs. unsupported Arrow IPC features.

Status: ✅ COMPLETED (2026-06-19)

**Implementation**:
- Added `Arrow IPC Support (ExecuteDaxQueries)` section to README.
- Documented currently supported parser capabilities, including dictionary batch handling.
- Documented explicit non-supported behavior (for example compression) and fail-fast diagnostics.
- Documented support boundary and validation approach via targeted parity tests and Arrow gate.

**Requirements**:
- Given connector README, should list supported Arrow data types and encoding schemes
- Given unsupported features, should explicitly document limitations (e.g., compression, large types, custom metadata)
- Given dictionary encoding, should confirm support status after fix validation
- Given future Arrow IPC versions, should document target Arrow format version

## Definition of Done

- Dictionary batch parsing succeeds for TOPN queries with text/categorical columns
- All parity tests (DateDim, MarvelFact, AlignmentDim, EyeDim) pass with both in-group and non-group endpoints
- Dictionary batch unit tests exist and pass
- README documents Arrow feature support clearly
