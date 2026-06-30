# Development Plan

<!--
  AIDD Template — Replace this file with your project's development plan.
  This document is read by AI agents to understand current priorities and
  suggest next steps. Update it as work progresses.
-->

## Active Work

<!--
  List the current phase/epic that is actively being worked on.
  Update status as tasks are completed.
-->

### Phase 7: Query-Agnostic Arrow IPC Parity Hardening
**Epic**: [tasks/arrow-query-agnostic-parity-epic.md](tasks/arrow-query-agnostic-parity-epic.md)
**Status**: ✅ COMPLETED (2026-06-30)
**Goal**: Extend parity coverage so Arrow IPC parsing matches `ExecuteQuery*` output regardless of DAX query shape, value distribution, or stream framing.

**Endpoint clarification (2026-06-30)**: The connector calls `v1.0/myorg/.../executeDaxQueries` (note the `Dax` in the path) — NOT the public `executeQueries` REST endpoint. `executeDaxQueries` returns `Content-Type: application/vnd.apache.arrow.stream` with the Arrow stream continuation marker (`0xFFFFFFFF`) as the leading bytes, so Tasks 1–5 below DO exercise the Arrow IPC parser end-to-end against the live tenant. A new gate pre-flight step (`Assert-ArrowResponseShape.ps1`) probes this endpoint each gate run and fails loudly if PBI ever silently downgrades to JSON.

**Tasks**:
- ✅ Multi-record-batch stream parity fixture (65,000-row GENERATESERIES, both endpoint pairs)
- ✅ Unicode / multi-byte UTF-8 text parity fixture (ASCII, Latin ext, CJK, emoji, empty, whitespace)
- ✅ Mixed-null validity bitmap parity fixture (10 rows toggling across byte boundary, all-null column, mixed boolean)
- ✅ Large dictionary-encoded stream parity fixture (CROSSJOIN GENERATESERIES × AlignmentDim, ~tens of thousands of rows)
- ✅ Extended scalar type parity (time, int64 magnitudes, high-precision decimal, small/large magnitudes)
- ✅ Static Arrow IPC fixture parser test (deterministic pyarrow-generated fixtures, 20 facts including corruption detection, credential-free)
- ✅ Gate + plan integration — static fixture wired into `Run-ArrowParsingGate.ps1` as step 4; new Arrow-response-shape pre-flight added as step 0; full gate green (6/6 steps)

---

### Phase 4: GitHub Actions Smoke Verification
**Epic**: [tasks/no-fallback-enforcement-executedaxqueries-epic.md](tasks/no-fallback-enforcement-executedaxqueries-epic.md)
**Status**: ⏳ READY FOR VERIFICATION
**Goal**: Validate end-to-end GitHub Actions execution with ci-actions environment and TEST_CONFIG_JSON secret.

**Tasks**:
- ⏳ Run workflow_dispatch focused test against `PBIRESTAPIComm.tests.datasets.parity.query.pq`
- ⏳ Confirm ci-actions environment secrets and protection flow are satisfied

**Note**: Dictionary parsing fix completed. Parity tests now stable with dictionary-encoded columns.

---

## Completed Work

<!--
  Archive completed phases here as a historical record.
-->

### Phase 6: Arrow Parsing Reliability Gate
**Epic**: [tasks/dictionary-batch-parsing-hardening-epic.md](tasks/dictionary-batch-parsing-hardening-epic.md)
**Status**: ✅ COMPLETED (2026-06-19)
**Goal**: Prevent recurring Arrow parsing regressions by enforcing a repeatable local reliability gate.

**Tasks**:
- ✅ Add DateDim Arrow soak runner for intermittent failure detection
- ✅ Add one-command Arrow parsing gate script
- ✅ Run gate with soak iterations and collect artifact summary (see `artifacts/arrow-gate/arrow-gate-20260619-171838.md` — all 4 steps PASS, 5 soak iterations PASS)
- ✅ Keep gate green before merging Arrow parser changes (standing policy)

---

### Phase 5: Dictionary Batch Parsing Hardening
**Epic**: [tasks/dictionary-batch-parsing-hardening-epic.md](tasks/dictionary-batch-parsing-hardening-epic.md)
**Status**: ✅ COMPLETED (2026-06-19)
**Goal**: Fix recursive dictionary batch parsing failures so TOPN queries with text/categorical columns succeed.

**Tasks**:
- ✅ Fixed recursive dictionary lookup by passing accumulated dictionaries to DictionaryBatch parsing
- ✅ Validated dictionary-encoded parity tests (DateDim, MarvelFact, AlignmentDim, EyeDim)
- ✅ Dictionary batch unit tests
- ⏳ Arrow feature support documentation (deferred to future hardening)

---

### Phase 3: No-Fallback Enforcement For ExecuteDaxQueries
**Epic**: [tasks/no-fallback-enforcement-executedaxqueries-epic.md](tasks/no-fallback-enforcement-executedaxqueries-epic.md)
**Status**: ✅ COMPLETED (2026-06-15)
**Goal**: Enforce and verify that ExecuteDaxQueries endpoint paths never fall back to ExecuteQuery endpoint paths.

**Tasks**:
- ✅ Define no-fallback contract tests
- ✅ Add static call-chain guard
- ✅ Harden ExecuteDax response pipeline
- ✅ Integrate targeted test execution

### Phase 2: Dataset Parity Integration Tests
**Epic**: [tasks/dataset-parity-integration-tests-epic.md](tasks/dataset-parity-integration-tests-epic.md)
**Status**: ✅ COMPLETED
**Goal**: Add deterministic JSON-vs-Arrow endpoint parity coverage with actionable mismatch reporting and targeted execution.

**Tasks**:
- ✅ Canonical normalization helpers
- ✅ Core type parity fixtures
- ✅ Edge case parity fixtures
- ✅ Actionable mismatch reporting
- ✅ Targeted execution integration
