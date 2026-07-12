---
name: arrow-format
description: Diagnose and regression-test Arrow IPC parsing issues in this connector, with emphasis on intermittent dictionary batch failures in ExecuteDaxQueriesInGroup DateDim TOPN paths.
---

# Arrow Format Skill

Use this skill when the user reports any Arrow parsing issue such as:
- "Arrow parse failed"
- "Dictionary batch parsing failed"
- Failures in ExecuteDaxQueries or ExecuteDaxQueriesInGroup
- Intermittent DateDim TOPN parity mismatches

## Primary Goal

Prove or disprove regressions without relying on manual user confirmation by running focused, repeatable, local tests.

## Required Validation Sequence

1. Run focused parity regression once with compile enabled:

```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq
```

2. Run connector proof validation:

```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName PBIRESTAPIComm.tests.connector.proof.query.pq
```

3. Run multi-iteration soak validation for intermittent failures:

```powershell
./CI/Scripts/Run-DateDimArrowSoak.ps1 -Iterations 5
```

The soak script writes logs to:
- artifacts/arrow-soak/

## What This Covers

- ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup parity
- ExecuteQuery vs ExecuteDaxQueries parity
- DateDim TOPN dictionary-encoded text/categorical scenarios
- Repeatability checks for intermittent parser failures

## Failure Handling Protocol

If any run fails:
1. Capture the exact failing test file and query identifier.
2. Capture the nested Arrow error chain details (Module, Stage, InnerMessage, InnerDetail).
3. Re-run the same failing target with compile enabled to eliminate stale MEZ artifacts.
4. Report whether failure is deterministic (repro every run) or intermittent (only in soak loop).

## Guardrails

- Do not switch to full-suite tests first.
- Use targeted test files and soak loop first.
- Keep no-fallback behavior intact.
- Do not mask Arrow parser errors with fallback logic.

## Done Criteria

A fix is considered validated only when:
- Focused parity passes.
- Connector proof passes.
- Soak loop passes all iterations with no intermittent failures.
