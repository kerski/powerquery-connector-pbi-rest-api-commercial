# Project Vision

This project delivers a production-ready Power Query connector for Power BI REST APIs with a specific quality bar for Arrow IPC parsing in DAX query endpoints. The connector must provide reliable, deterministic behavior when returning tabular results from both JSON and Arrow pathways.

## Objective

Build and maintain a connector where `ExecuteDaxQueries*` output is validated against `ExecuteQuery*` output through deterministic, cell-by-cell parity tests, while keeping local and CI test execution fast through targeted test-file selection.

## Requirements

### 1. Git Workflow

General rules:
- Keep changes minimal and task-focused.
- Do not modify unrelated files.
- Require targeted parity validation before merge.
- Run full split suite only when needed (pre-merge hardening or release validation).

### 2. Architecture

Core architecture:
- Connector implementation: `PBIRESTAPIComm.pq`.
- Arrow detection/parsing helpers live under `Arrow.*` functions in `PBIRESTAPIComm.pq`.
- Test suites are split into per-domain files: `PBIRESTAPIComm.tests.*.query.pq`.
- CI orchestration script: `CI/Scripts/Run-PQTests.ps1`.

Design direction:
- Keep Arrow parsing logic modular and testable.
- Keep normalization/comparison behavior centralized in tests to avoid inconsistent assertions.
- Preserve backward compatibility for existing JSON endpoint behavior.
- Never fall back from `ExecuteDaxQueries*` to `ExecuteQuery*` under any condition, including Arrow detection/parsing failures; failures must stay visible and actionable.

### 3. Testing

Testing is mandatory and built around deterministic parity and selective execution.

Test strategy:
- Baseline: `ExecuteQuery` and `ExecuteQueryInGroup` JSON responses.
- Candidate: `ExecuteDaxQueries` and `ExecuteDaxQueriesInGroup` Arrow-capable responses.
- Compare canonicalized tables for:
  - Ordered column names and count.
  - Row count.
  - Cell-by-cell normalized values with type-aware handling.

Required coverage:
- Arrow helper unit and error-path tests for detection and binary helpers.
- Dataset parity scenarios for representative data-type matrix and edge payloads.
- Focused parity gate test file (`PBIRESTAPIComm.tests.datasets.parity.query.pq`) must remain runnable in isolation.

Execution rules to reduce token usage and runtime:
- Default development loop uses targeted files with `-TestFileName`.
- Preferred command pattern:
  - `./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName <file>`
- Use full split suite only when explicitly required:
  - `./CI/Scripts/Run-PQTests.ps1 -Compile $false`

CI and GitHub Actions requirements:
- CI must support targeted test execution via `-TestFileName`.
- CI must support full-suite execution as a separate, explicit mode.
- GitHub Actions must run on a Windows runner and use the same script (`CI/Scripts/Run-PQTests.ps1`) to avoid workflow drift.
- Non-interactive authentication must be driven by repository secrets and environment variables.

### 4. Documentation

Documentation must make the workflow reproducible for humans and agents.

Required documentation:
- Vision and planning docs describe parity goals and constraints.
- A dedicated GitHub Actions testing guide documents:
  - Required secrets.
  - Trigger modes (targeted vs full).
  - Example commands and troubleshooting.
- README references the canonical CI/GitHub Actions testing guide.

### 5. Code Quality

- Follow existing Power Query and script style patterns.
- Keep parsing and normalization logic deterministic.
- Failures must report enough context to locate mismatches quickly.
- Avoid hidden behavior differences between local runs and CI runs.

## Constraints

- Do not broaden scope beyond DAX/Arrow response handling when working on this stream.
- Do not implement, reintroduce, or rely on any fallback path from `ExecuteDaxQueries*` to `ExecuteQuery*`.
- Do not replace targeted runs with always-on full-suite runs.
- Do not introduce CI-only behavior that differs from local script behavior.
- Keep authentication and environment handling secure; no credentials in source.

## Success Criteria

- Arrow and JSON parity tests are deterministic and actionable.
- Arrow helper functions have direct unit/error-path coverage.
- `CI/Scripts/Run-PQTests.ps1 -TestFileName` is the default iteration path for developers and agents.
- GitHub Actions can run targeted and full suites reliably using the same CI script.
- Workflow setup and operation are documented clearly enough for repeatable onboarding.

---

## Future Work & Backlog

- Expand parity matrix for larger payloads and additional edge cases.
- Add richer machine-readable test result artifacts for CI analytics.
- Add optional scheduled full-suite reliability runs.
- Address the existing Arrow compile diagnostic around `ArrowParseField` name resolution in `PBIRESTAPIComm.pq` and harden compile-time validation in the dev workflow.
