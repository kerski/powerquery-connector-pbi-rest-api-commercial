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

### Phase 8: Universal Arrow Dictionary-Batch Fix
**Status**: 🚧 IN PROGRESS (opened 2026-07-10) — core fix landed; Pillars 2 & 4 remain
**Goal**: Permanently eliminate recurring "Dictionary batch parsing failed" errors on real DAX query shapes (for example `TOPN(10, DateDim, DateDim[Date], DESC)`), without ever falling back to `ExecuteQuery*`.

**Why this phase exists**: Despite Phases 5–7 being marked complete, live queries that return **multiple dictionary-encoded text columns** still fail with recursively nested `DictionaryBatch` errors (observed offsets 1080 → 1440 → 1696 → RecordBatch 2056). Root cause is a **coverage gap plus build hygiene**, not a one-off parser bug:
- The offline fixture corpus (`CI/Scripts/Generate-ArrowFixtures.py`) only ever exercises a **single** dictionary column, so multi-dictionary batches are an untested path.
- Stale/duplicate `.mez` builds meant some failures were run against an old connector (error text `"Dictionary batch parsing failed"` does not exist in current source).
- The parser relies on masking heuristics (aligned/unaligned body double-`try`, `indexInt - 1` index-base guess) instead of spec-correct logic validated against an oracle.

**Strategy**: Use pyarrow as a byte-level oracle (it emits IPC framing byte-identical to the `executeDaxQueries` endpoint). Drive the corpus from the real failing shapes, then fix the structural bugs those fixtures expose.

**Tasks**:
- ✅ **Pillar 0 — Build hygiene** (2026-07-10): removed duplicate/nested `bin\AnyCPU\Debug\bin\...` output and bare `.mez`; untracked them from git and added `.gitignore` rules; fixed the `-replace ".mez"` regex-wildcard bug in `Run-PQTests.ps1`; added pre-compile cleanup, post-compile "exactly one mez" verification, and a test-phase guard that refuses to run against stale/duplicate builds.
- ✅ **Pillar 1 — Reproduce offline** (2026-07-10): added pyarrow fixtures `multi_dictionary_columns` (3 dict text columns — reproduces the TOPN/DateDim failure), `datedim_shaped` (int64 + 2 dict + bool), `dictionary_with_nulls`, and `dictionary_int16_indices`. Regenerated `tests/fixtures/arrow_fixtures.json` (10 fixtures) and the static fixture test. A credential-free probe confirmed the offline corpus reproduced the failure: **all 10 fixtures failed** before the fix.
- ✅ **Pillar 3 — Fix structural bugs the corpus exposed** (2026-07-10): found the true root cause in `ArrowResolvePendingDictionaryBatches` — two bugs in one `List.Generate`/`List.Last` fixpoint. (1) With no pending batches (the case after every schema message), `List.Generate` yielded an empty list, `List.Last` returned `null`, and `null[Pending]` threw "We cannot apply field access to the type Null" — this broke **every** Arrow response, not just dictionary ones. (2) `List.Generate` emits `selector(state)` before running `next(state)` (where the dictionary materialization work lived), so the loaded dictionaries were never emitted and `List.Last` returned the pre-load state → "Dictionary values were not loaded". Replaced the whole fixpoint with a correct recursive `resolve`/`onePass` helper (`List.Accumulate` + `@resolve`). After the fix, **all 10 fixtures parse and match cell-by-cell** (multi_dictionary_columns 10 rows, datedim_shaped 10 rows, dictionary_encoded 5 rows, etc.). The earlier index-base guessing and aligned/unaligned double-`try` were not the cause and remain for a later cleanup.
- ⏳ **Pillar 2 — Real captures become permanent fixtures**: wire `Capture-ArrowFixture.ps1` → pyarrow so any live failure is captured as raw bytes, parsed by pyarrow to produce the expected table, and appended to the manifest (no hand-authored expectations).
- ⏳ **Pillar 4 — CI gate**: run the offline fixture suite on every build (fast, no secrets). **Known gap**: the static fixture test currently reports `Status=Passed` whenever the query merely evaluates; individual failing `Fact`s are `try`-wrapped and do not fail the run. The gate must assert every fact `Result="Success"` so a red fixture cannot pass silently. Keep the live parity suite as the integration gate.

**Definition of Done**:
- ✅ `TOPN(10, DateDim, ...)` and other multi-dictionary shapes parse correctly and match cell-by-cell (proven offline via `multi_dictionary_columns` / `datedim_shaped`).
- ✅ An offline fixture reproduces the current failure and then passes after the fix.
- ✅ No `ExecuteQuery*` fallback anywhere in the `ExecuteDax*` chain (existing static guard stays green).
- ⏳ CI gate fails on any failing fact (Pillar 4).

---

### Phase 9: Release Hygiene, Documentation & Secret Safety
**Status**: 📋 PLANNED (opened 2026-07-12)
**Goal**: Ship a clean, accurately documented repository with no extraneous files and no committed secrets, and give `ExecuteDaxQueries` / `ExecuteDaxQueriesInGroup` a clear, diagrammed call tree in the README.

**Why this phase exists**: The recent Arrow debugging work left behind ad-hoc scratch files (`_tmp_*.txt`, `_tmp_*.log`, `_probe_*.query.pq`, parity dumps) and the README has not been reconciled against the current `ExecuteDax*` architecture. Before release we need the repo to be self-explanatory for humans and agents, provably free of secrets, and free of stale/duplicate build or diagnostic artifacts.

**Tasks**:
- ⏳ **File cleanup**: Inventory and remove (or `.gitignore`) extraneous/unneeded files — root scratch captures (`_tmp_parity_live.txt`, `_tmp_testrun.log`, `_probe_overflow.query.pq`, `_probe_timing.query.pq`, `proof-output.txt`, `datedim-parity-proof.txt`), any stale/duplicate `.mez`, and other non-source diagnostic dumps. Keep only what the build/tests/docs require. Do not delete in-progress work without confirmation.
- ⏳ **README accuracy pass**: Reconcile `README.md` with the current architecture — `ExecuteDaxQueries*` (Arrow-capable) vs `ExecuteQuery*` (JSON) endpoints, the no-fallback guarantee, and pointer to the CI/GitHub Actions testing guide. Correct any stale function names, paths, or commands.
- ⏳ **Mermaid call-tree diagram**: Add a Mermaid diagram to `README.md` showing the call tree for `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup` down through `PostExecuteDax` → `ExecuteDaxResponseAsTable` → detection (`ExecuteDaxDetectResponseKind`) → Arrow (`ArrowFromBinary` → `ArrowParseStream` → dictionary/record batch) vs JSON (`ExecuteDaxParseJsonResponse`) paths.
- ⏳ **Testing up to date**: Confirm the split test suite reflects current behavior (Arrow dictionary fixes, no-fallback contract), the datedim regression fixture stays green, and README/testing docs list the current commands and files. Note any Phase 8 CI-gate gap that still applies.
- ⏳ **Secret & bad-file safety**: Verify no secrets are committed (e.g. `CI/Scripts/variables.test.json` stays ignored; scan tracked files for tokens/passwords), confirm `.gitignore` covers scratch/log/test-output patterns, and ensure no large/binary junk or stale build outputs are staged.

**Definition of Done**:
- ⏳ Repo contains no extraneous scratch/diagnostic files in source control; `.gitignore` covers their patterns.
- ⏳ `README.md` accurately describes the `ExecuteDax*` architecture and includes a working Mermaid call-tree diagram for `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup`.
- ⏳ Test suite and testing docs are current; datedim regression fixture green.
- ⏳ No secrets or bad files tracked; verified by inspection of tracked files and `.gitignore`.

---

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
