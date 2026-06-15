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

### Phase 4: GitHub Actions Smoke Verification
**Epic**: [tasks/no-fallback-enforcement-executedaxqueries-epic.md](tasks/no-fallback-enforcement-executedaxqueries-epic.md)
**Status**: ⏳ PENDING VERIFICATION
**Goal**: Validate end-to-end GitHub Actions execution with ci-actions environment and TEST_CONFIG_JSON secret.

**Tasks**:
- ⏳ Run workflow_dispatch focused test against `PBIRESTAPIComm.tests.datasets.nofallback.query.pq`
- ⏳ Confirm ci-actions environment secrets and protection flow are satisfied

---

## Completed Work

<!--
  Archive completed phases here as a historical record.
-->

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
