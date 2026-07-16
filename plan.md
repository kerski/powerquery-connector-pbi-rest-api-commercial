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

### Phase 10: Dataset Parity Failure Triage & Runtime Stabilization
**Status**: 🚧 IN PROGRESS (opened 2026-07-15)
**Goal**: Resolve the current `PBIRESTAPIComm.tests.datasets.parity.query.pq` failure and reduce time-to-signal so full split-suite runs do not stall on one long parity file.

**Why this phase exists**: Current runs show `PBIRESTAPIComm.tests.datasets.parity.query.pq` failing with a connector error after extended runtime (`Failed 4567.50 ...`) and this file contains intentionally heavy live fixtures that can delay feedback.

**Tasks**:
- ⏳ Capture the exact failing fact/query from the parity file output and map it to its DAX fixture identifier.
- ⏳ Reproduce the failing fact with targeted runs (`-TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq`) and isolate whether failure is endpoint, parser, or assertion drift.
- ⏳ Add a lightweight profiling pass/log marker to identify slowest parity fixtures in local runs.
- ✅ Split/gate heavyweight parity fixtures into an explicit slow lane via `RunHeavyParity` switch in `PBIRESTAPIComm.tests.datasets.parity.query.pq`, preserving default targeted parity confidence.
- ⏳ Validate that full split-suite order keeps parity last and still reports actionable failure context.

**Definition of Done**:
- ⏳ The currently failing parity case is identified and fixed with a deterministic assertion.
- ⏳ Full split-suite runs surface earlier file results before parity finishes.
- ⏳ A documented fast lane vs slow lane parity workflow exists and is reflected in test commands/docs.

---

### Phase 11: Cross-Tool Multi-EVALUATE Parity (DateTime Probe)
**Status**: 🚧 IN PROGRESS (opened 2026-07-15)
**Goal**: Establish a reproducible parity check for multiple EVALUATE statements across PowerShell, Python, and Power Query using a controlled DateTime probe query in the target workspace/dataset.

**Why this phase exists**: Current diagnostics show environment-dependent behavior for multi-EVALUATE responses (for example one empty Arrow stream in SPN context). We need a deterministic, tool-agnostic verification path that does not depend on the legacy workspace setup and can be rerun locally and in CI.

**Reference**:
- Microsoft guidance for multiple EVALUATE statements: https://learn.microsoft.com/en-us/power-bi/developer/execute-dax-queries-arrow/powershell-multiple-evaluate-statements

**Probe query design (variables-driven)**:
- Reuse existing `GroupTestID` and `DatasetTestID` from `CI/Scripts/variables.test.json` (no new template keys required).
- Define a dedicated query payload that issues two EVALUATE statements with explicit set labels so result identity survives table combine.
- Proposed query shape:
  - `EVALUATE ROW("ProbeSet", "A", "NowUtc", UTCNOW())`
  - `EVALUATE ROW("ProbeSet", "B", "NowUtc", UTCNOW())`

**Tasks**:
- ✅ Implement PowerShell baseline probe script `CI/Scripts/Probe-MultiEvaluate.ps1` that calls `executeDaxQueries`, records Content-Type, Arrow stream segment count (EOS split), and writes `artifacts/multi-eval-powershell-canonical.json`.
- ✅ Enhance Python probe (`CI/Scripts/Probe-MultiEvaluate.py`) with `--group-id`, `--dataset-id`, `--query-file`, and `--output` to emit `artifacts/multi-eval-python-canonical.json`.
- ✅ Add a Power Query test file `PBIRESTAPIComm.tests.multievaluate.datetimeprobe.query.pq` asserting both `ProbeSet` values (`A`, `B`) and non-null `NowUtc` values are present.
- ✅ Add canonical comparison logic via `CI/Scripts/Compare-MultiEvaluateParity.py` to compare PowerShell and Python artifacts (endpoint/content-type/stream-count/query-count).
- ✅ Document fast commands in `docs/TESTING-AIDD.md` for running PowerShell probe, Python probe, comparison, and targeted PQ test.
- ✅ Reconcile discrepancy: request payload shape is the primary driver in this environment (`rest` mode with `queries[]` returned one empty stream, `connector` mode with top-level `query` returned two populated streams), with PowerShell/Python connector-mode artifacts and PQ probe test now aligned.
- ✅ Add fail-fast guards in both probes for the known bad REST-mode pattern (single empty Arrow stream) so incorrect payload mode is surfaced immediately.

**Definition of Done**:
- ✅ For the configured workspace/dataset, PowerShell and Python probes agree on stream count and canonical row set for the DateTime two-EVALUATE query.
- ✅ Power Query targeted test returns both probe sets and passes deterministic assertions.
- ✅ Cross-tool parity comparison artifact is generated and stored under `artifacts/` with clear pass/fail summary.
- ✅ Workflow is documented with no dependency on the legacy workspace-specific query set.

---

### Phase 12: Multi-EVALUATE "First Table Only" Root-Cause & Stale-Mez Detection
**Status**: ✅ COMPLETED (2026-07-16)
**Goal**: Prove definitively that the connector returns ALL result sets from a multi-EVALUATE query (same-schema AND different-schema), and eliminate the recurring "I copied the mez but still only get the first table" confusion.

**Why this phase exists**: The DateTime probe (Phase 11) only proved *same-schema* two-EVALUATE combine, which is a weak proof. A user copied the mez into Power BI Desktop and still observed only the first table for a real 7-EVALUATE query. We must (a) prove heterogeneous multi-result-set combine at the M level, and (b) make the loaded build version unambiguous so a stale/cached mez cannot masquerade as a connector bug.

**Findings (2026-07-16)**:
- The connector's `ArrowParseStream` resets per-stream schema/dictionary state at each Arrow EOS marker and `Table.Combine`s every result set; `ExecuteDaxJsonToTable` flattens all `results[*].tables[*]`.
- New Power Query proof test `PBIRESTAPIComm.tests.multievaluate.heterogeneous.query.pq` **passes**: 5 same-schema EVALUATEs → 5 rows; 3 different-schema EVALUATEs → union of columns + 3 rows.
- Conclusion: the connector code is NOT dropping result sets. The "first table only" symptom is client-side — a stale/cached `.mez` in Power BI Desktop (or a server/permission context that returns a single empty stream, as seen earlier under SPN).

**Tasks**:
- ✅ Add strong Power Query proof test covering many same-schema result sets AND heterogeneous (different-schema) result sets (`PBIRESTAPIComm.tests.multievaluate.heterogeneous.query.pq`), registered in `Run-PQTests.ps1`.
- ✅ Add a queryable build stamp `PBIRESTAPIComm.Version` and bump connector version to `2.1.1` so the loaded build can be confirmed from a blank query in Power BI Desktop.
- ⏳ Document a Power BI Desktop verification recipe (confirm `PBIRESTAPIComm.Version`, clear the connector/query cache, replace the `.mez` in `[Documents]\Power BI Desktop\Custom Connectors`, restart Desktop) in `docs/TESTING-AIDD.md`.
- ⏳ Provide a copy-paste blank-query snippet the user can run in Desktop to reproduce multi-EVALUATE and see all result sets.
- ⏳ If the user's specific dataset still returns one empty stream with their own credentials, capture the raw bytes via `Capture-ArrowResponse.ps1` and confirm whether it is a server/permission behavior rather than a connector issue.

**Definition of Done**:
- ✅ Heterogeneous multi-EVALUATE proof test passes (same-schema-many + different-schema).
- ✅ Connector exposes a queryable version stamp; version bumped so stale mez is detectable.
- ✅ Desktop verification recipe documented and validated by the user against their workspace.
- ✅ User confirmed the connector code returns all result sets; "first table only" symptom was a stale/cached mez in Power BI Desktop.

---

### Phase 13: Multi-EVALUATE "List of Tables" Result Shape (per-result-set schema)
**Status**: ✅ COMPLETED (2026-07-16)
**Goal**: Change `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup` so they return a **list of tables** — one table per EVALUATE result set, each preserving its own schema — instead of a single combined table.

**Decision (2026-07-16)**: Approved as an intentional **breaking change**. No `AsList`/`AsTable` variants — the existing function names keep their names and simply return a `list` of `table`. Consumers index the list (e.g., `{0}`) or iterate it.

**Why**: Combining heterogeneous result sets into one table unions columns and produces sparse rows, which is lossy and awkward. A list of tables preserves each result set's native schema and is the natural shape for multi-EVALUATE payloads (e.g., test runners returning several distinct result tables).

**Behavior change**:
- Before: `ExecuteDaxQueries(...)` / `ExecuteDaxQueriesInGroup(...)` returned one `table` (Arrow streams / JSON `results[*].tables[*]` combined via `Table.Combine`).
- After: they return a `list` of `table`, in result-set order. A single-EVALUATE query returns a one-item list; N EVALUATE statements return an N-item list.

**Compatibility & versioning**:
- This is breaking for any consumer expecting a table (must now take `{0}` or iterate). Bump connector version to **`3.0.0`** and update `PBIRESTAPIComm.Version`.
- Preserve the no-fallback contract: the list path must never call `ExecuteQuery*`; extend/keep the static guard in `Run-PQTests.ps1` over the changed blocks.
- Vision touchpoint: `vision.md` describes `ExecuteDaxQueries*` producing "a single canonical table" validated cell-by-cell vs `ExecuteQuery*`. Update `vision.md` so parity is defined as "result set 0 (or the corresponding index) matches `ExecuteQuery*`", since `ExecuteQuery*` (JSON) remains single-result-set.

**Implementation outline**:
- ⏳ Add `ExecuteDaxResponseAsTableList (response, headers) as list` returning per-result-set tables (Arrow: stream segments' tables; JSON: `results[*].tables[*]`). Keep `ExecuteDaxResponseAsTable` (combine) as an internal helper/test hook so existing binary→table unit tests remain valid.
- ⏳ Expose the list from the Arrow path: add `ArrowFromBinaryTables`/`ArrowParseStreamTables (as list)`; keep `ArrowFromBinary`/`ArrowParseStream` as combined-table helpers for the static-fixture and helper tests.
- ⏳ Add `PostExecuteDaxList (params) as list`.
- ⏳ Change `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup` to call `PostExecuteDaxList` and return `list`; change their `Value.ReplaceType` signatures from `as table` to `as list` and refresh documentation metadata/examples.
- ⏳ Keep the argument-validation error path returning a clear value (e.g., a one-item list containing an error/message table, or raise an error) — decide during implementation.

**Test & consumer impact (all updated)**:
- ✅ `PBIRESTAPIComm.tests.datasets.parity.query.pq` — `GetExecuteDaxTable`/`GetExecuteDaxTableInGroup` now take the first result set (`...{0}`) for single-EVALUATE parity.
- ✅ `PBIRESTAPIComm.tests.connector.proof.query.pq` — `ExecuteDaxQueries(...)` → `...{0}`.
- ✅ `PBIRESTAPIComm.tests.proof.query.pq` — `ExecuteDaxQueries(...)` → `...{0}`.
- ✅ `PBIRESTAPIComm.tests.showdata.query.pq` — `ExecuteDaxQueries(...)` → `...{0}`.
- ✅ `PBIRESTAPIComm.tests.datasets.query.pq` — `ExecuteDaxQueriesInGroup(...)` → `...{0}`.
- ✅ `PBIRESTAPIComm.tests.multievaluate.query.pq` — rewritten to assert a list of 2 tables (5-row TOPN item 0, 1-row COUNTROWS item 1).
- ✅ `PBIRESTAPIComm.tests.multievaluate.datetimeprobe.query.pq` — rewritten to assert a 2-item list, each a 1-row table with its own `ProbeSet`/`NowUtc`.
- ✅ `PBIRESTAPIComm.tests.multievaluate.heterogeneous.query.pq` — rewritten to assert a 3-item list, each item having its OWN distinct schema (`[Alpha]`; `[Beta]`; `[Gamma]`) — no union.
- ✅ All list-shape assertions added: list length = number of EVALUATEs; each item `Value.Is(_, type table)`; per-item column names are the result set's own (no column union across items).

**Docs**:
- ✅ Update `docs/TESTING-AIDD.md` Desktop snippet and expected output to show a **list of tables** (expand item 0, 1, 2), and note the version `2.2.0`.
- ✅ Update `README.md` `ExecuteDax*` description and call-tree notes to reflect list output.

**Decisions (approved 2026-07-16)**:
1. Version `2.2.0` (minor bump, not semver major) — user preference for smaller increment.
2. Argument-validation / error case: raise a hard error via `error Error.Record(...)`.
3. Keep `ExecuteDaxResponseAsTable`/`ArrowFromBinary` combined-table helpers internally for existing unit/fixture tests — confirmed.

**Definition of Done**:
- ✅ `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup` return a list of per-result-set tables, each preserving its own schema.
- ✅ All affected tests updated and green; new list-shape assertions added (heterogeneous, same-schema, single-EVALUATE, edge cases).
- ✅ No-fallback guard green; parity suite updated to compare the correct result-set index.
- ✅ Version bumped to `2.2.0`; `vision.md`, `README.md`, and `docs/TESTING-AIDD.md` updated for the new output shape.
- ✅ User confirmed list-of-tables output works in Power BI Desktop with fresh `2.2.0` mez.

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
