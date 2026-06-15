# No-Fallback Enforcement For ExecuteDaxQueries Epic

**Status**: ✅ COMPLETED (2026-06-15)
**Goal**: Enforce and verify that ExecuteDaxQueries and ExecuteDaxQueriesInGroup never fall back to ExecuteQuery endpoint paths under any condition.

## Overview

WHY: The project vision now defines no-fallback behavior as a hard requirement. This epic adds explicit safeguards and tests so fallback cannot be introduced accidentally during future refactors.

---

## Task 1: Define No-Fallback Contract Tests

Add test cases that encode no-fallback behavior as a non-negotiable contract.

Status: Completed on 2026-06-15.

**Requirements**:
- Given Arrow detection/parsing failure conditions, should surface failure behavior without rerouting to ExecuteQuery endpoint paths.
- Given non-Arrow JSON responses from ExecuteDaxQueries endpoints, should use only ExecuteDax JSON table handling logic.
- Given malformed Arrow payloads, should fail with actionable Arrow diagnostics rather than endpoint substitution.

## Task 2: Add Static Call-Chain Guard

Add a targeted test or guard assertion that fails if ExecuteDax call paths reference ExecuteQuery functions.

Status: Completed on 2026-06-15.

**Requirements**:
- Given connector source inspection, should detect forbidden references from ExecuteDaxQueries chain to ExecuteQuery or ExecuteQueryInGroup.
- Given a forbidden reference is introduced, should fail deterministically with a clear message indicating the violating symbol.

## Task 3: Harden ExecuteDax Response Pipeline

Review and minimally harden the DAX response path to keep behavior explicit and maintainable.

Status: Completed on 2026-06-15.

**Requirements**:
- Given ExecuteDax response processing, should only branch between Arrow parsing and DAX JSON parsing.
- Given parse failures, should preserve visible error behavior and avoid hidden fallback logic.
- Given refactoring, should keep helper boundaries clear for unit-level verification.

## Task 4: Targeted Test Execution Integration

Ensure no-fallback tests run quickly in isolation via CI script targeting.

Status: Completed on 2026-06-15.

**Requirements**:
- Given no-fallback test file name, should run only that file through CI/Scripts/Run-PQTests.ps1 -TestFileName.
- Given failures, should report violating contract condition and failing test clearly.
- Given pass state, should complete without requiring full-suite execution.

## Definition of Done

- No-fallback behavior is verified by targeted, deterministic tests.
- ExecuteDax call chain is guarded against direct or indirect endpoint fallback references.
- Failure diagnostics remain actionable and visible.
- Targeted no-fallback test execution is documented and usable in the default dev loop.