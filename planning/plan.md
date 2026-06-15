# Arrow IPC Stream Validation Plan

## Purpose
Establish a reliable test strategy to validate Arrow IPC parsing by comparing `ExecuteDaxQueries*` table output to `ExecuteQuery*` JSON output, with deterministic cell-by-cell matching and focused test execution for future agentic development.

## Goals
1. Verify that Arrow and JSON pathways produce equivalent tabular results for the same DAX query.
2. Validate parsing behavior for each supported data type and common edge cases.
3. Run only targeted test files/scenarios with `Run-PQTests.ps1` to reduce token usage.
4. Add unit-level tests for each Arrow helper/detection/parsing function to isolate regressions quickly.

## Scope
- In scope:
  - `PBIRESTAPIComm.ExecuteQuery`
  - `PBIRESTAPIComm.ExecuteQueryInGroup`
  - `PBIRESTAPIComm.ExecuteDaxQueries`
  - `PBIRESTAPIComm.ExecuteDaxQueriesInGroup`
  - Arrow helpers under `Arrow.*` in `PBIRESTAPIComm.pq`
- Out of scope:
  - Expanding endpoint coverage unrelated to DAX/Arrow response handling.

## Test Architecture

### 1) Golden Comparison Path (JSON vs Arrow)
- Use `ExecuteQuery*` as baseline (JSON response).
- Convert JSON result payload (`results/tables/rows`) into a canonical table shape.
- Run equivalent query via `ExecuteDaxQueries*` and normalize to the same canonical shape.
- Perform deterministic comparison:
  - Same column count and ordered names.
  - Same row count.
  - Cell-by-cell equality with type-aware normalization.

### 2) Canonical Normalization Rules
- Normalize values before comparison:
  - Null handling (`null` vs missing fields).
  - Number precision/scale (decimal and floating tolerance policy).
  - Date/DateTime/DateTimeZone formatting and timezone normalization.
  - Boolean exact match.
  - Text exact match (including empty string).
  - Binary/text representations where applicable.
- Keep normalization logic centralized so all tests share identical semantics.

### 3) Data Type Matrix
Create dedicated query fixtures that each emphasize one or more types:
- Integer/Whole Number
- Decimal/Double/Currency
- Boolean
- Text (ASCII + Unicode)
- Date/Time/DateTime/DateTimeZone
- Blank/Null-heavy columns
- Mixed and computed columns (renamed, calculated, fully-qualified names)
- Edge payloads: empty result set, single row, wide table, high row count within allowed limits

### 4) Arrow Function Unit Tests
Add isolated unit tests for Arrow helpers/functions, including success and failure paths:
- Detection:
  - `Arrow.Detection.GetContentType`
  - `Arrow.Detection.IsArrowContentType`
  - `Arrow.Detection.HasArrowMagic`
  - `Arrow.Detection.IsArrowResponse`
- Binary helpers:
  - `Arrow.BinaryEx.Buffer`
  - `Arrow.BinaryEx.Slice`
  - `Arrow.BinaryEx.Length`
- Error-path behaviors:
  - Invalid magic handling
  - Unsupported compression detection
  - Malformed/unsupported payload failures
- Keep these tests independent from live service variability where possible.

### 5) Integration Tests for Query Endpoints
- Add focused integration assertions in dataset test suite(s) that:
  - Run the same DAX query through both endpoint families.
  - Compare canonicalized tables cell-by-cell.
  - Surface exact mismatch location (row index, column name, expected vs actual).
- Include both non-group and in-group variants where environment variables allow.

## Targeted Test Execution (Token Optimization)
- Use `Run-PQTests.ps1 -TestFileName` for narrow runs during iteration.
- Recommended workflow:
  1. Arrow helper unit test file(s) only.
  2. Dataset parity test file(s) only.
  3. Full split suite only before merge.
- Keep test files split by concern (Arrow unit vs endpoint parity) so agent runs can stay minimal.

## Failure Reporting Requirements
- On mismatch, report:
  - Query identifier
  - Endpoint pair (`ExecuteQuery*` vs `ExecuteDaxQueries*`)
  - Column and row coordinates
  - Normalized expected/actual values
  - Value type metadata when relevant
- Ensure failures are actionable without re-running broad suites.

## Implementation Phases
1. Define canonical conversion and normalization utilities.
2. Add Arrow helper unit tests and error-path tests.
3. Add JSON-vs-Arrow parity tests for core type fixtures.
4. Expand matrix to edge cases and larger payloads.
5. Integrate selective test execution guidance into regular dev workflow.

## Definition of Done
- Cell-by-cell parity tests exist for representative type coverage.
- Arrow helper functions have direct unit tests for positive/negative paths.
- `Run-PQTests.ps1` selective execution is the default dev loop for these tests.
- Failures identify exact mismatch coordinates and parsing context.
- Plan is maintainable and usable by future agentic development workflows.
